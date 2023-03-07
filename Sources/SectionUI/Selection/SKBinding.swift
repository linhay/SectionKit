//
//  SKBinding.swift
//  SectionUI
//
//  Created by linhey on 2023/3/6.
//

import Foundation
import Combine

@propertyWrapper
public struct SKBinding<Value> {

    public var publisher: AnyPublisher<Value, Never> {
        subject.eraseToAnyPublisher()
    }
    private var subject = PassthroughSubject<Value, Never>()
    
    public var wrappedValue: Value {
        get { _get() }
        nonmutating set { _set(newValue) }
    }

    public var projectedValue: SKBinding<Value> { self }
    
    private let _get: () -> Value
     private let _set: (Value) -> Void

    public init(get: @escaping () -> Value, set: @escaping (Value) -> Void) {
        self._get = get
        self._set = set
    }
    
    public init<Root>(on object: Root, keyPath: ReferenceWritableKeyPath<Root, Value>)  {
        self.init {
            object[keyPath: keyPath]
        } set: { value in
            object[keyPath: keyPath] = value
        }
    }
    
    public init<Root>(on object: Root, keyPath: ReferenceWritableKeyPath<Root, Value>, default: Value) where Root: AnyObject {
        self.init { [weak object] in
            object?[keyPath: keyPath] ?? `default`
        } set: { [weak object] value in
            object?[keyPath: keyPath] = value
        }
    }

    public init(_ source: SKBinding<Value>) {
        self.init(get: source._get, set: source._set)
    }

    public static func constant(_ value: Value) -> SKBinding<Value> {
        .init(get: { value }, set: { _ in })
    }
    
}
