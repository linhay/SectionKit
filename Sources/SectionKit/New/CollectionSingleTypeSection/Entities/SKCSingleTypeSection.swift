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
    
    func on(cellAction kind: CellActionKind, block: @escaping CellActionBlock) -> Self {
        if cellActions[kind] == nil {
            cellActions[kind] = []
        }
        cellActions[kind]?.append(block)
        return self
    }
    
}
