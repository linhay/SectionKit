//
//  File.swift
//
//
//  Created by linhey on 2022/3/14.
//

#if canImport(CoreGraphics)
import Foundation
public protocol SKConfigurableView: SKConfigurableModelProtocol & SKConfigurableLayoutProtocol {}

public extension SKConfigurableView where Model == Void {
    
    func config(_ model: Model) {}
    
}

#endif
