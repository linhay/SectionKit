//
//  File.swift
//  
//
//  Created by linhey on 2022/8/18.
//

import UIKit
import Combine

public extension SKConfigurableView where Self: UICollectionViewCell & SKLoadViewProtocol {
    
    static func singleTypeWrapper(_ models: [Model] = []) -> SKCSingleTypeSection<Self> {
        .init(models)
    }
    
    static func singleTypeWrapper(count: Int) -> SKCSingleTypeSection<Self> where Model == Void {
        .init(.init(repeating: (), count: count))
    }
    
}

open class SKCSingleTypeSection<Cell: UICollectionViewCell & SKConfigurableView & SKLoadViewProtocol>: SKCSingleTypeSectionProtocol {
    
    public typealias CellActionBlock = (CellActionResult) -> Void
    public typealias CellStyleBlock  = (CellStyleResult) -> Void
    public typealias CellStyleBox    = IDBox<UUID, CellStyleBlock>
    public typealias SupplementaryActionBlock = (SupplementaryActionResult) -> Void
    
    public enum CellActionType: Int, Hashable {
        case selected
        case willDisplay
        case didEndDisplay
        case config
    }
    
    public enum SupplementaryActionType: Int, Hashable {
        case willDisplay
        case didEndDisplay
    }
    
    public struct CellActionResult {
        public let section: SKCSingleTypeSection<Cell>
        public let type: CellActionType
        public let model: Cell.Model
        public let row: Int
    }
    
    public struct CellStyleResult {
        
        public let row: Int
        public let model: Cell.Model
        public let section: SKCSingleTypeSection<Cell>
        
        init(row: Int, model: Cell.Model, section: SKCSingleTypeSection<Cell>) {
            self.row = row
            self.model = model
            self.section = section
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
    }
    
    public struct Pulishers {
        lazy var cellActionPulisher = cellActionSubject.eraseToAnyPublisher()
        lazy var supplementaryActionPulisher = supplementaryActionSubject.eraseToAnyPublisher()
        fileprivate lazy var cellActionSubject = PassthroughSubject<CellActionResult, Never>()
        fileprivate lazy var supplementaryActionSubject = PassthroughSubject<SupplementaryActionResult, Never>()
    }
    
    open var sectionInjection: SKCSectionInjection?
    
    public private(set) var models: [Model]
    public lazy var safeSizeProvider: SKSafeSizeProvider = defaultSafeSizeProvider
    
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
    
    public init(_ models: [Model] = []) {
        self.models = models
    }
    
    open func config(sectionView: UICollectionView) {
        register(Cell.self)
    }
    
    open func item(at row: Int) -> UICollectionViewCell {
        let cell = dequeue(at: row) as Cell
        let model = models[row]
        cell.config(model)
        if !cellStyles.isEmpty {
            let result = CellStyleResult(row: row, model: model, section: self)
            cellStyles.forEach { style in
                style.value(result)
            }
        }
        return cell
    }
    
    open func itemSize(at row: Int) -> CGSize {
        guard models.indices.contains(row) else {
            return .zero
        }
        return Cell.preferredSize(limit: safeSizeProvider.size, model: models[row])
    }
    
    open func item(selected row: Int) {
        sendAction(.selected, row: row)
    }
    
    open func item(willDisplay view: UICollectionViewCell, row: Int) {
        sendAction(.willDisplay, row: row)
    }
    
    open func item(didEndDisplaying view: UICollectionViewCell, row: Int) {
        sendDeleteAction(.didEndDisplay, row: row)
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
        guard let supplementary = supplementaries[.header] else {
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
    
    open func supplementary(willDisplay view: UICollectionReusableView, kind: SKSupplementaryKind, at row: Int) {
        sendSupplementaryAction(.willDisplay, kind: kind, row: row)
    }
    
    open func supplementary(didEndDisplaying view: UICollectionReusableView, kind: SKSupplementaryKind, at row: Int) {
        sendSupplementaryAction(.didEndDisplay, kind: kind, row: row)
    }
    
}

public extension SKCSingleTypeSection {
    
    var indexForSelectedItems: [Int] {
        (sectionView.indexPathsForSelectedItems ?? [])
            .filter { $0.section == sectionIndex }
            .map(\.row)
    }
    
    func cellForItem(at row: Int) -> Cell? {
        sectionView.cellForItem(at: indexPath(from: row)) as? Cell
    }
    
    var visibleCells: [Cell] {
        indexsForVisibleItems
            .compactMap(cellForItem(at:))
    }
    
    var indexsForVisibleItems: [Int] {
        sectionView.indexPathsForVisibleItems.filter { $0.section == sectionIndex }.map(\.row)
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
        models.enumerated().forEach { item in
            deletedModels[item.offset] = item.element
        }
        reload(models)
        return self
    }
    
    @discardableResult
    func set<T>(supplementary: SKCSupplementary<T>) -> Self {
        register(supplementary.type, for: supplementary.kind)
        supplementaries[supplementary.kind] = supplementary
        return self
    }
    
    @discardableResult
    func remove(supplementary kind: SKSupplementaryKind) -> Self {
        supplementaries[kind] = nil
        return self
    }
    
}

public extension SKCSingleTypeSection {
    
    func swapAt(_ i: Int, _ j: Int) {
        sectionView.performBatchUpdates {
            models.swapAt(i, j)
            sectionView.moveItem(at: indexPath(from: i), to: indexPath(from: j))
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
        remove([item])
    }
    
    func remove(_ items: [Model]) where Model: Equatable {
        let rows = self.models
            .enumerated()
            .filter { items.contains($0.element) }
            .map(\.offset)
        remove(rows)
    }
    
}


public extension SKCSingleTypeSection {
    
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
    
    func remove(cellStyle ids: [CellStyleBox.ID]) {
        let ids = Set(ids)
        self.cellStyles = cellStyles.filter { !ids.contains($0.id) }
    }
    
}

public extension SKCSingleTypeSection {
    
    func deselectItem(at row: Int, animated: Bool = true) {
        sectionView.deselectItem(at: indexPath(from: row), animated: animated)
    }
    
    func selectItem(at row: Int, animated: Bool = true, scrollPosition: UICollectionView.ScrollPosition = .bottom) {
        sectionView.selectItem(at: indexPath(from: row), animated: animated, scrollPosition: scrollPosition)
    }
    
}


private extension SKCSingleTypeSection {
    
    func sendDeleteAction(_ type: CellActionType, row: Int) {
        let result = CellActionResult(section: self, type: type, model: deletedModels[row] ?? models[row], row: row)
        deletedModels[row] = nil
        sendAction(result)
    }
    
    func sendAction(_ type: CellActionType, row: Int) {
        let result = CellActionResult(section: self, type: type, model: models[row], row: row)
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
    
}
