//
//  SKLayoutDirection.swift
//  SectionKit2
//
//  Created by linhey on 2023/3/9.
//

import Foundation

public struct SKLayoutDirection: OptionSet {
    
    public static let horizontal = SKLayoutDirection(rawValue: 1 << 0)
    public static let vertical   = SKLayoutDirection(rawValue: 1 << 1)
    
    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
}
