//
//  File.swift
//  
//
//  Created by linhey on 2022/8/13.
//

import UIKit

public final class SKCRegistrationSection: SKCRegistrationSectionProtocol {
    
    public var registrationSectionInjection: SKCRegistrationSectionInjection?
    public var supplementaries: [SKSupplementaryKind: any SKCSupplementaryRegistrationProtocol]
    public var registrations: [any SKCCellRegistrationProtocol]
    
    public convenience init() {
        self.init([:], [])
    }
    
    public convenience init(@SKCRegistrationSectionBuilder builder: (() -> [SKCRegistrationSectionBuilderStore])) {
        let stores = builder()
        var supplementaries: [SKSupplementaryKind: any SKCSupplementaryRegistrationProtocol] = [:]
        var registrations: [any SKCCellRegistrationProtocol] = []
        
        for store in stores {
            switch store {
            case .supplementary(let item):
                supplementaries[item.kind] = item
            case .registration(let item):
                registrations.append(item)
            }
        }
        self.init(supplementaries, registrations)
    }
    
    public init(_ supplementaries: [SKSupplementaryKind: any SKCSupplementaryRegistrationProtocol],
                _ registrations: [any SKCCellRegistrationProtocol]) {
        self.supplementaries = supplementaries
        self.registrations = registrations
    }
    
}
