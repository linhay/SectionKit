//
//  File.swift
//  
//
//  Created by linhey on 2022/8/12.
//

import Foundation
#if canImport(UIKit)
import UIKit

/// 提供 Cell - preferredSize(limit size: CGSize, model: Model?) 中 limit size 的值
public enum SKSafeSizeProviderKind {
    /// 使用默认的 safeSizeProvider 提供者尺寸
    case `default`
    /// 使用固定的 CGSize 来提供尺寸
    case fixed(CGSize)
    /// 根据比例来计算尺寸
    case fraction(Double)
}

public struct SKSafeSizeProvider {

    public var size: CGSize { block() }
    private let block: () -> CGSize
    
    public init(block: @escaping () -> CGSize) {
        self.block = block
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

public extension SKSafeSizeProviderProtocol where Self: SKCSectionActionProtocol & SKCViewDelegateFlowLayoutProtocol {
    
    var defaultSafeSizeProvider: SKSafeSizeProvider {
        SKSafeSizeProvider { [weak self] in
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
            
            guard min(size.width, size.height) > 0 else {
                return CGSize(width: max(size.width, 0), height: max(size.height, 0))
            }
            
            return size
        }
    }
    
}

public protocol SKSafeSizeProviderProtocol: AnyObject {
    var safeSizeProvider: SKSafeSizeProvider { get }
    var cellSafeSizeProvider: SKSafeSizeProvider? { get }
}

public extension SKSafeSizeProviderProtocol {
    var cellSafeSizeProvider: SKSafeSizeProvider? { nil }
}

public protocol SKSafeSizeSetterProviderProtocol: SKSafeSizeProviderProtocol {
    var safeSizeProvider: SKSafeSizeProvider { set get }
    var cellSafeSizeProvider: SKSafeSizeProvider? { set get }
}

public extension SKSafeSizeSetterProviderProtocol where Self: SKCSectionProtocol {
    
    @discardableResult
    func cellSafeSize(_ kind: SKSafeSizeProviderKind, transforms: SKSafeSizeTransform) -> Self {
        cellSafeSize(kind, transforms: [transforms])
    }

    @discardableResult
    func cellSafeSize(_ kind: SKSafeSizeProviderKind, transforms: [SKSafeSizeTransform] = []) -> Self {
        
        func transform(size: CGSize) -> CGSize {
            return transforms.reduce(into: size, { $0 = $1.transform($0) })
        }
        
        switch kind {
        case .fixed(let size):
            self.cellSafeSizeProvider = .init(block: {
                return transform(size: size)
            })
        case .default:
            self.cellSafeSizeProvider = .init(block: { [weak self] in
                guard let self = self else { return .zero }
                let size = self.safeSizeProvider.size
                return transform(size: size)
            })
        case .fraction(let value):
            self.cellSafeSizeProvider = .init(block: { [weak self] in
                guard let self = self else { return .zero }
                let size = safeSizeProvider.size
                guard value > 0, value <= 1 else {
                    return size
                }
                
                let count = floor(1 / value)
                let itemWidth = floor((size.width - (count - 1) * minimumInteritemSpacing) / count)
                let newSize = CGSize(width: itemWidth, height: size.height)
                return transform(size: newSize)
            })
        }
        return self
    }
    
    @discardableResult
    func safeSize(_ provider: SKSafeSizeProvider) -> Self {
        safeSizeProvider = provider
        return self
    }
    
    @discardableResult
    func safeSize(_ path: KeyPath<Self, SKSafeSizeProvider>) -> Self {
        return safeSize(self[keyPath: path])
    }
    
    @discardableResult
    func safeSize<Root>(_ path: KeyPath<Root, SKSafeSizeProvider>, on object: Root) -> Self {
        return safeSize(object[keyPath: path])
    }
}

#endif
