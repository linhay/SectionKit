//
//  File.swift
//  
//
//  Created by linhey on 2022/8/16.
//

import Foundation

public class STCollectionRegistrationEndDisplayStore {
    
    var supplementaries: [SKSupplementaryKind: any STCollectionSupplementaryRegistrationProtocol] = [:]
    var registrations: [Int: any STCollectionCellRegistrationProtocol] = [:]
    
    func supplementary(_ kind: SKSupplementaryKind, function: StaticString = #function) -> (any STCollectionSupplementaryRegistrationProtocol)? {
        return supplementaries[kind]
    }
    
    func registration(at row: Int, function: StaticString = #function) -> (any STCollectionCellRegistrationProtocol)? {
        return registrations[row]
    }
    
}
