//
//  File.swift
//  
//
//  Created by linhey on 2024/6/12.
//

import UIKit
import SectionKit

public extension SKCLayoutPlugins {
    
    struct AdjustAttributesAgent: SKCLayoutPlugin {
        
        let layoutWeakBox: SKWeakBox<SKCollectionFlowLayout>
        let adjusts: [SKCPluginAdjustAttributes]
        
        init(layout: SKCollectionFlowLayout, adjusts: [SKCPluginAdjustAttributes]) {
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
                var attributes = attributes
                store[attributes.indexPath.section]?.style.build(&attributes)
                return attributes
            }
        }
    }
    
}
