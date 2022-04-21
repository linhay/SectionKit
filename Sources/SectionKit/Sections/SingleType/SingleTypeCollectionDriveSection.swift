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
    /// 视图事件回调(显示隐藏)
    public let publishers = SectionPublishers()
    
    /// 原始数据
    public let dataSubject: CurrentValueSubject<(models: [Cell.Model], isUnTransformed: Bool), Never>
    /// 数据转换器
    public let dataTransforms: [SectionDataTransform<Cell.Model>]
    /// 内置数据转换器
    public let dataDefaultTransforms = SectionTransforms<Cell>()
    /// UI驱动所用数据集
    public var models: [Cell.Model] { self.dataSubject.value.models }
    
    open var sectionState: SectionState?
    
    open var itemCount: Int { models.count }
    
    /// cell 样式配置
    private var itemStyleProvider: ((_ row: Int, _ cell: Cell) -> Void)?
    
    private var cancellables = Set<AnyCancellable>()
    /// 注册队列
    private var registerQueue = [(SingleTypeCollectionDriveSection<Cell>) -> Void]()
    
    public required init(_ models: [Cell.Model] = [], transforms: [SectionDataTransform<Cell.Model>] = []) {
        self.dataSubject = .init((models, true))
        self.dataTransforms = dataDefaultTransforms.all + transforms
        dataSubject
            .filter(\.isUnTransformed)
            .map(\.models)
            .map { [weak self] models -> [Cell.Model] in
                guard let self = self else { return [] }
                return self.modelsFilter(models, transforms: self.dataTransforms)
            }
            .sink { [weak self] models in
                guard let self = self else { return }
                self.dataSubject.send((models, true))
            }.store(in: &cancellables)
    }
    
    open func config(models: [Cell.Model]) {
        dataSubject.send((models, true))
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
    
}

/// init
public extension SingleTypeCollectionDriveSection {
    
    convenience init(count: Int, transforms: [SectionDataTransform<Cell.Model>] = []) where Cell.Model == Void {
        self.init(repeating: (), count: count)
    }
    
    convenience init(repeating: Cell.Model, count: Int, transforms: [SectionDataTransform<Cell.Model>] = []) {
        self.init(.init(repeating: repeating, count: count), transforms: transforms)
    }
    
}

/// register
public extension SingleTypeCollectionDriveSection {
    
    /// 注册 View, Cell
    /// - Parameter builds: 待注册数据
    func register(_ builds: ((SingleTypeCollectionDriveSection<Cell>) -> Void)...) {
        register(builds)
    }
    
    /// 注册 View, Cell
    /// - Parameter builds: 待注册数据
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

public extension SingleTypeCollectionDriveSection {
    
    /// 配置 Cell 样式
    /// - Parameter builder: 回调
    /// - Returns: 链式调用
    @discardableResult
    func itemStyle(_ builder: @escaping (_ row: Int, _ cell: Cell) -> Void) -> Self {
        self.itemStyleProvider = builder
        return self
    }
    
    /// 配置当前 Section 样式
    /// - Parameter builder: 回调
    /// - Returns: 链式调用
    @discardableResult
    func sectionStyle(_ builder: @escaping (_ section: Self) -> Void) -> Self {
        builder(self)
        return self
    }
    
    /// item 选中事件订阅 (可以同时订阅多次, 等同于 `publishers.cell.selected.sink`)
    /// - Parameter builder: 订阅回调
    /// - Returns: self
    @discardableResult
    func onItemSelected(_ builder: @escaping (_ row: Int, _ model: Cell.Model) -> Void) -> Self {
        publishers.cell.selected.sink { result in
            builder(result.row, result.model)
        }.store(in: &cancellables)
        return self
    }
    
