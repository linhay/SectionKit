// MIT License
//
// Copyright (c) 2020 linhey
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

#if canImport(UIKit)
import Foundation
import UIKit
#if canImport(Combine)
import Combine
#endif

open class SingleTypeCollectionDriveSection<Cell: UICollectionViewCell & SectionLoadViewProtocol & ConfigurableView>: SingleTypeSectionProtocol, SectionCollectionDequeueProtocol, SectionCollectionDriveProtocol {
    
    public typealias SectionPublishers = SingleTypeSectionPublishers<Cell.Model, UICollectionReusableView>
    public let publishers = SectionPublishers()
    
    /// 原始数据
    private let dataSubject: CurrentValueSubject<[Cell.Model], Never>
    /// 数据转换器
    private let dataTransforms: [DataTransform]
    /// 内置数据转换器
    private let systemDataTransforms = SystemTransforms()
    /// UI驱动所用数据集
    public private(set) var models: [Cell.Model] = []
    

    
    open var sectionState: SectionState?
    open var itemCount: Int { models.count }
    
    /// cell 样式配置
    private var itemStyleProvider: ((_ row: Int, _ cell: Cell) -> Void)?
    
    private var cancellables = Set<AnyCancellable>()
    /// 注册队列
    private var registerQueue = [(SingleTypeCollectionDriveSection<Cell>) -> Void]()
    
    public required init(_ models: [Cell.Model] = [], transforms: [DataTransform] = []) {
        self.dataSubject = .init(models)
        self.dataTransforms = systemDataTransforms.all + transforms
        self.models = self.models(transforms: dataTransforms)
    }
    
    open func config(models: [Cell.Model]) {
        dataSubject.send(models)
        reload()
    }
    
    open func config(sectionView: UICollectionView) {
        register(Cell.self)
        registerQueue.forEach { task in
            task(self)
        }
        registerQueue.removeAll()
    }
    
    open func item(at row: Int) -> UICollectionViewCell {
        let cell = dequeue(at: row) as Cell
        cell.config(models[row])
        itemStyleProvider?(row, cell)
        return cell
    }
    
    open func cellForTypeItem(at row: Int) -> Cell? {
        return cellForItem(at: row) as? Cell
    }
    
    open var visibleTypeItems: [Cell] {
        return visibleCells.compactMap({ $0 as? Cell })
    }
    
    open func item(willDisplay row: Int) {
        publishers.cell._willDisplay.send(.init(row: row, model: models[row]))
    }
    
    open func item(didEndDisplaying row: Int) {
        publishers.cell._didEndDisplaying.send(.init(row: row, model: models[row]))
    }
    
    open func supplementary(willDisplay view: UICollectionReusableView, forElementKind elementKind: SectionSupplementaryKind, at row: Int) {
        let result = SectionPublishers.SupplementaryResult(view: view, elementKind: elementKind, row: row)
        publishers.supplementary._willDisplay.send(result)
    }
    
    open func supplementary(didEndDisplaying view: UICollectionReusableView, forElementKind elementKind: SectionSupplementaryKind, at row: Int) {
        let result = SectionPublishers.SupplementaryResult(view: view, elementKind: elementKind, row: row)
        publishers.supplementary._didEndDisplaying.send(result)
    }
    
    private func models(transforms: [DataTransform]) -> [Cell.Model] {
        var list = dataSubject.value
        for transform in dataTransforms {
            list = transform.task?(list) ?? list
        }
        return list
    }
    
}

/// DataTransform
extension SingleTypeCollectionDriveSection {

    open class DataTransform {
        open var task: (([Cell.Model]) -> [Cell.Model])?
        public init(task: (([Cell.Model]) -> [Cell.Model])?) {
            self.task = task
        }
    }
    
    public class HiddenDataTransform: DataTransform {
        func by(_ block: @escaping () -> Bool) {
            task = { list in
                block() ? [] : list
            }
        }
    }
    
    private class SystemTransforms {
        var hidden: HiddenDataTransform = .init(task: nil)
        let validate: DataTransform = .init(task: { $0.filter(Cell.validate) })
        lazy var all = [self.hidden, self.validate]
    }
    
}

