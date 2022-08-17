//
//  File.swift
//  
//
//  Created by linhey on 2022/8/16.
//

import Foundation

public class STCollectionRegistrationSectionInjection: STCollectionSectionInjection {
    
    var supplementaries: [SKSupplementaryKind: any STCollectionSupplementaryRegistrationProtocol] = [:]
    var registrations: [Int: any STCollectionCellRegistrationProtocol] = [:]
    
    func supplementary(_ kind: SKSupplementaryKind, function: StaticString = #function) -> (any STCollectionSupplementaryRegistrationProtocol)? {
        let item = supplementaries[kind]
        supplementaries[kind] = nil
        return item
    }
    
    func registration(at row: Int, function: StaticString = #function) -> (any STCollectionCellRegistrationProtocol)? {
        let item = registrations[row]
        registrations[row] = nil
        return item
    }
    
}
