//
//  SKBinding.swift
//  SectionUI
//
//  Created by linhey on 2023/3/6.
//

import Foundation
import Combine

/// SKBinding 属性包装器，提供双向数据绑定功能
/// SKBinding property wrapper providing bidirectional data binding functionality
@propertyWrapper
public struct SKBinding<Value> {
    
    /// 包装的值，支持读取和设置
    /// Wrapped value supporting get and set operations
    public var wrappedValue: Value {
        get { _get() }
        nonmutating set {
            // 执行所有设置器回调
            // Execute all setter callbacks
            for item in _set {
                item(newValue)
            }
            // 如果有设置器，发送变化通知
            // Send change notification if setters exist
            if !_set.isEmpty {
                self.changedSubject.send(newValue)
            }
        }
    }

    /// 返回 SKBinding 的实例，用于访问绑定本身
    /// Returns SKBinding instance for accessing the binding itself
    public var projectedValue: SKBinding<Value> { self }
    
    /// 值变化的发布者，用于监听数据变化
    /// Publisher for value changes, used to observe data changes
    public var changedPublisher: AnyPublisher<Value, Never> { changedSubject.eraseToAnyPublisher() }
    
    /// 是否可设置，基于是否有设置器回调
    /// Whether settable, based on whether setter callbacks exist
    public var isSetable: Bool { !_set.isEmpty }

    /// 获取值的闭包
    /// Closure for getting value
    private let _get: () -> Value
    
    /// 设置值的闭包数组
    /// Array of closures for setting value
    private let _set: [(Value) -> Void]
    
    /// 变化通知的主题
    /// Subject for change notifications
    private let changedSubject = PassthroughSubject<Value, Never>()

    /// 初始化方法，接受一个 getter 和可选的 setter
    /// Initialization method accepting a getter and optional setter
    public init(get: @escaping () -> Value, set: ((Value) -> Void)? = nil) {
        if let set = set {
            self.init(get: get, set: [set])
        } else {
            self.init(get: get, set: [])
        }
    }
    
    /// 私有初始化方法，接受 getter 和 setter 数组
    /// Private initialization method accepting getter and setter array
    private init(get: @escaping () -> Value, set: [(Value) -> Void]) {
        self._get = get
        self._set = set
    }
    
}

public extension SKBinding {
    
    /// 创建一个常量绑定，值不可变
    /// Create a constant binding with immutable value
    static func constant(_ value: Value) -> SKBinding<Value> {
        .init(get: { value }, set: { _ in })
    }
    
    /// 创建一个常量绑定，使用闭包提供值
    /// Create a constant binding using closure to provide value
    static func constant(_ value: @escaping () -> Value) -> SKBinding<Value> {
        .init(get: value, set: { _ in })
    }
    
}

public extension SKBinding {
    
    /// 从 CurrentValueSubject 创建绑定
    /// Create binding from CurrentValueSubject
    init(_ source: CurrentValueSubject<Value, Never>) {
        self.init(get: { source.value }, set: { source.send($0) })
    }
    
    /// 从可选值的 CurrentValueSubject 创建绑定，提供默认值
    /// Create binding from optional CurrentValueSubject with default value
    init(_ source: CurrentValueSubject<Value?, Never>, default: Value) {
        self.init(get: { source.value ?? `default` }, set: { source.send($0) })
    }
    
}

public extension SKBinding {
    
    /// 从现有的 SKBinding 创建新的绑定
    /// Create new binding from existing SKBinding
    init(_ source: SKBinding<Value>) {
        self.init(get: source._get, set: source._set)
    }
    
    /// 从对象的 keyPath 创建绑定
    /// Create binding from object's keyPath
    init<Root>(on object: Root, keyPath: ReferenceWritableKeyPath<Root, Value>) {
        self.init {
            object[keyPath: keyPath]
        } set: { value in
            object[keyPath: keyPath] = value
        }
    }
    
    /// 从弱引用对象的 keyPath 创建绑定，提供默认值
    /// Create binding from weakly referenced object's keyPath with default value
    init<Root>(on object: Root, keyPath: ReferenceWritableKeyPath<Root, Value>, default: Value) where Root: AnyObject {
        self.init { [weak object] in
            object?[keyPath: keyPath] ?? `default`
        } set: { [weak object] value in
            object?[keyPath: keyPath] = value
        }
    }
    
    /// 从弱引用对象的可选 keyPath 创建绑定，提供默认值
    /// Create binding from weakly referenced object's optional keyPath with default value
    init<Root>(on object: Root, keyPath: ReferenceWritableKeyPath<Root, Value?>, default: Value) where Root: AnyObject {
        self.init { [weak object] in
            object?[keyPath: keyPath] ?? `default`
        } set: { [weak object] value in
            object?[keyPath: keyPath] = value
        }
    }
    
}
