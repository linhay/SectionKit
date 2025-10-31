//
//  File.swift
//
//
//  Created by linhey on 2022/8/12.
//

import Foundation
#if canImport(UIKit)
import UIKit

public protocol SKSafeSizeProviderProtocol: AnyObject {
    var safeSizeProvider: SKSafeSizeProvider { get }
}

public struct SKSafeSizeProvider {
    
    public typealias Block = (_ context: Context) -> CGSize

    public struct Context {
        public let kind: SKSupplementaryKind
        public let indexPath: IndexPath
        public init(kind: SKSupplementaryKind, indexPath: IndexPath) {
            self.kind = kind
            self.indexPath = indexPath
        }
        
        public static func cell(at row: Int, in section: SKCSectionProtocol) -> Context {
            return .init(kind: .cell, indexPath: section.indexPath(from: row))
        }
        
        public static func header(in section: SKCSectionProtocol) -> Context {
            return .init(kind: .header, indexPath: section.indexPath(from: 0))
        }
        
        public static func footer(in section: SKCSectionProtocol) -> Context {
            return .init(kind: .footer, indexPath: section.indexPath(from: 0))
        }
        
    }
    
    private let block: Block
    
    @available(*, deprecated, renamed: "size(context:)")
    public var size: CGSize {
        block(.init(kind: .cell, indexPath: .init(row: 0, section: 0)))
    }
    
    @available(*, deprecated)
    public init(block: @escaping Block) {
        self.block = block
    }
    
    public func size(context: Context) -> CGSize {
        block(context)
    }
    
    
    public init(block: @escaping () -> CGSize) {
        self.block = { _ in
            block()
        }
    }
    
    public static func `default`(sectionView: @escaping () -> UICollectionView?,
                          sectionInset: @escaping () -> UIEdgeInsets?) -> SKSafeSizeProvider {
        SKSafeSizeProvider { context in
            guard let sectionView = sectionView() else { return .zero }
            let sectionInset = sectionInset() ?? .zero
            guard let flowLayout = sectionView.collectionViewLayout as? UICollectionViewFlowLayout else {
                return  .init(width: sectionView.bounds.width
                              - sectionView.contentInset.left
                              - sectionView.contentInset.right
                              - sectionInset.left
                              - sectionInset.right,
                              height: sectionView.bounds.height
                              - sectionView.contentInset.top
                              - sectionView.contentInset.bottom
                              - sectionInset.top
                              - sectionInset.bottom)
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
            
            guard min(size.width, size.height) > 0 else {
                return CGSize(width: max(size.width, 0), height: max(size.height, 0))
            }
            
            return size
        }

    }
    
}

public struct SKSafeSizeTransform {
    
    public let transform: (CGSize) -> CGSize
    
    public init(transform: @escaping (CGSize) -> CGSize) {
        self.transform = transform
    }
    
    public static func print(prefix: String) -> SKSafeSizeTransform {
#if DEBUG
        .init { size in
            debugPrint(prefix, size)
            return size
        }
#else
        .init { $0 }
#endif
    }

    /// 基于宽度设置高度的比例
    public static func height(asRatioOfWidth ratio: CGFloat) -> SKSafeSizeTransform {
        SKSafeSizeTransform { CGSize(width: $0.width, height: $0.width * ratio) }
    }
    
    /// 基于高度设置宽度的比例
    public static func width(asRatioOfHeight ratio: CGFloat) -> SKSafeSizeTransform {
        SKSafeSizeTransform { CGSize(width: $0.height * ratio, height: $0.height) }
    }
    
    public static func fixed(height value: CGFloat) -> SKSafeSizeTransform {
        SKSafeSizeTransform { CGSize(width: $0.width, height: value) }
    }
    
    public static func fixed(width value: CGFloat) -> SKSafeSizeTransform {
        SKSafeSizeTransform { CGSize(width: value, height: $0.height) }
    }
    
    public static func offset(height value: CGFloat) -> SKSafeSizeTransform {
        SKSafeSizeTransform { CGSize(width: $0.width, height: $0.height + value) }
    }
    
    public static func offset(width value: CGFloat) -> SKSafeSizeTransform {
        SKSafeSizeTransform { CGSize(width: $0.width + value, height: $0.height) }
    }
    
}

public extension SKCViewDelegateFlowLayoutProtocol where Self: SKCSectionActionProtocol {
    
    var defaultSafeSizeProvider: SKSafeSizeProvider {
        SKSafeSizeProvider.default(sectionView: { [weak self] in
            return self?.sectionView
        }, sectionInset: { [weak self] in
            return self?.sectionInset
        })
    }
    
}

#endif
