//
//  SKPublished.swift
//  SectionKit
//
//  Created by linhey on 12/5/24.
//

import Combine
import Foundation

/// 发布者类型枚举
/// Publisher type enumeration
public enum SKPublishedKind {
    /// 透传主题，不保存最后的值
    /// Pass-through subject, doesn't retain last value
    case passThrough
    
    /// 当前值主题，保存最后的值
    /// Current value subject, retains last value
    case currentValue
}

public extension Publisher {
    
    /// 忽略输出类型，将输出转换为 Void
    /// Ignore output type, convert output to Void
    func ignoreOutputType() -> any Publisher<Void, Failure> {
        self.map { _ in () }
    }
    
    /// 分配值到弱引用对象的属性
    /// Assign value to property of weakly referenced object
    func assign<Root: AnyObject>(
        onWeak object: Root,
        to keyPath: ReferenceWritableKeyPath<Root, Output>
    ) -> AnyCancellable {
        self.sink { _ in
            
        } receiveValue: { [weak object] value in
            guard let object = object else { return }
            object[keyPath: keyPath] = value
        }
    }
    
}
    
/// SK 发布值类，提供灵活的发布者功能
/// SK published value class providing flexible publisher functionality
public final class SKPublishedValue<Output>: Publisher, Sendable {
    
    /// 失败类型，永不失败
    /// Failure type, never fails
    public typealias Failure = Never
    
    /// 变换发布者的闭包类型
    /// Transform publisher closure type
    public typealias TransformPublisher = (_ publisher: AnyPublisher<Output, Failure>) -> AnyPublisher<Output, Failure>
    public typealias TransformAnyPublisher = (_ publisher: AnyPublisher<Output, Failure>) -> any Publisher<Output, Failure>
    public typealias TransformOnValueChanged = (_ old: Output, _ new: Output) -> Void
    public typealias TransformOnChanged = (_ value: Output) -> Void

    public struct Transform {
                
        public let publisher: TransformPublisher?
        public let onChanged: TransformOnValueChanged?

        public init(publisher publisherTransform: TransformPublisher? = nil,
                    onChanged: TransformOnValueChanged? = nil) {
            self.publisher = publisherTransform
            self.onChanged = onChanged
        }
        
        public static func mapPublisher(_ transform: @escaping TransformAnyPublisher) -> Transform {
            .init { publisher in
                transform(publisher).eraseToAnyPublisher()
            }
        }
        
        public static func print(prefix: String = "") -> Transform {
            .init(onChanged: { old, new in
                if prefix.isEmpty {
                    Swift.print("[SKPublished]", old, "=>", new)
                } else {
                    Swift.print("[SKPublished]", prefix, old, "=>", new)
                }
            })
        }
        
        public static func onChanged(_ transhform: @escaping TransformOnChanged) -> Transform {
            .init(onChanged: { old, new in
                transhform(new)
            })
        }
        
        public static func onChanged(_ transhform: @escaping TransformOnChanged) -> Transform where Output: Equatable {
            .init(onChanged: { old, new in
                guard old != new else {
                    return
                }
                transhform(new)
            })
        }

        public static func receiveOnMainQueue() -> Transform {
            .mapPublisher { $0.receive(on: DispatchQueue.main) }
        }
        
        public static func removeDuplicates() -> Transform where Output: Equatable {
            .mapPublisher { $0.removeDuplicates() }
        }
        
        public static func dropFirst(count: Int = 1) -> Transform {
            .mapPublisher { $0.dropFirst(count) }
        }
        
        public static func drop(while predicate: @escaping (Output) -> Bool) -> Transform {
            .mapPublisher { $0.drop(while: predicate) }
        }
        
        public static func filter(_ isIncluded: @escaping (Output) -> Bool) -> Transform {
            .mapPublisher { $0.filter(isIncluded) }
        }
        
    }
    
    public var value: Output {
        didSet {
            currentValueSubject?.send(value)
            passThroughSubject?.send(value)
            transforms.forEach { $0.onChanged?(oldValue, value) }
        }
    }
    
    private let passThroughSubject: PassthroughSubject<Output, Failure>?
    private let currentValueSubject: CurrentValueSubject<Output, Failure>?
    private let subject: AnyPublisher<Output, Failure>

    public var transforms: [Transform] = []
    
    public var publisher: AnyPublisher<Output, Failure> {
        return transforms.compactMap(\.publisher).reduce(subject) { $1($0) }
    }
    
