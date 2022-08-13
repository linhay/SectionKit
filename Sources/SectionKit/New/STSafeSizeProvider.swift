//
//  File.swift
//  
//
//  Created by linhey on 2022/8/12.
//

import Foundation
import UIKit

public protocol STSafeSizeProviderProtocol: AnyObject {
    var safeSizeProvider: STSafeSizeProvider { get }
}

public struct STSafeSizeProvider {
    
    public var size: CGSize { block() }
    private let block: () -> CGSize
    
    public init(block: @escaping () -> CGSize) {
        self.block = block
    }
    
}

public extension STCollectionViewDelegateFlowLayoutProtocol where Self: STCollectionActionProtocol {
    
    var defaultSafeSizeProvider: STSafeSizeProvider {
        STSafeSizeProvider { [weak self] in
            guard let self = self else { return .zero }
            let sectionView = self.sectionView
            let sectionInset = self.sectionInset
            guard let flowLayout = sectionView.collectionViewLayout as? UICollectionViewFlowLayout else {
                return sectionView.bounds.size
            }
            
            let size: CGSize
            switch flowLayout.scrollDirection {
            case .horizontal:
                size = .init(width: sectionView.bounds.width,
                             height: sectionView.bounds.height
                             - sectionView.contentInset.top
                             - sectionView.contentInset.bottom
                             - sectionInset.top
                             - sectionInset.bottom)
            case .vertical:
                size = .init(width: sectionView.bounds.width
                             - sectionView.contentInset.left
                             - sectionView.contentInset.right
                             - sectionInset.left
                             - sectionInset.right,
                             height: sectionView.bounds.height)
            @unknown default:
                size = sectionView.bounds.size
            }
            assert(min(size.width, size.height) > 0, "无法取得正确的 size: \(size)")
            return size
        }
    }
    
}
