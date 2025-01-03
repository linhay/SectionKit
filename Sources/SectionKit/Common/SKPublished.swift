//
//  STVideoPublished.swift
//  CoolUp
//
//  Created by linhey on 12/5/24.
//

import Combine
import Foundation

public enum SKPublishedKind {
    case passThrough
    case currentValue
}

public final class SKPublishedValue<Output>: Publisher {
    
    public typealias Failure = Never
    public typealias TranshformPublisher = (_ publisher: AnyPublisher<Output, Failure>) -> AnyPublisher<Output, Failure>
    public typealias TranshformAnyPublisher = (_ publisher: AnyPublisher<Output, Failure>) -> any Publisher<Output, Failure>
    public typealias TranshformOnValueChanged = (_ old: Output, _ new: Output) -> Void
    public typealias TranshformOnChanged = (_ value: Output) -> Void

    public struct Transhform {
        
        public let publisher: TranshformPublisher?
        public let onChanged: TranshformOnValueChanged?

        public init(publisher publisherTranshform: TranshformPublisher? = nil,
                    onChanged: TranshformOnValueChanged? = nil) {
            self.publisher = publisherTranshform
            self.onChanged = onChanged
        }
        
        public init(publisher publisherTranshform: TranshformAnyPublisher?) {
            if let publisherTranshform = publisherTranshform {
                self.publisher = { publisher in
                    publisherTranshform(publisher).eraseToAnyPublisher()
                }
            } else {
                self.publisher = nil
            }
            self.onChanged = nil
        }
        
        public static func print(prefix: String = "") -> Transhform {
            .init { old, new in
                if prefix.isEmpty {
                    Swift.print("[SKPublished]", old, "=>", new)
                } else {
                    Swift.print("[SKPublished]", prefix, old, "=>", new)
                }
            }
        }
        
        public static func onChanged(_ transhform: @escaping TranshformOnChanged) -> Transhform {
            .init { old, new in
                transhform(new)
            }
        }
        
        public static func onChanged(_ transhform: @escaping TranshformOnChanged) -> Transhform where Output: Equatable {
            .init { old, new in
                guard old != new else {
                    return
                }
                transhform(new)
            }
        }
        
        public static func removeDuplicates() -> Transhform where Output: Equatable {
            Transhform.init { publisher in
                publisher.removeDuplicates()
            }
        }
        
    }
    
    public var value: Output {
        didSet {
            currentValueSubject?.send(value)
            passThroughSubject?.send(value)
            transhforms.forEach { $0.onChanged?(oldValue, value) }
        }
    }
    
    private let passThroughSubject: PassthroughSubject<Output, Failure>?
    private let currentValueSubject: CurrentValueSubject<Output, Failure>?
    private let subject: AnyPublisher<Output, Failure>

    public var transhforms: [Transhform] = []
    
    public var publisher: AnyPublisher<Output, Failure> {
        return transhforms.compactMap(\.publisher).reduce(subject) { $1($0) }
    }

    public init(wrappedValue: Output, kind: SKPublishedKind = .currentValue, transhforms: [Transhform] = []) {
        self.value = wrappedValue
        self.transhforms = transhforms
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
    
    public func sink(receiveValue: @escaping ((Output) -> Void)) -> AnyCancellable {
        publisher
            .receive(on: RunLoop.main)
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
    
    public func receive<S>(subscriber: S) where S : Subscriber, Never == S.Failure, Output == S.Input {
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
                transhforms: [SKPublishedValue<Value>.Transhform] = []) {
        self.projectedValue = .init(wrappedValue: wrappedValue, kind: kind, transhforms: transhforms)
    }
    
    public init<V>(kind: SKPublishedKind = .currentValue,
                   transhforms: [SKPublishedValue<Value>.Transhform] = []) where Value == Optional<V> {
        self.projectedValue = .init(wrappedValue: nil, kind: kind, transhforms: transhforms)
    }
    
    public init(wrappedValue: Value,
                kind: SKPublishedKind = .currentValue,
                transhforms: SKPublishedValue<Value>.Transhform) {
        self.projectedValue = .init(wrappedValue: wrappedValue, kind: kind, transhforms: [transhforms])
    }
    
    public init<V>(kind: SKPublishedKind = .currentValue,
                   transhforms: SKPublishedValue<Value>.Transhform) where Value == Optional<V> {
        self.projectedValue = .init(wrappedValue: nil, kind: kind, transhforms: [transhforms])
    }
    
    public init(initialValue: Value) {
        self.init(wrappedValue: initialValue)
    }
    
}
