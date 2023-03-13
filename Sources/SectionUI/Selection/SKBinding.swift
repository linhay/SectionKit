//
//  SKBinding.swift
//  SectionUI
//
//  Created by linhey on 2023/3/6.
//

import Foundation

@propertyWrapper
public struct SKBinding<Value> {
    
    // 包装的值
    public var wrappedValue: Value {
        get { _get() }
        nonmutating set { _set(newValue) }
    }

    // 返回 SKBinding 的实例
    public var projectedValue: SKBinding<Value> { self }
    
    private let _get: () -> Value
    private let _set: (Value) -> Void
    
    // 初始化方法，接受一个 getter 和 setter
    public init(get: @escaping () -> Value, set: @escaping (Value) -> Void) {
        self._get = get
        self._set = set
    }
    
}

public extension SKBinding {
    
    // 创建一个常量绑定
    static func constant(_ value: Value) -> SKBinding<Value> {
        .init(get: { value }, set: { _ in })
    }
    
}

public extension SKBinding {
    
    // 从一个现有的绑定创建一个新的绑定
    init(_ source: SKBinding<Value>) {
        self.init(get: source._get, set: source._set)
    }
    
    // 从一个对象的 keyPath 创建一个绑定
    init<Root>(on object: Root, keyPath: ReferenceWritableKeyPath<Root, Value>)  {
        self.init {
            object[keyPath: keyPath]
        } set: { value in
            object[keyPath: keyPath] = value
        }
    }
    
    // 从一个对象的 keyPath 和默认值创建一个绑定
    init<Root>(on object: Root, keyPath: ReferenceWritableKeyPath<Root, Value>, default: Value) where Root: AnyObject {
        self.init { [weak object] in
            object?[keyPath: keyPath] ?? `default`
        } set: { [weak object] value in
            object?[keyPath: keyPath] = value
        }
    }
    
}
