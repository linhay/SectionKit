//
//  SKIDBox.swift
//  SectionKit2
//
//  Created by linhey on 2023/12/15.
//

import Foundation

/// ID 盒子结构体，为值类型提供唯一标识符包装
/// ID box structure providing unique identifier wrapper for value types
public struct SKIDBox<ID, Value> {
    
    /// 标识符类型别名
    /// Identifier type alias
    public typealias ID = ID
    
    /// 唯一标识符
    /// Unique identifier
    public let id: ID
    
    /// 被包装的值
    /// Wrapped value
    public let value: Value
    
    /// 使用指定 ID 和值初始化
    /// Initialize with specified ID and value
    public init(id: ID, value: Value) {
        self.id = id
        self.value = value
    }
    
    /// 使用自动生成的 UUID 作为 ID 初始化（仅当 ID 类型为 UUID 时）
    /// Initialize with auto-generated UUID as ID (only when ID type is UUID)
    public init(value: Value) where ID == UUID {
        self.id = UUID()
        self.value = value
    }
    
}
