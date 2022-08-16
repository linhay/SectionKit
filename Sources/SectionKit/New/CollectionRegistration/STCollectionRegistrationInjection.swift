//
//  File.swift
//  
//
//  Created by linhey on 2022/8/15.
//

import Foundation

public protocol STCollectionRegistrationInjectionProtocol {
    
    associatedtype Action: Hashable
    
    var index: Int { get }
    var events: [Action: (Self) -> Void] { get set }
    
}
         
public extension STCollectionRegistrationInjectionProtocol {
    
    mutating func add(_ action: Action, block: ((Self) -> Void)?) {
        self.events[action] = block
    }
    
    mutating func reset(_ events: [Action: (Self) -> Void]) {
        self.events = events
    }
    
    func send(_ action: Action) {
        guard let event = events[action] else {
            assertionFailure()
            return
        }
        event(self)
    }
}

public final class STCollectionRegistrationInjection: STCollectionRegistrationInjectionProtocol {
    

    public struct Action: OptionSet, Hashable {
        
        public let rawValue: Int
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
        
    }
    
    public var index: Int
    public var events: [Action: (STCollectionRegistrationInjection) -> Void]

    public init(index: Int,
                events: [Action : (STCollectionRegistrationInjection) -> Void] = [:]) {
        self.index = index
        self.events = events
    }
    
}

public extension STCollectionRegistrationInjection.Action {
    
    static let reload = Self(rawValue: 1 << 1)
    static let delete = Self(rawValue: 1 << 2)
    
}
