//
//  File.swift
//
//
//  Created by linhey on 2022/5/9.
//

import Combine
import Foundation

public class SingleTypeSectionDataSource<Cell: SectionConfigurableModelProtocol> {
    public struct DataModel {
        public let models: [Cell.Model]
        /// 是否经过转换器
        public var isTransformed: Bool
        /// 是否需要立即刷新视图
        public let options: DataOptions
    }
    
    public struct DataOptions {
        /// 是否更新数据后立刻刷新视图
        public var isNeedReload: Bool
    }
    
    public private(set) lazy var reloadPublisher = reloadSubject.eraseToAnyPublisher()
    
    public let dataOptions: DataOptions
    /// 原始数据
    public let dataSubject: CurrentValueSubject<DataModel, Never>
    /// 数据转换器
    public let dataTransforms: [SectionDataTransform<Cell.Model>]
    
    /// 内置数据转换器
    private let dataDefaultTransforms = SectionTransforms<Cell>()
    
    private let reloadSubject = PassthroughSubject<Void, Never>()
    
    private var cancellables = Set<AnyCancellable>()
    
    public init(_ models: [Cell.Model] = [], transforms: [SectionDataTransform<Cell.Model>] = []) {
        let dataOptions = DataOptions(isNeedReload: true)
        self.dataOptions = dataOptions
        dataSubject = .init(.init(models: models, isTransformed: transforms.isEmpty, options: dataOptions))
        dataTransforms = dataDefaultTransforms.all + transforms
        
        dataSubject
            .filter { !$0.isTransformed }
            .map(\.models)
            .map { [weak self] models -> [Cell.Model] in
                guard let self = self else { return [] }
                return self.modelsFilter(models, transforms: self.dataTransforms)
            }
            .sink { [weak self] models in
                guard let self = self else { return }
                self.dataSubject.send(.init(models: models, isTransformed: true, options: dataOptions))
            }.store(in: &cancellables)
        
        dataSubject
            .filter(\.isTransformed)
            .sink(receiveValue: { [weak self] model in
                guard let self = self else { return }
                if model.options.isNeedReload {
                    self.reloadSubject.send()
                }
            })
            .store(in: &cancellables)
    }
    
    func reload() {
        var model = dataSubject.value
        model.isTransformed = false
        dataSubject.send(model)
    }
    
    func hidden(by: @escaping () -> Bool) {
        dataDefaultTransforms.hidden.by(by)
        reload()
    }
}

public extension SingleTypeSectionDataSource {
    /// 采用 transforms 来处理原始数据集
    /// - Parameters:
    ///   - models: 原始数据集
    ///   - transforms: 转换器
    /// - Returns: 数据集
    func modelsFilter(_ models: [Cell.Model], transforms: [SectionDataTransform<Cell.Model>]) -> [Cell.Model] {
        return Self.modelsFilter(models, transforms: transforms)
    }
    
    /// 采用 transforms 来处理原始数据集
    /// - Parameters:
    ///   - models: 原始数据集
    ///   - transforms: 转换器
    /// - Returns: 数据集
    static func modelsFilter(_ models: [Cell.Model], transforms: [SectionDataTransform<Cell.Model>]) -> [Cell.Model] {
        var list = models
        for transform in transforms {
            list = transform.task?(list) ?? list
        }
        return list
    }
}
