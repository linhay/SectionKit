//
//  File.swift
//  
//
//  Created by linhey on 2022/8/13.
//

import UIKit

public final class STCollectionRegistrationSection: STCollectionRegistrationSectionProtocol {
    
    public var registrationSectionInjection: STCollectionRegistrationSectionInjection?
    public var supplementaries: [SKSupplementaryKind: any STCollectionSupplementaryRegistrationProtocol]
    public var registrations: [any STCollectionCellRegistrationProtocol]
    
    public convenience init() {
        self.init([:], [])
    }
    
    public convenience init(@SupplementaryBuilder _ supplementaries: (() -> BuildSupplementaryStore),
                            @RegistrationBuilder registrations: (() -> BuildRegistrationsStore)) {
        self.init(supplementaries().supplementaries, registrations().registrations)
    }
    
    public convenience init(@RegistrationBuilder _ registrations: (() -> BuildRegistrationsStore)) {
        self.init({ }, registrations: registrations)
    }
    
    public init(_ supplementaries: [SKSupplementaryKind: any STCollectionSupplementaryRegistrationProtocol],
                _ registrations: [any STCollectionCellRegistrationProtocol]) {
        self.supplementaries = supplementaries
        self.registrations = registrations
    }
    
}


public extension STCollectionRegistrationSection {
    
    struct BuildSupplementaryStore {
        public var supplementaries: [SKSupplementaryKind: any STCollectionSupplementaryRegistrationProtocol] = [:]
    }
    
    struct BuildRegistrationsStore {
        public var registrations: [any STCollectionCellRegistrationProtocol] = []
    }
    
    @resultBuilder
    struct SupplementaryBuilder {
        
        public typealias Store = BuildSupplementaryStore
        public typealias View  = STCollectionSupplementaryRegistrationProtocol

        public static func buildExpression(_ expression: Void) -> Store {
            .init()
        }
        
        public static func buildExpression(_ expression: any View) -> Store {
            buildExpression([expression])
        }
        
        public static func buildExpression(_ expression: [any View]) -> Store {
            var dict = [SKSupplementaryKind: any View]()
            expression.forEach { item in
                dict[item.kind] = item
            }
            return Store(supplementaries: dict)
        }
        
        public static func buildExpression(_ expression: [Store]) -> Store {
            buildExpression(expression.map(\.supplementaries.values).flatMap({ $0 }))
        }
        
        public static func buildBlock(_ components: Store...) -> Store {
            buildExpression(components)
        }
        
    }
    
    @resultBuilder
    struct RegistrationBuilder {
        
        public typealias Store = BuildRegistrationsStore
        public typealias View  = STCollectionCellRegistrationProtocol
        
        public static func buildExpression(_ expression: Void) -> Store {
            .init()
        }
        
        public static func buildExpression(_ expression: [any View]) -> Store {
            BuildRegistrationsStore(registrations: expression)
        }
        
        
        public static func buildExpression(_ expression: any View) -> Store {
            buildExpression([expression])
        }
        
        public static func buildExpression(_ expression: [Store]) -> Store {
            buildExpression(expression.map(\.registrations).flatMap({ $0 }))
        }
        
        public static func buildBlock(_ components: Store...) -> Store {
            buildExpression(components)
        }
        
    }
    
}
