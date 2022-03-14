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

public protocol SectionTableProtocol: SectionProtocol {
    var headerHeight: CGFloat { get }
    var footerHeight: CGFloat { get }
    var sectionView: UITableView { get }
    func itemHeight(at row: Int) -> CGFloat
    var headerView: UITableViewHeaderFooterView? { get }
    var footerView: UITableViewHeaderFooterView? { get }
    func config(sectionView: UITableView)
    func item(at row: Int) -> UITableViewCell
    func leadingSwipeActions(at row: Int) -> [UIContextualAction]
    func trailingSwipeActions(at row: Int) -> [UIContextualAction]
}

public extension SectionTableProtocol {
    var headerHeight: CGFloat { 0 }
    var footerHeight: CGFloat { 0 }
    var headerView: UITableViewHeaderFooterView? { nil }
    var footerView: UITableViewHeaderFooterView? { nil }
    var sectionView: UITableView {
        guard let view = core?.sectionView as? UITableView else {
            assertionFailure("can't find sectionView, before `SectionCollectionProtocol` into `Manager`")
            return UITableView()
        }
        return view
    }
    
    func leadingSwipeActions(at row: Int) -> [UIContextualAction] { return [] }
    func trailingSwipeActions(at row: Int) -> [UIContextualAction] { return [] }
}

public extension SectionTableProtocol {

    func indexForItem(at point: CGPoint) -> Int? {
        guard let indexPath = sectionView.indexPathForRow(at: point), indexPath.section == index else {
            return nil
        }
        return indexPath.row
    }

    func index(for cell: UITableViewCell) -> Int? {
        guard let indexPath = sectionView.indexPath(for: cell), indexPath.section == index else {
            return nil
        }
        return indexPath.row
    }

    // Returns any existing visible or prepared cell for the index path. Returns nil when no cell exists, or if index path is out of range.
    func cellForItem(at row: Int) -> UITableViewCell? {
        return sectionView.cellForRow(at: indexPath(from: row))
    }

    var visibleCells: [UITableViewCell] {
         indexsForVisibleItems.map(indexPath(from:))
             .compactMap { indexPath in
                 sectionView.cellForRow(at: indexPath)
             }
     }

    var indexsForVisibleItems: [Int] {
         (sectionView.indexPathsForVisibleRows ?? [])
            .filter({ $0.section == index })
            .map(\.row)
    }

}

public extension SectionTableProtocol {

    func pick(_ updates: (() -> Void), completion: ((Bool) -> Void)?) {
        sectionView.performBatchUpdates(updates, completion: completion)
    }

}

/// Interacting with the collection view.
public extension SectionTableProtocol {

    func scroll(to row: Int, at scrollPosition: UITableView.ScrollPosition, animated: Bool) {
        sectionView.scrollToRow(at: indexPath(from: row), at: scrollPosition, animated: animated)
    }

}

/// These properties control whether items can be selected, and if so, whether multiple items can be simultaneously selected.
public extension SectionTableProtocol {
    
    var indexForSelectedItems: [Int] {
        (sectionView.indexPathsForSelectedRows ?? [])
            .filter({ $0.section == index })
            .map(\.row)
    }
    
    func selectItem(at row: Int?, animated: Bool, scrollPosition: UITableView.ScrollPosition) {
        sectionView.selectRow(at: indexPath(from: row), animated: animated, scrollPosition: scrollPosition)
    }

    func deselectItem(at row: Int, animated: Bool) {
        sectionView.deselectRow(at: indexPath(from: row), animated: animated)
    }

}

/// These methods allow dynamic modification of the current set of items in the collection view
public extension SectionTableProtocol {
    
    func reload(with animation: UITableView.RowAnimation = .none) {
        sectionView.reloadSections(.init(integer: index), with: animation)
    }

    func insertItems(at rows: [Int], with animation: UITableView.RowAnimation = .none) {
        guard rows.isEmpty == false else {
            return
        }
        if let max = rows.max(), itemCount <= max {
            sectionView.reloadData()
        } else {
            sectionView.insertRows(at: indexPath(from: rows), with: animation)
        }
    }
    
    func deleteItems(at rows: [Int], with animation: UITableView.RowAnimation = .none) {
        guard rows.isEmpty == false else {
            return
        }
        if itemCount <= 0 {
            sectionView.reloadData()
        } else {
            sectionView.deleteRows(at: indexPath(from: rows), with: animation)
        }
    }
    
    func moveItem(at row: Int, to newIndexPath: IndexPath) {
        sectionView.moveRow(at: indexPath(from: row), to: newIndexPath)
    }
    
    func moveItem(at row1: Int, to row2: Int) {
        sectionView.moveRow(at: indexPath(from: row1), to: indexPath(from: row2))
    }
    
    func reloadItems(at rows: [Int], with animation: UITableView.RowAnimation = .none) {
        sectionView.reloadRows(at: indexPath(from: rows), with: animation)
    }

}

#endif
