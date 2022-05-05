// MIT License
//
// Copyright (c) 2020 linhey
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

#if canImport(UIKit)
import UIKit

open class SectionCollectionFlowLayout: UICollectionViewFlowLayout {
    
    public typealias DecorationView = UICollectionReusableView & SectionLoadViewProtocol
    
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
        
        public init(sectionIndex: SectionCollectionFlowLayout.BindingKey<Int>,
                    viewType: SectionCollectionFlowLayout.DecorationView.Type,
                    zIndex: Int = -1,
                    layout: [SectionCollectionFlowLayout.DecorationLayout] = [.header, .cells, .footer],
                    insets: UIEdgeInsets = .zero) {
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
    
    /// 布局插件样式
    public enum PluginMode {
        /// 左对齐
        case left
        /// 居中对齐
        case centerX
        /// fix: header & footer 贴合 cell
        case fixSupplementaryViewInset
        /// fix: header & footer size与设定值不符
        case fixSupplementaryViewSize
        /// 置顶section header view
        case sectionHeadersPinToVisibleBounds([BindingKey<Int>])
        /// section 装饰视图
        case decorations([Decoration])
        
        var id: Int {
            switch self {
            case .left:    return 1
            case .centerX: return 2
            case .fixSupplementaryViewSize: return 3
            case .fixSupplementaryViewInset: return 4
            case .sectionHeadersPinToVisibleBounds: return 5
            case .decorations: return 6
            }
        }
        
        var priority: Int {
            switch self {
            case .left:    return 100
            case .centerX: return 100
            case .fixSupplementaryViewSize: return 1
            case .fixSupplementaryViewInset: return 2
            case .decorations: return 200
            case .sectionHeadersPinToVisibleBounds: return 300
            }
        }
    }
    
    public var pluginModes: [PluginMode] = [] {
        didSet {
            var set = Set<Int>()
            var newPluginModes = [PluginMode]()
            
            /// 优先级冲突去重
            for item in pluginModes {
                if case .decorations(let decorations) = item {
                    decorations.map(\.viewType).forEach { type in
                        if let nib = type.nib {
                            register(nib, forDecorationViewOfKind: type.identifier)
                        } else {
                            register(type.self, forDecorationViewOfKind: type.identifier)
                        }
                    }
                }
                
                if set.insert(item.priority).inserted {
                    newPluginModes.append(item)
                } else {
                    assertionFailure("mode冲突: \(newPluginModes.filter({ $0.priority == item.priority }))")
                }
            }
            /// mode 重排
            pluginModes = newPluginModes.sorted(by: { $0.priority < $1.priority })
        }
    }
    
    public func update(mode: PluginMode) {
        var modes = pluginModes.filter({ $0.id != mode.id })
        modes.append(mode)
        self.pluginModes = modes
    }
    
    private lazy var oldBounds = CGRect.zero
    private lazy var decorationViewCache = Set<Int>()
    private lazy var sectionRects = [Int: CGRect]()
    
    override public func prepare() {
        super.prepare()
        guard let collectionView = collectionView else {
            return
        }
        sectionRects.removeAll()
        decorationViewCache.removeAll()
        oldBounds = collectionView.bounds
    }
    
    open override func invalidationContext(forBoundsChange newBounds: CGRect) -> UICollectionViewLayoutInvalidationContext {
        let context = super.invalidationContext(forBoundsChange: newBounds)
        for pluginMode in pluginModes {
            switch pluginMode {
            case .sectionHeadersPinToVisibleBounds(let elements):
                if sectionHeadersPinToVisibleBounds {
                    assertionFailure("sectionHeadersPinToVisibleBounds == true 与 pluginMode.sectionHeadersPinToVisibleBounds 冲突")
                }
                let indexPaths = elements
                    .compactMap(\.wrappedValue)
                    .filter { index in
                        return sectionRects[index]?.intersects(newBounds) ?? true
                    }
                    .map({ IndexPath(row: 0, section: $0) })
                context.invalidateSupplementaryElements(ofKind: UICollectionView.elementKindSectionHeader, at: indexPaths)
            default:
                break
            }
        }
        return context
    }
    
    open override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard let attributes = super.layoutAttributesForSupplementaryView(ofKind: elementKind, at: indexPath) else {
            return nil
        }
        guard let collectionView = collectionView else {
            return nil
        }
        
        for pluginMode in pluginModes {
            switch pluginMode {
            case .sectionHeadersPinToVisibleBounds(let elements):
                guard attributes.representedElementKind == UICollectionView.elementKindSectionHeader,
                      elements.compactMap(\.wrappedValue).contains(attributes.indexPath.section),
                      let rect = sectionRects[indexPath.section] else {
                    break
                }
                attributes.zIndex += attributes.indexPath.section
                if collectionView.contentOffset.y >= rect.minY, collectionView.contentOffset.y <= rect.maxY {
                    if collectionView.contentOffset.y + attributes.frame.height >= rect.maxY {
                        attributes.frame.origin.y = rect.maxY - attributes.frame.height
                    } else {
                        attributes.frame.origin.y = collectionView.contentOffset.y
                    }
                }
            default:
                break
            }
        }
        return attributes
    }
    
