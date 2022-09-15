//
//  File.swift
//  
//
//  Created by linhey on 2022/8/31.
//

import UIKit

public extension SKConfigurableView where Self: UICollectionViewCell & SKLoadViewProtocol {
    
    static func singleTypeWrapper(@SectionArrayResultBuilder<Model> builder: () -> [Model]) -> SKCSingleTypeSection<Self> {
        .init(builder())
    }
    
    static func singleTypeWrapper(_ models: [Model]) -> SKCSingleTypeSection<Self> {
        .init(models)
    }
    
    static func singleTypeWrapper() -> SKCSingleTypeSection<Self> {
        singleTypeWrapper([] as [Model])
    }
    
    static func singleTypeWrapper(_ models: Model...) -> SKCSingleTypeSection<Self> {
        singleTypeWrapper(models)
    }
    
    static func singleTypeWrapper(_ tasks: [() -> Self.Model]) -> SKCSingleTypeSection<Self> {
        return singleTypeWrapper(tasks.map({ $0() }))
    }
    
    static func singleTypeWrapper(_ tasks: [() async throws -> Model]) async throws -> SKCSingleTypeSection<Self> {
        var models = [Model]()
        for task in tasks {
            models.append(try await task())
        }
        return singleTypeWrapper(models)
    }
    
    static func singleTypeWrapper(count: Int) -> SKCSingleTypeSection<Self> where Model == Void {
        singleTypeWrapper(.init(repeating: (), count: count))
    }
    
}
