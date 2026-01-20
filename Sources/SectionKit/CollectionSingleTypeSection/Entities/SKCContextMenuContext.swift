//
//  ContextMenuContext.swift
//  SectionKit
//
//  Created by linhey on 1/20/26.
//

import UIKit

public struct SKCContextMenuContext<Cell: UICollectionViewCell & SKConfigurableView & SKLoadViewProtocol>: SKCSingleTypeCellActionContextProtocol {
    
    public let section: SKCSingleTypeSection<Cell>
    public let model: Cell.Model
    public let row: Int
    
    init(section: SKCSingleTypeSection<Cell>,
         model: Cell.Model,
         row: Int) {
        self.section = section
        self.model = model
        self.row = row
    }
    
}

public struct CellActionContext<Cell: UICollectionViewCell & SKConfigurableView & SKLoadViewProtocol>: SKCSingleTypeSectionRowContext, SKCSingleTypeCellActionContextProtocol {
    
    public let section: SKCSingleTypeSection<Cell>
    public let type: SKCCellActionType
    public let model: Cell.Model
    public let row: Int
    public var indexPath: IndexPath { section.indexPath(from: row) }
    fileprivate let _view: SKWeakBox<Cell>?
    
    public func view() -> Cell {
        guard let cell = _view?.value ?? section.cellForItem(at: row) else {
            assertionFailure()
            return .init(frame: .zero)
        }
        return cell
    }
    
    init(section: SKCSingleTypeSection<Cell>,
                     type: SKCCellActionType,
                     model: Cell.Model, row: Int,
                     _view: Cell?) {
        self.section = section
        self.type = type
        self.model = model
        self.row = row
        self._view = .init(_view)
    }
}

public struct SupplementaryActionContext<Cell: UICollectionViewCell & SKConfigurableView & SKLoadViewProtocol> {
    public let section: SKCSingleTypeSection<Cell>
    public let type: SKCSupplementaryActionType
    public let kind: SKSupplementaryKind
    public let row: Int
    let _view: SKWeakBox<UICollectionReusableView>?
    
    public func view() -> UICollectionReusableView {
        guard let cell = _view?.value ?? section.supplementary(kind: kind, at: row) else {
            assertionFailure()
            return .init(frame: .zero)
        }
        return cell
    }
    
    init(section: SKCSingleTypeSection<Cell>,
         type: SKCSupplementaryActionType,
         kind: SKSupplementaryKind,
         row: Int,
         view: UICollectionReusableView?) {
        self.section = section
        self.type = type
        self.kind = kind
        self.row = row
        self._view = .init(view)
    }
}
