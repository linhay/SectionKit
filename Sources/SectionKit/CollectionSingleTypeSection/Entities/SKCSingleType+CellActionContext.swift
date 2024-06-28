//
//  File.swift
//  
//
//  Created by linhey on 2024/6/28.
//

import Foundation

public extension SKCSingleTypeSection.CellActionContext {
    
    func reload() {
        section.refresh(at: row)
    }
    
    func reload(with model: Cell.Model) {
        refresh(with: model)
    }
    
    func refresh(with model: Cell.Model) {
        section.refresh(with: .init(row: row, model: model))
    }

    func remove() {
        section.remove(row)
    }
    
    func delete() {
        section.delete(row)
    }
    
    func insert(after model: Cell.Model) {
        section.insert(at: row, model)
    }
    
    func insert(after model:[ Cell.Model]) {
        section.insert(at: row, model)
    }
    
}
