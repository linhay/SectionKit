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
    
}

open class SKCSingleTypeSection<Cell: UICollectionViewCell & SKConfigurableView & SKLoadViewProtocol>: SKCSingleTypeSectionProtocol {
    
    public typealias CellActionBlock = (CellActionResult) -> Void
    
    public enum CellActionKind: Int, Hashable {
        case selected
    }
    
    public struct CellActionResult {
        public let section: SKCSingleTypeSection<Cell>
        public let kind: CellActionKind
        public let model: Cell.Model
        public let row: Int
    }
    
    public struct Pulishers {
        lazy var cellActionPulisher = cellActionSubject.eraseToAnyPublisher()
        fileprivate lazy var cellActionSubject = PassthroughSubject<CellActionResult, Never>()
    }
    
    open var sectionInjection: SKCSectionInjection?
    
    open var models: [Model]
    
    open lazy var safeSizeProvider: SKSafeSizeProvider = defaultSafeSizeProvider
    open lazy var sectionInset: UIEdgeInsets = .zero
    open lazy var minimumLineSpacing: CGFloat = .zero
    open lazy var minimumInteritemSpacing: CGFloat = .zero

    open var itemCount: Int { models.count }
    
    public private(set) lazy var pulishers = Pulishers()
    
    private lazy var supplementaries: [SKSupplementaryKind: any SKCSupplementaryProtocol] = [:]
    private lazy var cellActions: [CellActionKind: [CellActionBlock]] = [:]

    public init(_ models: [Model] = []) {
        self.models = models
    }
    
    open func config(sectionView: UICollectionView) {
        register(Cell.self)
    }
    
    open func item(at row: Int) -> UICollectionViewCell {
        let cell = dequeue(at: row) as Cell
        cell.config(models[row])
        return cell
    }
    
    open func itemSize(at row: Int) -> CGSize {
        guard models.indices.contains(row) else {
            return .zero
        }
        return Cell.preferredSize(limit: safeSizeProvider.size, model: models[row])
    }
    
    public func item(selected row: Int) {
        let result = CellActionResult(section: self, kind: .selected, model: models[row], row: row)
        cellActions[.selected]?.forEach({ block in
            block(result)
        })
        pulishers.cellActionSubject.send(result)
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
    
    func selectItem(at row: Int?, animated: Bool, scrollPosition: UICollectionView.ScrollPosition) {
        guard let row = row else { return }
        sectionView.selectItem(at: indexPath(from: row), animated: animated, scrollPosition: scrollPosition)
    }
    
    func deselectItem(at row: Int, animated: Bool) {
        sectionView.deselectItem(at: indexPath(from: row), animated: animated)
    }
    
}

public extension SKCSingleTypeSection {
    
    @discardableResult
    func config(models: [Model]) -> Self {
        reload(models)
        return self
    }
    
    @discardableResult
    func set<T>(supplementary: SKCSupplementary<T>) -> Self {
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
                models.remove(at: row)
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
    
    func on(cellAction kind: CellActionKind, block: @escaping CellActionBlock) -> Self {
        if cellActions[kind] == nil {
            cellActions[kind] = []
        }
        cellActions[kind]?.append(block)
        return self
    }
    
}
