//
//  SKCAnySectionProtocol.swift
//  SectionKit
//
//  Created by linhey on 5/22/25.
//

import UIKit
import Foundation

/// 任意 Section 协议，提供类型擦除的 Section 抽象
/// Any section protocol providing type-erased section abstraction
public protocol SKCAnySectionProtocol: SKCSectionActionProtocol {
    /// 底层的 section 实例
    /// Underlying section instance
    var section: SKCSectionProtocol { get }
    
    /// 对象标识符，用于唯一标识
    /// Object identifier for unique identification
    var objectIdentifier: ObjectIdentifier { get }
}
 
public extension SKCAnySectionProtocol {
    /// 项目数量，代理到底层 section
    /// Item count, delegated to underlying section
    var itemCount: Int { section.itemCount }
    
    /// Section 注入配置，代理到底层 section
    /// Section injection configuration, delegated to underlying section
    var sectionInjection: SKCSectionInjection? {
        get { section.sectionInjection }
        set { section.sectionInjection = newValue }
    }
    
    /// 配置 section 视图，代理到底层 section
    /// Configure section view, delegated to underlying section
    func config(sectionView: UICollectionView) {
        section.config(sectionView: sectionView)
    }
    
    /// 获取对象标识符
    /// Get object identifier
    var objectIdentifier: ObjectIdentifier { .init(section) }
}

public extension SKCAnySectionProtocol where Self: SKCSectionProtocol {
    /// 当自身已经是 SKCSectionProtocol 时，返回自身
    /// When self is already SKCSectionProtocol, return self
    var section: SKCSectionProtocol { self }
}
