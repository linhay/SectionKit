//
//  File.swift
//  
//
//  Created by linhey on 2022/8/18.
//

import UIKit
import Combine

open class SKCSingleTypeSection<Cell: UICollectionViewCell & SKConfigurableView & SKLoadViewProtocol>: SKCSingleTypeSectionProtocol {
    
    public typealias SectionStyleBlock = (_ section: SKCSingleTypeSection<Cell>) -> Void
    
    public typealias LoadedBlock = (_ section: SKCSingleTypeSection<Cell>) -> Void
    public typealias CellActionBlock = (_ context: CellActionResult) -> Void
    public typealias CellStyleBlock  = (_ context: CellStyleResult) -> Void
    public typealias CellStyleBox    = IDBox<UUID, CellStyleBlock>
    
    public typealias SupplementaryActionBlock = (_ context: SupplementaryActionResult) -> Void
    
    public enum CellActionType: Int, Hashable {
        /// 选中
        case selected
        /// 即将显示
        case willDisplay
        /// 结束显示
        case didEndDisplay
        /// 配置完成
        case config
    }
    
    public enum SupplementaryActionType: Int, Hashable {
        /// 即将显示
        case willDisplay
        /// 结束显示
        case didEndDisplay
    }
    
    public struct CellActionResult {
        
        public let section: SKCSingleTypeSection<Cell>
        public let type: CellActionType
        public let model: Cell.Model
        public let row: Int
        fileprivate let _view: Cell?
        
        public func view() -> Cell {
            guard let cell = _view ?? section.cellForItem(at: row) else {
                assertionFailure()
                return .init(frame: .zero)
            }
            return cell
        }
        
        fileprivate init(section: SKCSingleTypeSection<Cell>,
                         type: CellActionType,
                         model: Cell.Model,
                         row: Int,
                         _view: Cell?) {
            self.section = section
            self.type = type
            self.model = model
            self.row = row
            self._view = _view
        }
    }
    
    public struct CellStyleResult {
        
        public let model: Cell.Model
        public let row: Int
        public let view: Cell
        public let section: SKCSingleTypeSection<Cell>
        
        fileprivate init(row: Int,
                         model: Cell.Model,
                         section: SKCSingleTypeSection<Cell>,
                         view: Cell) {
            self.row = row
            self.model = model
            self.section = section
            self.view = view
        }
        
    }
    
    public struct SupplementaryActionResult {
        public let section: SKCSingleTypeSection<Cell>
        public let type: SupplementaryActionType
        public let kind: SKSupplementaryKind
        public let row: Int
    }
    
    public struct IDBox<ID, Value> {
        
        public typealias ID = ID
        public let id: ID
        public let value: Value
        
        public init(id: ID, value: Value) {
            self.id = id
            self.value = value
        }
        
        public init(value: Value) where ID == UUID {
            self.id = UUID()
            self.value = value
        }
        
    }
    
    public class Pulishers {
        /// cell 事件订阅, 事件类型参照 `CellActionType`
        public private(set) lazy var cellActionPulisher = cellActionSubject.eraseToAnyPublisher()
        /// supplementary 事件订阅, 事件类型参照 `SupplementaryActionType`
        public private(set) lazy var supplementaryActionPulisher = supplementaryActionSubject.eraseToAnyPublisher()
        
        fileprivate lazy var cellActionSubject = PassthroughSubject<CellActionResult, Never>()
        fileprivate lazy var supplementaryActionSubject = PassthroughSubject<SupplementaryActionResult, Never>()
    }
    
    open var sectionInjection: SKCSectionInjection?
    
    /// 配置 cell 与 supplementary 的 limit size
    public lazy var safeSizeProvider: SKSafeSizeProvider = defaultSafeSizeProvider
    
    /// 预加载
    public private(set) lazy var prefetch: SKCPrefetch = .init { [weak self] in
        return self?.itemCount ?? 0
    }
    
    /// cell 对应的数据集
    public private(set) var models: [Model]
    
    open lazy var sectionInset: UIEdgeInsets = .zero
    open lazy var minimumLineSpacing: CGFloat = .zero
    open lazy var minimumInteritemSpacing: CGFloat = .zero
    open var itemCount: Int { models.count }
    
    public private(set) lazy var pulishers = Pulishers()
    
    private lazy var deletedModels: [Int: Model] = [:]
    
