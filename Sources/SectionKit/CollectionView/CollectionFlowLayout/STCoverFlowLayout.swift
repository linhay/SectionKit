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

public class STCoverFlowLayout: UICollectionViewFlowLayout {
    override public func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        // 1.获取该范围内的布局数组
        let attributes = super.layoutAttributesForElements(in: rect)
        // 2.计算出整体中心点的 x 坐标
        let centerX = collectionView!.contentOffset.x + collectionView!.bounds.width / 2
        
        // 3.根据当前的滚动，对每个 cell 进行相应的缩放
        attributes?.forEach { attr in
            // 获取每个 cell 的中心点，并计算这俩个中心点的偏移值
            let pad = abs(centerX - attr.center.x)
            
            // 如何计算缩放比?我的思路是，距离越小，缩放比越小，缩放比最大是1，当俩个中心点的 x 坐标
            // 重合的时候，缩放比就为 1.
            
            // 缩放因子
            let factor = 0.0009
            // 计算缩放比
            let scale = 1 / (1 + pad * CGFloat(factor))
            attr.transform = CGAffineTransform(scaleX: scale, y: scale)
        }
        // 4.返回修改后的 attributes 数组
        return attributes
    }
    
    /// 滚动时停下的偏移量
    /// - Parameters:
    ///   - proposedContentOffset: 将要停止的点
    ///   - velocity: 滚动速度
    /// - Returns: 滚动停止的点
    override public func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity _: CGPoint) -> CGPoint {
        var targetPoint = proposedContentOffset
        // 1.计算中心点的 x 值
        let centerX = proposedContentOffset.x + collectionView!.bounds.width / 2
        // 2.获取这个点可视范围内的布局属性
        let attrs = layoutAttributesForElements(in: CGRect(x: proposedContentOffset.x, y: proposedContentOffset.y, width: collectionView!.bounds.size.width, height: collectionView!.bounds.size.height))
        
        // 3. 需要移动的最小距离
        var moveDistance = CGFloat(MAXFLOAT)
        // 4.遍历数组找出最小距离
        attrs!.forEach { attr in
            if abs(attr.center.x - centerX) < abs(moveDistance) {
                moveDistance = attr.center.x - centerX
            }
        }
        // 5.返回一个新的偏移点
        if targetPoint.x > 0, targetPoint.x < collectionViewContentSize.width - collectionView!.bounds.width {
            targetPoint.x += moveDistance
        }
        
        return targetPoint
    }
    
    override public func shouldInvalidateLayout(forBoundsChange _: CGRect) -> Bool {
        return true
    }
    
    override public var collectionViewContentSize: CGSize {
        return CGSize(width: sectionInset.left
                      + sectionInset.right
                      + (CGFloat(collectionView!.numberOfItems(inSection: 0)) * (itemSize.width + minimumLineSpacing))
                      - minimumLineSpacing, height: 0)
    }
}
#endif
