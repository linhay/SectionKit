//
//  File.swift
//
//
//  Created by linhey on 2022/4/28.
//

import Foundation

public extension SingleTypeCollectionDriveSection {
    /// 配置 Cell 样式
    /// - Parameters:
    ///   - target: weak 对象
    ///   - builder: 回调
    /// - Returns: 链式调用
    @discardableResult
    func itemStyle<T: AnyObject>(on target: T, _ builder: @escaping (_ self: T, _ row: Int, _ cell: Cell) -> Void) -> Self {
        return itemStyle { [weak target] row, cell in
            guard let target = target else { return }
            builder(target, row, cell)
        }
    }
    
    /// 配置当前 Section 样式
    /// - Parameters:
    ///   - target: weak 对象
    ///   - builder: 回调
    /// - Returns: 链式调用
    @discardableResult
    func sectionStyle<T: AnyObject>(on target: T, _ builder: @escaping (_ self: T, _ section: Self) -> Void) -> Self {
        return sectionStyle { [weak target] section in
            guard let target = target else { return }
            builder(target, section)
        }
    }
    
    /// item 选中事件订阅 (可以同时订阅多次, 等同于 `publishers.cell.selected.sink`)
    /// - target: weak 对象
    /// - Parameter builder: 订阅回调
    /// - Returns: self
    @discardableResult
    func onItemSelected<T: AnyObject>(on target: T, _ builder: @escaping (_ self: T, _ row: Int, _ model: Cell.Model) -> Void) -> Self {
        return onItemSelected { [weak target] row, model in
            guard let target = target else { return }
            builder(target, row, model)
        }
    }
    
    /// item 显示事件订阅 (可以同时订阅多次, 等同于 `publishers.cell.willDisplay.sink`)
    /// - target: weak 对象
    /// - Parameter builder: 订阅回调
    /// - Returns: self
    @discardableResult
    func onItemWillDisplay<T: AnyObject>(on target: T, _ builder: @escaping (_ self: T, _ row: Int, _ model: Cell.Model) -> Void) -> Self {
        return onItemWillDisplay { [weak target] row, model in
            guard let target = target else { return }
            builder(target, row, model)
        }
    }
    
    /// item 结束显示事件订阅 (可以同时订阅多次, 等同于 `publishers.cell.didEndDisplaying.sink`)
    ///   - target: weak 对象
    /// - Parameter builder: 订阅回调
    /// - Returns: self
    @discardableResult
    func onItemEndDisplay<T: AnyObject>(on target: T, _ builder: @escaping (_ self: T, _ row: Int, _ model: Cell.Model) -> Void) -> Self {
        return onItemEndDisplay { [weak target] row, model in
            guard let target = target else { return }
            builder(target, row, model)
        }
    }
}
