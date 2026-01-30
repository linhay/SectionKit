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
        public let label: String
        public init(section: any SKCSectionProtocol, tag: Int, label: String = "") {
            self.section = section
            self.tag = tag
            self.label = label
        }
    }

    public struct IndexPathResult {
        public weak var section: (any SKCSectionProtocol)?
        public let row: Int
        public let kind: SKSupplementaryKind
        public let tag: Int
        public let label: String
    }

    public init() {}

    @Published public var displayedCellIndexPaths = [IndexPath]()
    @Published public var displayedHeaderIndexPaths = [IndexPath]()
    @Published public var displayedFooterIndexPaths = [IndexPath]()

public func indexPathsForVisibleArea(
        _ sections: [TopSectionForVisibleAreaItem]
    ) -> AnyPublisher<[IndexPathResult], Never> {
        return
            Publishers
            .CombineLatest3(
                $displayedCellIndexPaths.removeDuplicates(),
                $displayedHeaderIndexPaths.removeDuplicates(),
                $displayedFooterIndexPaths.removeDuplicates()
            )
            .map { cells, headers, footers -> [IndexPathResult] in
                let indexForSection: [Int: TopSectionForVisibleAreaItem] =
                    sections
                    .filter { $0.section != nil && $0.section?.isBindSectionView == true }
                    .reduce(into: [:]) { result, box in
                        if let index = box.section?.sectionIndex {
                            result[index] = box
                        }
                    }
                var results = [IndexPathResult]()
                /// 按照组 header -> cell -> footer 顺序返回
                for header in headers {
                    if let box = indexForSection[header.section] {
                        results.append(
                            IndexPathResult(
                                section: box.section,
                                row: header.row,
                                kind: .header,
                                tag: box.tag,
                                label: box.label
                            )
                        )
                    }
                }
                for cell in cells {
                    if let box = indexForSection[cell.section] {
                        results.append(
                            IndexPathResult(
                                section: box.section,
                                row: cell.row,
                                kind: .cell,
                                tag: box.tag,
                                label: box.label
                            )
                        )
                    }
                }
                for footer in footers {
                    if let box = indexForSection[footer.section] {
                        results.append(
                            IndexPathResult(
                                section: box.section,
                                row: footer.row,
                                kind: .footer,
                                tag: box.tag,
                                label: box.label
                            )
                        )
                    }
                }

                results.sort { first, second in
                    if first.section === second.section {
                        // 同一组内，header < cell < footer
                        if first.kind == second.kind {
                            return first.row < second.row
                        } else {
                            switch (first.kind, second.kind) {
                            case (.header, .cell), (.header, .footer), (.cell, .footer):
                                return true
                            default:
                                return false
                            }
                        }
                    } else {
                        return (first.section?.sectionIndex ?? 0) < (second.section?.sectionIndex ?? 0)
                    }
                }
                print("[IndexPathResult]: \(results.map { "\($0.tag)-\($0.kind)-\($0.section?.indexPath(from: $0.row) ?? .init(item: -1, section: -1))" })")
                return results
            }
            .eraseToAnyPublisher()
    }

    /// 获取可见区域内顶部的Cell的IndexPaths
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

    /// 获取可见区域内的Sections
    public func sectionsForVisibleArea(_ sections: [TopSectionForVisibleAreaItem])
        -> AnyPublisher<[TopSectionForVisibleAreaItem], Never>
    {
        return
            Publishers
            .CombineLatest3(
                $displayedCellIndexPaths.removeDuplicates(),
                $displayedHeaderIndexPaths.removeDuplicates(),
                $displayedFooterIndexPaths.removeDuplicates()
            )
            .map { cells, headers, footers -> [TopSectionForVisibleAreaItem] in
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
                var results = [TopSectionForVisibleAreaItem]()
                for sectionIndex in visibles {
                    if let box = indexForSection[sectionIndex] {
                        results.append(box)
                    }
                }
                return results
            }
            .eraseToAnyPublisher()
    }
    
    /// 获取可见区域内顶部的Section
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
