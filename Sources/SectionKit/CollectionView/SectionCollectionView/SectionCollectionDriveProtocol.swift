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

public protocol SectionCollectionDriveProtocol: SectionProtocol {
    
    var sectionView: UICollectionView { get }

    func config(sectionView: UICollectionView)
    func item(at row: Int) -> UICollectionViewCell
    
    /// SupplementaryView
    func willDisplaySupplementaryView(view: UICollectionReusableView, forElementKind elementKind: String, at row: Int)
    func didEndDisplayingSupplementaryView(view: UICollectionReusableView, forElementKind elementKind: String, at row: Int)

    /// contextMenu
    @available(iOS 13.0, *)
    func contextMenuConfiguration(at row: Int, point: CGPoint) -> UIContextMenuConfiguration?
    
    func reload()
}

public extension SectionCollectionDriveProtocol {
    
    func willDisplaySupplementaryView(view: UICollectionReusableView, forElementKind elementKind: String, at row: Int) {}
    
    func didEndDisplayingSupplementaryView(view: UICollectionReusableView, forElementKind elementKind: String, at row: Int) {}
    
}

public extension SectionCollectionDriveProtocol {
    
    var sectionView: UICollectionView {
        guard let view = core?.sectionView as? UICollectionView else {
            assertionFailure("can't find sectionView, before `SectionCollectionProtocol` into `Manager`")
            return UICollectionView()
        }
        return view
    }
    
}

public extension SectionCollectionDriveProtocol {
    
    @available(iOS 13.0, *)
    func contextMenuConfiguration(at row: Int, point: CGPoint) -> UIContextMenuConfiguration? { nil }
    
}

public extension SectionCollectionDriveProtocol {

    func deselect(at row: Int, animated: Bool) {
        sectionView.deselectItem(at: indexPath(from: row), animated: animated)
    }

    func cell(at row: Int) -> UICollectionViewCell? {
        return sectionView.cellForItem(at: indexPath(from: row))
    }

    func row(for cell: UICollectionViewCell) -> Int? {
        guard let indexPath = sectionView.indexPath(for: cell), indexPath.section == core?.index else {
            return nil
        }
        return indexPath.row
    }

    func pick(_ updates: (() -> Void), completion: ((Bool) -> Void)? = nil) {
        sectionView.performBatchUpdates(updates, completion: completion)
    }

}

public extension SectionCollectionDriveProtocol {

    func reload() {
        core?.reloadDataEvent?()
    }

    func reload(at row: Int) {
        reload(at: [row])
    }

    func reload(at rows: [Int]) {
        sectionView.reloadItems(at: rows.map({ self.indexPath(from: $0) }))
    }

}

public extension SectionCollectionDriveProtocol {

    func insert(at row: Int, willUpdate: (() -> Void)) {
        insert(at: [row], willUpdate: willUpdate)
    }

    func insert(at rows: [Int], willUpdate: (() -> Void)) {
        guard rows.isEmpty == false else {
            return
        }
        willUpdate()
        sectionView.insertItems(at: indexPaths(from: rows))
    }

}

public extension SectionCollectionDriveProtocol {

    func delete(at row: Int, willUpdate: (() -> Void)) {
        delete(at: [row], willUpdate: willUpdate)
    }

    func delete(at rows: [Int], willUpdate: (() -> Void)) {
        guard rows.isEmpty == false else {
            return
        }
        willUpdate()
        if itemCount <= 0 {
            core?.reloadDataEvent?()
        } else {
            sectionView.deleteItems(at: indexPaths(from: rows))
        }
    }

}

public extension SectionCollectionDriveProtocol {

    func scroll(to row: Int, at scrollPosition: UICollectionView.ScrollPosition, animated: Bool) {
        sectionView.scrollToItem(at: indexPath(from: row), at: scrollPosition, animated: animated)
    }

    func select(at row: Int?, animated: Bool, scrollPosition: UICollectionView.ScrollPosition) {
        sectionView.selectItem(at: indexPath(from: row), animated: animated, scrollPosition: scrollPosition)
    }

}
#endif
