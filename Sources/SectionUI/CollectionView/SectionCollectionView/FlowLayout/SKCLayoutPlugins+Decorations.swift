//
//  File.swift
//
//
//  Created by linhey on 2023/10/13.
//

import UIKit

public extension SKCLayoutPlugins {
    
    public typealias DecorationView = UICollectionReusableView & SKLoadViewProtocol
    
    public enum DecorationLayout {
        case header
        case cells
        case footer
    }
    
    public struct Decoration {
        public var sectionIndex: BindingKey<Int>
        public var viewType: DecorationView.Type
        public var zIndex: Int
        public var layout: [DecorationLayout]
        public var insets: UIEdgeInsets
        
        public init(sectionIndex: BindingKey<Int>,
                    viewType: DecorationView.Type,
                    zIndex: Int = -1,
                    layout: [DecorationLayout] = [.header, .cells, .footer],
                    insets: UIEdgeInsets = .zero)
        {
            self.sectionIndex = sectionIndex
            self.viewType = viewType
            self.zIndex = zIndex
            self.layout = layout
            self.insets = insets
        }
    }
    
    public class BindingKey<Value> {
        private let closure: () -> Value?
        
        public var wrappedValue: Value? { closure() }
        
        public init(get closure: @escaping () -> Value?) {
            self.closure = closure
        }
    }
    
    
    struct Decorations: SKCLayoutPlugin {
        
        let layout: UICollectionViewFlowLayout
        let decorations: [Decoration]
        let fixSupplementaryViewInset: SKCLayoutPlugins.FixSupplementaryViewInset?
        let cache: SKBinding<Set<IndexPath>>
        
        init(layout: UICollectionViewFlowLayout, 
             decorations: [Decoration],
             fixSupplementaryViewInset: SKCLayoutPlugins.FixSupplementaryViewInset?,
             cache: SKBinding<Set<IndexPath>>) {
            self.layout = layout
            self.decorations = decorations
            self.fixSupplementaryViewInset = fixSupplementaryViewInset
            self.cache = cache
            
            decorations.map(\.viewType).forEach { type in
                if let nib = type.nib {
                    layout.register(nib, forDecorationViewOfKind: type.identifier)
                } else {
                    layout.register(type.self, forDecorationViewOfKind: type.identifier)
                }
            }
        }
        
        func run(with attributes: [UICollectionViewLayoutAttributes]) -> [UICollectionViewLayoutAttributes]? {
            var dict = [Int: [Int: Decoration]](minimumCapacity: decorations.count)
            decorations.forEach { item in
                if let value = item.sectionIndex.wrappedValue {
                    if dict[value] == nil {
                        dict[value] = [item.zIndex: item]
                    } else {
                        dict[value]?[item.zIndex] = item
                    }
                }
            }
            
            var all: [Int: Decoration]?
            if let wrappedValue = BindingKey<Int>.all.wrappedValue {
                all = dict[wrappedValue]
            }
            
            var sectionSet = Set<Int>()
            let sections = attributes
                .map(\.indexPath.section)
                .filter { sectionSet.insert($0).inserted }
                .map { sectionIndex -> [UICollectionViewLayoutAttributes] in
                    if let decorations = dict[sectionIndex] ?? all {
                        return decorations.values.enumerated().compactMap { task(section: sectionIndex, index: $0, decoration: $1) }
                    } else {
                        return [UICollectionViewLayoutAttributes]()
                    }
                }.flatMap { $0 }
            
            return attributes + sections
            
        }
        
        func task(section: Int, index: Int, decoration: Decoration) -> UICollectionViewLayoutAttributes? {
            let sectionIndexPath = IndexPath(item: index, section: section)
            if cache.wrappedValue.contains(sectionIndexPath) {
                return nil
            }
            
            var frames = [CGRect]()
            
            if decoration.layout.contains(.header),
               let attributes = layout.layoutAttributesForSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, at: sectionIndexPath)
            {
                let frame: CGRect = attributes.frame
                if frame.width > 0, frame.height > 0 {
                    if let frame = fixSupplementaryViewInset?.run(with: [attributes])?.first?.frame {
                        frames.append(frame)
                    } else {
                        frames.append(frame)
                    }
                }
            }
            
            if decoration.layout.contains(.footer),
               let attributes = layout.layoutAttributesForSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, at: sectionIndexPath)
            {
                let frame: CGRect = attributes.frame
                if frame.width > 0, frame.height > 0 {
                    if let frame = fixSupplementaryViewInset?.run(with: [attributes])?.first?.frame {
                        frames.append(frame)
                    } else {
                        frames.append(frame)
                    }
                }
            }
            
            if decoration.layout.contains(.cells) {
                let cells = (0 ..< collectionView.numberOfItems(inSection: section)).compactMap { layout.layoutAttributesForItem(at: IndexPath(row: $0, section: section))?.frame }
                if let frame = CGRect.union(cells) {
                    frames.append(frame)
                }
            }
            
            guard let frame = CGRect.union(frames) else {
                return nil
            }
            
            let attribute = UICollectionViewLayoutAttributes(forDecorationViewOfKind: decoration.viewType.identifier, with: sectionIndexPath)
            attribute.zIndex = decoration.zIndex
            attribute.frame = frame.apply(insets: decoration.insets)
            cache.wrappedValue.update(with: sectionIndexPath)
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

fileprivate extension CGRect {
    static func union(_ list: [CGRect]) -> CGRect? {
        guard let first = list.first else {
            return nil
        }
        return list.dropFirst().reduce(first) { $0.union($1) }
    }
    
    func apply(insets: UIEdgeInsets) -> CGRect {
        .init(x: origin.x + insets.left,
              y: origin.y + insets.top,
              width: width - insets.left - insets.right,
              height: height - insets.top - insets.bottom)
    }
}

