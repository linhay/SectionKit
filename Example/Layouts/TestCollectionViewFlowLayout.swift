//
//  CenteredCollectionViewFlowLayout.swift
//  Example
//
//  Created by linhey on 5/27/25.
//

import UIKit

class TestCollectionViewFlowLayout: UICollectionViewFlowLayout {

    override func prepare() {
        print("prepare()")
        super.prepare()
    }

    override var collectionViewContentSize: CGSize {
        print("collectionViewContentSize")
        return super.collectionViewContentSize
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        print("layoutAttributesForElements(in: \(rect))")
        return super.layoutAttributesForElements(in: rect)
    }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        print("layoutAttributesForItem(at: \(indexPath))")
        return super.layoutAttributesForItem(at: indexPath)
    }

    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        let value = super.shouldInvalidateLayout(forBoundsChange: newBounds)
        print("shouldInvalidateLayout(forBoundsChange: \(newBounds)) -> \(value)")
        return value
    }

    override func invalidateLayout() {
        print("invalidateLayout()")
        super.invalidateLayout()
    }

    override func invalidateLayout(with context: UICollectionViewLayoutInvalidationContext) {
        print("invalidateLayout(with: \(context))")
        super.invalidateLayout(with: context)
    }

    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        print("targetContentOffset(forProposedContentOffset: \(proposedContentOffset), velocity: \(velocity))")
        return super.targetContentOffset(forProposedContentOffset: proposedContentOffset, withScrollingVelocity: velocity)
    }

    override func prepare(forCollectionViewUpdates updateItems: [UICollectionViewUpdateItem]) {
        print("prepare(forCollectionViewUpdates: \(updateItems))")
        super.prepare(forCollectionViewUpdates: updateItems)
    }

    override func finalizeCollectionViewUpdates() {
        print("finalizeCollectionViewUpdates()")
        super.finalizeCollectionViewUpdates()
    }

    override func initialLayoutAttributesForAppearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        print("initialLayoutAttributesForAppearingItem(at: \(itemIndexPath))")
        return super.initialLayoutAttributesForAppearingItem(at: itemIndexPath)
    }

    override func finalLayoutAttributesForDisappearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        print("finalLayoutAttributesForDisappearingItem(at: \(itemIndexPath))")
        return super.finalLayoutAttributesForDisappearingItem(at: itemIndexPath)
    }
}