    override open func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let collectionView = collectionView,
              var attributes = super.layoutAttributesForElements(in: rect) else {
            return nil
        }
        
        if pluginModes.isEmpty {
            return attributes
        }
        
        attributes = attributes.compactMap({ $0.copy() as? UICollectionViewLayoutAttributes })
        for mode in pluginModes {
            switch mode {
            case .sectionHeadersPinToVisibleBounds:
                attributes
                    .filter({ attribute in
                        switch attribute.representedElementCategory {
                        case .supplementaryView:
                            return true
                        case .cell:
                            return true
                        case .decorationView:
                            return false
                        @unknown default:
                            return false
                        }
                    })
                    .forEach { attribute in
                        if let rect = sectionRects[attribute.indexPath.section] {
                            sectionRects[attribute.indexPath.section] = rect.union(attribute.frame)
                        } else {
                            sectionRects[attribute.indexPath.section] = attribute.frame
                        }
                    }
                break
            case .fixSupplementaryViewSize:
                attributes = modeFixSupplementaryViewSize(collectionView, attributes: attributes) ?? []
            case .centerX:
                attributes = modeCenterX(collectionView, attributes: attributes) ?? []
            case .left:
                attributes = modeLeft(collectionView, attributes: attributes) ?? []
            case .fixSupplementaryViewInset:
                attributes = modeFixSupplementaryViewInset(collectionView, attributes: attributes) ?? []
            case .decorations(let decorations):
                attributes = modeDecorations(collectionView, decorations: decorations, attributes: attributes) ?? []
            }
        }
        
        return attributes
    }
    
    override public func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return oldBounds.size != newBounds.size
        || sectionHeadersPinToVisibleBounds
        || sectionFootersPinToVisibleBounds
        || pluginModes.contains(where: { $0.priority == PluginMode.sectionHeadersPinToVisibleBounds([]).priority })
    }
    
}

// MARK: - Mode
private extension SectionCollectionFlowLayout {
    
    func modeDecorations(_ collectionView: UICollectionView,
                         decorations: [Decoration],
                         attributes: [UICollectionViewLayoutAttributes]) -> [UICollectionViewLayoutAttributes]? {
        
        let hasFixSupplementaryViewInset = pluginModes.contains(where: { $0.id == PluginMode.fixSupplementaryViewInset.id })

        func task(section: Int, decoration: Decoration) -> UICollectionViewLayoutAttributes? {
            if decorationViewCache.contains(section) {
                return nil
            }
            
            let sectionIndexPath = IndexPath(item: 0, section: section)
            
            var frames = [CGRect]()
            let inset = insetForSection(at: section)

            if decoration.layout.contains(.header),
               var frame = self.layoutAttributesForSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, at: sectionIndexPath)?.frame,
               frame.width > 0,
               frame.height > 0 {
                if hasFixSupplementaryViewInset {
                    frame.origin.y += inset.top
                }
                frames.append(frame)
            }
            
            if decoration.layout.contains(.cells) {
                let cells = (0..<collectionView.numberOfItems(inSection: section)).compactMap({ layoutAttributesForItem(at: IndexPath(row: $0, section: section))?.frame })
                if let frame = CGRect.union(cells) {
                    frames.append(frame)
                }
            }
            
            if decoration.layout.contains(.footer),
               var frame = self.layoutAttributesForSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, at: sectionIndexPath)?.frame,
               frame.width > 0,
               frame.height > 0 {
                if hasFixSupplementaryViewInset {
                    frame.origin.y -= inset.bottom
                }
                frames.append(frame)
            }
            
