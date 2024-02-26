//
//  File.swift
//
//
//  Created by linhey on 2023/7/25.
//

import Foundation
import UIKit

/// 配置当前 section 样式
public extension SKCSingleTypeSection {
    
    /// 配置当前 section 样式
    /// - Parameter item: 回调
    /// - Returns: self
    @discardableResult
    func setSectionStyle(_ item: @escaping SectionStyleBlock) -> Self {
        item(self)
        return self
    }
    
    @discardableResult
    func setSectionStyle<Value>(_ path: ReferenceWritableKeyPath<SKCSingleTypeSection<Cell>, Value>, _ value: Value) -> Self {
        self[keyPath: path] = value
        return self
    }
    
    @discardableResult
    func setSectionStyle<Value>(_ path: ReferenceWritableKeyPath<SKCSingleTypeSection<Cell>, Value?>, _ value: Value?) -> Self {
        self[keyPath: path] = value
        return self
    }
    
    @discardableResult
    func setSectionStyle<Value>(_ paths: [ReferenceWritableKeyPath<SKCSingleTypeSection<Cell>, Value>], _ value: Value) -> Self {
        for path in paths {
            self[keyPath: path] = value
        }
        return self
    }
    
    @discardableResult
    func setSectionStyle<Value>(_ paths: [ReferenceWritableKeyPath<SKCSingleTypeSection<Cell>, Value?>], _ value: Value?) -> Self {
        for path in paths {
            self[keyPath: path] = value
        }
        return self
    }
    
}

/// 配置 Cell 样式
public extension SKCSingleTypeSection {

    @discardableResult
    func setCellStyle(_ item: @escaping CellStyleBlock) -> Self {
        return setCellStyle(.init(value: item))
    }
    
    @discardableResult
    func setCellStyle<T>(_ path: ReferenceWritableKeyPath<SKCCellStyleContext<Cell>, T>, _ value: T) -> Self {
        return setCellStyle { context in
            context[keyPath: path] = value
        }
    }
    
    @discardableResult
    func setCellStyle<T>(_ path: ReferenceWritableKeyPath<SKCCellStyleContext<Cell>, T?>, _ value: T?) -> Self {
        return setCellStyle { context in
            context[keyPath: path] = value
        }
    }
    
    @discardableResult
    func setCellStyle(_ item: CellStyleBox) -> Self {
        cellStyles.append(item)
        return self
    }
    
    func remove(cellStyle ids: [CellStyleBox.ID]) {
        let ids = Set(ids)
        self.cellStyles = cellStyles.filter { !ids.contains($0.id) }
    }
    
}

public extension SKCSingleTypeSection {
    
    /// 订阅事件类型
    /// - Parameters:
    ///   - kind: 事件类型
    ///   - block: 回调
    /// - Returns: self
    @discardableResult
    func onCellAction(_ kind: CellActionType, block: @escaping CellActionBlock) -> Self {
        if cellActions[kind] == nil {
            cellActions[kind] = []
        }
        cellActions[kind]?.append(block)
        return self
    }
    
    func onCellShould(_ kind: CellShouldType, _ value: Bool) -> Self {
        onCellShould(kind) { _ in
            value
        }
    }
    
    func onCellShould(_ kind: CellShouldType, block: @escaping CellShouldBlock) -> Self {
        if cellShoulds[kind] == nil {
            cellShoulds[kind] = []
        }
        cellShoulds[kind]?.append(block)
        return self
    }
    
}

public extension SKCSingleTypeSection {
    
    func onContextMenu(_ block: @escaping ContextMenuBlock) -> Self {
        cellContextMenus.append(block)
        return self
    }
    
    func onContextMenu(where predicate: @escaping (_ context: ContextMenuContext) -> Bool,
                       block: @escaping ContextMenuBlock) -> Self {
        return onContextMenu { context in
            guard predicate(context) else {
                return nil
            }
            return block(context)
        }
    }
    
}

public extension SKCSingleTypeSection {
    
    /// 订阅事件类型
    /// - Parameters:
    ///   - kind: 事件类型
    ///   - block: 回调
    /// - Returns: self
    @discardableResult
    func onCellAction<ON: AnyObject>(on: ON, _ kind: CellActionType, block: @escaping CellActionWeakBlock<ON>) -> Self {
        return onCellAction(kind) { [weak on] context in
            guard let on = on else { return }
            block(on, context)
        }
    }
    
    @discardableResult
    func setCellStyle<ON: AnyObject>(on: ON, _ block: @escaping CellStyleWeakBlock<ON>) -> Self {
        return setCellStyle { [weak on] context in
            guard let on = on else { return }
            block(on, context)
        }
    }
    
    @discardableResult
    func setSectionStyle<ON: AnyObject>(on: ON, _ block: @escaping SectionStyleWeakBlock<ON>) -> Self {
        return setSectionStyle { [weak on] section in
            guard let on = on else { return }
            block(on, section)
        }
    }
    
}
