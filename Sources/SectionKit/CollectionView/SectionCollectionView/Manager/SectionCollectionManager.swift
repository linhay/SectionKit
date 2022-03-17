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
        return dynamicTypes.lazy.map({ $0.section as! SectionCollectionDriveProtocol })
    }
    
    private let dataSource = SectionCollectionViewDataSource()
    private let delegate   = SectionCollectionViewDelegateFlowLayout()
    private let prefetchDataSource = SectionDataSourcePrefetching()
    
    private lazy var placeholderSection = PlaceholderSection()
    
    @MainActor
    public init(sectionView: UICollectionView) {
        environment = .init(sectionView: sectionView, reloadDataEvent: nil)
        environment.reloadDataEvent = { [weak self] in
            self?.reload()
        }
        
        sectionView.prefetchDataSource = prefetchDataSource
        sectionView.delegate = delegate
        sectionView.dataSource = dataSource
        
        prefetchDataSource.sectionEvent.delegate(on: self) { (self, index) in
            return self.section(at: index) as? SectionDataSourcePrefetchingProtocol
        }
        
        dataSource.sectionsEvent.delegate(on: self) { (self, _) in
            return self.sections
        }
        dataSource.sectionEvent.delegate(on: self) { (self, index) in
            return self.section(at: index)
        }
        
        delegate.sectionsEvent.delegate(on: self) { (self, _) in
            return self.sections
        }
        delegate.sectionEvent.delegate(on: self) { (self, index) in
            return self.section(at: index)
        }
    }
    
    private func section(at index: Int) -> SectionCollectionDriveProtocol {
        guard index >= 0, index < self.sections.count else {
            return placeholderSection
        }
        return self.sections[index]
    }
    
    private class PlaceholderSection: SectionCollectionDriveProtocol {
        func config(sectionView: UICollectionView) {}
        func item(at row: Int) -> UICollectionViewCell { UICollectionViewCell() }
        var core: SectionState?
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
        case .compositional(let configuration):
            return UICollectionViewCompositionalLayout(sectionProvider: { [weak self] index, environment in
                guard let self = self,
                      let section = self.dynamicTypes[index].section as? SectionCollectionCompositionalLayoutProtocol else {
                    assertionFailure("compositional 模式下 所有 section 都需要遵守 SectionCollectionCompositionalLayoutProtocol")
                    return nil
                }
                return section.compositionalLayout(environment: environment)
            }, configuration: configuration)
        case .custom(let layout):
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
        case .insert(let indexSet):
            sectionView.insertSections(indexSet)
        case .delete(let indexSet):
            sectionView.deleteSections(indexSet)
        case .move(from: let from, to: let to):
            sectionView.moveSection(from, toSection: to)
        }
    }
    
}

public extension SectionCollectionManager {
    
    @MainActor
    func pick(_ updates: (() -> Void), completion: ((Bool) -> Void)? = nil) {
        isPicking = true
        updates()
        isPicking = false
        reload()
        completion?(true)
    }
    
    @MainActor
    func reload() {
        let action = reducer.reducer(action: .reload, environment: environment)
        operational(action)
    }
    
}

public extension SectionCollectionManager {
    
    @MainActor
    func update<Section: SectionWrapperProtocol>(_ sections: Section...) {
        update(sections)
    }
    
    @MainActor
    func update<Section: SectionWrapperProtocol>(_ sections: [Section]) {
        update(sections.map(\.eraseToDynamicType))
    }
    
    @MainActor
    func insert<Section: SectionWrapperProtocol>(_ sections: Section..., at index: Int) {
        insert(sections, at: index)
    }
    
    @MainActor
    func insert<Section: SectionWrapperProtocol>(_ sections: [Section], at index: Int) {
        insert(sections.map(\.eraseToDynamicType), at: index)
    }
    
    @MainActor
    func delete<Section: SectionWrapperProtocol>(_ sections: Section...) {
        delete(sections)
    }
    
    @MainActor
    func delete<Section: SectionWrapperProtocol>(_ sections: [Section]) {
        delete(sections.map(\.eraseToDynamicType))
    }
    
    @MainActor
    func move<Section1: SectionWrapperProtocol, Section2: SectionWrapperProtocol>(from: Section1, to: Section2) {
        move(from: from.eraseToDynamicType, to: to.eraseToDynamicType)
    }
    
}

public extension SectionCollectionManager {
    
    @MainActor
    func update(_ sections: SectionCollectionDriveProtocol...) {
        update(sections)
    }
    
    @MainActor
    func update(_ sections: [SectionCollectionDriveProtocol]) {
        update(sections.map(\.eraseToDynamicType))
    }
    
    @MainActor
    func insert(_ sections: SectionCollectionDriveProtocol..., at index: Int) {
        insert(sections, at: index)
    }
    
    @MainActor
    func insert(_ sections: [SectionCollectionDriveProtocol], at index: Int) {
        insert(sections.map(\.eraseToDynamicType), at: index)
    }
    
    @MainActor
    func delete(_ sections: SectionCollectionDriveProtocol...) {
        delete(sections)
    }
    
    @MainActor
    func delete(_ sections: [SectionCollectionDriveProtocol]) {
        delete(sections.map(\.eraseToDynamicType))
    }
    
    @MainActor
    func move(from: SectionCollectionDriveProtocol, to: SectionCollectionDriveProtocol) {
        move(from: from.eraseToDynamicType, to: to.eraseToDynamicType)
    }
    
}

public extension SectionCollectionManager {
    
    @MainActor
    func update(_ types: [SectionDynamicType]) {
        let update = reducer.reducer(action: .update(types: types), environment: environment)
        types.map(\.section).compactMap({ $0 as? SectionCollectionDriveProtocol }).forEach({ $0.config(sectionView: sectionView) })
        operational(update)
    }
    
    @MainActor
    func insert(_ types: [SectionDynamicType], at index: Int) {
        let insert = reducer.reducer(action: .insert(types: types, at: index), environment: environment)
        types.map(\.section).compactMap({ $0 as? SectionCollectionDriveProtocol }).forEach({ $0.config(sectionView: sectionView) })
        operational(insert)
    }
    
    @MainActor
    func delete(_ types: [SectionDynamicType]) {
        operational(reducer.reducer(action: .delete(types: types), environment: environment))
    }
    
    @MainActor
    func move(from: SectionDynamicType, to: SectionDynamicType) {
        operational(reducer.reducer(action: .move(from: from, to: to), environment: environment))
    }
    
}

#endif

