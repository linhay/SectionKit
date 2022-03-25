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
    
    func config(sectionView: UITableView)
    func item(at row: Int) -> UITableViewCell
    func itemSize(at row: Int) -> CGSize

    func item(willSelect row: Int) -> Int?
    func item(willDeselect row: Int) -> Int?
    
    func item(editingStyle row: Int) -> UITableViewCell.EditingStyle
    func item(shouldIndentWhileEditing row: Int) -> Bool
    func item(willBeginEditing row: Int)
    func item(didEndEditing row: Int)
    
    /// SupplementaryView
    func supplementary(kind: SectionSupplementaryKind) -> UIView?
    func supplementarySize(kind: SectionSupplementaryKind) -> CGSize?
    func supplementary(willDisplay view: UIView, forElementKind elementKind: SectionSupplementaryKind)
    func supplementary(didEndDisplaying view: UIView, forElementKind elementKind: SectionSupplementaryKind)
    
    var headerView: UITableViewHeaderFooterView? { get }
    var footerView: UITableViewHeaderFooterView? { get }
    
    var headerSize: CGSize? { get }
    var footerSize: CGSize? { get }
    
    func swipeActions(leading row: Int) -> [UIContextualAction]
    func swipeActions(trailing row: Int) -> [UIContextualAction]
}

public extension SectionTableProtocol {

    func swipeActions(leading row: Int) -> [UIContextualAction] { [] }
    func swipeActions(trailing row: Int) -> [UIContextualAction] { [] }
    
}

public extension SectionTableProtocol {

    func item(willSelect row: Int) -> Int? { nil }
    func item(willDeselect row: Int) -> Int? { nil }
}

public extension SectionTableProtocol {
    
    func item(editingStyle row: Int) -> UITableViewCell.EditingStyle { .none }
    func item(shouldIndentWhileEditing row: Int) -> Bool { true }
    func item(willBeginEditing row: Int) {}
    func item(didEndEditing row: Int) {}
}

public extension SectionTableProtocol {

    var headerView: UITableViewHeaderFooterView? { nil }
    var footerView: UITableViewHeaderFooterView? { nil }
    
    var headerSize: CGSize? { nil }
    var footerSize: CGSize? { nil }
    
    func supplementary(kind: SectionSupplementaryKind) -> UIView? {
        switch kind {
        case .header:
            return headerView
        case .footer:
            return footerView
        case .custom:
            return nil
        }
    }
    
    func supplementarySize(kind: SectionSupplementaryKind) -> CGSize? {
        switch kind {
        case .header:
            return headerSize
        case .footer:
            return footerSize
        case .custom:
            return nil
        }
    }
    
    func supplementary(willDisplay view: UIView, forElementKind elementKind: SectionSupplementaryKind) {}
    func supplementary(didEndDisplaying view: UIView, forElementKind elementKind: SectionSupplementaryKind) {}
    
}

public extension SectionTableProtocol {
    
    var sectionView: UITableView {
        guard let view = sectionState?.sectionView as? UITableView else {
            assertionFailure("can't find sectionView, before `SectionCollectionProtocol` into `Manager`")
            return UITableView()
        }
        return view
    }

}

public extension SectionTableProtocol {

    func indexForItem(at point: CGPoint) -> Int? {
        guard let indexPath = sectionView.indexPathForRow(at: point), indexPath.section == sectionIndex else {
            return nil
        }
        return indexPath.row
    }

    func index(for cell: UITableViewCell) -> Int? {
        guard let indexPath = sectionView.indexPath(for: cell), indexPath.section == sectionIndex else {
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
            .filter({ $0.section == sectionIndex })
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
            .filter({ $0.section == sectionIndex })
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
    
    func reload(with animation: UITableView.RowAnimation = .automatic) {
        sectionView.reloadSections(.init(integer: sectionIndex), with: animation)
    }

    func insertItems(at rows: [Int], with animation: UITableView.RowAnimation = .automatic) {
        guard rows.isEmpty == false else {
            return
        }
        if let max = rows.max(), itemCount <= max {
            sectionView.reloadData()
        } else {
            sectionView.insertRows(at: indexPath(from: rows), with: animation)
        }
    }
    
    func deleteItems(at rows: [Int], with animation: UITableView.RowAnimation = .automatic) {
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
    
    func reloadItems(at rows: [Int], with animation: UITableView.RowAnimation = .automatic) {
        sectionView.reloadRows(at: indexPath(from: rows), with: animation)
    }

}

#endif