            guard var frame = CGRect.union(frames) else {
                return nil
            }
            
            frame = .init(x: frame.origin.x+decoration.insets.left,
                          y: frame.origin.y+decoration.insets.top,
                          width: frame.width-decoration.insets.left-decoration.insets.right,
                          height: frame.height-decoration.insets.top-decoration.insets.bottom)
            
            let attribute = UICollectionViewLayoutAttributes(forDecorationViewOfKind: decoration.viewType.identifier, with: sectionIndexPath)
            attribute.zIndex = decoration.zIndex
            attribute.frame = frame
            decorationViewCache.update(with: attribute.indexPath.section)
            return attribute
        }
        
        var dict = [Int: Decoration](minimumCapacity: decorations.count)
        decorations.forEach { item in
            if let value = item.sectionIndex.wrappedValue {
                dict[value] = item
            }
        }
        
        var all: Decoration?
        if let wrappedValue = BindingKey<Int>.all.wrappedValue {
            all = dict[wrappedValue]
        }
        
        var sectionSet = Set<Int>()
        let sections = attributes
            .map(\.indexPath.section)
            .filter({ sectionSet.insert($0).inserted })
        
        return attributes + sections.compactMap { sectionIndex in
            if let decoration = dict[sectionIndex] ?? all {
                return task(section: sectionIndex, decoration: decoration)
            } else {
                return nil
            }
        }
    }
    
    func modeFixSupplementaryViewSize(_ collectionView: UICollectionView, attributes: [UICollectionViewLayoutAttributes]) -> [UICollectionViewLayoutAttributes]? {
        attributes
            .filter { $0.representedElementCategory == .supplementaryView }
            .forEach { attribute in
                if attribute.representedElementKind == UICollectionView.elementKindSectionFooter {
                    attribute.size = self.footerSizeForSection(at: attribute.indexPath.section)
                } else if attribute.representedElementKind == UICollectionView.elementKindSectionHeader {
                    attribute.size = self.headerSizeForSection(at: attribute.indexPath.section)
                }
            }
        return attributes
    }
    
    func modeFixSupplementaryViewInset(_ collectionView: UICollectionView, attributes: [UICollectionViewLayoutAttributes]) -> [UICollectionViewLayoutAttributes]? {
        attributes
            .filter { $0.representedElementCategory == .supplementaryView }
            .forEach { attribute in
                let inset = insetForSection(at: attribute.indexPath.section)
                if attribute.representedElementKind == UICollectionView.elementKindSectionFooter {
                    attribute.frame.origin.y -= inset.bottom
                } else if attribute.representedElementKind == UICollectionView.elementKindSectionHeader {
                    attribute.frame.origin.y += inset.top
                }
            }
        return attributes
    }
    
    func modeCenterX(_ collectionView: UICollectionView, attributes: [UICollectionViewLayoutAttributes]) -> [UICollectionViewLayoutAttributes]? {
        
        func appendLine(_ lineStore: [UICollectionViewLayoutAttributes],
                        _ collectionView: UICollectionView) -> [UICollectionViewLayoutAttributes] {
            guard let firstItem = lineStore.first else {
                return lineStore
            }
            
            var spacing = self.minimumInteritemSpacing
            
            if let delegate = collectionView.delegate as? UICollectionViewDelegateFlowLayout {
                spacing = delegate.collectionView?(collectionView, layout: self, minimumInteritemSpacingForSectionAt: firstItem.indexPath.section) ?? spacing
            }
            
            let allWidth = lineStore.reduce(0, { $0 + $1.frame.width }) + spacing * CGFloat(lineStore.count - 1)
            let offset = (collectionView.bounds.width - allWidth) / 2
            firstItem.frame.origin.x = offset
            _ = lineStore.dropFirst().reduce(firstItem) { (result, item) -> UICollectionViewLayoutAttributes in
                item.frame.origin.x = result.frame.maxX + spacing
                return item
            }
            return lineStore
        }
        
        var lineStore = [UICollectionViewLayoutAttributes]()
        var list = [UICollectionViewLayoutAttributes]()
        
        for item in attributes {
            guard item.representedElementCategory == .cell else {
                list.append(item)
                continue
            }
            
            if lineStore.isEmpty {
                lineStore.append(item)
            } else if let lastItem = lineStore.last,
                      lastItem.indexPath.section == item.indexPath.section,
                      lastItem.frame.minY == item.frame.minY {
                lineStore.append(item)
            } else {
                list.append(contentsOf: appendLine(lineStore, collectionView))
                lineStore = [item]
            }
        }
        
        list.append(contentsOf: appendLine(lineStore, collectionView))
        return list
    }
    
    func modeLeft(_ collectionView: UICollectionView, attributes: [UICollectionViewLayoutAttributes]) -> [UICollectionViewLayoutAttributes]? {
        
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
            
            let delegate = collectionView.delegate as? UICollectionViewDelegateFlowLayout
            let insets = delegate?.collectionView?(collectionView,
                                                   layout: self,
                                                   insetForSectionAt: item.indexPath.section) ?? sectionInset
            
            let minimumInteritemSpacing = delegate?.collectionView?(collectionView,
                                                                    layout: self,
                                                                    minimumInteritemSpacingForSectionAt: item.indexPath.section) ?? minimumInteritemSpacing
            
            switch scrollDirection {
            case .horizontal:
                if let lastItem = section.last {
                    if lastItem.indexPath.section != item.indexPath.section {
                        item.frame.origin.x = lastItem.frame.maxX + insets.left
                    } else {
                        item.frame.origin.x = lastItem.frame.maxX + minimumInteritemSpacing
                    }
                } else {
                    item.frame.origin.x = insets.left
                }
            case .vertical:
                if section.last?.indexPath.section != item.indexPath.section {
                    section.removeAll()
                }
                
                if let lastItem = section.last, lastItem.frame.maxY == item.frame.maxY {
                    item.frame.origin.x = lastItem.frame.maxX + minimumInteritemSpacing
                } else {
                    item.frame.origin.x = insets.left
                }
            @unknown default:
                break
            }
            
            section.append(item)
            list.append(item)
        }
        return list
    }
    
}

