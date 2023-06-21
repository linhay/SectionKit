//
//  File.swift
//  
//
//  Created by linhey on 2022/8/11.
//

#if canImport(UIKit)
import UIKit
import Combine

public class SKCManager {
    
    public class SKPublishers {
        fileprivate lazy var sectionsSubject = CurrentValueSubject<[SKCBaseSectionProtocol], Never>([])
        public private(set) lazy var sectionsPublisher = sectionsSubject.eraseToAnyPublisher()
    }
    
    public struct Configuration {
        /// 将 reloadSections 操作替换为 reloadData 操作
        public var replaceReloadWithReloadData = false
        /// 将 insertSections 操作替换为 reloadData 操作
        public var replaceInsertWithReloadData = true
        /// 将 deleteSections 操作替换为 reloadData 操作
        public var replaceDeleteWithReloadData = false
    }

    public static var configuration = Configuration()
    public var configuration = SKCManager.configuration
    public private(set) lazy var publishers = SKPublishers()
    public private(set) weak var sectionView: UICollectionView?
    
    public var sections: [SKCBaseSectionProtocol] { publishers.sectionsSubject.value }
    public var scrollObserver: SKScrollViewDelegate { delegate }
    public private(set) lazy var prefetching = SKCViewDataSourcePrefetching { [weak self] section in
        self?.safe(section: section)
    }
    
    private lazy var endDisplaySections: [Int: SKCBaseSectionProtocol] = [:]
    private lazy var delegate = SKCViewDelegateFlowLayout { [weak self] indexPath in
        self?.safe(section: indexPath.section)
    } endDisplaySection: { [weak self] indexPath in
        self?.safe(section: indexPath.section)
    } sections: { [weak self] in
        return self?.sections.lazy.compactMap({ $0 as? SKCViewDelegateFlowLayoutProtocol }) ?? []
    }
    
    private lazy var dataSource = SKCDataSource { [weak self] indexPath in
        self?.safe(section: indexPath.section)
    } sections: { [weak self] in
        self?.sections ?? []
    }
    
    private lazy var context = SKCSectionInjection.SectionViewProvider(sectionView)
    
    public init(sectionView: UICollectionView) {
        self.sectionView = sectionView
        sectionView.delegate = delegate
        sectionView.dataSource = dataSource
        sectionView.prefetchDataSource = prefetching
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
    
    func pick(_ updates: () -> Void, completion: ((_ flag: Bool) -> Void)? = nil) {
        sectionView?.performBatchUpdates(updates, completion: completion)
    }
    
    func reload(_ section: SKCBaseSectionProtocol) {
        reload([section])
    }
    
    func reload(_ sections: [SKCBaseSectionProtocol]) {
        guard let sectionView = sectionView else {
            return
        }
        context.sectionView = nil
        context = .init(sectionView)
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
    
    func append(_ input: [SKCBaseSectionProtocol]) {
        insert(input, at: sections.count)
    }
    
}

private extension SKCManager {
    
    func safe<T>(section: Int) -> T? {
        guard sections.indices.contains(section) else {
            return nil
        }
        return sections[section] as? T
    }
    
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

            section.sectionInjection = .init(index: start + offset, sectionView: context)
                .add(action: .reloadData, event: { injection in
                    injection.sectionView?.reloadData()
                })
                .add(action: .reload, event: { injection in
                    /**
                     可以使用以下方式将 reloadSection 全局替换成 reloadData
                     SKCSectionInjection.configuration.setMapAction { action in
                     if action == .reload {
                     return .reloadData
                     }
                     return action
                     }
                     */
                    injection.sectionView?.reloadSections(IndexSet(integer: injection.index))
                })
                .add(action: .delete, event: { injection in
                    injection.sectionView?.deleteSections(IndexSet(integer: injection.index))
                })
            
            if let sectionView = context.sectionView {
                section.config(sectionView: sectionView)
            }
            return section
        })
    }

}

#endif
