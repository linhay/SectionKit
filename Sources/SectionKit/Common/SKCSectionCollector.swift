//
//  SKCSectionCollector.swift
//  Pods
//
//  Created by linhey on 5/29/25.
//

import Foundation
import UIKit

public class SKCSectionCollector {
    
    public var sections: [SKCSectionProtocol] = []
    
    public init() {}
    
}

public extension SKCSectionCollector {
    
    func append(_ item: SKCSectionProtocol?) {
        guard let item else { return }
        sections.append(item)
    }

}

public extension SKCSectionCollector {
    
    public typealias When<Object> = (_ object: Object) -> Bool
    public typealias FindSection<Object> = (_ object: Object) -> SKCSectionProtocol?

    @discardableResult
    func append<Object: SKCAnySectionProtocol>(_ item: Object?, when: When<Object>? = nil) {
        append(item, section: \.section, when: when)
    }
    
    func append<Object: SKCAnySectionProtocol>(_ list: [Object?], when: When<Object>? = nil) {
        append(list, section: \.section, when: when)
    }
    
    @discardableResult
    func append<Object>(_ item: Object?, section: FindSection<Object>, when: When<Object>? = nil) -> Bool {
        if let item = item, when?(item) ?? true, let section = section(item) {
                sections.append(section)
            return true
        } else {
            return false
        }
    }
    
    func append<Object>(_ list: [Object?], section: FindSection<Object>, when: When<Object>? = nil) {
        for item in list {
            append(item, section: section, when: when)
        }
    }
    
}

