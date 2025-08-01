//
//  SKCManager.swift
//  SectionKit
//
//  Created by linhey on 2022/8/11.
//

#if canImport(UIKit)
import UIKit
import Combine

/// 请求 ID 类，用于管理异步请求的生命周期
/// Request ID class for managing asynchronous request lifecycle
public class SKRequestID {
    
    /// 请求的唯一标识符
    /// Unique identifier for the request
    public let id: String
    
    /// 是否已取消
    /// Whether cancelled
    var isCancelled: Bool = false
    
    /// 执行任务的闭包，返回 true 表示任务完成
    /// Task closure, returns true when task is completed
    let task: () -> Bool
    
    /// 初始化请求 ID
    /// Initialize request ID
    init(id: String, task: @escaping () -> Bool) {
        self.id = id
        self.task = task
    }
    
    /// 取消请求
    /// Cancel request
    public func cancel() {
        isCancelled = true
    }
    
    /// 执行请求任务
    /// Perform request task
    public func perform() {
        if !isCancelled, task() {
            cancel()
        }
    }
    
}

/// 请求发布者结构体，包含布局相关的发布者
/// Request publishers structure containing layout-related publishers
public struct SKRequestPublishers {
    /// 布局子视图的发布者
    /// Publisher for layout subviews
    public let layoutSubviews = PassthroughSubject<Void, Never>()
    public init() {}
}

/// 请求视图协议，定义具有请求发布者的视图
/// Request view protocol defining views with request publishers
public protocol SKCRequestViewProtocol {
    /// 请求发布者实例
    /// Request publishers instance
    var requestPublishers: SKRequestPublishers { get }
}

/// SKC 管理器发布者类，管理 section 相关的发布者
/// SKC manager publishers class managing section-related publishers
public class SKCManagerPublishers {
    
    /// section 数组的主题
    /// Subject for sections array
    fileprivate lazy var sectionsSubject = CurrentValueSubject<[SKCBaseSectionProtocol], Never>([])
    
    /// 只读的 section 发布者
    /// Read-only sections publisher
    public private(set) lazy var sectionsPublisher = sectionsSubject.eraseToAnyPublisher()
    
    /// 当前的 section 数组
    /// Current sections array
    public var sections: [SKCBaseSectionProtocol] { sectionsSubject.value }
    
    /// 安全获取指定索引的 section
    /// Safely get section at specified index
    func safe<T>(section: Int) -> T? {
        guard sections.indices.contains(section) else {
            return nil
        }
        return sections[section] as? T
    }
    
    /// 获取指定类型的 section 集合
    /// Get collection of sections of specified type
    func collection<T>(_ type: T.Type = T.self) -> any Collection<T> {
        sections.lazy.compactMap({ $0 as? T })
    }
}

/// SKC 管理器主类，负责管理集合视图的数据和行为
/// Main SKC manager class responsible for managing collection view data and behavior
public class SKCManager {
    
    /// 转换器结构体，用于在处理过程中转换数据
    /// Converters structure for transforming data during processing
    public struct Converts {
        /// 转换器类型定义
        /// Converter type definition
        public typealias Convert<T> = (_ manager: SKCManager, _ item: T) -> T
        
        /// section 注入转换器数组
        /// Array of section injection converters
        public var sectionInjection = [Convert<SKCSectionInjection>]()
    }
    
    /// 配置结构体，定义管理器的行为配置
    /// Configuration structure defining manager behavior settings
    public struct Configuration {
        /// 将 reloadSections 操作替换为 reloadData 操作
        /// Replace reloadSections operations with reloadData operations
        public var replaceReloadWithReloadData = false
        
        /// 将 insertSections 操作替换为 reloadData 操作  
        /// Replace insertSections operations with reloadData operations
        public var replaceInsertWithReloadData = true
        
        /// 将 deleteSections 操作替换为 reloadData 操作
        /// Replace deleteSections operations with reloadData operations
        public var replaceDeleteWithReloadData = false
    }
    
    /// 静态配置实例
    /// Static configuration instance
    public static var configuration = Configuration()
    
    /// 实例配置
    /// Instance configuration
    public var configuration = SKCManager.configuration
    
    /// 转换器实例
    /// Converters instance
    public var converts = Converts()
    public private(set) lazy var publishers = SKCManagerPublishers()
    public private(set) weak var sectionView: UICollectionView?
    public var sections: [SKCBaseSectionProtocol] { publishers.sections }
    