    public convenience init(wrappedValue: Output, kind: SKPublishedKind = .currentValue, transform: Transform) {
        self.init(wrappedValue: wrappedValue, kind: kind, transform: [transform])
    }
    
    @available(*, deprecated, message: "Use init(wrappedValue:kind:transform:) instead")
    public convenience init(wrappedValue: Output, kind: SKPublishedKind = .currentValue, transhforms: [Transform] = []) {
        self.init(wrappedValue: wrappedValue, kind: kind, transform: transhforms)
    }
    
    public init(wrappedValue: Output, kind: SKPublishedKind = .currentValue, transform: [Transform] = []) {
        self.value = wrappedValue
        self.transforms = transform
        switch kind {
        case .passThrough:
            let subject = PassthroughSubject<Output, Failure>()
            passThroughSubject = subject
            currentValueSubject = nil
            self.subject = subject.eraseToAnyPublisher()
        case .currentValue:
            let subject = CurrentValueSubject<Output, Failure>(wrappedValue)
            passThroughSubject = nil
            currentValueSubject = subject
            self.subject = subject.eraseToAnyPublisher()
        }
    }

}

public extension SKPublishedValue {
    
    func send(_ value: Output) {
        self.value = value
    }
    
    func send() where Output == Void {
     send(())
    }
    
}

public extension SKPublishedValue {
    
     func sink(receiveValue: @escaping ((Output) -> Void)) -> AnyCancellable {
        publisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: receiveValue)
    }
    
     func bind(_ receiveValue: @escaping (Output) -> Void) -> AnyCancellable {
        if Thread.isMainThread {
            receiveValue(value)
        } else {
            DispatchQueue.main.sync {
                receiveValue(value)
            }
        }
        return sink(receiveValue: receiveValue)
    }
    
     func receive<S>(subscriber: S) where S : Subscriber, Never == S.Failure, Output == S.Input {
        publisher.receive(subscriber: subscriber)
    }
    
}


@propertyWrapper public struct SKPublished<Value> {
    
    public var wrappedValue: Value {
        set { projectedValue.value = newValue }
        get { projectedValue.value }
    }
    
    public var projectedValue: SKPublishedValue<Value>

    public init(wrappedValue: Value,
                kind: SKPublishedKind = .currentValue,
                transform: [SKPublishedValue<Value>.Transform] = []) {
        self.projectedValue = .init(wrappedValue: wrappedValue, kind: kind, transform: transform)
    }
    
    public init<V>(kind: SKPublishedKind = .currentValue,
                   transform: [SKPublishedValue<Value>.Transform] = []) where Value == Optional<V> {
        self.projectedValue = .init(wrappedValue: nil, kind: kind, transform: transform)
    }
    
    public init(wrappedValue: Value,
                kind: SKPublishedKind = .currentValue,
                transform: SKPublishedValue<Value>.Transform) {
        self.projectedValue = .init(wrappedValue: wrappedValue, kind: kind, transform: [transform])
    }
    
    public init<V>(kind: SKPublishedKind = .currentValue,
                   transform: SKPublishedValue<Value>.Transform) where Value == Optional<V> {
        self.projectedValue = .init(wrappedValue: nil, kind: kind, transform: [transform])
    }
    
    
    @available(*, deprecated)
    public init(wrappedValue: Value,
                kind: SKPublishedKind = .currentValue,
                transhforms: [SKPublishedValue<Value>.Transform]) {
        self.projectedValue = .init(wrappedValue: wrappedValue, kind: kind, transform: transhforms)
    }
    
    @available(*, deprecated)
    public init<V>(kind: SKPublishedKind = .currentValue,
                   transhforms: [SKPublishedValue<Value>.Transform]) where Value == Optional<V> {
        self.projectedValue = .init(wrappedValue: nil, kind: kind, transform: transhforms)
    }
    
    @available(*, deprecated)
    public init(wrappedValue: Value,
                kind: SKPublishedKind = .currentValue,
                transhforms: SKPublishedValue<Value>.Transform) {
        self.projectedValue = .init(wrappedValue: wrappedValue, kind: kind, transform: [transhforms])
    }
    
    @available(*, deprecated)
    public init<V>(kind: SKPublishedKind = .currentValue,
                   transhforms: SKPublishedValue<Value>.Transform) where Value == Optional<V> {
        self.projectedValue = .init(wrappedValue: nil, kind: kind, transform: [transhforms])
    }
    
    public init(initialValue: Value) {
        self.init(wrappedValue: initialValue)
    }
    
}