/// init
public extension SingleTypeCollectionDriveSection {
    
    convenience init(count: Int, transforms: [DataTransform] = []) where Cell.Model == Void {
        self.init(repeating: (), count: count)
    }
    
    convenience init(repeating: Cell.Model, count: Int, transforms: [DataTransform] = []) {
        self.init(.init(repeating: repeating, count: count), transforms: transforms)
    }
    
}

/// register
public extension SingleTypeCollectionDriveSection {
    
    /// 注册 View, Cell
    func register(_ builds: ((SingleTypeCollectionDriveSection<Cell>) -> Void)...) {
        register(builds)
    }
    
    /// 注册 View, Cell
    func register(_ builds: [(SingleTypeCollectionDriveSection<Cell>) -> Void]) {
        if isLoaded {
            builds.forEach { build in
                build(self)
            }
        } else {
            registerQueue.append(contentsOf: builds)
        }
    }
    
}

/// 隐藏该 Section
public extension SingleTypeCollectionDriveSection {
    
    /// 隐藏该 Section
    /// - Parameter by: bool
    /// - Returns: self
    @discardableResult
    func hidden(by: @escaping () -> Bool) -> Self {
        systemDataTransforms.hidden.by(by)
        reload()
        return self
    }
    
    @discardableResult
    func hidden(_ value: Bool) -> Self {
        self.hidden { value }
        return self
    }
    
    @discardableResult
    func hidden<T: AnyObject>(by: T, _ keyPath: KeyPath<T, Bool>) -> Self {
        self.hidden { [weak by] in
            by?[keyPath: keyPath] ?? false
        }
        return self
    }
    
    @discardableResult
    func hidden<T>(by: T, _ keyPath: KeyPath<T, Bool>) -> Self {
        self.hidden { by[keyPath: keyPath] }
        return self
    }
    
}

/// 链式调用 - Style
public extension SingleTypeCollectionDriveSection {
    
    @discardableResult
    func itemStyle(_ builder: @escaping (_ row: Int, _ cell: Cell) -> Void) -> Self {
        self.itemStyleProvider = builder
        return self
    }
    
    @discardableResult
    func sectionStyle(_ builder: @escaping (_ section: Self) -> Void) -> Self {
        builder(self)
        return self
    }
    
}

public extension SingleTypeCollectionDriveSection {
    
    /// item 选中事件订阅 (可以同时订阅多次, 等同于 `publishers.cell.selected.sink`)
    /// - Parameter builder: 订阅回调
    /// - Returns: self
    func onItemSelected(_ builder: @escaping (_ row: Int, _ model: Cell.Model) -> Void) -> Self {
        publishers.cell.selected.sink { result in
            builder(result.row, result.model)
        }.store(in: &cancellables)
        return self
    }
    
    /// item 显示事件订阅 (可以同时订阅多次, 等同于 `publishers.cell.willDisplay.sink`)
    /// - Parameter builder: 订阅回调
    /// - Returns: self
    func onItemWillDisplay(_ builder: @escaping (_ row: Int, _ model: Cell.Model) -> Void) -> Self {
        publishers.cell.willDisplay.sink { result in
            builder(result.row, result.model)
        }.store(in: &cancellables)
        return self
    }
    
    /// item 结束显示事件订阅 (可以同时订阅多次, 等同于 `publishers.cell.didEndDisplaying.sink`)
    /// - Parameter builder: 订阅回调
    /// - Returns: self
    func onItemEndDisplay(_ builder: @escaping (_ row: Int, _ model: Cell.Model) -> Void) -> Self {
        publishers.cell.didEndDisplaying.sink { result in
            builder(result.row, result.model)
        }.store(in: &cancellables)
        return self
    }
    
}

/// 增删
extension SingleTypeCollectionDriveSection {
    
    public func insert(_ models: [Cell.Model], at row: Int) {
        self.models.insert(contentsOf: models, at: row)
        insertItems(at: [row])
    }
    
    public func remove(at rows: [Int]) {
        rows.sorted(by: >).forEach { index in
            models.remove(at: index)
        }
        deleteItems(at: rows)
    }
    
}
#endif
