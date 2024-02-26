//
//  File.swift
//
//
//  Created by linhey on 2023/10/13.
//

import UIKit
import SectionKit

public extension SKCLayoutPlugins {
    
    typealias DecorationView = UICollectionReusableView & SKLoadViewProtocol
    
    enum DecorationLayout {
        case header
        case cells
        case footer
    }
    
    enum DecorationMode {
        /// 按照可视视图区域计算
        case visibleView
        /// 按照原始的 section 区域计算
        case section
        /// 没有头尾时用sectioninset填充
        case useSectionInsetWhenNotExist(_ layout: [DecorationLayout] = [.header, .footer])
        
    }
    
    struct Decoration {
        
        public struct Item {
            
            public let index: BindingKey<Int>
            public let layout: [DecorationLayout]
            public let modes: [DecorationMode]
            
            public init(index: BindingKey<Int>,
                        modes: [DecorationMode] = [.visibleView],
                        layout: [DecorationLayout] = [.header, .cells, .footer]) {
                self.index  = index
                self.modes  = modes
                self.layout = layout
                
                #if DEBUG
                var useSectionInsetWhenNotExist = false
                var visibleViewOrSection = false
                self.modes.forEach({ mode in
                    switch mode {
                    case .visibleView, .section:
                        visibleViewOrSection = true
                    case .useSectionInsetWhenNotExist:
                        useSectionInsetWhenNotExist = true
                    }
                })
                
                if useSectionInsetWhenNotExist, visibleViewOrSection == false {
                    assertionFailure("需要指定 .visibleView 或者 .section")
                }
                #endif
            }
            
            public init(_ section: SKCSectionProtocol,
                        modes: [DecorationMode] = [.visibleView],
                        layout: [DecorationLayout] = [.header, .cells, .footer]) {
                self.init(index: .init(section), modes: modes, layout: layout)
            }
        }
        
        public let from: Item
        public let to: Item?
        
        public let viewType: DecorationView.Type
        public let insets: UIEdgeInsets
        public let zIndex: Int
        
        public init(section: SKCSectionProtocol,
                    viewType: DecorationView.Type,
                    mode: [DecorationMode] = [.visibleView],
                    zIndex: Int = -1,
                    layout: [DecorationLayout] = [.header, .cells, .footer],
                    insets: UIEdgeInsets = .zero) {
            self.init(sectionIndex: .init(section),
                      viewType: viewType,
                      zIndex: zIndex,
                      layout: layout,
                      insets: insets)
        }
        
        public init(sectionIndex: BindingKey<Int>,
                    viewType: DecorationView.Type,
                    modes: [DecorationMode] = [.visibleView],
                    zIndex: Int = -1,
                    layout: [DecorationLayout] = [.header, .cells, .footer],
                    insets: UIEdgeInsets = .zero) {
            self.to = nil
            self.from = .init(index: sectionIndex, modes: modes, layout: layout)
            self.viewType = viewType
            self.insets = insets
            self.zIndex = zIndex
        }
        
        public init(from: Item, to: Item?,
                    viewType: DecorationView.Type,
                    zIndex: Int = -1,
                    insets: UIEdgeInsets = .zero) {
            self.from = from
            self.to = to
            self.viewType = viewType
            self.zIndex = zIndex
            self.insets = insets
        }
        
        func apply(to layout: UICollectionViewFlowLayout) {
            if let nib = viewType.nib {
                layout.register(nib, forDecorationViewOfKind: viewType.identifier)
            } else {
                layout.register(viewType.self, forDecorationViewOfKind: viewType.identifier)
            }
        }
    }
    
    class BindingKey<Value> {
        
        private let closure: () -> Value?
        public var wrappedValue: Value? { closure() }
        
        public init(get closure: @escaping () -> Value?) {
            self.closure = closure
        }
        
    }
    
    struct Decorations: SKCLayoutPlugin {
        
        let layout: SKCollectionFlowLayout
        let decorations: [Decoration]
        let fixSupplementaryViewInset: SKCLayoutPlugins.FixSupplementaryViewInset?
        
        init(layout: SKCollectionFlowLayout,
             decorations: [Decoration],
             fixSupplementaryViewInset: SKCLayoutPlugins.FixSupplementaryViewInset?) {
            self.layout = layout
            self.decorations = decorations
            self.fixSupplementaryViewInset = fixSupplementaryViewInset
            decorations.forEach { decoration in
                decoration.apply(to: layout)
            }
        }
        
        func run(with attributes: [UICollectionViewLayoutAttributes]) -> [UICollectionViewLayoutAttributes]? {
            var dict = [Int: [Int: [Decoration]]](minimumCapacity: decorations.count)
            decorations.forEach { item in
                if let value = item.from.index.wrappedValue {
                    if dict[value] == nil {
                        dict[value] = [:]
                    }
                    
                    if dict[value]?[item.zIndex] == nil {
                        dict[value]?[item.zIndex] = [item]
                    } else {
                        dict[value]?[item.zIndex]?.append(item)
                    }
                }
            }
            
            var all: [Int: [Decoration]]?
            if let wrappedValue = BindingKey<Int>.all.wrappedValue {
                all = dict[wrappedValue]
            }
            
            var set = Set<Int>()
            let sections = attributes
                .map(\.indexPath.section)
                .filter { set.insert($0).inserted }
                .map { index -> [UICollectionViewLayoutAttributes] in
                    guard let decorations = dict[index] ?? all else {
                        return [UICollectionViewLayoutAttributes]()
                    }
                    return decorations
                        .sorted(by: { $0.key < $1.key })
                        .compactMap { (zIndex: Int, list: [SKCLayoutPlugins.Decoration]) in
                            list.enumerated().compactMap { (offset, decoration) in
                                task(section: index, index: offset, decoration: decoration)
                            }
                        }.flatMap({ $0 })
                }.flatMap { $0 }
            
            return attributes + sections
            
        }
        
        func frame(for item: Decoration.Item, at section: IndexPath) -> CGRect? {
            
            var supplementaryMode: DecorationMode?
            var sectionInsetPaddingWhenLayout: [DecorationLayout] = []
        
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
            
            func inset(_ layout: DecorationLayout) -> CGFloat {
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
            var unions = [DecorationLayout]()

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
        
        func task(section: Int, index: Int, decoration: Decoration) -> UICollectionViewLayoutAttributes? {
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

public extension SKCLayoutPlugins.BindingKey {
    static func constant(_ value: Value) -> SKCollectionFlowLayout.BindingKey<Value> {
        .init(get: { value })
    }
}

public extension SKCLayoutPlugins.BindingKey where Value == Int {
    static let all = SKCollectionFlowLayout.BindingKey.constant(-1)
}

extension SKCLayoutPlugins.BindingKey: Equatable where Value: Equatable {
    public static func == (lhs: SKCollectionFlowLayout.BindingKey<Value>, rhs: SKCollectionFlowLayout.BindingKey<Value>) -> Bool {
        return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }
}

extension SKCLayoutPlugins.BindingKey: Hashable where Value: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(closure())
    }
}
