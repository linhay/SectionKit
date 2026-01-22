//
//  SKCTaeckDelegateObserver.swift
//  iDxyer
//
//  Created by linhey on 11/25/25.
//  Copyright © 2025 dxy.cn. All rights reserved.
//

import Combine
import UIKit

public class SKCDisplayTracker: SKScrollViewDelegateObserverProtocol {

    public struct TopSectionForVisibleAreaItem {
        public weak var section: (any SKCSectionProtocol)?
        public let tag: Int
        public init(section: any SKCSectionProtocol, tag: Int) {
            self.section = section
            self.tag = tag
        }
    }

    public init() {}

    @Published public var displayedCellIndexPaths = [IndexPath]()
    @Published public var displayedHeaderIndexPaths = [IndexPath]()
    @Published public var displayedFooterIndexPaths = [IndexPath]()

    public func topCellIndexPathForVisibleArea(_ sections: [TopSectionForVisibleAreaItem])
        -> AnyPublisher<[IndexPath], Never>
    {
        $displayedCellIndexPaths
            .removeDuplicates()
            .map { cells in
                let indexForSection: [Int: TopSectionForVisibleAreaItem] =
                    sections
                    .filter { $0.section != nil && $0.section?.isBindSectionView == true }
                    .reduce(into: [:]) { result, box in
                        if let index = box.section?.sectionIndex {
                            result[index] = box
                        }
                    }

                var _y: CGFloat?
                var results = [IndexPath]()
                for cell in cells {
                    guard let section = indexForSection[cell.section]?.section,
                        let frame = section.layoutAttributesForItem(at: cell.row)?.frame
                    else {
                        continue
                    }

                    if let y = _y {
                        if y > frame.origin.y {
                            _y = frame.origin.y
                            results = [cell]
                        } else if y == frame.origin.y {
                            results.append(cell)
                        }
                    } else {
                        _y = frame.origin.y
                        results = [cell]
                    }
                }
                return results
            }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    public func topSectionForVisibleArea(_ sections: [TopSectionForVisibleAreaItem])
        -> AnyPublisher<TopSectionForVisibleAreaItem?, Never>
    {
        return
            Publishers
            .CombineLatest3(
                $displayedCellIndexPaths.removeDuplicates(),
                $displayedHeaderIndexPaths.removeDuplicates(),
                $displayedFooterIndexPaths.removeDuplicates()
            )
            .map { cells, headers, footers -> TopSectionForVisibleAreaItem? in
                let visibles = Set(
                    cells.map(\.section) + headers.map(\.section) + footers.map(\.section)
                ).sorted()
                let indexForSection: [Int: TopSectionForVisibleAreaItem] =
                    sections
                    .filter { $0.section != nil && $0.section?.isBindSectionView == true }
                    .reduce(into: [:]) { result, box in
                        if let index = box.section?.sectionIndex {
                            result[index] = box
                        }
                    }
                for sectionIndex in visibles {
                    if let box = indexForSection[sectionIndex] {
                        return box
                    }
                }
                return nil
            }
            .eraseToAnyPublisher()
    }

    private func updateVisibleItems(_ scrollView: UIScrollView) {
        guard let sectionView = scrollView as? UICollectionView else { return }
        displayedCellIndexPaths = sectionView.indexPathsForVisibleItems
        displayedHeaderIndexPaths = sectionView.indexPathsForVisibleSupplementaryElements(
            ofKind: SKSupplementaryKind.header.rawValue)
        displayedFooterIndexPaths = sectionView.indexPathsForVisibleSupplementaryElements(
            ofKind: SKSupplementaryKind.footer.rawValue)
    }

    public func scrollViewDidScroll(_ scrollView: UIScrollView, value: Void) {
        updateVisibleItems(scrollView)
    }

    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView, value: Void) {
        updateVisibleItems(scrollView)
    }

    public func scrollViewDidEndDragging(
        _ scrollView: UIScrollView, willDecelerate decelerate: Bool, value: Void
    ) {
        if !decelerate {
            updateVisibleItems(scrollView)
        }
    }

}
