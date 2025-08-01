//
//  SKBindingKey.swift
//  SectionUI
//
//  Created by linhey on 2024/3/17.
//

import Foundation
import UIKit

/// 使用闭包绑定值的类型
/// A type that binds a value using a closure.
public struct SKBindingKey<Value> {
    
    /// 获取值的闭包
    /// Closure for getting value
    private let closure: () -> Value?
    
    /// 从闭包获取的包装值
    /// The wrapped value obtained from the closure.
    public var wrappedValue: Value? { closure() }

    /// 使用闭包初始化新的绑定键
    /// Initializes a new binding key with a closure.
    /// - Parameter closure: 返回要绑定值的闭包 / A closure that returns the value to be bound.
    /// - Example:
    /// ```
    /// let bindingKey = SKBindingKey<Int> { return 5 }
    /// print(bindingKey.wrappedValue) // Prints "Optional(5)"
    /// ```
    public init(get closure: @escaping () -> Value?) {
        self.closure = closure
    }
    
    /// 使用特定值初始化新的绑定键
    /// Initializes a new binding key with a specific value.
    /// - Parameter value: 要绑定的值 / The value to be bound.
    /// - Example:
    /// ```
    /// let bindingKey = SKBindingKey(5)
    /// print(bindingKey.wrappedValue) // Prints "Optional(5)"
    /// ```
    public init(_ value: Value?) {
        self.closure = { value }
    }
}

public extension SKBindingKey {
    /// 创建具有特定值的常量绑定键
    /// Creates a constant binding key with a specific value.
    /// - Parameter value: 要绑定的常量值 / The constant value to be bound.
    /// - Returns: 始终返回指定值的绑定键 / A binding key that always returns the specified value.
    /// - Example:
    /// ```
    /// let constantKey = SKBindingKey.constant(10)
    /// print(constantKey.wrappedValue) // Prints "Optional(10)"
    /// ```
    static func constant(_ value: Value) -> SKBindingKey<Value> {
        .init(get: { value })
    }
}

public extension SKBindingKey where Value == Int {
    
    /// 表示所有 section 的常量绑定键
    /// A constant binding key representing all sections.
    static let all = SKBindingKey.constant(-1000000)

    /// 从集合视图和键路径创建相对绑定键
    /// Creates a relative binding key from a collection view and a key path.
    /// - Parameters:
    ///   - view: 集合视图 / The collection view.
    ///   - task: 从 section 范围获取相对值的键路径 / The key path to get the relative value from the range of sections.
    /// - Returns: 获取相对 section 索引的绑定键 / A binding key that gets the relative section index.
    /// - Example:
    /// ```
    /// let collectionView: UICollectionView? = ...
    /// let relativeKey = SKBindingKey.relative(from: collectionView, \.first)
    /// print(relativeKey.wrappedValue)
    /// ```
    static func relative(from view: UICollectionView?, _ task: @escaping (_ range: Range<Int>) -> Int?) -> Self {
       return .init(get: { [weak view] in
            guard let view = view else {
                return nil
            }
            return task(0..<view.numberOfSections)
        })
    }
    
    /// 使用 section 操作协议和偏移量初始化新的绑定键
    /// Initializes a new binding key with a section action protocol and an offset.
    /// - Parameters:
    ///   - section: section 操作协议 / The section action protocol.
    ///   - offset: 要添加到 section 索引的偏移量，默认为 0 / The offset to be added to the section index. Defaults to 0.
    /// - Example:
    /// ```
    /// let section: SKCSectionActionProtocol = ...
    /// let sectionKey = SKBindingKey(section, offset: 1)
    /// print(sectionKey.wrappedValue)
    /// ```
    init(_ section: SKCSectionActionProtocol, offset: Int = 0) {
        self.init(get: { [weak section] in
            guard let section = section, let injection = section.sectionInjection else {
                return nil
            }
            return injection.index + offset
        })
    }
}

extension SKBindingKey: Equatable where Value: Equatable {
    
    /// 检查两个绑定键是否相等
    /// Checks if two binding keys are equal.
    /// - Parameters:
    ///   - lhs: 左侧绑定键 / The left-hand side binding key.
    ///   - rhs: 右侧绑定键 / The right-hand side binding key.
    /// - Returns: 如果包装值相等则返回 `true`，否则返回 `false` / `true` if the wrapped values are equal, otherwise `false`.
    /// - Example:
    /// ```
    /// let key1 = SKBindingKey(5)
    /// let key2 = SKBindingKey(5)
    /// print(key1 == key2) // Prints "true"
    /// ```
    public static func == (lhs: SKBindingKey<Value>,
                           rhs: SKBindingKey<Value>) -> Bool {
        return lhs.wrappedValue == rhs.wrappedValue
    }
    
}

extension SKBindingKey: Hashable where Value: Hashable {
    
    /// 将包装值哈希到提供的哈希器中
    /// Hashes the wrapped value into the provided hasher.
    /// - Parameter hasher: 组合此实例组件时使用的哈希器 / The hasher to use when combining the components of this instance.
    /// - Example:
    /// ```
    /// let key = SKBindingKey(5)
    /// var hasher = Hasher()
    /// key.hash(into: &hasher)
    /// print(hasher.finalize())
    /// ```
    public func hash(into hasher: inout Hasher) {
        hasher.combine(closure())
    }
}
