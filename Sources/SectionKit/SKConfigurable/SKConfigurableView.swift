//
//  File.swift
//
//
//  Created by linhey on 2022/3/14.
//

#if canImport(CoreGraphics)
import Foundation
#if canImport(UIKit)
import UIKit

// 定义了可配置视图协议,组合可配置模型,布局和UIView协议
public protocol SKConfigurableView: SKConfigurableModelProtocol & SKConfigurableLayoutProtocol & UIView {}

public extension SKConfigurableView where Model == Void {
    
    func config(_ model: Model) {}
    
}

// 支持通过RawRepresentable配置模型
public extension SKConfigurableView {
    
    func config<T: RawRepresentable>(_ model: T) where Model == T.RawValue {
        config(model.rawValue)
    }
    
}

#endif

#endif
