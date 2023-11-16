//
//  File.swift
//  
//
//  Created by linhey on 2023/10/13.
//

import UIKit
import SectionKit

protocol SKCLayoutPlugin {
    var layout: UICollectionViewFlowLayout { get }
}

extension SKCLayoutPlugin {
    
    var collectionView: UICollectionView {
        guard let view = layout.collectionView else {
            assertionFailure("can't find sectionView, before `SectionCollectionProtocol` into `Manager`")
            return UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        }
        return view
    }
    
    var delegateFlowLayout: UICollectionViewDelegateFlowLayout? {
        collectionView.delegate as? UICollectionViewDelegateFlowLayout
    }
    
    var scrollDirection: UICollectionView.ScrollDirection {
        layout.scrollDirection
    }

    func headerSize(at section: Int) -> CGSize {
        guard let size = delegateFlowLayout?.collectionView?(collectionView,
                                                            layout: layout,
                                                            referenceSizeForHeaderInSection: section) else {
            return .zero
        }
        return size
    }
    
    func footerSize(at section: Int) -> CGSize {
        guard let size = delegateFlowLayout?.collectionView?(collectionView,
                                                            layout: layout,
                                                            referenceSizeForFooterInSection: section) else {
            return .zero
        }
        return size
    }
    
    func insetForSection(at section: Int) -> UIEdgeInsets {
        guard let inset = delegateFlowLayout?.collectionView?(collectionView,
                                                              layout: layout,
                                                              insetForSectionAt: section) else {
            return layout.sectionInset
        }
        return inset
    }
    
    func minimumInteritemSpacing(at section: Int) -> CGFloat {
        guard let minimumInteritemSpacing = delegateFlowLayout?.collectionView?(collectionView,
                                                              layout: layout,
                                                              minimumInteritemSpacingForSectionAt: section) else {
            return layout.minimumInteritemSpacing
        }
        return minimumInteritemSpacing
    }
    
    func minimumLineSpacing(at section: Int) -> CGFloat {
        guard let minimumLineSpacing = delegateFlowLayout?.collectionView?(collectionView,
                                                              layout: layout,
                                                              minimumLineSpacingForSectionAt: section) else {
            return layout.minimumLineSpacing
        }
        return minimumLineSpacing
    }
    
    func kind(of attribute: UICollectionViewLayoutAttributes) -> SKSupplementaryKind {
        return .init(rawValue: attribute.representedElementKind ?? "")
    }
    
}

extension CGRect {
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
