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

public class SectionCollectionManager {
    private var environment: SectionReducer.Environment<UICollectionView>
    private var reducer = SectionReducer(state: .init())
    private var isPicking = false
    
    public var sectionView: UICollectionView { environment.sectionView }
    public var dynamicTypes: [SectionDynamicType] { reducer.state.types }
    public var sections: LazyMapSequence<LazySequence<[SectionDynamicType]>.Elements, SectionCollectionDriveProtocol> {
        return dynamicTypes.lazy.map { $0.section as! SectionCollectionDriveProtocol }
    }
    
    private let dataSource = SectionCollectionViewDataSource()
    private let delegate = SectionCollectionViewDelegateFlowLayout()
    private let prefetchDataSource = SectionDataSourcePrefetching()
    
    private lazy var placeholderSection = PlaceholderSection()
    
    public init(sectionView: UICollectionView) {
        environment = .init(sectionView: sectionView, reloadDataEvent: nil)
        environment.reloadDataEvent = { [weak self] in
            self?.reload()
        }
        
        sectionView.prefetchDataSource = prefetchDataSource
        sectionView.delegate = delegate
        sectionView.dataSource = dataSource
        
        prefetchDataSource.sectionEvent.delegate(on: self) { (self, index) in
            self.section(at: index) as? SectionDataSourcePrefetchingProtocol
        }
        
        dataSource.sectionsEvent.delegate(on: self) { (self, _) in
            self.sections
        }
        dataSource.sectionEvent.delegate(on: self) { (self, index) in
            self.section(at: index)
        }
        
        delegate.sectionsEvent.delegate(on: self) { (self, _) in
            self.sections
        }
        delegate.sectionEvent.delegate(on: self) { (self, index) in
            self.section(at: index)
        }
    }
    
    private func section(at index: Int) -> SectionCollectionDriveProtocol {
        guard index >= 0, index < sections.count else {
            return placeholderSection
        }
        return sections[index]
    }
    
    private class PlaceholderSection: SectionCollectionDriveProtocol {
        func supplementary(kind _: SectionSupplementaryKind, at _: Int) -> UICollectionReusableView? {
            nil
        }
        
        func config(sectionView _: UICollectionView) {}
        func item(at _: Int) -> UICollectionViewCell { UICollectionViewCell() }
        var sectionState: SectionState?
        let itemCount: Int = 0
    }
}

public extension SectionCollectionManager {
    enum Layout {
        case flow
        case compositional(UICollectionViewCompositionalLayoutConfiguration = UICollectionViewCompositionalLayoutConfiguration())
        case custom(UICollectionViewFlowLayout)
    }
    
    func set(layout: Layout, animated: Bool = true) {
        sectionView.setCollectionViewLayout(collectionViewLayout(layout), animated: animated)
    }
    
    private func collectionViewLayout(_ layout: Layout) -> UICollectionViewLayout {
        switch layout {
        case .flow:
            return UICollectionViewFlowLayout()
        case let .compositional(configuration):
            return UICollectionViewCompositionalLayout(sectionProvider: { [weak self] index, environment in
                guard let self = self,
                      let section = self.dynamicTypes[index].section as? SectionCollectionCompositionalLayoutProtocol
                else {
                    assertionFailure("compositional 模式下 所有 section 都需要遵守 SectionCollectionCompositionalLayoutProtocol")
                    return nil
                }
                return section.compositionalLayout(environment: environment)
            }, configuration: configuration)
        case let .custom(layout):
            return layout
        }
    }
}

private extension SectionCollectionManager {
    func operational(_ refresh: SectionReducer.OutputAction) {
        guard isPicking == false else {
            return
        }
        
        switch refresh {
        case .none:
            break
        case .reload:
            sectionView.reloadData()
        case let .insert(indexSet):
            sectionView.insertSections(indexSet)
        case let .delete(indexSet):
            sectionView.deleteSections(indexSet)
        case let .move(from: from, to: to):
            sectionView.moveSection(from, toSection: to)
        }
    }
}

public extension SectionCollectionManager {
    func pick(_ updates: () -> Void, completion: ((Bool) -> Void)? = nil) {
        isPicking = true
        updates()
        isPicking = false
        reload()
        completion?(true)
    }
    
