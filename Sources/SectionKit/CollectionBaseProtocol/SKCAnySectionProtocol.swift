//
//  SKCAnySectionProtocol.swift
//  SectionKit
//
//  Created by linhey on 5/22/25.
//

import Foundation

public protocol SKCAnySectionProtocol {
    var section: SKCSectionProtocol { get }
    var objectIdentifier: ObjectIdentifier { get }
}
 
public extension SKCAnySectionProtocol {
    var objectIdentifier: ObjectIdentifier { .init(section) }
}

public extension SKCAnySectionProtocol where Self: SKCSectionProtocol {
    var section: SKCSectionProtocol { self }
}
