// MIT License
//
// Copyright (c) 2020 linhey
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

#if canImport(UIKit)
import UIKit

public protocol SKCollectionDriveProtocol: SKSectionProtocol {
    func config(sectionView: UICollectionView)
    func item(at row: Int) -> UICollectionViewCell
    
    /// SupplementaryView
    func supplementary(kind: SKSupplementaryKind, at row: Int) -> UICollectionReusableView?
    func supplementary(willDisplay view: UICollectionReusableView, forElementKind elementKind: SKSupplementaryKind, at row: Int)
    func supplementary(didEndDisplaying view: UICollectionReusableView, forElementKind elementKind: SKSupplementaryKind, at row: Int)
    
    /// contextMenu
    func contextMenuConfiguration(at row: Int, point: CGPoint) -> UIContextMenuConfiguration?
}

public extension SKCollectionDriveProtocol {
    func supplementary(willDisplay _: UICollectionReusableView, forElementKind _: SKSupplementaryKind, at _: Int) {}
    func supplementary(didEndDisplaying _: UICollectionReusableView, forElementKind _: SKSupplementaryKind, at _: Int) {}
}

public extension SKCollectionDriveProtocol {
    var sectionView: UICollectionView {
        guard let view = sectionInjection?.sectionView as? UICollectionView else {
            assertionFailure("can't find sectionView, before `SectionCollectionProtocol` into `Manager`")
            return UICollectionView()
        }
        return view
    }
}

public extension SKCollectionDriveProtocol {
    func contextMenuConfiguration(at _: Int, point _: CGPoint) -> UIContextMenuConfiguration? { nil }
}

public extension SKCollectionDriveProtocol {
    func layoutAttributesForItem(at row: Int) -> UICollectionViewLayoutAttributes? {
        sectionView.layoutAttributesForItem(at: indexPath(from: row))
    }
    
    func layoutAttributesForSupplementaryElement(ofKind kind: String, at row: Int) -> UICollectionViewLayoutAttributes? {
        sectionView.layoutAttributesForSupplementaryElement(ofKind: kind, at: indexPath(from: row))
    }
    
    func indexForItem(at point: CGPoint) -> Int? {
        guard let indexPath = sectionView.indexPathForItem(at: point), indexPath.section == sectionIndex else {
            return nil
        }
        return indexPath.row
    }
    
    func index(for cell: UICollectionViewCell) -> Int? {
        guard let indexPath = sectionView.indexPath(for: cell), indexPath.section == sectionIndex else {
            return nil
        }
        return indexPath.row
    }
    
    // Returns any existing visible or prepared cell for the index path. Returns nil when no cell exists, or if index path is out of range.
    func cellForItem(at row: Int) -> UICollectionViewCell? {
        return sectionView.cellForItem(at: indexPath(from: row))
    }
    
    var visibleCells: [UICollectionViewCell] {
        indexsForVisibleItems.map(indexPath(from:))
            .compactMap { indexPath in
                sectionView.cellForItem(at: indexPath)
            }
    }
    
    var indexsForVisibleItems: [Int] {
        sectionView.indexPathsForVisibleItems.filter { $0.section == sectionIndex }.map(\.row)
    }
    
    func visibleSupplementaryViews(of elementKind: String) -> [UICollectionReusableView] {
        sectionView.visibleSupplementaryViews(ofKind: elementKind)
    }
    
    func indexsForVisibleSupplementaryViews(of elementKind: String) -> [Int] {
        sectionView.indexPathsForVisibleSupplementaryElements(ofKind: elementKind).filter { $0.section == sectionIndex }.map(\.row)
    }
}

public extension SKCollectionDriveProtocol {
    func pick(_ updates: () -> Void, completion: ((Bool) -> Void)? = nil) {
        sectionView.performBatchUpdates(updates, completion: completion)
    }
}

/// Interacting with the collection view.
public extension SKCollectionDriveProtocol {
    func scroll(to row: Int, at scrollPosition: UICollectionView.ScrollPosition, animated: Bool) {
        sectionView.scrollToItem(at: indexPath(from: row), at: scrollPosition, animated: animated)
    }
}

/// These properties control whether items can be selected, and if so, whether multiple items can be simultaneously selected.
public extension SKCollectionDriveProtocol {
    var indexForSelectedItems: [Int] {
        (sectionView.indexPathsForSelectedItems ?? [])
            .filter { $0.section == sectionIndex }
            .map(\.row)
    }
    
    func selectItem(at row: Int?, animated: Bool, scrollPosition: UICollectionView.ScrollPosition) {
        sectionView.selectItem(at: indexPath(from: row), animated: animated, scrollPosition: scrollPosition)
    }
    
    func deselectItem(at row: Int, animated: Bool) {
        sectionView.deselectItem(at: indexPath(from: row), animated: animated)
    }
}

/// These methods allow dynamic modification of the current set of items in the collection view
public extension SKCollectionDriveProtocol {
    func reload() {
        sectionInjection?.reloadDataEvent?()
    }
    
    func insertItems(at rows: [Int]) {
        guard rows.isEmpty == false else {
            return
        }
        sectionView.insertItems(at: indexPath(from: rows))
    }
    
    func deleteItems(at rows: [Int]) {
        guard rows.isEmpty == false else {
            return
        }
        if itemCount <= 0 {
            sectionInjection?.reloadDataEvent?()
        } else {
            sectionView.deleteItems(at: indexPath(from: rows))
        }
    }
    
    func moveItem(at row: Int, to newIndexPath: IndexPath) {
        sectionView.moveItem(at: indexPath(from: row), to: newIndexPath)
    }
    
    func moveItem(at row1: Int, to row2: Int) {
        sectionView.moveItem(at: indexPath(from: row1), to: indexPath(from: row2))
    }
    
    func reloadItems(at rows: [Int]) {
        sectionView.reloadItems(at: indexPath(from: rows))
    }
}

#endif
