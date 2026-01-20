//
//  File.swift
//  
//
//  Created by linhey on 2024/6/28.
//

import Foundation
import UIKit

public enum SKCActionContextVersion {
    case current
}

public protocol SKCSingleAssociatedViewContextProtocol {
    associatedtype AssociatedView: UIView
    func view(version: SKCActionContextVersion) -> AssociatedView
}

public extension SKCSingleAssociatedViewContextProtocol {
    
    func view(version: SKCActionContextVersion = .current) -> AssociatedView {
        return self.view(version: version)
    }
    
    func view<View>(as type: View.Type) -> View? {
        return self.view(version: .current) as? View
    }
    
    var view: AssociatedView {
        return self.view(version: .current)
    }
    
}

public protocol SKCSingleTypeCellActionContextProtocol: SKCSingleTypeSectionRowContext, SKCSingleAssociatedViewContextProtocol {
    var model: Cell.Model { get }
}

public extension SKCSingleTypeCellActionContextProtocol {
    
    func reload(with model: Cell.Model) {
        refresh(with: model)
    }
    
    func refresh(with model: Cell.Model) {
        section.refresh(with: .init(row: row, model: model))
    }

    func insert(before model: Cell.Model) {
        insert(after: [model])
    }
    
    func insert(before model: [Cell.Model]) {
        section.insert(at: row, model)
    }
    
    func insert(after model: Cell.Model) {
        insert(after: [model])
    }
    
    func insert(after model: [Cell.Model]) {
        section.insert(at: row + 1, model)
    }
    
}
