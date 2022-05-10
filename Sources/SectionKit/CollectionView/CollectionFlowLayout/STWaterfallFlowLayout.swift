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

public class STWaterfallFlowLayout: UICollectionViewFlowLayout {
    /// 列缓存
    private var colStore = [Int: [UICollectionViewLayoutAttributes]]()
    /// 列宽度映射
    private var widthStore = [Int: CGFloat]()
    /// 列高映射
    private var heightStore = [Int: CGFloat]()
    /// cell缓存
    private var cache = [UICollectionViewLayoutAttributes]()
    /// 解析到的cell序列
    private var parseIndexPath: IndexPath?
    
    private var cacheBounds = CGRect.zero
    
    override public func prepare() {
        super.prepare()
        colStore.removeAll()
        widthStore.removeAll()
        heightStore.removeAll()
        cache.removeAll()
        parseIndexPath = nil
        cacheBounds = collectionView?.bounds ?? .zero
    }
    
    override public var collectionViewContentSize: CGSize {
        guard let collectionView = collectionView,
              let maxY = heightStore.values.max()
        else {
            return .zero
        }
        return .init(width: collectionView.bounds.width, height: maxY)
    }
    
    override public func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return cacheBounds.size != newBounds.size
    }
    
    override open func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        parse(in: .init(x: rect.minX, y: rect.minY, width: rect.width, height: rect.height * 2))
        return cache
    }
    
    private func parse(in rect: CGRect) {
        if let min = heightStore.values.min(), min > rect.maxY {
            return
        }
        
        guard let collectionView = collectionView,
              let dataSource = collectionView.dataSource,
              let sectionCount = dataSource.numberOfSections?(in: collectionView)
        else {
            return
        }
        
        let initIndexPath: IndexPath
        if let indexPath = parseIndexPath {
            initIndexPath = .init(item: indexPath.item + 1, section: indexPath.section)
        } else {
            initIndexPath = .init(row: 0, section: 0)
        }
        let initSection = initIndexPath.section
        for section in initIndexPath.section ..< sectionCount {
            let count = dataSource.collectionView(collectionView, numberOfItemsInSection: section)
            if initIndexPath.item >= count {
                continue
            }
            for item in (initSection == section ? initIndexPath.item : 0) ..< count {
                let cell = parseCell(at: .init(row: item, section: section))
                cache.append(cell)
                if let min = heightStore.values.min(), min > rect.maxY {
                    return
                }
            }
        }
    }
    
    private func parseCell(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes {
        let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
        parseIndexPath = indexPath
        
        guard let collectionView = collectionView,
              let delegate = collectionView.delegate as? UICollectionViewDelegateFlowLayout,
              let size = delegate.collectionView?(collectionView, layout: self, sizeForItemAt: indexPath)
        else {
            return attributes
        }
        
        let inset = delegate.collectionView?(collectionView, layout: self, insetForSectionAt: indexPath.section) ?? .zero
        let interitemSpacer = delegate.collectionView?(collectionView, layout: self, minimumInteritemSpacingForSectionAt: indexPath.section) ?? 0
        let lineSpacer = delegate.collectionView?(collectionView, layout: self, minimumLineSpacingForSectionAt: indexPath.section) ?? 0
        
        attributes.frame.size = size
        attributes.frame.origin = .init(x: 0, y: 0)
        
        let minX = widthStore.values.reduce(0) { $0 + $1 } + CGFloat(widthStore.keys.count) * interitemSpacer
        if minX + size.width <= collectionView.bounds.width - inset.right - inset.left {
            attributes.frame.origin.x = minX + inset.left
            attributes.frame.origin.y = inset.top
            
            let index = colStore.keys.count
            widthStore[index] = attributes.frame.width
            heightStore[index] = attributes.frame.maxY
            colStore[index] = [attributes]
            return attributes
        }
        
        if let index = widthStore.compactMap({ $0.value == size.width ? $0.key : nil })
            .sorted(by: { heightStore[$0] == heightStore[$1] ? $0 < $1 : heightStore[$0]! < heightStore[$1]! }).first,
           let lastItem = colStore[index]?.last
        {
            attributes.frame.origin = .init(x: lastItem.frame.minX, y: lastItem.frame.maxY + lineSpacer)
            colStore[index] = (colStore[index] ?? []) + [attributes]
            heightStore[index] = attributes.frame.maxY
        } else {
            let index = colStore.keys.count
            
            widthStore[index] = attributes.frame.width
            heightStore[index] = attributes.frame.maxY
            colStore[index] = [attributes]
        }
        
        return attributes
    }
}
#endif
