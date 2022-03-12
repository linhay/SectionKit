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

    func dequeue<T: UITableViewCell>(at row: Int, identifier: String = String(describing: T.self)) -> T {
        return sectionView.dequeueReusableCell(withIdentifier: identifier, for: indexPath(from: row)) as! T
    }

    func dequeue<T: UITableViewHeaderFooterView>(identifier: String = String(describing: T.self)) -> T {
        return sectionView.dequeueReusableHeaderFooterView(withIdentifier: identifier) as! T
    }

}

public extension SectionTableProtocol {

    func deselect(at row: Int, animated: Bool) {
        sectionView.deselectRow(at: indexPath(from: row), animated: animated)
    }

    func cell(at row: Int) -> UITableViewCell? {
        return sectionView.cellForRow(at: indexPath(from: row))
    }

    func pick(_ updates: (() -> Void), completion: ((Bool) -> Void)?) {
        if #available(iOS 11.0, *) {
            sectionView.performBatchUpdates(updates, completion: completion)
        } else {
            sectionView.beginUpdates()
            updates()
            sectionView.endUpdates()
            completion?(true)
        }
    }

}

public extension SectionTableProtocol {

    /// 刷新整组元素
    /// - Parameter animation: 动画
    func reload(with animation: UITableView.RowAnimation = .none) {
        sectionView.reloadSections(.init(integer: index), with: animation)
    }

    /// 刷新单个元素
    /// - Parameters:
    ///   - row: 序号
    ///   - animation: 动画
    func reload(at row: Int, with animation: UITableView.RowAnimation = .none) {
        reload(at: [row], with: animation)
    }

    /// 刷新多个元素
    /// - Parameters:
    ///   - row: 序号
    ///   - animation: 动画
    func reload(at rows: [Int], with animation: UITableView.RowAnimation = .none) {
        sectionView.reloadRows(at: indexPaths(from: rows), with: animation)
    }

}

public extension SectionTableProtocol {

    func insert(at row: Int,
                with animation: UITableView.RowAnimation = .none,
                willUpdate: (() -> Void)) {
        insert(at: [row], with: animation, willUpdate: willUpdate)
    }

    func insert(at rows: [Int],
                with animation: UITableView.RowAnimation = .none,
                willUpdate: (() -> Void)) {
        guard rows.isEmpty == false else {
            return
        }
        willUpdate()
        if let max = rows.max(), itemCount <= max {
            sectionView.reloadData()
        } else {
            sectionView.insertRows(at: indexPaths(from: rows), with: animation)
        }
    }

}

public extension SectionTableProtocol {

    func delete(at row: Int, with animation: UITableView.RowAnimation = .none, willUpdate: (() -> Void)) {
        delete(at: [row], willUpdate: willUpdate)
    }

    func delete(at rows: [Int], with animation: UITableView.RowAnimation = .none, willUpdate: (() -> Void)) {
        guard rows.isEmpty == false else {
            return
        }
        willUpdate()
        if itemCount <= 0 {
            sectionView.reloadData()
        } else {
            sectionView.deleteRows(at: indexPaths(from: rows), with: animation)
        }
    }

}
#endif
