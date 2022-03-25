//
//  File.swift
//  
//
//  Created by linhey on 2022/3/10.
//

#if canImport(UIKit)
import UIKit

public protocol SectionCollectionDequeueProtocol {
    
    var sectionView: UICollectionView { get }
    var sectionIndex: Int { get }
    
}

public extension SectionCollectionDequeueProtocol {
    
    func dequeue<T: UICollectionViewCell & SectionLoadViewProtocol>(at row: Int) -> T {
        return sectionView.dequeueReusableCell(withReuseIdentifier: T.identifier, for: .init(row: row, section: sectionIndex)) as! T
    }
    
    func dequeue<T: UICollectionReusableView & SectionLoadViewProtocol>(kind: SectionSupplementaryKind) -> T {
        return sectionView.dequeueReusableSupplementaryView(ofKind: kind.rawValue,
                                                               withReuseIdentifier: T.identifier,
                                                               for: IndexPath(row: 0, section: sectionIndex)) as! T
    }
    
    /// 注册 `LoadViewProtocol` 类型的 UICollectionViewCell
    ///
    /// - Parameter cell: UICollectionViewCell
    func register<T: UICollectionViewCell & SectionLoadViewProtocol>(_ cell: T.Type) {
        if let nib = T.nib {
            sectionView.register(nib, forCellWithReuseIdentifier: T.identifier)
        } else {
            sectionView.register(T.self, forCellWithReuseIdentifier: T.identifier)
        }
    }
    
    func register<T: UICollectionReusableView & SectionLoadViewProtocol>(_ view: T.Type, for kind: SectionSupplementaryKind) {
        if let nib = T.nib {
            sectionView.register(nib, forSupplementaryViewOfKind: kind.rawValue, withReuseIdentifier: T.identifier)
        } else {
            sectionView.register(T.self, forSupplementaryViewOfKind: kind.rawValue, withReuseIdentifier: T.identifier)
        }
    }
    
}
#endif
