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
    public var sections: LazyMapSequence<LazyFilterSequence<LazyMapSequence<LazySequence<[SectionDynamicType]>.Elements, SectionTableProtocol?>>, SectionTableProtocol> { reducer.state.types.lazy.compactMap({ $0.section as? SectionTableProtocol }) }
    
    private let dataSource = SectionTableViewDataSource()
    private let delegate = SectionTableViewDelegate()
    private let prefetchDataSource = SectionDataSourcePrefetching()

    public init(sectionView: UITableView) {
        environment = .init(sectionView: sectionView)
        
        sectionView.delegate = delegate
        sectionView.dataSource = dataSource
        sectionView.prefetchDataSource = prefetchDataSource
        
        delegate.sectionEvent.delegate(on: self) { (self, index) in
            return self.section(at: index)
        }
        
        dataSource.sectionEvent.delegate(on: self) { (self, index) in
            return self.section(at: index)
        }
        
        dataSource.count.delegate(on: self) { (self, _) in
            return self.sections.count
        }
            
        prefetchDataSource.sectionEvent.delegate(on: self) { (self, index) in
            return self.section(at: index) as? SectionDataSourcePrefetchingProtocol
        }
        
    }
    
    private func section(at index: Int) -> SectionTableProtocol {
        guard index >= 0, index < self.sections.count else {
            assertionFailure("无对应的 section index: \(index)")
            return PlaceholderSection()
        }
        return self.sections[index]
    }
    
    private class PlaceholderSection: SectionTableProtocol {
        func itemHeight(at row: Int) -> CGFloat { 0 }
        func config(sectionView: UITableView) {}
        func item(at row: Int) -> UITableViewCell { UITableViewCell() }
        var core: SectionState?
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
        case .insert(let indexSet):
            sectionView.insertSections(indexSet, with: animation)
        case .delete(let indexSet):
            sectionView.deleteSections(indexSet, with: animation)
        case .move(from: let from, to: let to):
            sectionView.moveSection(from, toSection: to)
        }
    }
    
}

public extension SectionTableManager {
    
    @MainActor
    func reload() {
        operational(reducer.reducer(action: .reload, environment: environment), with: .none)
    }
    
    @MainActor
    func update(_ sections: SectionTableProtocol..., with animation: UITableView.RowAnimation = .none) {
        update(sections, with: animation)
    }
    
    @MainActor
    func update(_ sections: [SectionTableProtocol], with animation: UITableView.RowAnimation = .none) {
        let update = reducer.reducer(action: .update(types: sections.map({ .section($0) })), environment: environment)
        sections.forEach({ $0.config(sectionView: sectionView) })
        operational(update, with: animation)
    }
    
    @MainActor
    func insert(_ sections: [SectionTableProtocol], at index: Int, with animation: UITableView.RowAnimation = .none) {
        let insert = reducer.reducer(action: .insert(types: sections.map({ .section($0) }), at: index), environment: environment)
        sections.forEach({ $0.config(sectionView: sectionView) })
        operational(insert, with: animation)
    }
    
    @MainActor
    func delete(_ sections: [SectionTableProtocol], with animation: UITableView.RowAnimation = .none) {
        operational(reducer.reducer(action: .delete(types: sections.map({ .section($0) })), environment: environment), with: animation)
    }
    
    @MainActor
    func move(from: SectionTableProtocol, to: SectionTableProtocol, with animation: UITableView.RowAnimation = .none) {
        operational(reducer.reducer(action: .move(from: .section(from), to: .section(to)), environment: environment), with: animation)
    }
    
}

#endif
