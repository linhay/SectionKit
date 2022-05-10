//
//  File.swift
//
//
//  Created by linhey on 2022/4/12.
//

#if canImport(UIKit)
import UIKit

@resultBuilder
public enum SingleTypeWrapperBuilder<Model> {
    
    public struct Item {
        let models: [Model]
        let transforms: [SectionDataTransform<Model>]
        
        init(models: [Model] = [], transforms: [SectionDataTransform<Model>] = []) {
            self.models = models
            self.transforms = transforms
        }
    }
    
    public static func buildLimitedAvailability(_ component: Item) -> Item {
        component
    }
    
    public static func buildArray(_ components: [Item]) -> Item {
        let models = components.lazy.reversed().first(where: { !$0.models.isEmpty })?.models ?? []
        let transforms = components.lazy.reversed().first(where: { !$0.transforms.isEmpty })?.transforms ?? []
        return .init(models: models, transforms: transforms)
    }
    
    public static func buildOptional(_ component: Item?) -> Item {
        return component ?? .init()
    }
    
    public static func buildEither(first component: Item) -> Item {
        component
    }
    
    public static func buildEither(second component: Item) -> Item {
        component
    }
    
    public static func buildBlock(_ components: Item...) -> Item {
        buildArray(components)
    }
}

public extension SingleTypeWrapperBuilder.Item {
    static func model(_ value: [Model]) -> Self {
        .init(models: value)
    }
    
    static func model(_ value: [() -> Model]) -> Self {
        .init(models: value.map { $0() })
    }
    
    static func model(_ value: Model...) -> Self {
        model(value)
    }
    
    static func model(_ value: (() -> Model)...) -> Self {
        model(value)
    }
    
    static func transform(_ value: [SectionDataTransform<Model>]) -> Self {
        .init(transforms: value)
    }
    
    static func transform(_ value: SectionDataTransform<Model>...) -> Self {
        transform(value)
    }
}

public extension SingleTypeWrapperBuilder.Item where Model == Void {
    static func model(count: Int) -> Self {
        model(.init(repeating: (), count: count))
    }
}

public extension SectionConfigurableView where Self: UICollectionViewCell & SectionLoadViewProtocol {
    static func singleTypeWrapper<Section: SingleTypeSection<Self>>(_ builder: (_ builder: SingleTypeWrapperBuilder<Self.Model>.Item.Type) -> SingleTypeWrapperBuilder<Self.Model>.Item) -> Section
    {
        let item = builder(SingleTypeWrapperBuilder<Self.Model>.Item.self)
        return singleTypeWrapper(item.models, transforms: item.transforms)
    }
    
    static func singleTypeWrapper<Section: SingleTypeSection<Self>>(count: Int, transforms: [SectionDataTransform<Model>] = []) -> Section where Model == Void {
        return singleTypeWrapper(.init(repeating: (), count: count), transforms: transforms)
    }
    
    static func singleTypeWrapper<Section: SingleTypeSection<Self>>(_ models: [Model] = [], transforms: [SectionDataTransform<Model>] = []) -> Section {
        return .init(models, transforms: transforms)
    }
    
    static func singleTypeWrapper<Section: SingleTypeSection<Self>>(_ models: Model..., transforms: [SectionDataTransform<Model>] = []) -> Section {
        return .init(models, transforms: transforms)
    }
}

public extension SectionConfigurableView where Self: UITableViewCell & SectionLoadViewProtocol {
    static func singleTypeWrapper<Section: SingleTypeTableSection<Self>>(_ builder: (_ builder: SingleTypeWrapperBuilder<Self.Model>.Item.Type) -> SingleTypeWrapperBuilder<Self.Model>.Item) -> Section
    {
        let item = builder(SingleTypeWrapperBuilder<Self.Model>.Item.self)
        return singleTypeWrapper(item.models, transforms: item.transforms)
    }
    
    static func singleTypeWrapper<Section: SingleTypeTableSection<Self>>(count: Int, transforms: [SectionDataTransform<Model>] = []) -> Section where Model == Void {
        return singleTypeWrapper(.init(repeating: (), count: count), transforms: transforms)
    }
    
    static func singleTypeWrapper<Section: SingleTypeTableSection<Self>>(_ models: [Model] = [], transforms: [SectionDataTransform<Model>] = []) -> Section {
        return .init(models, transforms: transforms)
    }
    
    static func singleTypeWrapper<Section: SingleTypeTableSection<Self>>(_ models: Model..., transforms: [SectionDataTransform<Model>] = []) -> Section {
        return .init(models, transforms: transforms)
    }
}
#endif
