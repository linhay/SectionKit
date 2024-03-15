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
import SectionKit

open class SKCollectionFlowLayout: UICollectionViewFlowLayout, SKCDelegateObserverProtocol {

    public typealias DecorationView = UICollectionReusableView & SKLoadViewProtocol
    public typealias FixSupplementaryViewInset = SKCLayoutPlugins.FixSupplementaryViewInset.Direction
    public typealias DecorationLayout = SKCLayoutPlugins.DecorationLayout
    public typealias Decoration = SKCLayoutPlugins.AnyDecoration
    public typealias BindingKey = SKCLayoutPlugins.BindingKey
    public typealias PluginMode = SKCLayoutPlugins.Mode

    class LayoutStore {
        
        lazy var cells: [IndexPath: UICollectionViewLayoutAttributes] = [:]
        lazy var decorations: [String: [IndexPath: UICollectionViewLayoutAttributes]] = [:]
        lazy var supplementaries: [String: [IndexPath: UICollectionViewLayoutAttributes]] = [:]
                
        init(attributes: [UICollectionViewLayoutAttributes]) {
            for attribute in attributes {
                store(attribute: attribute)
            }
        }
        
        func store(attribute: UICollectionViewLayoutAttributes) {
            switch attribute.representedElementCategory {
            case .cell:
                cells[attribute.indexPath] = attribute
            case .supplementaryView:
                guard let representedElementKind = attribute.representedElementKind else { return }
                if supplementaries[representedElementKind] == nil {
                    supplementaries[representedElementKind] = [attribute.indexPath: attribute]
                } else {
                    supplementaries[representedElementKind]?[attribute.indexPath] = attribute
                }
            case .decorationView:
                guard let representedElementKind = attribute.representedElementKind else { return }
                if decorations[representedElementKind] == nil {
                    decorations[representedElementKind] = [attribute.indexPath: attribute]
                } else {
                    decorations[representedElementKind]?[attribute.indexPath] = attribute
                }
            @unknown default:
                return
            }

        }

    }
    
    struct PluginsStore {
        var decorations: SKCLayoutPlugins.Decorations?
        init(decorations: SKCLayoutPlugins.Decorations? = nil) {
            self.decorations = decorations
        }
    }
    
    public var plugins: SKCLayoutPlugins? {
        didSet {
            sectionHeadersPinToVisibleBoundsPlugin = nil
        }
    }
    
    private lazy var oldBounds = CGRect.zero
    private var layoutTempStore: LayoutStore?
    private var layoutStore: LayoutStore = .init(attributes: [])
    private var pluginsStore: PluginsStore = .init()
    private var sectionHeadersPinToVisibleBoundsPlugin: SKCLayoutPlugins.SectionHeadersPinToVisibleBounds?
    
    public func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath, value: Void) {
        pluginsStore.decorations?.observe(kind: .willDisplay, identifier: elementKind, at: indexPath, view: view)
    }
    
    public func collectionView(_ collectionView: UICollectionView, didEndDisplayingSupplementaryView view: UICollectionReusableView, forElementOfKind elementKind: String, at indexPath: IndexPath, value: Void) {
        pluginsStore.decorations?.observe(kind: .didEndDisplay, identifier: elementKind, at: indexPath, view: view)
    }
    
    override public func prepare() {
        super.prepare()
        guard let collectionView = collectionView else {
            return
        }
        layoutStore = .init(attributes: [])
        oldBounds = collectionView.bounds
    }
    
    override open func invalidationContext(forBoundsChange newBounds: CGRect) -> UICollectionViewLayoutInvalidationContext {
        let context = super.invalidationContext(forBoundsChange: newBounds)
        sectionHeadersPinToVisibleBoundsPlugin?.invalidationContext(context: context, forBoundsChange: newBounds)
        return context
    }

    override open func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        defer { layoutTempStore = nil }
        
        guard var attributes = super.layoutAttributesForElements(in: rect) else {
            return nil
        }
        guard let modes = plugins?.modes, !modes.isEmpty else { return attributes }

        attributes = attributes.compactMap { $0.copy() as? UICollectionViewLayoutAttributes }
        layoutTempStore = .init(attributes: attributes)
        
        var fixSupplementaryViewInset: SKCLayoutPlugins.FixSupplementaryViewInset?
        for mode in modes {
            switch mode {
            case .sectionHeadersPinToVisibleBounds(let elements):
                if sectionHeadersPinToVisibleBoundsPlugin == nil {
                    sectionHeadersPinToVisibleBoundsPlugin = .init(layout: self, elements: elements)
                }
                attributes = sectionHeadersPinToVisibleBoundsPlugin?.run(with: attributes) ?? []
            case .fixSupplementaryViewSize:
                attributes = SKCLayoutPlugins.FixSupplementaryViewSize(layout: self, condition: .excluding([])).run(with: attributes) ?? []
            case .adjustSupplementaryViewSize(let condition):
                attributes = SKCLayoutPlugins.FixSupplementaryViewSize(layout: self, condition: condition).run(with: attributes) ?? []
            case .centerX:
                attributes = SKCLayoutPlugins.CenterX(layout: self).run(with: attributes) ?? []
            case .left:
                attributes = SKCLayoutPlugins.Left(layout: self).run(with: attributes) ?? []
            case let .fixSupplementaryViewInset(direction):
                fixSupplementaryViewInset = SKCLayoutPlugins.FixSupplementaryViewInset(layout: self, direction: direction)
                attributes = fixSupplementaryViewInset?.run(with: attributes) ?? []
            case let .decorations(decorations):
                let plugin = SKCLayoutPlugins.Decorations(layout: self,
                                                          decorations: decorations,
                                                          fixSupplementaryViewInset: fixSupplementaryViewInset)
                pluginsStore.decorations = plugin
                attributes = plugin.run(with: attributes) ?? []
            }
        }
        
        return attributes
    }
        
    open override func layoutAttributesForDecorationView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        if let decoration = layoutTempStore?.decorations[elementKind]?[indexPath] {
            return decoration
        } else if let decoration = layoutStore.decorations[elementKind]?[indexPath] {
            return decoration
        } else if let decoration = super.layoutAttributesForDecorationView(ofKind: elementKind, at: indexPath) {
            layoutStore.store(attribute: decoration)
            return decoration
        } else {
            return nil
        }
    }
    
    open override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        if let cell = layoutTempStore?.cells[indexPath] {
            return cell
        } else {
            return super.layoutAttributesForItem(at: indexPath)
        }
    }

    func attributes(of supplementary: String, at indexPath: IndexPath, useCache: Bool) -> UICollectionViewLayoutAttributes? {
        let attributes: UICollectionViewLayoutAttributes?
        if useCache, let supplementary = layoutTempStore?.supplementaries[supplementary]?[indexPath] {
            attributes = supplementary
        } else {
            attributes = super.layoutAttributesForSupplementaryView(ofKind: supplementary, at: indexPath)
        }
        guard let attributes = attributes else { return attributes }
        sectionHeadersPinToVisibleBoundsPlugin?.layoutAttributesForSupplementaryView(ofKind: supplementary, at: indexPath, with: attributes)
        return attributes
    }
    
    override open func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return attributes(of: elementKind, at: indexPath, useCache: true)
    }
    
    override public func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        oldBounds.size != newBounds.size 
        || sectionHeadersPinToVisibleBounds
        || sectionFootersPinToVisibleBounds
        || sectionHeadersPinToVisibleBoundsPlugin != nil
    }
}
#endif
