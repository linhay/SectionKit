//
//  CenteredCollectionViewFlowLayout.swift
//  Example
//
//  Created by linhey on 5/27/25.
//

import UIKit
class CenteredCollectionViewFlowLayout: UICollectionViewFlowLayout {

    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint,
                                      withScrollingVelocity velocity: CGPoint) -> CGPoint {
        guard let collectionView = collectionView else { return proposedContentOffset }

        let isHorizontal = scrollDirection == .horizontal
        let collectionViewSize = collectionView.bounds.size
        let midSide = isHorizontal
            ? proposedContentOffset.x + collectionViewSize.width / 2
            : proposedContentOffset.y + collectionViewSize.height / 2

        // 获取当前可见区域
        let targetRect = CGRect(origin: proposedContentOffset, size: collectionViewSize)
        guard let attributesArray = layoutAttributesForElements(in: targetRect), !attributesArray.isEmpty else {
            return proposedContentOffset
        }

        // 找出距离中心最近的 cell
        var closestAttribute: UICollectionViewLayoutAttributes?
        var minDistance = CGFloat.greatestFiniteMagnitude

        for attributes in attributesArray {
            let itemCenter = isHorizontal ? attributes.center.x : attributes.center.y
            let distance = abs(itemCenter - midSide)
            if distance < minDistance {
                minDistance = distance
                closestAttribute = attributes
            }
        }

        guard let closest = closestAttribute else {
            return proposedContentOffset
        }

        // 修正 offset，使 cell 居中
        if isHorizontal {
            let offsetX = closest.center.x - collectionViewSize.width / 2
            let maxOffsetX = collectionView.contentSize.width - collectionViewSize.width + collectionView.contentInset.right
            let minOffsetX = -collectionView.contentInset.left
            let finalOffsetX = min(max(offsetX, minOffsetX), maxOffsetX)
            return CGPoint(x: finalOffsetX, y: proposedContentOffset.y)
        } else {
            let offsetY = closest.center.y - collectionViewSize.height / 2
            let maxOffsetY = collectionView.contentSize.height - collectionViewSize.height + collectionView.contentInset.bottom
            let minOffsetY = -collectionView.contentInset.top
            let finalOffsetY = min(max(offsetY, minOffsetY), maxOffsetY)
            return CGPoint(x: proposedContentOffset.x, y: finalOffsetY)
        }
    }
}
