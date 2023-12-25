//
//  SKCCellStyleContext.swift
//  SectionKit2
//
//  Created by linhey on 2023/12/15.
//

import UIKit

public struct SKCCellStyleContext<Cell: UICollectionViewCell & SKConfigurableView & SKLoadViewProtocol>: SKCSingleTypeSectionRowContext {
    
    public let section: SKCSingleTypeSection<Cell>
    public let model: Cell.Model
    public let row: Int
    public let view: Cell
    
    init(section: SKCSingleTypeSection<Cell>, model: Cell.Model, row: Int, view: Cell) {
        self.row = row
        self.model = model
        self.section = section
        self.view = view
    }
    
}
