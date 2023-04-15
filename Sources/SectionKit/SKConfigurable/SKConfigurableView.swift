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

public protocol SKConfigurableView: SKConfigurableModelProtocol & SKConfigurableLayoutProtocol & UIView {}

public extension SKConfigurableView where Model == Void {
    
    func config(_ model: Model) {}
    
}

public extension SKConfigurableView {
    
    func config<T: RawRepresentable>(_ model: T) where Model == T.RawValue {
        config(model.rawValue)
    }
    
}

#endif

#endif