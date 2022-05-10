//
//  File.swift
//
//
//  Created by linhey on 2022/4/28.
//

import Foundation

public extension SingleTypeCollectionDriveSection where Cell.Model == Void {
    convenience init(count: Int, transforms _: [SectionDataTransform<Cell.Model>] = []) {
        self.init(repeating: (), count: count)
    }
}

public extension SingleTypeCollectionDriveSection where Cell.Model == Void {
    /// item 选中事件订阅 (可以同时订阅多次, 等同于 `publishers.cell.selected.sink`)
    /// - Parameter builder: 订阅回调
    /// - Returns: self
    @discardableResult
    func onItemSelected(_ builder: @escaping (_ row: Int) -> Void) -> Self {
        publishers.cell.selected.sink { result in
            builder(result.row)
        }.store(in: &cancellables)
        return self
    }
    
    /// item 显示事件订阅 (可以同时订阅多次, 等同于 `publishers.cell.willDisplay.sink`)
    /// - Parameter builder: 订阅回调
    /// - Returns: self
    @discardableResult
    func onItemWillDisplay(_ builder: @escaping (_ row: Int) -> Void) -> Self {
        publishers.cell.willDisplay.sink { result in
            builder(result.row)
        }.store(in: &cancellables)
        return self
    }
    
    /// item 结束显示事件订阅 (可以同时订阅多次, 等同于 `publishers.cell.didEndDisplaying.sink`)
    /// - Parameter builder: 订阅回调
    /// - Returns: self
    @discardableResult
    func onItemEndDisplay(_ builder: @escaping (_ row: Int) -> Void) -> Self {
        publishers.cell.didEndDisplaying.sink { result in
            builder(result.row)
        }.store(in: &cancellables)
        return self
    }
}
