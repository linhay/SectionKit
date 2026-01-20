//
//  File.swift
//
//
//  Created by linhey on 2023/7/25.
//

import Foundation
import UIKit

public extension SKCSingleTypeSection {
    typealias AsyncCellActionBlock = AsyncContextBlock<SKCCellActionContext<Cell>, Void>
}

/// 配置当前 section 样式
public extension SKCSingleTypeSection {
    
    /// 配置当前 section 样式
    /// - Parameter item: 回调
    /// - Returns: self
    @discardableResult
    func setSectionStyle(_ item: SectionStyleBlock?) -> Self {
        if let item = item {
            item(self)
        }
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

public extension SKCSingleTypeSection {
    
    @discardableResult
    func clearContextMenuActions() -> Self {
        cellContextMenus.removeAll()
        return self
    }
    
    func onContextMenu(_ block: @escaping ContextMenuBlock) -> Self {
        cellContextMenus.append(block)
        return self
    }
    
    func onContextMenu(where predicate: @escaping (_ context: SKCContextMenuContext<Cell>) -> Bool,
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