    private lazy var supplementaries: [SKSupplementaryKind: any SKCSupplementaryProtocol] = [:]
    private lazy var supplementaryActions: [SupplementaryActionType: [SupplementaryActionBlock]] = [:]
    private lazy var cellActions: [CellActionType: [CellActionBlock]] = [:]
    private lazy var cellStyles: [CellStyleBox] = []
    private lazy var loadedTasks: [LoadedBlock] = []
    
    public init(_ models: [Model] = []) {
        self.models = models
    }
    public init(_ models: Model...) {
        self.models = models
    }
    
    open func apply(models: [Model]) {
        models.enumerated().forEach { item in
            deletedModels[item.offset] = item.element
        }
        reload(models)
    }
    
    open func config(sectionView: UICollectionView) {
        register(Cell.self)
        loadedTasks.forEach { task in
            task(self)
        }
    }
    
    open func item(at row: Int) -> UICollectionViewCell {
        let cell = dequeue(at: row) as Cell
        let model = models[row]
        cell.config(model)
        if !cellStyles.isEmpty {
            let result = CellStyleResult(row: row, model: model, section: self, view: cell)
            cellStyles.forEach { style in
                style.value(result)
            }
        }
        sendAction(.config, view: cell, row: row)
        return cell
    }
    
    open func itemSize(at row: Int) -> CGSize {
        guard models.indices.contains(row) else {
            return .zero
        }
        return Cell.preferredSize(limit: safeSizeProvider.size, model: models[row])
    }
    
    open func item(selected row: Int) {
        sendAction(.selected, view: nil, row: row)
    }
    
    open func item(willDisplay view: UICollectionViewCell, row: Int) {
        sendAction(.willDisplay, view: view as? Cell, row: row)
    }
    
    open func item(didEndDisplaying view: UICollectionViewCell, row: Int) {
        sendDeleteAction(.didEndDisplay, view: view as? Cell, row: row)
    }
    
    open var headerSize: CGSize {
        guard let supplementary = supplementaries[.header] else {
            return .zero
        }
        return supplementary.size(safeSizeProvider.size)
    }
    
    open var headerView: UICollectionReusableView? {
        guard let supplementary = supplementaries[.header] else {
            return nil
        }
        return supplementary.dequeue(from: sectionView, indexPath: indexPath(from: 0))
    }
    
    open var footerSize: CGSize {
        guard let supplementary = supplementaries[.footer] else {
            return .zero
        }
        return supplementary.size(safeSizeProvider.size)
    }
    
    open var footerView: UICollectionReusableView? {
        guard let supplementary = supplementaries[.footer] else {
            return nil
        }
        return supplementary.dequeue(from: sectionView, indexPath: indexPath(from: 0))
    }
    
    open func supplementary(kind: SKSupplementaryKind, at row: Int) -> UICollectionReusableView? {
        switch kind {
        case .header:
            return headerView
        case .footer:
            return footerView
        case .cell, .custom:
            return nil
        }
    }
    
    open func supplementary(willDisplay view: UICollectionReusableView, kind: SKSupplementaryKind, at row: Int) {
        sendSupplementaryAction(.willDisplay, kind: kind, row: row)
    }
    
    open func supplementary(didEndDisplaying view: UICollectionReusableView, kind: SKSupplementaryKind, at row: Int) {
        sendSupplementaryAction(.didEndDisplay, kind: kind, row: row)
    }
    
    open func item(canFocus row: Int) -> Bool {
        true
    }
    
    @available(iOS 15.0, *)
    open func item(selectionFollowsFocus row: Int) -> Bool {
        true
    }
    
    @available(iOS 14.0, *)
    open func item(canEdit row: Int) -> Bool {
        false
    }
    
    open func item(shouldSpringLoad row: Int, with context: UISpringLoadedInteractionContext) -> Bool {
        true
    }
    
    open func item(shouldBeginMultipleSelectionInteraction row: Int) -> Bool {
        false
    }
    
    open func item(didBeginMultipleSelectionInteraction row: Int) {
        
    }
    
    /// 预测加载 rows
    /// - Parameter rows: rows
    open func prefetch(at rows: [Int]) {
        self.prefetch.prefetch.send(rows)
    }
    
    /// 取消加载
    /// - Parameter rows: rows
    open func cancelPrefetching(at rows: [Int]) {
        self.prefetch.cancelPrefetching.send(rows)
    }
    
}

public extension SKCSingleTypeSection {
    
    /// 获取被选中的 cell 集合
    var indexForSelectedItems: [Int] {
        (sectionView.indexPathsForSelectedItems ?? [])
            .filter { $0.section == sectionIndex }
            .map(\.row)
    }
    
