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
import UIKit
#if canImport(Combine)
import Combine
#endif

open class SingleTypeCollectionDriveSection<Cell: UICollectionViewCell & SectionLoadViewProtocol & SectionConfigurableView>: SingleTypeSectionProtocol, SectionCollectionDequeueProtocol, SectionCollectionDriveProtocol {
    public typealias SectionPublishers = SingleTypeSectionPublishers<Cell.Model, UICollectionReusableView>
    /// 视图事件回调(显示隐藏)
    public let publishers = SectionPublishers()
    public let dataSource: SingleTypeSectionDataSource<Cell>
    /// UI驱动所用数据集
    public private(set) lazy var models: [Cell.Model] = []
    
    open var sectionState: SectionState?
    
    open var itemCount: Int { models.count }
    
    /// cell 样式配置
    private var itemStyleProvider: ((_ row: Int, _ cell: Cell) -> Void)?
    
    /// 外部数据订阅
    private var modelsCancellable: AnyCancellable?
    internal var cancellables = Set<AnyCancellable>()
    
    /// 注册队列
    private var registerQueue = [(SingleTypeCollectionDriveSection<Cell>) -> Void]()
    
    public required init(_ models: [Cell.Model] = [], transforms: [SectionDataTransform<Cell.Model>] = []) {
        dataSource = .init(models, transforms: transforms)
        dataSource.reloadPublisher.sink { [weak self] _ in
            self?.sectionState?.reloadDataEvent?()
        }.store(in: &cancellables)
        dataSource.dataSubject.filter(\.isTransformed).map(\.models).sink { [weak self] models in
            self?.models = models
        }.store(in: &cancellables)
    }
    
    open func config(models: [Cell.Model]) {
        dataSource.dataSubject.send(.init(models: models, isTransformed: false, options: dataSource.dataOptions))
    }
    
    open func config(sectionView _: UICollectionView) {
        register(Cell.self)
        registerQueue.forEach { task in
            task(self)
        }
        registerQueue.removeAll()
    }
    
    open func item(at row: Int) -> UICollectionViewCell {
        let cell = dequeue(at: row) as Cell
        if let model = model(at: row) {
            cell.config(model)
        }
        itemStyleProvider?(row, cell)
        return cell
    }
    
    public func supplementary(kind _: SectionSupplementaryKind, at _: Int) -> UICollectionReusableView? {
        return nil
    }
    
    open func cellForTypeItem(at row: Int) -> Cell? {
        return cellForItem(at: row) as? Cell
    }
    
    open var visibleTypeItems: [Cell] {
        return visibleCells.compactMap { $0 as? Cell }
    }
    
    open func item(willDisplay row: Int) {
        if let model = model(at: row) {
            publishers.cell._willDisplay.send(.init(row: row, model: model))
        }
    }
    
    open func item(didEndDisplaying row: Int) {
        if let model = model(at: row) {
            publishers.cell._didEndDisplaying.send(.init(row: row, model: model))
        }
    }
    
    open func supplementary(willDisplay view: UICollectionReusableView, forElementKind elementKind: SectionSupplementaryKind, at row: Int) {
        let result = SectionPublishers.SupplementaryResult(view: view, elementKind: elementKind, row: row)
        publishers.supplementary._willDisplay.send(result)
    }
    
    open func supplementary(didEndDisplaying view: UICollectionReusableView, forElementKind elementKind: SectionSupplementaryKind, at row: Int) {
        let result = SectionPublishers.SupplementaryResult(view: view, elementKind: elementKind, row: row)
        publishers.supplementary._didEndDisplaying.send(result)
    }
    
    open func reload() {
        dataSource.reload()
    }
    
    private func model(at: Int) -> Cell.Model? {
        guard models.indices.contains(at) else {
            return nil
        }
        return models[at]
    }
}

/// init
public extension SingleTypeCollectionDriveSection {
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

/// 数据订阅
public extension SingleTypeCollectionDriveSection {
    /// 覆盖现有数据
    /// - Parameter models: Publisher
    @discardableResult
    func config(models: AnyPublisher<[Cell.Model], Never>) -> Self {
        modelsCancellable = models.sink(receiveValue: { [weak self] models in
            self?.config(models: models)
        })
        return self
    }
    
    /// 新数据将拼接至最后
    /// - Parameter models: Publisher
    @discardableResult
    func append(models: AnyPublisher<[Cell.Model], Never>) -> Self {
        modelsCancellable = models.sink(receiveValue: { [weak self] models in
            self?.append(models)
        })
        return self
    }
}

/// Transforms
public extension SingleTypeCollectionDriveSection {
    /// 订阅隐藏消息
    /// - Parameter publisher: Publisher
    /// - Returns: 链式调用
    @discardableResult
    func hidden(by publisher: AnyPublisher<Bool, Never>) -> Self {
        publisher.removeDuplicates().sink { [weak self] value in
            self?.hidden(value)
        }.store(in: &cancellables)
        return self
    }
}

public extension SingleTypeCollectionDriveSection {
    /// 配置 Cell 样式
    /// - Parameter builder: 回调
    /// - Returns: 链式调用
    @discardableResult
    func itemStyle(_ builder: @escaping (_ row: Int, _ cell: Cell) -> Void) -> Self {
        itemStyleProvider = builder
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

/// 增删
public extension SingleTypeCollectionDriveSection {
    func insert(_ models: [Cell.Model], at row: Int) {
        guard models.isEmpty == false else {
            return
        }
        if !self.models.indices.contains(row) {
            assertionFailure("数组越界")
        }
        var list = self.models
        list.insert(contentsOf: models, at: row)
        
        var options = dataSource.dataOptions
        options.isNeedReload = false
        dataSource.dataSubject.send(.init(models: list, isTransformed: true, options: options))
        insertItems(at: [row])
    }
    
    func remove(at rows: [Int]) {
        guard rows.isEmpty == false else {
            return
        }
        if let max = rows.max(), !self.models.indices.contains(max) {
            assertionFailure("数组越界")
        }
        var list = models
        rows.sorted(by: >).forEach { index in
            list.remove(at: index)
        }
        
        var options = dataSource.dataOptions
        options.isNeedReload = false
        dataSource.dataSubject.send(.init(models: list, isTransformed: true, options: options))
        deleteItems(at: rows)
    }
}
#endif
