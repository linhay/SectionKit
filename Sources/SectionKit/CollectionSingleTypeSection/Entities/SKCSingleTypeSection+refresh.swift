//
//  File.swift
//  
//
//  Created by linhey on 2023/7/25.
//

import Foundation


/// 指定更新
public extension SKCSingleTypeSection {
    
    func refresh(_ model: Model) where Model: Equatable {
        self.refresh([model])
    }
    
    func refresh(_ models: [Model]) where Model: Equatable {
        sectionInjection?.reload(cell: rows(with: models))
    }
    
    func refresh(_ model: Model) where Model: AnyObject {
        self.refresh([model])
    }
    
    func refresh(_ models: [Model]) where Model: AnyObject {
        let indexs = models
            .enumerated()
            .compactMap { item in
                models.contains(where: { $0 === item.element }) ? item.offset : nil
            }
        sectionInjection?.reload(cell: indexs)
    }
    
    func refresh(at row: Int) {
        sectionInjection?.reload(cell: row)
    }
    
    func refresh(at row: [Int]) {
        sectionInjection?.reload(cell: row)
    }
    
}