    /// 获取可见的 cell 集合
    var visibleCells: [Cell] {
        indexsForVisibleItems
            .compactMap(cellForItem(at:))
    }
    
    /// 获取可见的 cell 的 row 集合
    var indexsForVisibleItems: [Int] {
        sectionView.indexPathsForVisibleItems.filter { $0.section == sectionIndex }.map(\.row)
    }
    
    /// 获取指定 row 的 Cell
    /// - Parameter row: row
    /// - Returns: cell
    func cellForItem(at row: Int) -> Cell? {
        sectionView.cellForItem(at: indexPath(from: row)) as? Cell
    }
    
    func visibleSupplementaryViews(of kind: SKSupplementaryKind) -> [UICollectionReusableView] {
        sectionView.visibleSupplementaryViews(ofKind: kind.rawValue)
    }
    
    func indexsForVisibleSupplementaryViews(of kind: SKSupplementaryKind) -> [Int] {
        sectionView
            .indexPathsForVisibleSupplementaryElements(ofKind: kind.rawValue)
            .filter { $0.section == sectionIndex }
            .map(\.row)
    }
    
}

public extension SKCSingleTypeSection {
    
    @discardableResult
    func config(models: [Model]) -> Self {
        apply(models: models)
        return self
    }
    
    @discardableResult
    func set<T>(supplementary: SKCSupplementary<T>) -> Self {
        taskIfLoaded { section in
            section.register(supplementary.type, for: supplementary.kind)
        }
        supplementaries[supplementary.kind] = supplementary
        reload()
        return self
    }
    
    @discardableResult
    func remove(supplementary kind: SKSupplementaryKind) -> Self {
        supplementaries[kind] = nil
        reload()
        return self
    }
    
}

public extension SKCSingleTypeSection {
    
    func swapAt(_ i: Int, _ j: Int) {
        guard i != j else {
            return
        }
        let x = min(i, j)
        let y = max(i, j)
        sectionView.performBatchUpdates {
            models.swapAt(x, y)
            sectionView.moveItem(at: indexPath(from: x), to: indexPath(from: y))
            sectionView.moveItem(at: indexPath(from: y), to: indexPath(from: x))
        }
    }
    
}

public extension SKCSingleTypeSection {
    
    func reload(_ models: [Model]) {
        self.models = models
        sectionView.reloadData()
    }
    
}

public extension SKCSingleTypeSection {
    
    func append(_ items: [Model]) {
        insert(at: models.count, items)
    }
    
    func append(_ item: Model) {
        append([item])
    }
    
    func insert(at row: Int, _ items: [Model]) {
        guard !items.isEmpty else {
            return
        }
        sectionView.performBatchUpdates {
            models.insert(contentsOf: items, at: row)
            sectionView.insertItems(at: (row..<(row + items.count)).map(indexPath(from:)))
        }
    }
    
    func insert(at row: Int, _ item: Model) {
        insert(at: row, [item])
    }
    
}

public extension SKCSingleTypeSection {
    
    func remove(_ row: Int) {
        remove([row])
    }
    
    func remove(_ rows: [Int]) {
        var set = Set<Int>()
        let rows = rows
            .filter { set.insert($0).inserted }
            .filter { models.indices.contains($0) }
            .sorted(by: >)
        guard !rows.isEmpty else {
            return
        }
        sectionView.performBatchUpdates {
            for row in rows {
                deletedModels[row] = models.remove(at: row)
            }
            sectionView.deleteItems(at: rows.map(indexPath(from:)))
        }
    }
    
    func remove(_ item: Model) where Model: Equatable {
        remove(rows(with: item))
    }
    
    func remove(_ items: [Model]) where Model: Equatable {
        remove(rows(with: items))
    }
    
    func remove(_ item: Model) where Model: AnyObject {
        remove(rows(with: item))
    }
    
    func remove(_ items: [Model]) where Model: AnyObject {
        remove(rows(with: items))
    }
    
}


public extension SKCSingleTypeSection {
    
    func rows(with item: Model) -> [Int] where Model: Equatable {
        rows(with: [item])
    }
    
    func rows(with items: [Model]) -> [Int] where Model: Equatable  {
        self.models
            .enumerated()
            .filter { items.contains($0.element) }
            .map(\.offset)
    }
    
    func rows(with item: Model) -> [Int] where Model: AnyObject {
        rows(with: [item])
    }
    
    func rows(with items: [Model]) -> [Int] where Model: AnyObject {
        let items = Set(items.map({ ObjectIdentifier($0) }))
        return self.models
            .enumerated()
            .filter { items.contains(ObjectIdentifier($0.element)) }
            .map(\.offset)
    }
    
}

