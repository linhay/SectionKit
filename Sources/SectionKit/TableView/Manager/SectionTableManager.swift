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

public class SectionTableManager {
    private var environment: SectionReducer.Environment<UITableView>
    private var reducer = SectionReducer(state: .init())
    
    var sectionView: UITableView { environment.sectionView }
    public var dynamicTypes: [SectionDynamicType] { reducer.state.types }
    public var sections: LazyMapSequence<LazyFilterSequence<LazyMapSequence<LazySequence<[SectionDynamicType]>.Elements, SectionTableProtocol?>>, SectionTableProtocol> { reducer.state.types.lazy.compactMap { $0.section as? SectionTableProtocol } }
    
    private let dataSource = SectionTableViewDataSource()
    private let delegate = SectionTableViewDelegate()
    private let prefetchDataSource = SectionDataSourcePrefetching()
    
    public init(sectionView: UITableView) {
        environment = .init(sectionView: sectionView)
        
        sectionView.delegate = delegate
        sectionView.dataSource = dataSource
        sectionView.prefetchDataSource = prefetchDataSource
        
        delegate.sectionEvent.delegate(on: self) { (self, index) in
            self.section(at: index)
        }
        
        dataSource.sectionEvent.delegate(on: self) { (self, index) in
            self.section(at: index)
        }
        
        dataSource.count.delegate(on: self) { (self, _) in
            self.sections.count
        }
        
        prefetchDataSource.sectionEvent.delegate(on: self) { (self, index) in
            self.section(at: index) as? SectionDataSourcePrefetchingProtocol
        }
    }
    
    private func section(at index: Int) -> SectionTableProtocol {
        guard index >= 0, index < sections.count else {
            assertionFailure("无对应的 section index: \(index)")
            return PlaceholderSection()
        }
        return sections[index]
    }
    
    private class PlaceholderSection: SectionTableProtocol {
        var sectionState: SectionState?
        func itemSize(at _: Int) -> CGSize { .zero }
        func item(at _: Int) -> UITableViewCell { UITableViewCell() }
        func config(sectionView _: UITableView) {}
        let itemCount: Int = 0
    }
}

private extension SectionTableManager {
    func operational(_ refresh: SectionReducer.OutputAction, with animation: UITableView.RowAnimation) {
        switch refresh {
        case .none:
            break
        case .reload:
            sectionView.reloadData()
        case let .insert(indexSet):
            sectionView.insertSections(indexSet, with: animation)
        case let .delete(indexSet):
            sectionView.deleteSections(indexSet, with: animation)
        case let .move(from: from, to: to):
            sectionView.moveSection(from, toSection: to)
        }
    }
}

public extension SectionTableManager {
    func update<Section: SectionWrapperProtocol>(_ sections: Section...) {
        update(sections)
    }
    
    func update<Section: SectionWrapperProtocol>(_ sections: [Section]) {
        update(sections.map(\.eraseToDynamicType))
    }
    
    func append<Section: SectionWrapperProtocol>(_ sections: Section..., with animation: UITableView.RowAnimation = .automatic) {
        append(sections, with: animation)
    }
    
    func append<Section: SectionWrapperProtocol>(_ sections: [Section], with animation: UITableView.RowAnimation = .automatic) {
        append(sections.map(\.eraseToDynamicType), with: animation)
    }
    
    func insert<Section: SectionWrapperProtocol>(_ sections: Section..., at index: Int, with animation: UITableView.RowAnimation = .automatic) {
        insert(sections, at: index, with: animation)
    }
    
    func insert<Section: SectionWrapperProtocol>(_ sections: [Section], at index: Int, with animation: UITableView.RowAnimation = .automatic) {
        insert(sections.map(\.eraseToDynamicType), at: index, with: animation)
    }
    
    func delete<Section: SectionWrapperProtocol>(_ sections: Section..., with animation: UITableView.RowAnimation = .automatic) {
        delete(sections, with: animation)
    }
    
    func delete<Section: SectionWrapperProtocol>(_ sections: [Section], with animation: UITableView.RowAnimation = .automatic) {
        delete(sections.map(\.eraseToDynamicType), with: animation)
    }
    
    func move<Section1: SectionWrapperProtocol, Section2: SectionWrapperProtocol>(from: Section1, to: Section2) {
        move(from: from.eraseToDynamicType, to: to.eraseToDynamicType)
    }
}

public extension SectionTableManager {
    func update(_ sections: SectionCollectionDriveProtocol...) {
        update(sections)
    }
    
    func update(_ sections: [SectionCollectionDriveProtocol]) {
        update(sections.map(\.eraseToDynamicType))
    }
    
    func append(_ sections: SectionCollectionDriveProtocol..., with animation: UITableView.RowAnimation = .automatic) {
        append(sections, with: animation)
    }
    
    func append(_ sections: [SectionCollectionDriveProtocol], with animation: UITableView.RowAnimation = .automatic) {
        append(sections.map(\.eraseToDynamicType), with: animation)
    }
    
    func insert(_ sections: SectionCollectionDriveProtocol..., at index: Int, with animation: UITableView.RowAnimation = .automatic) {
        insert(sections, at: index, with: animation)
    }
    
    func insert(_ sections: [SectionCollectionDriveProtocol], at index: Int, with animation: UITableView.RowAnimation = .automatic) {
        insert(sections.map(\.eraseToDynamicType), at: index, with: animation)
    }
    
    func delete(_ sections: SectionCollectionDriveProtocol..., with animation: UITableView.RowAnimation = .automatic) {
        delete(sections, with: animation)
    }
    
    func delete(_ sections: [SectionCollectionDriveProtocol], with animation: UITableView.RowAnimation = .automatic) {
        delete(sections.map(\.eraseToDynamicType), with: animation)
    }
    
    func move(from: SectionCollectionDriveProtocol, to: SectionCollectionDriveProtocol) {
        move(from: from.eraseToDynamicType, to: to.eraseToDynamicType)
    }
}

public extension SectionTableManager {
    func update(_ types: [SectionDynamicType]) {
        let update = reducer.reducer(action: .update(types: types), environment: environment)
        types.map(\.section).compactMap { $0 as? SectionTableProtocol }.forEach { $0.config(sectionView: sectionView) }
        operational(update, with: .none)
    }
    
    func append(_ types: [SectionDynamicType], with _: UITableView.RowAnimation = .automatic) {
        insert(types, at: dynamicTypes.count - 1)
    }
    
    func insert(_ types: [SectionDynamicType], at index: Int, with animation: UITableView.RowAnimation = .automatic) {
        let insert = reducer.reducer(action: .insert(types: types, at: index), environment: environment)
        types.map(\.section).compactMap { $0 as? SectionTableProtocol }.forEach { $0.config(sectionView: sectionView) }
        operational(insert, with: animation)
    }
    
    func delete(_ types: [SectionDynamicType], with animation: UITableView.RowAnimation = .automatic) {
        operational(reducer.reducer(action: .delete(types: types), environment: environment), with: animation)
    }
    
    func move(from: SectionDynamicType, to: SectionDynamicType) {
        operational(reducer.reducer(action: .move(from: from, to: to), environment: environment), with: .automatic)
    }
}

#endif
