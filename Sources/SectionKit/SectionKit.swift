//
//  SectionKit.swift
//  SectionKit2
//
//  Created by linhey on 2023/5/24.
//

import Foundation
import UIKit

/// SectionKit 主类，提供全局配置和共享实例
/// Main SectionKit class providing global configuration and shared instance
public class SKSectionKit {
    
    /// 共享单例实例
    /// Shared singleton instance
    public static var shared = SKSectionKit()
    
    /// 全局配置选项
    /// Global configuration options
    public var options = Options()
    
    /// 配置选项结构体
    /// Configuration options structure
    public struct Options {
        /// 当承载视图 size 为0时禁用刷新（已废弃）
        /// Disable refresh when container view size is zero (deprecated)
        @available(*, deprecated, message: "已不再使用 / No longer used")
        public var disableReloadWhenViewSizeIsZero = true
    }
    
}

/// SectionKit 包装器，为兼容类型提供命名空间
/// SectionKit wrapper providing namespace for compatible types
public class SKWrapper<Base: SKCompatible> {
    /// 被包装的基础对象
    /// The wrapped base object
    public let base: Base
    
    /// 初始化包装器
    /// Initialize wrapper
    public init(_ base: Base) {
        self.base = base
    }
}

/// SectionKit 兼容性协议，遵循此协议的类型可以使用 sk 命名空间
/// SectionKit compatibility protocol, types conforming to this can use sk namespace
public protocol SKCompatible: AnyObject {}

public extension SKCompatible {
    /// 实例级别的 sk 命名空间访问器
    /// Instance-level sk namespace accessor
    var sk: SKWrapper<Self> { return SKWrapper(self) }
    
    /// 类型级别的 sk 命名空间访问器
    /// Type-level sk namespace accessor
    static var sk: SKWrapper<Self>.Type { return SKWrapper<Self>.self }
}

/// 扩展 UIView 使其兼容 SectionKit
/// Extend UIView to be compatible with SectionKit
extension UIView: SKCompatible {}