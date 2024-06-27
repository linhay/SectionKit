//
//  File.swift
//  
//
//  Created by linhey on 2024/6/12.
//

import UIKit
import SectionKit

public extension SKCLayoutPlugins {
    
    public struct AdjustAttributesAgent: SKCLayoutPlugin {
        
        public let layoutWeakBox: SKWeakBox<SKCollectionFlowLayout>
        public let adjusts: [SKCPluginAdjustAttributes]
        
        public init(layout: SKCollectionFlowLayout, adjusts: [SKCPluginAdjustAttributes]) {
            self.layoutWeakBox = .init(layout)
            self.adjusts = adjusts
        }
        
        func run(with attributes: [UICollectionViewLayoutAttributes]) -> [UICollectionViewLayoutAttributes]? {
            var store = [Int: SKCPluginAdjustAttributes]()
            for adjust in adjusts {
                if let key = adjust.section?.wrappedValue {
                    store[key] = adjust
                }
            }
            return attributes.map { attributes in
                var context = SKCPluginAdjustAttributes.Context(plugin: self, attributes: attributes)
                if let build = store[attributes.indexPath.section]?.style.build {
                    context = build(context)
                }
                return attributes
            }
        }
    }
    
}
