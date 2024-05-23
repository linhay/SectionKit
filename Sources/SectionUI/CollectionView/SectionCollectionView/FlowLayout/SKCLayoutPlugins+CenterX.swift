//
//  File.swift
//
//
//  Created by linhey on 2023/10/13.
//

import UIKit
import SectionKit

extension SKCLayoutPlugins {
    
    struct CenterX: SKCLayoutPlugin {
        
        var layoutWeakBox: SKWeakBox<SKCollectionFlowLayout>
        let sections: [SKBindingKey<Int>]
        
        init(layout: SKCollectionFlowLayout, sections: [SKBindingKey<Int>]) {
            self.layoutWeakBox = .init(layout)
            self.sections = sections
        }
        
        func run(with attributes: [UICollectionViewLayoutAttributes]) -> [UICollectionViewLayoutAttributes]? {
            var lineStore = [UICollectionViewLayoutAttributes]()
            var list = [UICollectionViewLayoutAttributes]()
            
            var attributes = attributes
            let sections = Set(self.sections.compactMap(\.wrappedValue))
            if let all = SKBindingKey<Int>.all.wrappedValue,
               sections.contains(all) {
                
            } else if sections.isEmpty {
                attributes = []
            } else {
                attributes = attributes.filter({ sections.contains($0.indexPath.section) })
            }
            
            for item in attributes {
                guard item.representedElementCategory == .cell else {
                    list.append(item)
                    continue
                }
                
                if lineStore.isEmpty {
                    lineStore.append(item)
                } else if let lastItem = lineStore.last,
                          lastItem.indexPath.section == item.indexPath.section,
                          lastItem.frame.minY == item.frame.minY
                {
                    lineStore.append(item)
                } else {
                    list.append(contentsOf: appendLine(lineStore))
                    lineStore = [item]
                }
            }
            
            list.append(contentsOf: appendLine(lineStore))
            return list
        }
        
        private func appendLine(_ lineStore: [UICollectionViewLayoutAttributes]) -> [UICollectionViewLayoutAttributes] {
            guard let firstItem = lineStore.first else {
                return lineStore
            }
            
            let spacing = minimumInteritemSpacing(at: firstItem.indexPath.section)
            let allWidth = lineStore.reduce(0) { $0 + $1.frame.width } + spacing * CGFloat(lineStore.count - 1)
            let offset = (collectionView.bounds.width - allWidth) / 2
            firstItem.frame.origin.x = offset
            _ = lineStore.dropFirst().reduce(firstItem) { result, item -> UICollectionViewLayoutAttributes in
                item.frame.origin.x = result.frame.maxX + spacing
                return item
            }
            return lineStore
        }
        
    }
    
}
