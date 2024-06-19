//
//  File.swift
//  
//
//  Created by linhey on 2024/6/19.
//

import Foundation

public struct SKInout<Object> {
    
    public let build: (_ object: inout Object) -> Void
    
    public init(_ build: @escaping (_ object: inout Object) -> Void) {
        self.build = build
    }
    
}


public extension SKInout {
    
    static func set(_ block: @escaping (_ object: inout Object) -> Void) -> SKInout<Object> {
        return .init(block)
    }
    
    static func set<V>(_ keyPath: ReferenceWritableKeyPath<Object, V>, _ value: V) -> SKInout<Object> {
        return .set { object in
            object[keyPath: keyPath] = value
        }
    }
    
    static func set<V>(_ keyPath: WritableKeyPath<Object, V>, _ value: V) -> SKInout<Object> {
        return .set { object in
            object[keyPath: keyPath] = value
        }
    }
    
    func set(_ block: @escaping (_ object: inout Object) -> Void) -> SKInout<Object> {
        return .init { object in
            build(&object)
            block(&object)
        }
    }
    
    func set<V>(_ keyPath: ReferenceWritableKeyPath<Object, V>, _ value: V) -> SKInout<Object> {
        return .set { object in
            object[keyPath: keyPath] = value
        }
    }
    
    func set<V>(_ keyPath: WritableKeyPath<Object, V>, _ value: V) -> SKInout<Object> {
        return .set { object in
            object[keyPath: keyPath] = value
        }
    }
    
}
