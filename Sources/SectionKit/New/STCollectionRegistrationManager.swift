//
//  File.swift
//  
//
//  Created by linhey on 2022/8/13.
//

import UIKit

public class STCollectionRegistrationManager {
    
    public lazy var sections: [STCollectionRegistrationSectionProtocol] = []
    public lazy var sectionsStore: [Int: STCollectionRegistrationSectionProtocol] = [:]
    
    private var lock = false
    private var waitSections: [STCollectionRegistrationSectionProtocol]?

    private lazy var delegate = STCollectionViewDelegateFlowLayout { [weak self] indexPath in
        return self?.sectionsStore[indexPath.section]
    } sections: { [weak self] in
        return self?.sections ?? []
    }
    
    private lazy var dataSource = STCollectionDataSource { [weak self] indexPath in
        self?.sectionsStore[indexPath.section]
    } sections: { [weak self] in
        self?.sections ?? []
    }
    
    private lazy var prefetching = STCollectionViewDataSourcePrefetching { [weak self] section in
        self?.sectionsStore[section] as? STCollectionViewDataSourcePrefetchingProtocol
    }
    
    public weak var sectionView: UICollectionView?
    
    private lazy var context = STCollectionSectionContext.SectionViewProvider(sectionView)
    
    public init(sectionView: UICollectionView) {
        self.sectionView = sectionView
        sectionView.delegate = delegate
        sectionView.dataSource = dataSource
        sectionView.prefetchDataSource = prefetching
    }
    
}

public extension STCollectionRegistrationManager {
    
    func insert(_ input: STCollectionRegistrationSectionProtocol, at: Int) {
        insert([input], at: at)
    }
    func insert(_ input: [any STCollectionRegistrationSectionProtocol], at: Int) {
        var sections = (waitSections ?? sections)
        sections.insert(contentsOf: input, at: at)
        update(sections)
    }
    
    func insert(_ input: STCollectionRegistrationSectionProtocol, before: STCollectionRegistrationSectionProtocol) {
        insert([input], before: before)
    }
    func insert(_ input: [any STCollectionRegistrationSectionProtocol], before: STCollectionRegistrationSectionProtocol) {
        guard let index = (waitSections ?? sections).firstIndex(where: { $0 === before }) else {
            return
        }
        insert(input, at: index)
    }
    
    func insert(_ input: STCollectionRegistrationSectionProtocol, after: STCollectionRegistrationSectionProtocol) {
        insert([input], after: after)
    }
    func insert(_ input: [any STCollectionRegistrationSectionProtocol], after: STCollectionRegistrationSectionProtocol) {
        guard let index = (waitSections ?? sections).firstIndex(where: { $0 === after }) else {
            return
        }
        insert(input, at: index + 1)
    }
    
    func append(_ input: STCollectionRegistrationSectionProtocol) { append([input]) }
    func append(_ input: [any STCollectionRegistrationSectionProtocol]) { update((waitSections ?? sections) + input) }
    
    func remove(_ input: [any STCollectionRegistrationSectionProtocol]) {
        let IDs = input.map({ ObjectIdentifier($0) })
        let sections = (waitSections ?? sections).filter({ !IDs.contains(ObjectIdentifier($0)) })
        update(sections)
    }
    func remove(_ input: STCollectionRegistrationSectionProtocol) { remove([input]) }
    
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
    
    func update(_ sections: [any STCollectionRegistrationSectionProtocol]) {
        
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
            
            /// 存储上一次 context 待函数结束自动释放
            let tempContext = context
            context = .init(sectionView)
            
            sections.enumerated().forEach { element in
                let section = element.element
                section.sectionState = .init(index: element.offset, sectionView: context)
                section.config(sectionView: sectionView)
            }
            
            if self.sections.isEmpty {
                self.sections = sections
                self.sectionsStore.removeAll()
                for section in sections {
                    if let index = section.sectionState?.index {
                        self.sectionsStore[index] = section
                    }
                }
                self.sectionView?.reloadData()
                return
            }
            
            let result = sections.difference(from: self.sections) { lhs, rhs in
                return lhs === rhs
            }
            
            if !result.removals.isEmpty {
                var removeIndexSet = IndexSet()
                for changed in result.removals.reversed() {
                    switch changed {
                    case let .remove(offset: offset, element: _, associatedWith: _):
                        removeIndexSet.update(with: offset)
                        self.sections.remove(at: offset)
                    default:
                        assertionFailure()
                    }
                }
                
                await pick {
                    sectionView.deleteSections(removeIndexSet)
                }
            }
            
            self.sections = sections
            self.sectionsStore.removeAll()
            for section in sections {
                if let index = section.sectionState?.index {
                    self.sectionsStore[index] = section
                }
            }
            
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

