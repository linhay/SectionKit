//
//  File.swift
//  
//
//  Created by linhey on 2024/6/19.
//

import Foundation
import UIKit

public struct SKCPluginAdjustAttributes {
    
    public typealias Style = SKInout<UICollectionViewLayoutAttributes>
    
    public var section: SKBindingKey<Int>?
    public var style: Style
    
    public init(section: SKBindingKey<Int>?, _ style: Style) {
        self.style = style
        self.section = section
    }
    
}
