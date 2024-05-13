//
//  File.swift
//
//
//  Created by linhey on 2023/10/13.
//

import UIKit
import SectionKit

public extension SKCLayoutPlugins {
                
    struct Decorations: SKCLayoutPlugin {
        
        let layoutWeakBox: SKWeakBox<SKCollectionFlowLayout>
        let decorations: [any SKCLayoutDecorationPlugin]
        let fixSupplementaryViewInset: SKCLayoutPlugins.FixSupplementaryViewInset?
        
        init(layout: SKCollectionFlowLayout,
             decorations: [any SKCLayoutDecorationPlugin],
             fixSupplementaryViewInset: SKCLayoutPlugins.FixSupplementaryViewInset?) {
            self.layoutWeakBox = .init(layout)
            self.decorations = decorations
            self.fixSupplementaryViewInset = fixSupplementaryViewInset
            decorations.forEach { decoration in
                decoration.apply(to: layout)
            }
        }
        
        func observe(kind: SKCSupplementaryActionType,
                     identifier: String,
                     at indexPath: IndexPath,
                     view: UICollectionReusableView) {
            decorations.forEach { decoration in
                decoration.apply(kind: kind, identifier: identifier, at: indexPath, view: view)
            }
        }
        
        func run(with attributes: [UICollectionViewLayoutAttributes]) -> [UICollectionViewLayoutAttributes]? {
            var current_sections = attributes.map(\.indexPath.section).sorted()
            var section_offset = [Int: Int]()
            var attributes = attributes
            
            for decoration in decorations {
                if decoration.from.index == .all {
                    for current_section in current_sections {
                        let offset = section_offset[current_section] ?? 0
                        if let attribute = task(section: current_section,
                                                index: offset,
                                                decoration: decoration) {
                            section_offset[current_section] = offset + 1
                            attributes.append(attribute)
                        }
                    }
                } else if let indexRange = decoration.indexRange {
                    let offset = section_offset[indexRange.lowerBound] ?? 0
                    if let attribute = task(section: indexRange.lowerBound,
                                            index: offset,
                                            decoration: decoration) {
                        section_offset[indexRange.lowerBound] = offset + 1
                        attributes.append(attribute)
                    }
                }
            }
        
            return attributes
        }
        
        func frame(for item: SKCLayoutDecoration.Item, at section: IndexPath) -> CGRect? {
            guard let layout else { return nil }
            
            var supplementaryMode: SKCLayoutDecoration.Mode?
            var sectionInsetPaddingWhenLayout: [SKCLayoutDecoration.Layout] = []
            
            for mode in item.modes {
                switch mode {
                case .section, .visibleView:
                    supplementaryMode = mode
                case .useSectionInsetWhenNotExist(let layout):
                    sectionInsetPaddingWhenLayout = layout
                }
            }
            
            func supplementary(of key: String) -> UICollectionViewLayoutAttributes? {
                guard let supplementaryMode = supplementaryMode else { return nil }
                switch supplementaryMode {
                case .section:
                    return layout.attributes(of: key, at: section, useCache: false)
                case .visibleView:
                    return layout.attributes(of: key, at: section, useCache: true)
                case .useSectionInsetWhenNotExist:
                    return nil
                }
            }
            
            func inset(_ layout: SKCLayoutDecoration.Layout) -> CGFloat {
                guard !sectionInsetPaddingWhenLayout.isEmpty else { return 0 }
                let insets = insetForSection(at: section.section)
                switch layout {
                case .header:
                    return insets.top
                case .cells:
                    return 0
                case .footer:
                    return insets.bottom
                }
            }
            
            var frames = [CGRect]()
            var unions = [SKCLayoutDecoration.Layout]()
            
            if item.layout.contains(.header),
               let attributes = supplementary(of: UICollectionView.elementKindSectionHeader),
               attributes.frame.width > 0,
               attributes.frame.height > 0 {
                frames.append(attributes.frame)
                unions.append(.header)
            }
            
            if item.layout.contains(.footer),
               let attributes = supplementary(of: UICollectionView.elementKindSectionFooter),
               attributes.frame.width > 0,
               attributes.frame.height > 0 {
                frames.append(attributes.frame)
                unions.append(.footer)
            }
            
            if item.layout.contains(.cells) {
                let cells = (0 ..< collectionView.numberOfItems(inSection: section.section)).compactMap {
                    layout.layoutAttributesForItem(at: IndexPath(row: $0, section: section.section))?.frame
                }
                if let frame = CGRect.union(cells) {
                    frames.append(frame)
                    unions.append(.cells)
                }
            }
            
            guard var frame = CGRect.union(frames) else {
                return nil
            }
            
            if !unions.contains(.header), sectionInsetPaddingWhenLayout.contains(.header) {
                let inset = inset(.header)
                frame.origin.y -= inset
                frame.size.height += inset
            }
            
            if !unions.contains(.footer), sectionInsetPaddingWhenLayout.contains(.footer) {
                let inset = inset(.footer)
                frame.size.height += inset
            }
            
            return frame
        }
        
        func task(section: Int, index: Int, decoration: any SKCLayoutDecorationPlugin) -> UICollectionViewLayoutAttributes? {
            let sectionIndexPath = IndexPath(item: index, section: section)
            var frames = [CGRect]()
            
            if let frame = frame(for: decoration.from, at: sectionIndexPath) {
                frames.append(frame)
            }
            
            if let to = decoration.to,
               let section = to.index.wrappedValue,
               let frame = frame(for: to, at: IndexPath(item: index, section: section)) {
                frames.append(frame)
            }
            
            guard let frame = CGRect.union(frames)?.apply(insets: decoration.insets) else {
                return nil
            }
            
            let attribute = UICollectionViewLayoutAttributes(forDecorationViewOfKind: decoration.viewType.identifier, with: sectionIndexPath)
            attribute.zIndex = decoration.zIndex
            attribute.frame = frame
            return attribute
        }
        
    }
    
}