    /// item 显示事件订阅 (可以同时订阅多次, 等同于 `publishers.cell.willDisplay.sink`)
    /// - Parameter builder: 订阅回调
    /// - Returns: self
    @discardableResult
    func onItemWillDisplay(_ builder: @escaping (_ row: Int, _ model: Cell.Model) -> Void) -> Self {
        publishers.cell.willDisplay.sink { result in
            builder(result.row, result.model)
        }.store(in: &cancellables)
        return self
    }
    
    /// item 结束显示事件订阅 (可以同时订阅多次, 等同于 `publishers.cell.didEndDisplaying.sink`)
    /// - Parameter builder: 订阅回调
    /// - Returns: self
    @discardableResult
    func onItemEndDisplay(_ builder: @escaping (_ row: Int, _ model: Cell.Model) -> Void) -> Self {
        publishers.cell.didEndDisplaying.sink { result in
            builder(result.row, result.model)
        }.store(in: &cancellables)
        return self
    }
    
}

public extension SingleTypeCollectionDriveSection {
    
    /// 配置 Cell 样式
    /// - Parameters:
    ///   - target: weak 对象
    ///   - builder: 回调
    /// - Returns: 链式调用
    @discardableResult
    func itemStyle<T: AnyObject>(on target: T, _ builder: @escaping (_ self: T, _ row: Int, _ cell: Cell) -> Void) -> Self {
        return itemStyle { [weak target] row, cell in
            guard let target = target else { return }
            builder(target, row, cell)
        }
    }
    
    /// 配置当前 Section 样式
    /// - Parameters:
    ///   - target: weak 对象
    ///   - builder: 回调
    /// - Returns: 链式调用
    @discardableResult
    func sectionStyle<T: AnyObject>(on target: T, _ builder: @escaping (_ self: T, _ section: Self) -> Void) -> Self {
        return sectionStyle { [weak target] section in
            guard let target = target else { return }
            builder(target, section)
        }
    }
    
    /// item 选中事件订阅 (可以同时订阅多次, 等同于 `publishers.cell.selected.sink`)
    /// - target: weak 对象
    /// - Parameter builder: 订阅回调
    /// - Returns: self
    @discardableResult
    func onItemSelected<T: AnyObject>(on target: T, _ builder: @escaping (_ self: T, _ row: Int, _ model: Cell.Model) -> Void) -> Self {
        return onItemSelected { [weak target] row, model in
            guard let target = target else { return }
            builder(target, row, model)
        }
    }
    
    /// item 显示事件订阅 (可以同时订阅多次, 等同于 `publishers.cell.willDisplay.sink`)
    /// - target: weak 对象
    /// - Parameter builder: 订阅回调
    /// - Returns: self
    @discardableResult
    func onItemWillDisplay<T: AnyObject>(on target: T, _ builder: @escaping (_ self: T, _ row: Int, _ model: Cell.Model) -> Void) -> Self {
        return onItemWillDisplay { [weak target] row, model in
            guard let target = target else { return }
            builder(target, row, model)
        }
    }
    
    /// item 结束显示事件订阅 (可以同时订阅多次, 等同于 `publishers.cell.didEndDisplaying.sink`)
    ///   - target: weak 对象
    /// - Parameter builder: 订阅回调
    /// - Returns: self
    @discardableResult
    func onItemEndDisplay<T: AnyObject>(on target: T, _ builder: @escaping (_ self: T, _ row: Int, _ model: Cell.Model) -> Void) -> Self {
        return onItemEndDisplay { [weak target] row, model in
            guard let target = target else { return }
            builder(target, row, model)
        }
    }
    
}


/// 增删
extension SingleTypeCollectionDriveSection {
    
    public func insert(_ models: [Cell.Model], at row: Int) {
        self.dataSubject.value.models.insert(contentsOf: models, at: row)
        insertItems(at: [row])
    }
    
    public func remove(at rows: [Int]) {
        rows.sorted(by: >).forEach { index in
            self.dataSubject.value.models.remove(at: index)
        }
        deleteItems(at: rows)
    }
    
}
#endif
