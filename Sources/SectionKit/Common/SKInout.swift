//
//  SKInout.swift
//  SectionKit
//
//  Created by linhey on 2024/6/19.
//

import Foundation

/// SK 输入输出结构体，提供链式配置对象的能力
/// SK inout structure providing chainable object configuration capability
public struct SKInout<Object> {
    
    /// 构建对象的闭包
    /// Closure for building object
    public let build: (_ object: Object) -> Object
    
    /// 初始化方法
    /// Initialization method
    public init(_ build: @escaping (_ object: Object) -> Object) {
        self.build = build
    }
    
}

public extension SKInout {
    
    /// 创建设置对象的 SKInout（可选版本）
    /// Create SKInout for setting object (optional version)
    static func set(_ block: ((_ object: Object) -> Void)?) -> SKInout<Object>? {
        guard let block = block else { return nil }
        return .init { object in
            block(object)
            return object
        }
    }
    
    /// 链式设置对象（可选版本）
    /// Chain set object (optional version)
    func set(_ block: ((_ object: Object) -> Void)?) -> SKInout<Object>? {
        guard let block = block else { return self }
        return .set { object in
            block(object)
            return object
        }
    }
    
}

public extension SKInout {
    
    /// 创建设置对象的 SKInout
    /// Create SKInout for setting object
    static func set(_ block: @escaping (_ object: Object) -> Object) -> SKInout<Object> {
        return .init(block)
    }
    
    /// 通过引用可写键路径设置属性值
    /// Set property value through reference writable key path
    static func set<V>(_ keyPath: ReferenceWritableKeyPath<Object, V>, _ value: V) -> SKInout<Object> {
        return .set { object in
            object[keyPath: keyPath] = value
            return object
        }
    }
    
    /// 通过可写键路径设置属性值
    /// Set property value through writable key path
    static func set<V>(_ keyPath: WritableKeyPath<Object, V>, _ value: V) -> SKInout<Object> {
        return .set { object in
            var object = object
            object[keyPath: keyPath] = value
            return object
        }
    }
    
}

public extension SKInout {

    /// 链式设置另一个 SKInout
    /// Chain set another SKInout
    func set(_ other: SKInout<Object>) -> SKInout<Object> {
        return .set { object in
            var object = object
            object = build(object)
            object = other.build(object)
            return object
        }
    }
    
    /// 链式设置对象
    /// Chain set object
    func set(_ block: @escaping (_ object: Object) -> Object) -> SKInout<Object> {
        return .set { object in
            var object = object
            object = build(object)
            object = block(object)
            return object
        }
    }
    
    /// 链式通过引用可写键路径设置属性值
    /// Chain set property value through reference writable key path
    func set<V>(_ keyPath: ReferenceWritableKeyPath<Object, V>, _ value: V) -> SKInout<Object> {
        return self.set { object in
            let object = object
            object[keyPath: keyPath] = value
            return object
        }
    }
    
    /// 链式通过可写键路径设置属性值
    /// Chain set property value through writable key path
    func set<V>(_ keyPath: WritableKeyPath<Object, V>, _ value: V) -> SKInout<Object> {
        return self.set { object in
            var object = object
            object[keyPath: keyPath] = value
            return object
        }
    }
    
}
