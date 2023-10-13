//
//  File.swift
//
//
//  Created by linhey on 2023/10/13.
//

import UIKit

public extension SKCLayoutPlugins {
    
    struct FixSupplementaryViewInset: SKCLayoutPlugin {
        
        public enum Direction: Int {
            case vertical
            case horizontal
            case all
        }
        
        let layout: UICollectionViewFlowLayout
        let direction: Direction
        
        func run(with attributes: [UICollectionViewLayoutAttributes]) -> [UICollectionViewLayoutAttributes]? {
            attributes
                .filter { $0.representedElementCategory == .supplementaryView }
                .forEach { attribute in
                    let inset = insetForSection(at: attribute.indexPath.section)
                    switch kind(of: attribute) {
                    case .header:
                        switch direction {
                        case .vertical:
                            attribute.frame.origin.y += inset.top
                        case .horizontal:
                            attribute.frame.origin.x += inset.left
                            attribute.frame.size.width -= (inset.left + inset.right)
                        case .all:
                            attribute.frame.origin.y += inset.top
                            attribute.frame.origin.x += inset.left
                            attribute.frame.size.width -= (inset.left + inset.right)
                        }
                    case .footer:
                        switch direction {
                        case .vertical:
                            attribute.frame.origin.y -= inset.bottom
                        case .horizontal:
                            attribute.frame.origin.x += inset.left
                            attribute.frame.size.width -= (inset.left + inset.right)
                        case .all:
                            attribute.frame.origin.y -= inset.bottom
                            attribute.frame.origin.x += inset.left
                            attribute.frame.size.width -= (inset.left + inset.right)
                        }
                    case .cell, .custom:
                        break
                    }
                }
            return attributes
        }
        
    }
    
}
