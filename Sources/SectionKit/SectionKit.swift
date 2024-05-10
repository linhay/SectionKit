//
//  SectionKit.swift
//  SectionKit2
//
//  Created by linhey on 2023/5/24.
//

import Foundation
import UIKit

public class SKSectionKit {
    
    public static var shared = SKSectionKit()
    
    public var options = Options()
    
    public struct Options {
        /// 当承载视图 size 为0时禁用刷新
        @available(*, deprecated, message: "已不再使用")
        public var disableReloadWhenViewSizeIsZero = true
    }
    
}

public class SKSectionWrapper<Base: SKSectionCompatible> {
    public let base: Base
    public init(_ base: Base) {
        self.base = base
    }
}

public protocol SKSectionCompatible: AnyObject {}

public extension SKSectionCompatible {
    var sk: SKSectionWrapper<Self> { return SKSectionWrapper(self) }
    static var sk: SKSectionWrapper<Self>.Type { return SKSectionWrapper<Self>.self }
}


extension UIView: SKSectionCompatible {}