    func pick(_ updates: @escaping (() async throws -> Void), completion: ((Bool) async throws -> Void)? = nil) {
        Task {
            isPicking = true
            try await updates()
            isPicking = false
            reload()
            try await completion?(true)
        }
    }
    
    func reload() {
        let action = reducer.reducer(action: .reload, environment: environment)
        operational(action)
    }
}

public extension SectionCollectionManager {
    func update<Section: SectionWrapperProtocol>(_ sections: Section...) {
        update(sections)
    }
    
    func update<Section: SectionWrapperProtocol>(_ sections: [Section]) {
        update(sections.map(\.eraseToDynamicType))
    }
    
    func append<Section: SectionWrapperProtocol>(_ sections: Section...) {
        append(sections)
    }
    
    func append<Section: SectionWrapperProtocol>(_ sections: [Section]) {
        append(sections.map(\.eraseToDynamicType))
    }
    
    func insert<Section: SectionWrapperProtocol>(_ sections: Section..., at index: Int) {
        insert(sections, at: index)
    }
    
    func insert<Section: SectionWrapperProtocol>(_ sections: [Section], at index: Int) {
        insert(sections.map(\.eraseToDynamicType), at: index)
    }
    
    func delete<Section: SectionWrapperProtocol>(_ sections: Section...) {
        delete(sections)
    }
    
    func delete<Section: SectionWrapperProtocol>(_ sections: [Section]) {
        delete(sections.map(\.eraseToDynamicType))
    }
    
    func move<Section1: SectionWrapperProtocol, Section2: SectionWrapperProtocol>(from: Section1, to: Section2) {
        move(from: from.eraseToDynamicType, to: to.eraseToDynamicType)
    }
}

public extension SectionCollectionManager {
    func update(_ sections: SectionCollectionDriveProtocol...) {
        update(sections)
    }
    
    func update(_ sections: [SectionCollectionDriveProtocol]) {
        update(sections.map(\.eraseToDynamicType))
    }
    
    func append(_ sections: SectionCollectionDriveProtocol...) {
        append(sections)
    }
    
    func append(_ sections: [SectionCollectionDriveProtocol]) {
        append(sections.map(\.eraseToDynamicType))
    }
    
    func insert(_ sections: SectionCollectionDriveProtocol..., at index: Int) {
        insert(sections, at: index)
    }
    
    func insert(_ sections: [SectionCollectionDriveProtocol], at index: Int) {
        insert(sections.map(\.eraseToDynamicType), at: index)
    }
    
    func delete(_ sections: SectionCollectionDriveProtocol...) {
        delete(sections)
    }
    
    func delete(_ sections: [SectionCollectionDriveProtocol]) {
        delete(sections.map(\.eraseToDynamicType))
    }
    
    func move(from: SectionCollectionDriveProtocol, to: SectionCollectionDriveProtocol) {
        move(from: from.eraseToDynamicType, to: to.eraseToDynamicType)
    }
}

public extension SectionCollectionManager {
    func update(_ types: [SectionDynamicType]) {
        let update = reducer.reducer(action: .update(types: types), environment: environment)
        types.map(\.section).compactMap { $0 as? SectionCollectionDriveProtocol }.forEach { $0.config(sectionView: sectionView) }
        operational(update)
    }
    
    func append(_ types: [SectionDynamicType]) {
        insert(types, at: dynamicTypes.count - 1)
    }
    
    func insert(_ types: [SectionDynamicType], at index: Int) {
        let insert = reducer.reducer(action: .insert(types: types, at: index), environment: environment)
        types.map(\.section).compactMap { $0 as? SectionCollectionDriveProtocol }.forEach { $0.config(sectionView: sectionView) }
        operational(insert)
    }
    
    func delete(_ types: [SectionDynamicType]) {
        operational(reducer.reducer(action: .delete(types: types), environment: environment))
    }
    
    func move(from: SectionDynamicType, to: SectionDynamicType) {
        operational(reducer.reducer(action: .move(from: from, to: to), environment: environment))
    }
}

#endif
