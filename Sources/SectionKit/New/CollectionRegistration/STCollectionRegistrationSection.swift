//
//  File.swift
//  
//
//  Created by linhey on 2022/8/13.
//

import UIKit

public final class STCollectionRegistrationSection: STCollectionRegistrationSectionProtocol {

    public var supplementaries: [SKSupplementaryKind : any STCollectionReusableViewRegistrationProtocol] = [:]
    
    public var registrations: [any STCollectionCellRegistrationProtocol] = []
    
    public var sectionState: STCollectionSectionContext?
    
    public init(supplementaries: [SKSupplementaryKind: any STCollectionReusableViewRegistrationProtocol] = [:],
                  registrations: [any STCollectionCellRegistrationProtocol] = []) {
        self.supplementaries = supplementaries
        self.registrations = registrations
    }
    
    public func config(sectionView: UICollectionView) {
        guard let sectionState = sectionState else {
            return
        }
        registrations.enumerated().forEach { item in
            var element = item.element
            element.register(sectionView: sectionView)
            element.indexPath = .init(row: item.offset, section: sectionState.index)
        }
    }
    
}
