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

open class SingleTypeTableSection<Cell: UITableViewCell>: SectionDataSourcePrefetchingProtocol, SectionTableProtocol, SingleTypeSectionProtocol where Cell: ConfigurableView & LoadViewProtocol {
    
    public private(set) var models: [Cell.Model]
    public var publishers = SingleTypeSectionPublishers<Cell.Model, UITableViewHeaderFooterView>()
    
    public let selectedEvent = SectionDelegate<Cell.Model, Void>()
    public let selectedRowEvent = SectionDelegate<Int, Void>()
    public let willDisplayEvent = SectionDelegate<Int, Void>()
    /// cell 样式配置
    public let cellStyleEvent = SectionDelegate<(row: Int, cell: Cell), Void>()
    
    public let headerViewProvider = SectionDelegate<SingleTypeTableSection, UITableViewHeaderFooterView>()
    public let headerSizeProvider = SectionDelegate<UITableView, CGSize>()
    
    public let footerViewProvider = SectionDelegate<SingleTypeTableSection, UITableViewHeaderFooterView>()
    public let footerSizeProvider = SectionDelegate<UITableView, CGSize>()
    
    open var headerView: UITableViewHeaderFooterView? { headerViewProvider.call(self) }
    open var footerView: UITableViewHeaderFooterView? { footerViewProvider.call(self) }
    
    public var headerSize: CGSize { headerSizeProvider.call(sectionView) ?? .zero }
    public var footerSize: CGSize { footerSizeProvider.call(sectionView) ?? .zero }
    
    public var core: SectionState?
        
    public init(_ models: [Cell.Model] = []) {
        self.models = models
    }
    
    open func config(models: [Cell.Model]) {
        self.models = validate(models)
        reload()
    }
    
    public func itemSize(at row: Int) -> CGSize {
        let width = sectionView.bounds.width
        return Cell.preferredSize(limit: .init(width: width,
                                               height: sectionView.bounds.height),
                                  model: models[row])
    }
    
    open func config(sectionView: UITableView) {
        register(Cell.self)
    }
    
    open func item(at row: Int) -> UITableViewCell {
        let cell = dequeue(at: row) as Cell
        cell.config(models[row])
        cellStyleEvent.call((row: row, cell: cell))
        return cell
    }
    
}

/// 增删
public extension SingleTypeTableSection {
    
    func insert(_ models: [Cell.Model], at row: Int) {
        self.models.insert(contentsOf: models, at: row)
        insertItems(at: [row])
    }
    
    func remove(at rows: [Int]) {
        rows.sorted(by: >).forEach { index in
            models.remove(at: index)
        }
        deleteItems(at: rows)
    }
    
    
}
#endif
