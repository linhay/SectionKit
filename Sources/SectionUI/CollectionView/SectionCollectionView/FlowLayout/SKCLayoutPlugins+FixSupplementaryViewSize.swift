//
//  File.swift
//  
//
//  Created by linhey on 2023/10/13.
//

import UIKit

extension SKCLayoutPlugins {
 
    struct FixSupplementaryViewSize: SKCLayoutPlugin {
        
        let layout: UICollectionViewFlowLayout
        
        func run(with attributes: [UICollectionViewLayoutAttributes]) -> [UICollectionViewLayoutAttributes]? {
            attributes
                .filter { $0.representedElementCategory == .supplementaryView }
                .forEach { attribute in
                    switch kind(of: attribute) {
                    case .header:
                        attribute.size = self.headerSize(at: attribute.indexPath.section)
                    case .footer:
                        attribute.size = self.footerSize(at: attribute.indexPath.section)
                    case .cell, .custom:
                        break
                    }
                }
            return attributes
        }
        
    }
    
}


