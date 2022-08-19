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

    public init(kind: SKSupplementaryKind,
                type: View.Type,
                config: ((View) -> Void)? = nil) {
        self.kind = kind
        self.type = type
        self.config = config
    }
    
    public init(kind: SKSupplementaryKind, type: View.Type, model: View.Model) where View: SKConfigurableView {
        self.kind = kind
        self.type = type
        self.config = { view in
            view.config(model)
        }
    }
    
}
