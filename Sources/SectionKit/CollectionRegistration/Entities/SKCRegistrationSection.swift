//
//  File.swift
//  
//
//  Created by linhey on 2022/8/13.
//

#if canImport(UIKit)
import UIKit

public final class SKCRegistrationSection: SKCRegistrationSectionProtocol {
    
    public private(set) lazy var prefetch: SKCPrefetch = .init { [weak self] in
        return self?.itemCount ?? 0
    }
    public var registrationSectionInjection: SKCRegistrationSectionInjection?
    public var supplementaries: [SKSupplementaryKind: any SKCSupplementaryRegistrationProtocol] = [:]
    public var registrations: [any SKCCellRegistrationProtocol] = []
    
    public lazy var minimumLineSpacing: CGFloat = 0
    public lazy var minimumInteritemSpacing: CGFloat = 0
    public lazy var sectionInset: UIEdgeInsets = .zero
    public let builder: () -> [SKCRegistrationSectionBuilderStore]
    
    public init(@SKCRegistrationSectionBuilder builder: @escaping (() -> [SKCRegistrationSectionBuilderStore])) {
        self.builder = builder
        self.apply(builder)
    }
    
}


#endif