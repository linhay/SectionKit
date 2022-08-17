//
//  File.swift
//  
//
//  Created by linhey on 2022/8/13.
//

import UIKit

public class STCollectionRegistrationManager {
    
    public lazy var sections: [SKCRegistrationSectionProtocol] = []
    public lazy var sectionsStore: [Int: SKCRegistrationSectionProtocol] = [:]
    
    private var lock = false
    private var waitSections: [SKCRegistrationSectionProtocol]?
    
    private lazy var delegate = STCollectionViewDelegateFlowLayout { [weak self] indexPath in
        guard let self = self, self.sections.indices.contains(indexPath.section) else {
            return nil
        }
        return self.sections[indexPath.section]
    } endDisplaySection: { [weak self] indexPath in
        guard let self = self else { return nil }
        return self.sectionsStore[indexPath.section] ?? self.sections[indexPath.section]
    } sections: { [weak self] in
        return self?.sections ?? []
    }
    
    private lazy var dataSource = STCollectionDataSource { [weak self] indexPath in
        self?.sections[indexPath.section]
    } sections: { [weak self] in
        self?.sections ?? []
    }
    
    private lazy var prefetching = STCollectionViewDataSourcePrefetching { [weak self] section in
        self?.sections[section] as? STCollectionViewDataSourcePrefetchingProtocol
    }
    
    public weak var sectionView: UICollectionView?
    
    private lazy var context = STCollectionSectionInjection.SectionViewProvider(sectionView)
    
    public init(sectionView: UICollectionView) {
        self.sectionView = sectionView
        sectionView.delegate = delegate
        sectionView.dataSource = dataSource
        sectionView.prefetchDataSource = prefetching
    }
    
}

public extension STCollectionRegistrationManager {
    
    func insert(_ input: SKCRegistrationSectionProtocol, at: Int) {
        insert([input], at: at)
    }
    func insert(_ input: [any SKCRegistrationSectionProtocol], at: Int) {
        var sections = (waitSections ?? sections)
        sections.insert(contentsOf: input, at: at)
        update(sections)
    }
    
    func insert(_ input: SKCRegistrationSectionProtocol, before: SKCRegistrationSectionProtocol) {
        insert([input], before: before)
    }
    func insert(_ input: [any SKCRegistrationSectionProtocol], before: SKCRegistrationSectionProtocol) {
        guard let index = (waitSections ?? sections).firstIndex(where: { $0 === before }) else {
            return
        }
        insert(input, at: index)
    }
    
    func insert(_ input: SKCRegistrationSectionProtocol, after: SKCRegistrationSectionProtocol) {
        insert([input], after: after)
    }
    func insert(_ input: [any SKCRegistrationSectionProtocol], after: SKCRegistrationSectionProtocol) {
        guard let index = (waitSections ?? sections).firstIndex(where: { $0 === after }) else {
            return
        }
        insert(input, at: index + 1)
    }
    
    func append(_ input: SKCRegistrationSectionProtocol) { append([input]) }
    func append(_ input: [any SKCRegistrationSectionProtocol]) { update((waitSections ?? sections) + input) }
    
    func remove(_ input: [any SKCRegistrationSectionProtocol]) {
        let IDs = input.map({ ObjectIdentifier($0) })
        let sections = (waitSections ?? sections).filter({ !IDs.contains(ObjectIdentifier($0)) })
        difference(sections)
    }
    func remove(_ input: SKCRegistrationSectionProtocol) { remove([input]) }
    
    func update(_ sections: [any SKCRegistrationSectionProtocol]) {
        difference(sections)
    }
    
    func update(_ section: any SKCRegistrationSectionProtocol) {
        difference([section])
    }
    
    @MainActor
    private func pick(_ block: () -> Void) async {
        await withUnsafeContinuation { continuation in
            sectionView?.performBatchUpdates {
                block()
            } completion: { _ in
                continuation.resume()
            }
        }
    }
    
}

private extension STCollectionRegistrationManager {
    
    func difference(_ sections: [any SKCRegistrationSectionProtocol], function: StaticString = #function) {
        
        guard !lock else {
            waitSections = sections
            return
        }
        lock = true
        
        Task { @MainActor in
            defer {
                lock = false
                if let section = waitSections {
                    update(section)
                    waitSections = nil
                }
            }
            guard let sectionView = sectionView else {
                return
            }
            
            self.sectionsStore.removeAll()
            
            /// 存储上一次 context 待函数结束自动释放
            let tempContext = context
            context = .init(sectionView)
            
            sections.enumerated().forEach { element in
                let section = element.element
                let injection = SKCRegistrationSectionInjection(index: element.offset, sectionView: context)
                section.registrationSectionInjection = injection
                section.prepare(injection: injection)
                section.config(sectionView: sectionView)
            }
            
            if self.sections.isEmpty {
                self.sections = sections
                self.sectionView?.reloadData()
                return
            }
            
            let result = sections.difference(from: self.sections) { lhs, rhs in
                return lhs === rhs
            }
            
            if !result.removals.isEmpty {
                var indexSet = [Int]()
                for changed in result.removals.reversed() {
                    switch changed {
                    case let .remove(offset: offset, element: element, associatedWith: _):
                        if let index = element.sectionInjection?.index {
                            self.sectionsStore[index] = element
                        }
                        indexSet.append(offset)
                    default:
                        assertionFailure()
                    }
                }
                await pick {
                    indexSet.forEach { offset in
                        self.sections.remove(at: offset)
                    }
                    sectionView.deleteSections(.init(indexSet))
                }
            }
            
            self.sections = sections
            
            if !result.insertions.isEmpty {
                var insertIndexSet = IndexSet()
                for changed in result.insertions {
                    switch changed {
                    case let .insert(offset: offset, element: _, associatedWith: _):
                        insertIndexSet.update(with: offset)
                    default:
                        assertionFailure()
                    }
                }
                
                await pick {
                    sectionView.insertSections(insertIndexSet)
                }
            }
        }
    }
    
}
