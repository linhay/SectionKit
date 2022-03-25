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

typealias SingleTypeSectionProtocol = SingleTypeSectionDataProtocol & SingleTypeSectionEventProtocol

public protocol SingleTypeSectionDataProtocol {
    
    associatedtype Cell: SectionLoadViewProtocol & SectionConfigurableModelProtocol
    
    var models: [Cell.Model] { get }
    func config(models: [Cell.Model])
    func validate(_ models: [Cell.Model]) -> [Cell.Model]
    
    /// 该部分接口与 Array 保持一致
    func insert(_ models: [Cell.Model], at row: Int)
    func remove(at rows: [Int])
}

public extension SingleTypeSectionDataProtocol {

    var itemCount: Int { models.count }

    /// 过滤无效数据
    func validate(_ models: [Cell.Model]) -> [Cell.Model] {
        models.filter({ Cell.validate($0) })
    }
    
}

public extension SingleTypeSectionDataProtocol {
    
    func append(_ data: Cell.Model...) {
        append(data)
    }
    
    func append(_ data: [Cell.Model]) {
        insert(data, at: models.count)
    }
    
    func insert(_ data: Cell.Model..., at row: Int) {
        insert(data, at: row)
    }
    
    func remove(at row: Int) {
        remove(at: [row])
    }
    
    func removeALl() {
        remove(at: .init(0..<models.count))
    }
    
    func remove(_ model: Cell.Model) where Cell.Model: AnyObject {
        let indexs = models.enumerated().compactMap { (offset, element) in
            return element === model ? offset : nil
        }
        remove(at: indexs)
    }
    
    func remove(_ model: Cell.Model) where Cell.Model: Equatable {
        let indexs = models.enumerated().compactMap { (offset, element) in
            return element == model ? offset : nil
        }
        remove(at: indexs)
    }

}

public protocol SingleTypeSectionEventProtocol {
    
    associatedtype Cell: SectionLoadViewProtocol & SectionConfigurableModelProtocol
    associatedtype ReusableView
    
    var models: [Cell.Model] { get }
    
    var publishers: SingleTypeSectionPublishers<Cell.Model, ReusableView> { get }
    var selectedEvent: SectionDelegate<Cell.Model, Void> { get }
    var selectedRowEvent: SectionDelegate<Int, Void> { get }
    var willDisplayEvent: SectionDelegate<Int, Void> { get }
}

public extension SingleTypeSectionEventProtocol where Self: SectionProtocol {
    
    func item(selected row: Int) {
        publishers.cell._selected.send(.init(row: row, model: models[row]))
        selectedEvent.call(models[row])
        selectedRowEvent.call(row)
    }
    
    func item(willDisplay row: Int) {
        publishers.cell._willDisplay.send(models[row])
    }
    
    func item(didEndDisplaying row: Int) {
        publishers.cell._didEndDisplaying.send(models[row])
    }
    
}


public extension SingleTypeSectionEventProtocol where Self: SectionDataSourcePrefetchingProtocol {

    func prefetch(at rows: [Int]) {
        publishers.prefetch._begin.send(rows)
    }
    
    func cancelPrefetching(at rows: [Int]) {
        publishers.prefetch._cancel.send(rows)
    }
    
}

#endif
