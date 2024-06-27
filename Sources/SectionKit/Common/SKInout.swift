//
//  File.swift
//  
//
//  Created by linhey on 2024/6/19.
//

import Foundation

public struct SKInout<Object> {
    
    public let build: (_ object: Object) -> Object
    
    public init(_ build: @escaping (_ object: Object) -> Object) {
        self.build = build
    }
    
}


public extension SKInout {
    
    static func set(_ block: @escaping (_ object: Object) -> Object) -> SKInout<Object> {
        return .init(block)
    }
    
    static func set<V>(_ keyPath: ReferenceWritableKeyPath<Object, V>, _ value: V) -> SKInout<Object> {
        return .set { object in
            object[keyPath: keyPath] = value
            return object
        }
    }
    
    static func set<V>(_ keyPath: WritableKeyPath<Object, V>, _ value: V) -> SKInout<Object> {
        return .set { object in
            var object = object
            object[keyPath: keyPath] = value
            return object
        }
    }
    
}

public extension SKInout {

    func set(_ block: @escaping (_ object: Object) -> Object) -> SKInout<Object> {
        return .set { object in
            var object = object
            object = build(object)
            object = block(object)
            return object
        }
    }
    
    func set<V>(_ keyPath: ReferenceWritableKeyPath<Object, V>, _ value: V) -> SKInout<Object> {
        return self.set { object in
            var object = object
            object[keyPath: keyPath] = value
            return object
        }
    }
    
    func set<V>(_ keyPath: WritableKeyPath<Object, V>, _ value: V) -> SKInout<Object> {
        return self.set { object in
            var object = object
            object[keyPath: keyPath] = value
            return object
        }
    }
    
}
