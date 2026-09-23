//
//  File.swift
//  
//
//  Created by linhey on 2023/8/14.
//

import UIKit

public protocol SKCSingleTypeSectionRowContext {
    associatedtype Cell: UICollectionViewCell & SKConfigurableView & SKLoadViewProtocol
    var section: SKCSingleTypeSection<Cell> { get }
    var row: Int { get }
}

public extension SKCSingleTypeSectionRowContext {
    
    var isFirstRow: Bool { row == 0 }
    var isLastRow: Bool { row >= section.models.count - 1 }
    
    func reload() {
        section.refresh(at: row)
    }
    
    func remove() {
        section.remove(row)
    }
    
    func delete() {
        section.delete(row)
    }
    
}
