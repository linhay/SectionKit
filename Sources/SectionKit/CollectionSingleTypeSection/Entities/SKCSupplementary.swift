//
//  File.swift
//  
//
//  Created by linhey on 2022/8/19.
//

import UIKit

public struct SKCSupplementary<View: UICollectionReusableView & SKLoadViewProtocol & SKConfigurableView>: SKCSupplementaryProtocol {
    
    public let kind: SKSupplementaryKind
    public let type: View.Type
    public let config: ((View) -> Void)?
    public let size: (CGSize) -> CGSize
    
    public init(kind: SKSupplementaryKind,
                type: View.Type,
                config: ((View) -> Void)? = nil,
                size: @escaping (_ limitSize: CGSize) -> CGSize) {
        self.kind = kind
        self.type = type
        self.config = config
        self.size = size
    }
    
    public init(kind: SKSupplementaryKind, type: View.Type, model: View.Model) where View: SKConfigurableView {
        self.init(kind: kind, type: type) { view in
            view.config(model)
        } size: { limitSize in
            View.preferredSize(limit: limitSize, model: model)
        }
    }
    
    public init(kind: SKSupplementaryKind, type: View.Type) where View: SKConfigurableView, View.Model == Void {
        self.init(kind: kind, type: type, model: ())
    }
    
}


public extension SKCSupplementary {
    
    static func header(type: View.Type,
                       config: ((View) -> Void)? = nil,
                       size: @escaping (_ limitSize: CGSize) -> CGSize) -> Self {
        self.init(kind: .header, type: type, config: config, size: size)
    }
    
    static func header(type: View.Type, model: View.Model) -> Self where View: SKConfigurableView {
        self.header(type: type) { view in
            view.config(model)
        } size: { limitSize in
            View.preferredSize(limit: limitSize, model: model)
        }
    }
    
    static func header(type: View.Type) -> Self where View: SKConfigurableView, View.Model == Void {
        self.header(type: type, model: ())
    }
    
}

public extension SKCSupplementary {
    
    static func footer(type: View.Type,
                       config: ((View) -> Void)? = nil,
                       size: @escaping (_ limitSize: CGSize) -> CGSize) -> Self {
        self.init(kind: .footer, type: type, config: config, size: size)
    }
    
    static func footer(type: View.Type, model: View.Model) -> Self where View: SKConfigurableView {
        self.header(type: type) { view in
            view.config(model)
        } size: { limitSize in
            View.preferredSize(limit: limitSize, model: model)
        }
    }
    
    static func footer(type: View.Type) -> Self where View: SKConfigurableView, View.Model == Void {
        self.header(type: type, model: ())
    }
    
}
