//
//  SKCTaeckDelegateObserver.swift
//  iDxyer
//
//  Created by linhey on 11/25/25.
//  Copyright © 2025 dxy.cn. All rights reserved.
//

import UIKit
import Combine

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
    
    public func topSectionForVisibleArea(_ sections: [TopSectionForVisibleAreaItem]) -> AnyPublisher<TopSectionForVisibleAreaItem?, Never> {
       return Publishers
            .CombineLatest3($displayedCellIndexPaths.removeDuplicates(),
                            $displayedHeaderIndexPaths.removeDuplicates(),
                            $displayedFooterIndexPaths.removeDuplicates())
            .map { cells, headers, footers -> TopSectionForVisibleAreaItem? in
                let visibles = Set(cells.map(\.section) + headers.map(\.section) + footers.map(\.section)).sorted()
                let indexForSection: [Int: TopSectionForVisibleAreaItem] = sections
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
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView, value: Void) {
        guard let sectionView = scrollView as? UICollectionView else { return }
        displayedCellIndexPaths   = sectionView.indexPathsForVisibleItems
        displayedHeaderIndexPaths = sectionView.indexPathsForVisibleSupplementaryElements(ofKind: SKSupplementaryKind.header.rawValue)
        displayedFooterIndexPaths = sectionView.indexPathsForVisibleSupplementaryElements(ofKind: SKSupplementaryKind.footer.rawValue)
    }
    
}
