//
//  File.swift
//  
//
//  Created by linhey on 2024/3/17.
//

import Foundation

public struct SKBindingKey<Value> {
    
    private let closure: () -> Value?
    public var wrappedValue: Value? { closure() }

    public init(get closure: @escaping () -> Value?) {
        self.closure = closure
    }
    
    public init(_ value: Value?) {
        self.closure = { value }
    }
    
}


public extension SKBindingKey {
    static func constant(_ value: Value) -> SKBindingKey<Value> {
        .init(get: { value })
    }
}

public extension SKBindingKey where Value == Int {
    static let all = SKBindingKey.constant(-1)
    
    init(_ section: SKCSectionActionProtocol) {
        self.init(get: { [weak section] in
            guard let section = section, let injection = section.sectionInjection else {
                return nil
            }
            return injection.index
        })
    }
}

extension SKBindingKey: Equatable where Value: Equatable {
    
    public static func == (lhs: SKBindingKey<Value>,
                           rhs: SKBindingKey<Value>) -> Bool {
        return lhs.wrappedValue == rhs.wrappedValue
    }
    
}

extension SKBindingKey: Hashable where Value: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(closure())
    }
}
