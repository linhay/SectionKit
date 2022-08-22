//
//  File.swift
//  
//
//  Created by linhey on 2022/8/19.
//

import Foundation

public struct SKCSupplementary<View: SKLoadViewProtocol>: SKCSupplementaryProtocol {
    
    public let kind: SKSupplementaryKind
    public let type: View.Type
    public let config: ((View) -> Void)?
    public let size: ((_ limitSize: CGSize, _ type: View.Type) -> CGSize)?

    public init(kind: SKSupplementaryKind,
                type: View.Type,
                config: ((View) -> Void)? = nil,
                size: ((_ limitSize: CGSize, _ type: View.Type) -> CGSize)?) {
        self.kind = kind
        self.type = type
        self.config = config
        self.size = size
    }
    
    public init(kind: SKSupplementaryKind, type: View.Type, model: View.Model) where View: SKConfigurableView {
        self.init(kind: kind, type: type) { view in
            view.config(model)
        } size: { limitSize, type in
            type.preferredSize(limit: limitSize, model: model)
        }
    }
    
}
