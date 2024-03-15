//
//  File.swift
//  
//
//  Created by linhey on 2023/10/13.
//

import UIKit
import SectionKit

extension SKCLayoutPlugins {
    
    struct Left: SKCLayoutPlugin {
        
        let layoutWeakBox: SKWeakBox<SKCollectionFlowLayout>
        
        init(layout: SKCollectionFlowLayout) {
            self.layoutWeakBox = .init(layout)
        }
        
        func run(with attributes: [UICollectionViewLayoutAttributes]) -> [UICollectionViewLayoutAttributes]? {
           
            switch scrollDirection {
            case .horizontal:
                return attributes
            case .vertical:
                break
            @unknown default:
                return attributes
            }
            
            var list = [UICollectionViewLayoutAttributes]()
            var section = [UICollectionViewLayoutAttributes]()
            
            for item in attributes {
                guard item.representedElementCategory == .cell else {
                    list.append(item)
                    continue
                }
                
                switch item.representedElementCategory {
                case .cell:
                    break
                case .decorationView:
                    list.append(item)
                    continue
                case .supplementaryView:
                    section.append(item)
                    list.append(item)
                    continue
                @unknown default:
                    list.append(item)
                    continue
                }
                
                let insets = insetForSection(at: item.indexPath.section)
                let minimumInteritemSpacing = minimumInteritemSpacing(at: item.indexPath.section)
                
                if section.last?.indexPath.section != item.indexPath.section {
                    section.removeAll()
                }
                
                if let lastItem = section.last, lastItem.frame.maxY == item.frame.maxY {
                    item.frame.origin.x = lastItem.frame.maxX + minimumInteritemSpacing
                } else {
                    item.frame.origin.x = insets.left
                }
    
                section.append(item)
                list.append(item)
            }
            return list
        }
    }
    
}
