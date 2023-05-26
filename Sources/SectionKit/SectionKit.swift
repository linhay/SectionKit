//
//  SectionKit.swift
//  SectionKit2
//
//  Created by linhey on 2023/5/24.
//

import Foundation

public class SKSectionKit {
    
    public static var shared = SKSectionKit()
    
    public var options = Options()
    
    public struct Options {
        /// 当承载视图 size 为0时禁用刷新
        public var disableReloadWhenViewSizeIsZero = true
    }
    
}
