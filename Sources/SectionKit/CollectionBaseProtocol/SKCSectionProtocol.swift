//
//  SKCSectionProtocol.swift
//  SectionKit
//
//  Created by linhey on 2022/8/12.
//

#if canImport(UIKit)
import UIKit

/// 基础 section 协议，组合了数据源、代理和操作协议
/// Base section protocol combining data source, delegate and action protocols
public typealias SKCBaseSectionProtocol = SKCSectionActionProtocol & SKCDataSourceProtocol & SKCDelegateProtocol

/// 完整的 section 协议，在基础协议基础上添加了布局和类型协议
/// Complete section protocol adding layout and type protocols to base protocol
public typealias SKCSectionProtocol = SKCBaseSectionProtocol & SKCViewDelegateFlowLayoutProtocol & SKCAnySectionProtocol

public extension SKCDataSourceProtocol where Self: SKCViewDelegateFlowLayoutProtocol {
    
    /// 获取指定类型和行的补充视图
    /// Get supplementary view for specified kind and row
    func supplementary(kind: SKSupplementaryKind, at row: Int) -> UICollectionReusableView? {
        switch kind {
        case .header:
            return headerView
        case .footer:
            return footerView
        case .cell, .custom:
            return nil
        }
    }
    
}
#endif
