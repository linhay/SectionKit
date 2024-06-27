//
//  File.swift
//  
//
//  Created by linhey on 2024/6/19.
//

import Foundation
import UIKit

public struct SKCPluginAdjustAttributes {
    
    public struct Context {
        public let plugin: SKCLayoutPlugin
        public var attributes: UICollectionViewLayoutAttributes
    }
    
    public typealias Style = SKInout<Context>
    
    public var section: SKBindingKey<Int>?
    public var style: Style
    
    public init(section: SKBindingKey<Int>?, _ style: Style) {
        self.style = style
        self.section = section
    }
    
}

public extension SKInout where Object == SKCPluginAdjustAttributes.Context {
    
    static var fixSupplementaryViewSize: SKInout<Object> {
        .set { context in
            guard context.attributes.representedElementCategory == .supplementaryView else {
                return context
            }

            let attribute = context.attributes
            let inset = context.plugin.insetForSection(at: attribute.indexPath.section)
            switch context.plugin.kind(of: attribute) {
            case .header:
                attribute.size = context.plugin.headerSize(at: attribute.indexPath.section)
            case .footer:
                attribute.size = context.plugin.footerSize(at: attribute.indexPath.section)
            case .cell, .custom:
                break
            }
            return context
        }
    }
    
}
