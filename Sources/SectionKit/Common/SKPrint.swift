//
//  SKPrint.swift
//  SectionKit2
//
//  Created by linhey on 2023/12/5.
//

import Foundation

/// SK 打印工具，提供条件性的调试输出功能
/// SK print utility providing conditional debug logging functionality
public struct SKPrint {
    
    /// 打印类型枚举
    /// Print type enumeration
    public enum Kind: Int {
        /// 高性能相关日志
        /// High performance related logs
        case highPerformance
    }
    
    /// 启用的打印类型集合
    /// Set of enabled print types
    public static var kinds = Set<Kind>([])
    
    /// 日志标识
    /// Log identifier
    static let logo = "[SectionKit]"
    
    /// 打印高性能相关信息
    /// Print high performance related information
    public static func highPerformance(_ items: Any...) {
        #if DEBUG
        guard kinds.contains(.highPerformance) else { return }
        debugPrint("\(logo) -> [HighPerformance]", items)
        #endif
    }
    
    /// 打印函数调用信息
    /// Print function call information
    public static func function(_ items: Any, _ function: StaticString = #function) {
        #if DEBUG
        debugPrint("\(logo) -> [\(function)]", items)
        #endif
    }
    
}
