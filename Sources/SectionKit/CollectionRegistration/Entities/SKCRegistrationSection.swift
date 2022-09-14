//
//  File.swift
//  
//
//  Created by linhey on 2022/8/13.
//

import UIKit

public final class SKCRegistrationSection: SKCRegistrationSectionProtocol {
    
    public private(set) lazy var prefetch: SKCPrefetch = .init { [weak self] in
        return self?.itemCount ?? 0
    }
    public var registrationSectionInjection: SKCRegistrationSectionInjection?
    public var supplementaries: [SKSupplementaryKind: any SKCSupplementaryRegistrationProtocol]
    public var registrations: [any SKCCellRegistrationProtocol]
    
    public lazy var minimumLineSpacing: CGFloat = 0
    public lazy var minimumInteritemSpacing: CGFloat = 0
    public lazy var sectionInset: UIEdgeInsets = .zero
    
    public convenience init() {
        self.init([:], [])
    }
    
    public convenience init(@SKCRegistrationSectionBuilder builder: (() -> [SKCRegistrationSectionBuilderStore])) {
        self.init()
        self.builder(builder)
    }
    
    public init(_ supplementaries: [SKSupplementaryKind: any SKCSupplementaryRegistrationProtocol],
                _ registrations: [any SKCCellRegistrationProtocol]) {
        self.supplementaries = supplementaries
        self.registrations = registrations
    }

}


public extension SKCRegistrationSection {
    
    @discardableResult
    func sectionStyle(_ builder: (_ section: SKCRegistrationSection) -> Void) -> SKCRegistrationSection {
        builder(self)
        return self
    }
    
    @discardableResult
    func builder<T: AnyObject>(on object: T,
                               @SKCRegistrationSectionBuilder
                               _ builder: ((_ object: T, _ section: SKCRegistrationSection) -> [SKCRegistrationSectionBuilderStore])) -> SKCRegistrationSection {
        return self.builder { [weak object, weak self] in
            if let object = object, let self = self {
                builder(object, self)
            }
        }
    }

    @discardableResult
    func builder(@SKCRegistrationSectionBuilder _ builder: (() -> [SKCRegistrationSectionBuilderStore])) -> SKCRegistrationSection {
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
        
        self.apply(supplementaries)
        self.apply(registrations)
        return self
    }
    
}
