//
//  SKConfigurableView.swift
//  SectionKit
//
//  Created by linhey on 2022/3/14.
//

import Foundation

/// 存在模型的视图协议，组合了存在模型协议和可配置布局协议
/// Protocol for views with existing model, combining existing model protocol and configurable layout protocol
public protocol SKExistModelView: SKExistModelProtocol & SKConfigurableLayoutProtocol { }

/// 可配置视图协议，组合了可配置模型协议和可配置布局协议
/// Configurable view protocol combining configurable model protocol and configurable layout protocol
public protocol SKConfigurableView: SKConfigurableModelProtocol & SKConfigurableLayoutProtocol {}

public extension SKConfigurableView where Model == Void {
    
    /// 为 Void 模型提供空实现
    /// Provide empty implementation for Void model
    func config(_ model: Model) {}
    
}

/// 支持通过 RawRepresentable 配置模型
/// Support configuring model through RawRepresentable
public extension SKConfigurableView {
    
    /// 使用 RawRepresentable 类型配置模型
    /// Configure model using RawRepresentable type
    func config<T: RawRepresentable>(_ model: T) where Model == T.RawValue {
        config(model.rawValue)
    }
    
}
