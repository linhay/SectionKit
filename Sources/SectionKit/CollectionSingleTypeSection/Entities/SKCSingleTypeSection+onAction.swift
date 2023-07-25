//
//  File.swift
//
//
//  Created by linhey on 2023/7/25.
//

import Foundation

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
    func setCellStyle(_ item: @escaping CellStyleBlock) -> Self {
        return setCellStyle(.init(value: item))
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
    
    func onCellShould(_ kind: CellShouldType, block: @escaping CellShouldBlock) -> Self {
        if cellShoulds[kind] == nil {
            cellShoulds[kind] = []
        }
        cellShoulds[kind]?.append(block)
        return self
    }
    
    func onContextMenu(_ block: @escaping ContextMenuBlock) -> Self {
        cellContextMenus.append(block)
        return self
    }
    
    func onContextMenuWithActions(_ block: @escaping ContextMenuWithActionsBlock) -> Self {
        return onContextMenu { context in
            let result = block(context)
            return .init(configuration: .init(actionProvider: { _ in
                return .init(children: result)
            }))
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
