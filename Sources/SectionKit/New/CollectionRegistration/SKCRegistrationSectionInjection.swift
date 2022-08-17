//
//  File.swift
//  
//
//  Created by linhey on 2022/8/16.
//

import Foundation

public class SKCRegistrationSectionInjection: STCollectionSectionInjection {
    
    var supplementaries: [SKSupplementaryKind: any SKCSupplementaryRegistrationProtocol] = [:]
    var registrations: [Int: any SKCCellRegistrationProtocol] = [:]
    
    func supplementary(_ kind: SKSupplementaryKind, function: StaticString = #function) -> (any SKCSupplementaryRegistrationProtocol)? {
        let item = supplementaries[kind]
        supplementaries[kind] = nil
        return item
    }
    
    func registration(at row: Int, function: StaticString = #function) -> (any SKCCellRegistrationProtocol)? {
        let item = registrations[row]
        registrations[row] = nil
        return item
    }
    
}
