//
//  File.swift
//  
//
//  Created by linhey on 2022/8/13.
//

import UIKit

public final class STCollectionRegistrationSection: STCollectionRegistrationSectionProtocol {
   
    public var sectionInjection: STCollectionSectionInjection?
    public var endDisplayStore: STCollectionRegistrationEndDisplayStore = .init()
    public var supplementaries: [any STCollectionSupplementaryRegistrationProtocol] = []
    public var registrations: [any STCollectionCellRegistrationProtocol] = []
    
    
    public init(supplementaries: [any STCollectionSupplementaryRegistrationProtocol] = [],
                registrations: [any STCollectionCellRegistrationProtocol] = []) {
        self.supplementaries = supplementaries
        self.registrations = registrations
    }
    
}

public extension STCollectionRegistrationSection {
    

    
}
