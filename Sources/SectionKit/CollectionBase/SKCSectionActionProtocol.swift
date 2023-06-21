//
//  File.swift
//
//
//  Created by linhey on 2022/8/11.
//

#if canImport(UIKit)
import UIKit

public protocol SKCSectionActionProtocol: AnyObject {
    
    var sectionView: UICollectionView { get }
    var sectionInjection: SKCSectionInjection? { get set }
    func config(sectionView: UICollectionView)
    
}

public extension SKCSectionActionProtocol {
    
    var sectionView: UICollectionView {
        guard let view = sectionInjection?.sectionView else {
            assertionFailure("can't find sectionView, before `SectionCollectionProtocol` into `Manager`")
            return UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        }
        return view
    }
    
    func config(sectionView: UICollectionView) {}
    
}

public extension SKCSectionActionProtocol {
    
    func pick(_ updates: () -> Void, completion: ((_ flag: Bool) -> Void)? = nil) {
        sectionInjection?.pick(updates, completion: completion)
    }
    
    func reload() {
        sectionInjection?.reload()
    }
    
    /// 刷新指定行
    /// - Parameter row: 指定行
    func refresh(at row: Int) {
        sectionInjection?.reload(cell: row)
    }
    
    /// 刷新指定行
    /// - Parameter row: 指定行
    func refresh(at row: [Int]) {
        sectionInjection?.reload(cell: row)
    }
    
    /// 移除指定行
    /// - Parameters:
    ///   - row: 指定行
    ///   - before: 移除数据
    func remove(at row: Int, before: (() -> Void)?) {
        before?()
        sectionInjection?.delete(cell: row)
    }
    
    /// 移除指定行
    /// - Parameters:
    ///   - row: 指定行
    ///   - before: 移除数据
    func remove(at row: [Int], before: (() -> Void)?) {
        before?()
        sectionInjection?.delete(cell: row)
    }
    
}

public extension SKCSectionActionProtocol {
    
    /// 获取被选中的 cell 集合
    var indexForSelectedItems: [Int] {
        (sectionInjection?.sectionView?.indexPathsForSelectedItems ?? [])
            .filter { $0.section == sectionInjection?.index }
            .map(\.row)
    }
    
    /// 获取可见的 cell 的 row 集合
    var indexsForVisibleItems: [Int] {
        sectionInjection?
            .sectionView?
            .indexPathsForVisibleItems
            .filter { $0.section == sectionInjection?.index }
            .map(\.row) ?? []
    }
    
    /// 获取可见的 cell 集合
    var visibleCells: [UICollectionViewCell] {
        let indexs = indexsForVisibleItems
        guard !indexs.isEmpty else {
            return []
        }
        return indexs.compactMap(cellForItem(at:))
    }
    
    /// 获取指定 row 的 Cell
    /// - Parameter row: row
    /// - Returns: cell
    func cellForItem(at row: Int) -> UICollectionViewCell? {
        sectionView.cellForItem(at: indexPath(from: row))
    }
    
    func visibleSupplementaryViews(of kind: SKSupplementaryKind) -> [UICollectionReusableView] {
        sectionInjection?
            .sectionView?
            .visibleSupplementaryViews(ofKind: kind.rawValue) ?? []
    }
    
    func indexsForVisibleSupplementaryViews(of kind: SKSupplementaryKind) -> [Int] {
        sectionInjection?
            .sectionView?
            .indexPathsForVisibleSupplementaryElements(ofKind: kind.rawValue)
            .filter { $0.section == sectionInjection?.index }
            .map(\.row) ?? []
    }
    
}

public extension SKCSectionActionProtocol {
    
    func layoutAttributesForItem(at row: Int) -> UICollectionViewLayoutAttributes? {
        sectionInjection?.sectionView?.collectionViewLayout.layoutAttributesForItem(at: indexPath(from: row))
    }
    
    func layoutAttributesForSupplementaryView(ofKind kind: SKSupplementaryKind, at row: Int) -> UICollectionViewLayoutAttributes? {
        sectionInjection?.sectionView?.collectionViewLayout.layoutAttributesForSupplementaryView(ofKind: kind.rawValue, at: indexPath(from: row))
    }
    
