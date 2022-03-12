//
//  File.swift
//  
//
//  Created by linhey on 2022/3/10.
//

#if canImport(UIKit)
import UIKit

public protocol SectionCollectionDequeueProtocol: SectionProtocol {}

public extension SectionCollectionDequeueProtocol {
    
    private var collectionView: UICollectionView {
        guard let view = core?.sectionView as? UICollectionView else {
            assertionFailure("can't find CollectionView")
            return UICollectionView()
        }
        return view
    }
    
    
    func dequeue<T: UICollectionViewCell & LoadViewProtocol>(at row: Int) -> T {
        return collectionView.dequeueReusableCell(withReuseIdentifier: T.identifier, for: indexPath(from: row)) as! T
    }

    func dequeue<T: UICollectionReusableView & LoadViewProtocol>(kind: SupplementaryViewKindType) -> T {
        return collectionView.dequeueReusableSupplementaryView(ofKind: kind.rawValue,
                                                            withReuseIdentifier: T.identifier,
                                                            for: IndexPath(row: 0, section: index)) as! T
    }
    
    /// 注册 `LoadViewProtocol` 类型的 UICollectionViewCell
    ///
    /// - Parameter cell: UICollectionViewCell
    func register<T: UICollectionViewCell & LoadViewProtocol>(_ cell: T.Type) {
        if let nib = T.nib {
            collectionView.register(nib, forCellWithReuseIdentifier: T.identifier)
        } else {
            collectionView.register(T.self, forCellWithReuseIdentifier: T.identifier)
        }
    }

    func register<T: UICollectionReusableView & LoadViewProtocol>(_ view: T.Type, for kind: SupplementaryViewKindType) {
        if let nib = T.nib {
            collectionView.register(nib, forSupplementaryViewOfKind: kind.rawValue, withReuseIdentifier: T.identifier)
        } else {
            collectionView.register(T.self, forSupplementaryViewOfKind: kind.rawValue, withReuseIdentifier: T.identifier)
        }
    }
    
}
#endif
