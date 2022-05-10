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
    var dataSource: SingleTypeSectionDataSource<Cell> { get }
    
    func config(models: [Cell.Model])
    
    /// 该部分接口与 Array 保持一致
    func insert(_ models: [Cell.Model], at row: Int)
    func remove(at rows: [Int])
    
    /// 重载数据
    func reload()
}

public extension SingleTypeSectionDataProtocol {
    var itemCount: Int { models.count }
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
    
    func removeAll() {
        remove(at: .init(0 ..< models.count))
    }
    
    func remove(_ model: Cell.Model) where Cell.Model: AnyObject {
        let indexs = models.enumerated().compactMap { offset, element in
            element === model ? offset : nil
        }
        remove(at: indexs)
    }
    
    func remove(_ model: Cell.Model) where Cell.Model: Equatable {
        let indexs = models.enumerated().compactMap { offset, element in
            element == model ? offset : nil
        }
        remove(at: indexs)
    }
}

/// DataTransform - Hidden
public extension SingleTypeSectionDataProtocol {
    /// 隐藏该 Section
    /// - Parameter by: bool
    /// - Returns: self
    @discardableResult
    func hidden(by: @escaping () -> Bool) -> Self {
        dataSource.hidden(by: by)
        return self
    }
    
    @discardableResult
    func hidden(_ value: Bool) -> Self {
        hidden { value }
        return self
    }
    
    @discardableResult
    func hidden<T: AnyObject>(by: T, _ keyPath: KeyPath<T, Bool>) -> Self {
        hidden { [weak by] in
            by?[keyPath: keyPath] ?? false
        }
        return self
    }
    
    @discardableResult
    func hidden<T>(by: T, _ keyPath: KeyPath<T, Bool>) -> Self {
        hidden { by[keyPath: keyPath] }
        return self
    }
}

public protocol SingleTypeSectionEventProtocol {
    associatedtype Cell: SectionLoadViewProtocol & SectionConfigurableModelProtocol
    associatedtype ReusableView
    
    var models: [Cell.Model] { get }
    
    var publishers: SingleTypeSectionPublishers<Cell.Model, ReusableView> { get }
}

public extension SingleTypeSectionEventProtocol where Self: SectionProtocol {
    func item(selected row: Int) {
        guard let model = model(at: row) else {
            return
        }
        publishers.cell._selected.send(.init(row: row, model: model))
    }
    
    func item(willDisplay row: Int) {
        guard let model = model(at: row) else {
            return
        }
        publishers.cell._willDisplay.send(.init(row: row, model: model))
    }
    
    func item(didEndDisplaying row: Int) {
        guard let model = model(at: row) else {
            return
        }
        publishers.cell._didEndDisplaying.send(.init(row: row, model: model))
    }
    
    private func model(at row: Int) -> Cell.Model? {
        guard models.indices.contains(row) else {
            return nil
        }
        return models[row]
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