    public private(set) lazy var dataSourceForward = SKCDataSourceForward()
    public private(set) lazy var flowLayoutForward = SKCDelegateFlowLayoutForward()
    public private(set) lazy var prefetchForward   = SKCDataSourcePrefetchingForward()
    public var scrollObserver: SKScrollViewDelegateForward { flowLayoutForward }
    
    private lazy var endDisplaySections: [Int: SKCBaseSectionProtocol] = [:]
    
    public lazy var flowlayoutDelegate = SKCDelegateFlowLayout(dataSource: publishers)
    public lazy var delegate = SKCDelegate(dataSource: publishers)
    public lazy var dataSource = SKCDataSource(dataSource: publishers)
    public lazy var prefetching = SKCDataSourcePrefetching(dataSource: publishers)
    
    private lazy var context = SKCSectionInjection.SectionViewProvider(sectionView, manager: self)
    
    var afterLayoutSubviewsRequests: [SKRequestID] = []
    private var cancellables = Set<AnyCancellable>()
    
    public init(sectionView: UICollectionView) {
        setup(sectionView: sectionView)
    }
    
    public init(sectionView: UICollectionView & SKCRequestViewProtocol) {
        setup(sectionView: sectionView)
        setup(request: sectionView)
    }
    
    private func setup(request: SKCRequestViewProtocol) {
        request.requestPublishers.layoutSubviews
            .filter({ [weak sectionView] in
                guard let sectionView = sectionView else {
                    return false
                }
                return sectionView.frame.width > 0 && sectionView.frame.height > 0
            })
            .throttle(for: .milliseconds(100), scheduler: RunLoop.main, latest: true)
            .sink { [weak self] _ in
                guard let self = self else { return }
                perform(of: &self.afterLayoutSubviewsRequests)
            }.store(in: &cancellables)
    }
    
    private func setup(sectionView: UICollectionView) {
        self.sectionView = sectionView
        sectionView.delegate = flowLayoutForward
        sectionView.dataSource = dataSourceForward
        sectionView.prefetchDataSource = prefetchForward
        flowLayoutForward.add(delegate)
        flowLayoutForward.add(flowlayoutDelegate)
        dataSourceForward.add(dataSource)
        prefetchForward.add(prefetching)
    }
    
}

public extension SKCManager {
    
    func insert(_ input: SKCBaseSectionProtocol, at: Int) {
        insert([input], at: at)
    }
    
    func insert(_ input: SKCBaseSectionProtocol, before: SKCBaseSectionProtocol) {
        insert([input], before: before)
    }
    func insert(_ input: [SKCBaseSectionProtocol], before: SKCBaseSectionProtocol) {
        guard let index = sections.firstIndex(where: { $0 === before }) else {
            return
        }
        insert(input, at: index)
    }
    
    func insert(_ input: SKCBaseSectionProtocol, after: SKCBaseSectionProtocol) {
        insert([input], after: after)
    }
    func insert(_ input: [SKCBaseSectionProtocol], after: SKCBaseSectionProtocol) {
        guard let index = sections.firstIndex(where: { $0 === after }) else {
            return
        }
        insert(input, at: index + 1)
    }
    
    func append(_ input: SKCBaseSectionProtocol) { append([input]) }
    
    func append(_ input: [SKCBaseSectionProtocol]) {
        insert(input, at: sections.count)
    }
    
    func delete(_ input: SKCBaseSectionProtocol) { remove(input) }
    func delete(_ input: [SKCBaseSectionProtocol]) { remove(input) }
    
    func remove(_ input: SKCBaseSectionProtocol) { remove([input]) }
    func remove(_ input: [SKCBaseSectionProtocol]) {
        guard !input.isEmpty else { return }
        
        var inputs   = Set(input.map(ObjectIdentifier.init))
        var indexs   = IndexSet()
        var sections = [SKCBaseSectionProtocol]()
        
        for item in self.sections.enumerated() {
            let object = ObjectIdentifier(item.element)
            if inputs.contains(object) {
                inputs.remove(object)
                indexs.update(with: item.offset)
            } else {
                sections.append(item.element)
            }
        }
        if let sectionView = sectionView,
           !configuration.replaceDeleteWithReloadData,
           !sections.isEmpty {
            publishers.sectionsSubject.send(offset(sections: sections, start: 0))
            sectionView.deleteSections(indexs)
        } else {
            reload(sections)
        }
    }
    
}

