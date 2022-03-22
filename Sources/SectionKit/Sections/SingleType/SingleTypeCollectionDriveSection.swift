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

open class SingleTypeCollectionDriveSection<Cell: UICollectionViewCell & LoadViewProtocol & ConfigurableView>: SingleTypeSectionProtocol, SectionCollectionDequeueProtocol, SectionCollectionDriveProtocol {    
    
    public private(set) var models: [Cell.Model]
    
    public typealias Publishers = SingleTypeSectionPublishers<Cell.Model, UICollectionReusableView>
    
    public let publishers = Publishers()
    public let selectedEvent = SectionDelegate<Cell.Model, Void>()
    public let selectedRowEvent = SectionDelegate<Int, Void>()
    public let willDisplayEvent = SectionDelegate<Int, Void>()
    
    /// cell 样式配置
    public let cellStyleProvider = SectionDelegate<(row: Int, cell: Cell), Void>()
    
    open var core: SectionState?
    
    private var cancellables = Set<AnyCancellable>()
    
    public init(_ models: [Cell.Model] = []) {
        self.models = models
    }
    
    public convenience init(count: Int) where Cell.Model == Void {
        self.init(repeating: (), count: count)
    }
    
    public convenience init(repeating: Cell.Model, count: Int) {
        self.init(.init(repeating: repeating, count: count))
    }
    
    open func config(models: [Cell.Model]) {
        self.models = validate(models)
        reload()
    }
    
    open func config(sectionView: UICollectionView) {
        register(Cell.self)
    }
    
    open func item(at row: Int) -> UICollectionViewCell {
        let cell = dequeue(at: row) as Cell
        cell.config(models[row])
        cellStyleProvider.call((row: row, cell: cell))
        return cell
    }
    
    open func cellForTypeItem(at row: Int) -> Cell? {
        return cellForItem(at: row) as? Cell
    }
    
    open var visibleTypeItems: [Cell] {
        return visibleCells.compactMap({ $0 as? Cell })
    }
    
    public func supplementaryView(willDisplay view: UICollectionReusableView, forElementKind elementKind: String, at row: Int) {
        let result = Publishers.SupplementaryResult(view: view, elementKind: elementKind, row: row)
        publishers.supplementary._willDisplay.send(result)
    }
    
    public func supplementaryView(didEndDisplaying view: UICollectionReusableView, forElementKind elementKind: String, at row: Int) {
        let result = Publishers.SupplementaryResult(view: view, elementKind: elementKind, row: row)
        publishers.supplementary._didEndDisplaying.send(result)
    }
    
}

/// 增删
extension SingleTypeCollectionDriveSection {
    
    public func insert(_ models: [Cell.Model], at row: Int) {
        self.models.insert(contentsOf: models, at: row)
        insertItems(at: [row])
    }
    
    public func remove(at rows: [Int]) {
        rows.sorted(by: >).forEach { index in
            models.remove(at: index)
        }
        deleteItems(at: rows)
    }
    
}
#endif
