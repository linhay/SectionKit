//
//  STVideoPublished.swift
//  CoolUp
//
//  Created by linhey on 12/5/24.
//

import Combine
import Foundation

private enum _SKPublishedDelivery {
    /// Use main queue for UI-related data delivery.
    ///
    /// Why main queue?
    /// - SKPublished is a UI-centric data structure
    /// - avoids exclusivity traps during re-entrant reads
    /// - ensures UI updates happen on the correct thread
    static let queue = DispatchQueue.main
}

public enum SKPublishedKind {
    case passThrough
    case currentValue
}

extension Publisher {

    public func ignoreOutputType() -> AnyPublisher<Void, Failure> {
        self.map { _ in () }.eraseToAnyPublisher()
    }

    public func assign<Root: AnyObject>(
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

public struct SKPublishedTransform<Output, Failure: Error> {

    public typealias TransformPublisher = (_ publisher: AnyPublisher<Output, Failure>) ->
        AnyPublisher<Output, Failure>
    public typealias TransformAnyPublisher = (_ publisher: AnyPublisher<Output, Failure>) ->
        any Publisher<Output, Failure>
    public typealias TransformOnValueChanged = (_ old: Output, _ new: Output) -> Void
    public typealias TransformOnChanged = (_ value: Output) -> Void

    public let publisher: TransformPublisher?
    public let onChanged: TransformOnValueChanged?

    public init(
        publisher publisherTransform: TransformPublisher? = nil,
        onChanged: TransformOnValueChanged? = nil
    ) {
        self.publisher = publisherTransform
        self.onChanged = onChanged
    }

    public static func mapPublisher(_ transform: @escaping TransformAnyPublisher)
        -> SKPublishedTransform
    {
        .init { publisher in
            transform(publisher).eraseToAnyPublisher()
        }
    }

    public static func print(prefix: String = "") -> SKPublishedTransform {
        .init(onChanged: { old, new in
            if prefix.isEmpty {
                Swift.print("[SKPublished]", old, "=>", new)
            } else {
                Swift.print("[SKPublished]", prefix, old, "=>", new)
            }
        })
    }

    public static func onChanged(_ transhform: @escaping TransformOnChanged) -> SKPublishedTransform
    {
        .init(onChanged: { old, new in
            transhform(new)
        })
    }

    public static func onChanged(_ transhform: @escaping TransformOnChanged) -> SKPublishedTransform
    where Output: Equatable {
        .init(onChanged: { old, new in
            guard old != new else {
                return
            }
            transhform(new)
        })
    }

    public static func receiveOnMainQueue() -> SKPublishedTransform {
        .mapPublisher { $0.receive(on: DispatchQueue.main) }
    }

    public static func removeDuplicates(by predicate: @escaping (Output, Output) -> Bool)
        -> SKPublishedTransform
    {
        .mapPublisher { $0.removeDuplicates(by: predicate) }
    }

    public static func removeDuplicates<ID: Equatable>(by keyPath: KeyPath<Output, ID>)
        -> SKPublishedTransform
    {
        removeDuplicates { $0[keyPath: keyPath] == $1[keyPath: keyPath] }
    }

    public static func removeDuplicates() -> SKPublishedTransform where Output: Equatable {
        .mapPublisher { $0.removeDuplicates() }
    }

    public static func dropFirst(count: Int = 1) -> SKPublishedTransform {
        .mapPublisher { $0.dropFirst(count) }
    }

    public static func drop(while predicate: @escaping (Output) -> Bool) -> SKPublishedTransform {
        .mapPublisher { $0.drop(while: predicate) }
    }

    public static func filter(_ isIncluded: @escaping (Output) -> Bool) -> SKPublishedTransform {
        .mapPublisher { $0.filter(isIncluded) }
    }

}

public final class SKPublishedValue<Output>: Publisher, @unchecked Sendable {

    public typealias Failure = Never
    public typealias Transform = SKPublishedTransform<Output, Never>

    private let lock = NSRecursiveLock()

    /// Backing storage for `value`.
    private var _value: Output

    public var value: Output {
        get { locked { _value } }
        set {
            setValue(newValue)
        }
    }

    private let passThroughSubject: PassthroughSubject<Output, Failure>?
    private let currentValueSubject: CurrentValueSubject<Output, Failure>?
    private let subject: AnyPublisher<Output, Failure>
    private var _transforms: [Transform] = []

    public var transforms: [Transform] {
        get { locked { _transforms } }
        set { locked { _transforms = newValue } }
    }

    public var publisher: AnyPublisher<Output, Failure> {
        return transforms.compactMap(\.publisher).reduce(subject) { $1($0) }
            .eraseToAnyPublisher()
    }

    public var anyPublisher: AnyPublisher<Output, Failure> {
        publisher
    }

    public convenience init(
        wrappedValue: Output, kind: SKPublishedKind = .currentValue, transform: Transform
    ) {
        self.init(wrappedValue: wrappedValue, kind: kind, transform: [transform])
    }

    @available(*, deprecated, message: "Use init(wrappedValue:kind:transform:) instead")
    public convenience init(
        wrappedValue: Output, kind: SKPublishedKind = .currentValue, transhforms: [Transform] = []
    ) {
        self.init(wrappedValue: wrappedValue, kind: kind, transform: transhforms)
    }

    public init(
        wrappedValue: Output, kind: SKPublishedKind = .currentValue, transform: [Transform] = []
    ) {
        self._value = wrappedValue
        self._transforms = transform

        let baseSubject: AnyPublisher<Output, Failure>
        switch kind {
        case .passThrough:
            let subject = PassthroughSubject<Output, Failure>()
            passThroughSubject = subject
            currentValueSubject = nil
            baseSubject = subject.eraseToAnyPublisher()
        case .currentValue:
            let subject = CurrentValueSubject<Output, Failure>(wrappedValue)
            passThroughSubject = nil
            currentValueSubject = subject
            baseSubject = subject.eraseToAnyPublisher()
        }
        self.subject = baseSubject.receive(on: _SKPublishedDelivery.queue).eraseToAnyPublisher()
    }

}

extension SKPublishedValue {

    fileprivate func setValue(_ newValue: Output) {
        let update = locked { () -> (oldValue: Output, handlers: [Transform.TransformOnValueChanged]) in
            let oldValue = _value
            _value = newValue
            currentValueSubject?.send(newValue)
            passThroughSubject?.send(newValue)
            return (oldValue, _transforms.compactMap(\.onChanged))
        }

        guard !update.handlers.isEmpty else { return }
        _SKPublishedDelivery.queue.async {
            update.handlers.forEach {
                $0(update.oldValue, newValue)
            }
        }
    }

    private func locked<T>(_ body: () throws -> T) rethrows -> T {
        lock.lock()
        defer { lock.unlock() }
        return try body()
    }

}

extension SKPublishedValue {

    public func send(_ value: Output) {
        self.value = value
    }

    public func send() where Output == Void {
        send(())
    }

}

extension SKPublishedValue {

    public func sink(receiveValue: @escaping ((Output) -> Void)) -> AnyCancellable {
        publisher
            .sink(receiveValue: receiveValue)
    }

    public func bind(_ receiveValue: @escaping (Output) -> Void) -> AnyCancellable {
        if Thread.isMainThread {
            receiveValue(value)
        } else {
            DispatchQueue.main.sync {
                receiveValue(value)
            }
        }
        return sink(receiveValue: receiveValue)
    }

    public func receive<S>(subscriber: S)
    where S: Subscriber, Never == S.Failure, Output == S.Input {
        publisher.receive(subscriber: subscriber)
    }

}

@propertyWrapper public struct SKPublished<Value> {

    public var wrappedValue: Value {
        set { projectedValue.setValue(newValue) }
        get { projectedValue.value }
    }

    public var projectedValue: SKPublishedValue<Value>

    public init(
        wrappedValue: Value,
        kind: SKPublishedKind = .currentValue,
        transform: [SKPublishedTransform<Value, Never>] = []
    ) {
        self.projectedValue = .init(wrappedValue: wrappedValue, kind: kind, transform: transform)
    }

    public init<V>(
        kind: SKPublishedKind = .currentValue,
        transform: [SKPublishedValue<Value>.Transform] = []
    ) where Value == V? {
        self.projectedValue = .init(wrappedValue: nil, kind: kind, transform: transform)
    }

    public init(
        wrappedValue: Value,
        kind: SKPublishedKind = .currentValue,
        transform: SKPublishedTransform<Value, Never>
    ) {
        self.projectedValue = .init(wrappedValue: wrappedValue, kind: kind, transform: [transform])
    }

    public init<V>(
        kind: SKPublishedKind = .currentValue,
        transform: SKPublishedValue<Value>.Transform
    ) where Value == V? {
        self.projectedValue = .init(wrappedValue: nil, kind: kind, transform: [transform])
    }

    @available(*, deprecated)
    public init(
        wrappedValue: Value,
        kind: SKPublishedKind = .currentValue,
        transhforms: [SKPublishedTransform<Value, Never>]
    ) {
        self.projectedValue = .init(wrappedValue: wrappedValue, kind: kind, transform: transhforms)
    }

    @available(*, deprecated)
    public init<V>(
        kind: SKPublishedKind = .currentValue,
        transhforms: [SKPublishedTransform<Value, Never>]
    ) where Value == V? {
        self.projectedValue = .init(wrappedValue: nil, kind: kind, transform: transhforms)
    }

    @available(*, deprecated)
    public init(
        wrappedValue: Value,
        kind: SKPublishedKind = .currentValue,
        transhforms: SKPublishedTransform<Value, Never>
    ) {
        self.projectedValue = .init(
            wrappedValue: wrappedValue, kind: kind, transform: [transhforms])
    }

    @available(*, deprecated)
    public init<V>(
        kind: SKPublishedKind = .currentValue,
        transhforms: SKPublishedTransform<Value, Never>
    ) where Value == V? {
        self.projectedValue = .init(wrappedValue: nil, kind: kind, transform: [transhforms])
    }

    public init(initialValue: Value) {
        self.init(wrappedValue: initialValue)
    }

}