private extension SectionCollectionFlowLayout {
    
    func headerSizeForSection(at section: Int) -> CGSize {
        guard let collectionView = collectionView,
              let delegate = collectionView.delegate as? UICollectionViewDelegateFlowLayout,
              let size = delegate.collectionView?(collectionView, layout: self, referenceSizeForHeaderInSection: section) else {
            return .zero
        }
        return size
    }
    
    func footerSizeForSection(at section: Int) -> CGSize {
        guard let collectionView = collectionView,
              let delegate = collectionView.delegate as? UICollectionViewDelegateFlowLayout,
              let size = delegate.collectionView?(collectionView, layout: self, referenceSizeForFooterInSection: section) else {
            return .zero
        }
        return size
    }
    
    func insetForSection(at section: Int) -> UIEdgeInsets {
        guard let collectionView = collectionView,
              let delegate = collectionView.delegate as? UICollectionViewDelegateFlowLayout,
              let inset = delegate.collectionView?(collectionView, layout: self, insetForSectionAt: section) else {
            return sectionInset
        }
        return inset
    }
    
}

extension CGRect {
    
    static func union(_ list: [CGRect]) -> CGRect? {
        guard let first = list.first else {
            return nil
        }
        return list.dropFirst().reduce(first, { $0.union($1) })
    }
    
}

public extension SectionCollectionFlowLayout.BindingKey {
    
    static func constant(_ value: Value) -> SectionCollectionFlowLayout.BindingKey<Value> {
        .init(get: { value })
    }
    
}

public extension SectionCollectionFlowLayout.BindingKey where Value == Int {
    
    static let all = SectionCollectionFlowLayout.BindingKey.constant(-1)
    
}

extension SectionCollectionFlowLayout.BindingKey: Equatable where Value: Equatable {
    
    public static func == (lhs: SectionCollectionFlowLayout.BindingKey<Value>, rhs: SectionCollectionFlowLayout.BindingKey<Value>) -> Bool {
        return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }
    
}

extension SectionCollectionFlowLayout.BindingKey: Hashable where Value: Hashable {
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.closure())
    }
    
}

#endif