    func layoutAttributesForDecorationView(ofKind kind: SKSupplementaryKind, at row: Int) -> UICollectionViewLayoutAttributes? {
        sectionInjection?.sectionView?.collectionViewLayout.layoutAttributesForDecorationView(ofKind: kind.rawValue, at: indexPath(from: row))
    }
    
}

public extension SKCSectionActionProtocol {
    
    /**
     该方法用于根据给定的value返回一个IndexPath对象。如果sectionInjection为nil，则会触发断言失败，并返回一个item为value，section为0的IndexPath对象。否则，返回一个item为value，section为sectionInjection的index的IndexPath对象。
     */
    func indexPath(from value: Int) -> IndexPath {
        guard let injection = sectionInjection else {
            assertionFailure()
            return .init(item: value, section: 0)
        }
        return .init(item: value, section: injection.index)
    }
    
    func _register<T: UICollectionViewCell & SKLoadViewProtocol>(_ cell: T.Type) {
        if let nib = T.nib {
            sectionView.register(nib, forCellWithReuseIdentifier: T.identifier)
        } else {
            sectionView.register(T.self, forCellWithReuseIdentifier: T.identifier)
        }
    }
    func _register<T: UICollectionReusableView & SKLoadViewProtocol>(_ view: T.Type, for kind: SKSupplementaryKind) {
        if let nib = T.nib {
            sectionView.register(nib, forSupplementaryViewOfKind: kind.rawValue, withReuseIdentifier: T.identifier)
        } else {
            sectionView.register(T.self, forSupplementaryViewOfKind: kind.rawValue, withReuseIdentifier: T.identifier)
        }
    }
    func _dequeue<V: UICollectionViewCell & SKLoadViewProtocol>(at row: Int) -> V {
        sectionView.dequeueReusableCell(withReuseIdentifier: V.identifier, for: indexPath(from: row)) as! V
    }
    func _dequeue<V: UICollectionReusableView & SKLoadViewProtocol>(kind: SKSupplementaryKind) -> V {
        sectionView.dequeueReusableSupplementaryView(ofKind: kind.rawValue, withReuseIdentifier: V.identifier, for: indexPath(from: 0)) as! V
    }
    
    func register<T: UICollectionViewCell & SKLoadViewProtocol>(_ cell: T.Type) { _register(cell) }
    func register<T: UICollectionReusableView & SKLoadViewProtocol>(_ view: T.Type, for kind: SKSupplementaryKind) { _register(view, for: kind) }
    
    func dequeue<V: UICollectionViewCell & SKLoadViewProtocol>(at row: Int, for type: V.Type) -> V { _dequeue(at: row) as V }
    func dequeue<V: UICollectionViewCell & SKLoadViewProtocol>(at row: Int) -> V { _dequeue(at: row) as V }
    
    func dequeue<V: UICollectionReusableView & SKLoadViewProtocol>(kind: SKSupplementaryKind, for type: V.Type) -> V { _dequeue(kind: kind) as V }
    func dequeue<V: UICollectionReusableView & SKLoadViewProtocol>(kind: SKSupplementaryKind) -> V { _dequeue(kind: kind) as V }
    
}


public extension SKCSectionActionProtocol where Self: SKCDataSourceProtocol {
    
    func scrollToTop(animated: Bool) {
        scroll(to: 0, at: .top, animated: animated)
    }
    
    func scrollToBottom(animated: Bool) {
        scroll(to: self.itemCount - 1, at: .bottom, animated: animated)
    }
    
    func scroll(to row: Int?, at scrollPosition: UICollectionView.ScrollPosition, animated: Bool) {
        guard let row = row, let sectionView = sectionInjection?.sectionView else {
            return
        }
        guard row >= 0, row < itemCount else {
            assertionFailure("row 的值应该在 (0..<\(itemCount) 之间")
            return
        }
        sectionView.scrollToItem(at: indexPath(from: row), at: scrollPosition, animated: animated)
    }
    
}

#endif