public extension SKCSingleTypeSection {
    
    /// 配置当前 section 样式
    /// - Parameter item: 回调
    /// - Returns: self
    @discardableResult
    func setSectionStyle(_ item: @escaping SectionStyleBlock) -> Self {
        item(self)
        return self
    }
    
}

public extension SKCSingleTypeSection {
    
    /// 订阅事件类型
    /// - Parameters:
    ///   - kind: 事件类型
    ///   - block: 回调
    /// - Returns: self
    @discardableResult
    func onCellAction(_ kind: CellActionType, block: @escaping CellActionBlock) -> Self {
        if cellActions[kind] == nil {
            cellActions[kind] = []
        }
        cellActions[kind]?.append(block)
        return self
    }
    
    @discardableResult
    func setCellStyle(_ item: CellStyleBox) -> Self {
        cellStyles.append(item)
        return self
    }
    
    @discardableResult
    func setCellStyle(_ item: @escaping CellStyleBlock) -> Self {
        cellStyles.append(.init(value: item))
        return self
    }
    
    func remove(cellStyle ids: [CellStyleBox.ID]) {
        let ids = Set(ids)
        self.cellStyles = cellStyles.filter { !ids.contains($0.id) }
    }
    
}

public extension SKCSingleTypeSection {
    
    /// 订阅事件类型
    /// - Parameters:
    ///   - kind: 事件类型
    ///   - block: 回调
    /// - Returns: self
    @discardableResult
    func onSupplementaryAction(_ kind: SupplementaryActionType, block: @escaping SupplementaryActionBlock) -> Self {
        if supplementaryActions[kind] == nil {
            supplementaryActions[kind] = []
        }
        supplementaryActions[kind]?.append(block)
        return self
    }
    
}

public extension SKCSingleTypeSection {
    
    func deselectItem(at row: Int, animated: Bool = true) {
        sectionView.deselectItem(at: indexPath(from: row), animated: animated)
    }
    
    func deselectItem(at item: Model, animated: Bool = true) where Model: Equatable {
        rows(with: item)
            .forEach { index in
                self.deselectItem(at: index, animated: animated)
            }
    }
    
    func deselectItem(at item: Model, animated: Bool = true) where Model: AnyObject {
        rows(with: item)
            .forEach { index in
                self.deselectItem(at: index, animated: animated)
            }
    }
    
    func selectItem(at row: Int, animated: Bool = true, scrollPosition: UICollectionView.ScrollPosition = .bottom) {
        sectionView.selectItem(at: indexPath(from: row), animated: animated, scrollPosition: scrollPosition)
    }
    
    func selectItem(at item: Model, animated: Bool = true, scrollPosition: UICollectionView.ScrollPosition = .bottom) where Model: Equatable {
        rows(with: item)
            .forEach { index in
                self.selectItem(at: index, animated: animated, scrollPosition: scrollPosition)
            }
    }
    
    func selectItem(at item: Model, animated: Bool = true, scrollPosition: UICollectionView.ScrollPosition = .bottom) where Model: AnyObject {
        rows(with: item)
            .forEach { index in
                self.selectItem(at: index, animated: animated, scrollPosition: scrollPosition)
            }
    }
    
}


public extension SKCSingleTypeSection {
    
    func sendDeleteAction(_ type: CellActionType, view: Cell?, row: Int) {
        let result = CellActionResult(section: self,
                                      type: type,
                                      model: deletedModels[row] ?? models[row],
                                      row: row, _view: view)
        deletedModels[row] = nil
        sendAction(result)
    }
    
    func sendAction(_ type: CellActionType, view: Cell?, row: Int) {
        let result = CellActionResult(section: self, type: type, model: models[row], row: row, _view: view)
        sendAction(result)
    }
    
    func sendAction(_ result: CellActionResult) {
        cellActions[result.type]?.forEach({ block in
            block(result)
        })
        pulishers.cellActionSubject.send(result)
    }
    
    func sendSupplementaryAction(_ type: SupplementaryActionType, kind: SKSupplementaryKind, row: Int) {
        let result = SupplementaryActionResult(section: self, type: type, kind: kind, row: row)
        supplementaryActions[type]?.forEach({ block in
            block(result)
        })
        pulishers.supplementaryActionSubject.send(result)
    }
    
    func taskIfLoaded(_ task: @escaping LoadedBlock) {
        if self.sectionInjection != nil {
            task(self)
        } else {
            loadedTasks.append(task)
        }
    }
    
}
