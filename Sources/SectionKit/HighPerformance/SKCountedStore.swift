//
//  File.swift
//  
//
//  Created by linhey on 2023/7/19.
//

#if canImport(ObjectiveC) && canImport(UIKit)
import ObjectiveC
import Foundation
import CoreFoundation

public class SKCountedStore {
    
    public typealias GlobalTrigger = (_ id: Int, _ count: Int) -> Void
    public struct Trigger {
        public let when: (Int) -> Bool
        public let callback: () -> Void
        
        public init(when: @escaping (Int) -> Bool,
                    callback: @escaping () -> Void) {
            self.when = when
            self.callback = callback
        }
    }
    
    public var cached: [Int: Int] = [:]
    public var triggers: [Int: [Trigger]] = [:]
    public var globalTriggers: [GlobalTrigger] = []
    public var maxCount: Int = .max

    public init() {}
    
}

public extension SKCountedStore {
    
    func trigger(global: @escaping GlobalTrigger) {
        self.globalTriggers.append(global)
    }
    
    func trigger(of id: Int, when: Int = 1, callback: @escaping () -> Void) {
        trigger(of: id, when: { $0 == when }, callback: callback)
    }
    
    func trigger(of id: Int, when: @escaping (Int) -> Bool, callback: @escaping () -> Void) {
        trigger(of: id, trigger: Trigger(when: when, callback: callback))
    }
    
    func trigger(of id: Int, trigger: Trigger) {
        if triggers[id] == nil {
            triggers[id] = [trigger]
        } else {
            triggers[id]?.append(trigger)
        }
    }
    
    @discardableResult
    func update(by id: Int, count: Int = 1) -> Int {
       
        var count = cached[id] ?? 0
        
        if count < maxCount {
            count += count
            cached[id] = count
        }
        
        if let triggers = triggers[id] {
            for trigger in triggers where trigger.when(count) {
                trigger.callback()
            }
        }
        
        for trigger in globalTriggers {
            trigger(id, count)
        }
        
        return count
    }
    
    func reset(by id: Int) {
        cached[id] = 0
    }
    
    func resetAll() {
        cached.removeAll()
    }
    
}

public extension SKCountedStore {
    
    func trigger<Model: Hashable>(of model: Model, when: Int = 1, callback: @escaping () -> Void) {
        trigger(of: model.hashValue, when: when, callback: callback)
    }
    
    func trigger<Model: Hashable>(of model: Model, when: @escaping (Int) -> Bool, callback: @escaping () -> Void) {
        trigger(of: model.hashValue, when: when, callback: callback)
    }
    
    @discardableResult
    func update<Model: Hashable>(by model: Model, count: Int = 1) -> Int {
        return update(by: model.hashValue, count: count)
    }
    
    func reset<Model: Hashable>(by model: Model) {
        reset(by: model.hashValue)
    }
    
    
}
#endif