public extension SKCManager {
    
    private func set(request: SKRequestID, to store: inout [SKRequestID]) {
        store = store.filter({ $0.id != request.id && $0.isCancelled == false })
        store.append(request)
    }
    
    private func perform(of store: inout [SKRequestID]) {
        store.forEach { $0.perform() }
        clear(of: &store)
    }
    
    private func clear(of store: inout [SKRequestID]) {
        store = store.filter({ $0.isCancelled == false })
    }
    
}

public extension SKCManager {
    
    @discardableResult
    func scroll(to section: Int,
                row: Int = 0,
                at scrollPosition: UICollectionView.ScrollPosition? = nil,
                offset: CGPoint? = nil,
                animated: Bool = true) -> SKRequestID? {
        guard sections.indices.contains(section) else {
            return nil
        }
        let seciton = sections[section]
        return scroll(to: seciton, row: row, at: scrollPosition, offset: offset, animated: animated)
    }
    
    @discardableResult
    func scroll(to section: SKCBaseSectionProtocol,
                row: Int = 0,
                at scrollPosition: UICollectionView.ScrollPosition? = nil,
                offset: CGPoint? = nil,
                animated: Bool = true) -> SKRequestID? {
        if _scroll(to: section, row: row, at: scrollPosition, offset: offset, animated: animated) {
            return nil
        } else {
            let request = SKRequestID(id: "scroll") { [weak self] in
                guard let self = self else { return false }
                return _scroll(to: section, row: row, at: scrollPosition, offset: offset, animated: animated)
            }
            set(request: request, to: &afterLayoutSubviewsRequests)
            return request
        }
    }
    
    private func _scroll(to section: SKCBaseSectionProtocol,
                         row: Int,
                         at scrollPosition: UICollectionView.ScrollPosition? = nil,
                         offset: CGPoint? = nil,
                         animated: Bool) -> Bool {
        return section.scroll(to: row, at: scrollPosition, offset: offset, animated: animated)
    }
}

public extension SKCManager {
    
    func pick(_ updates: () -> Void, completion: ((_ flag: Bool) -> Void)? = nil) {
        sectionView?.performBatchUpdates(updates, completion: completion)
    }
    
    func reload() {
        sectionView?.reloadData()
    }
    
    func reload(_ section: SKCBaseSectionProtocol) {
        reload([section])
    }
    
    func reload(_ sections: [SKCBaseSectionProtocol]) {
        guard let sectionView = sectionView else {
            return
        }
        context.sectionView = nil
        context = .init(sectionView, manager: self)
        self.endDisplaySections.removeAll()
        self.sections
            .enumerated()
            .forEach({ item in
                self.endDisplaySections[item.offset] = item.element
            })
        self.publishers.sectionsSubject.send(bind(sections: sections, start: 0))
        security(check: sections)
        sectionView.reloadData()
    }
    
    func insert(_ input: [SKCBaseSectionProtocol], at: Int) {
        guard !input.isEmpty else { return }
        var sections = sections
        sections.insert(contentsOf: bind(sections: input, start: at), at: at)
        security(check: sections)
        if let sectionView = sectionView,
           !configuration.replaceInsertWithReloadData {
            publishers.sectionsSubject.send(sections)
            sectionView.insertSections(IndexSet(integersIn: at..<(at + input.count)))
        } else {
            reload(sections)
        }
    }
    
}

private extension SKCManager {
    
    /// 安全自检
    func security(check sections: @autoclosure () -> [SKCBaseSectionProtocol]) {
#if DEBUG
        for section in sections() {
            assert(section.sectionInjection != nil)
        }
#endif
    }
    
    func offset(sections: [SKCBaseSectionProtocol], start: Int) -> [SKCBaseSectionProtocol] {
        sections.enumerated().map { element in
            let section = element.element
            let offset = element.offset
            section.sectionInjection?.index = start + offset
            return section
        }
    }
    
    func bind(sections: [SKCBaseSectionProtocol], start: Int) -> [SKCBaseSectionProtocol] {
        return sections.enumerated().map({ element in
            let section = element.element
            let offset = element.offset
            
            section.sectionInjection = converts
                .sectionInjection
                .reduce(into: .init(index: start + offset, sectionView: context)) { result, convert in
                    result = convert(self, result)
                }
            
            if let sectionView = context.sectionView {
                section.config(sectionView: sectionView)
            }
            return section
        })
    }
    
}

#endif
