//
//  SKPrint.swift
//  SectionKit2
//
//  Created by linhey on 2023/12/5.
//

import Foundation

public struct SKPrint {
    
    public enum Kind: Int {
        case highPerformance
    }
    
    public static var kinds = Set<Kind>([])
    static let logo = "[SectionKit]"
    
    static func highPerformance(_ items: Any...) {
        #if DEBUG
        guard kinds.contains(.highPerformance) else { return }
        debugPrint("\(logo) -> [HighPerformance]", items)
        #endif
    }
    
}
