//
//  File.swift
//  
//
//  Created by linhey on 2022/4/12.
//

import UIKit

public extension ConfigurableView where Self: UICollectionViewCell & SectionLoadViewProtocol {
    
    static func singleTypeWrapper<Section: SingleTypeSection<Self>>(count: Int, transforms: [SectionDataTransform<Model>] = []) -> Section where Model == Void {
        return singleTypeWrapper(repeating: (), count: count, transforms: transforms)
    }
    
    static func singleTypeWrapper<Section: SingleTypeSection<Self>>(repeating: Model, count: Int, transforms: [SectionDataTransform<Model>] = []) -> Section {
        return singleTypeWrapper(.init(repeating: repeating, count: count), transforms: transforms)
    }
    
    static func singleTypeWrapper<Section: SingleTypeSection<Self>>(_ models: Model..., transforms: [SectionDataTransform<Model>] = []) -> Section {
        return singleTypeWrapper(models, transforms: transforms)
    }
    
    static func singleTypeWrapper<Section: SingleTypeSection<Self>>(_ models: [Model] = [], transforms: [SectionDataTransform<Model>] = []) -> Section {
        return .init(models, transforms: transforms)
    }
    
    static func singleTypeWrapper<Section: SingleTypeSection<Self>>(_ tasks: (() -> Model)..., transforms: [SectionDataTransform<Model>] = []) -> Section {
        return singleTypeWrapper(tasks, transforms: transforms)
    }
    
    static func singleTypeWrapper<Section: SingleTypeSection<Self>>(_ tasks: [() -> Model], transforms: [SectionDataTransform<Model>] = []) -> Section {
        return singleTypeWrapper(tasks.map({ $0() }), transforms: transforms)
    }
    
    static func singleTypeWrapper<Section: SingleTypeSection<Self>>(_ tasks: [() async throws -> Model], transforms: [SectionDataTransform<Model>] = []) async throws -> Section {
        var models = [Model]()
        for task in tasks {
            models.append(try await task())
        }
        return .init(models, transforms: transforms)
    }
    
}

public extension ConfigurableView where Self: UITableViewCell & SectionLoadViewProtocol {
    
    static func singleTypeWrapper(_ models: Model...) -> SingleTypeTableSection<Self> {
        return singleTypeWrapper(models)
    }
    
    static func singleTypeWrapper(_ models: [Model] = []) -> SingleTypeTableSection<Self> {
        return .init(models)
    }
    
    static func singleTypeWrapper(_ tasks: (() -> Model)...) -> SingleTypeTableSection<Self> {
        return singleTypeWrapper(tasks)
    }
    
    static func singleTypeWrapper(_ tasks: [() -> Model]) -> SingleTypeTableSection<Self> {
        return singleTypeWrapper(tasks.map({ $0() }))
    }
    
    static func singleTypeWrapper(_ tasks: [() async throws -> Model]) async throws -> SingleTypeTableSection<Self> {
        var models = [Model]()
        for task in tasks {
            models.append(try await task())
        }
        return .init(models)
    }
    
}
