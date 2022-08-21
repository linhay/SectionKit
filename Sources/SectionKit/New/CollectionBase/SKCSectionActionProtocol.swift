//
//  File.swift
//  
//
//  Created by linhey on 2022/8/11.
//

import UIKit
 
public protocol SKCSectionActionProtocol: AnyObject {
    
    var sectionView: UICollectionView { get }
    var sectionInjection: SKCSectionInjection? { get set }
    func config(sectionView: UICollectionView)

}

public extension SKCSectionActionProtocol {
    
    var sectionView: UICollectionView {
        guard let view = sectionInjection?.sectionView else {
            assertionFailure("can't find sectionView, before `SectionCollectionProtocol` into `Manager`")
            return UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        }
        return view
    }
    
    func config(sectionView: UICollectionView) {}
            
}

public extension SKCSectionActionProtocol {
    
    func reload() {
        sectionInjection?.send(.reload)
    }
    
}

public extension SKCSectionActionProtocol {
    
    func indexPath(from value: Int) -> IndexPath {
        guard let injection = sectionInjection else {
            assertionFailure()
            return .init(item: value, section: 0)
        }
        return .init(item: value, section: injection.index)
    }
    
    func dequeue<T: UICollectionViewCell>(at row: Int, identifier: String = String(describing: T.self)) -> T {
        return sectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath(from: row)) as! T
    }

    func dequeue<T: UICollectionReusableView>(kind: SKSupplementaryKind, identifier: String = String(describing: T.self)) -> T {
        return sectionView.dequeueReusableSupplementaryView(ofKind: kind.rawValue, withReuseIdentifier: identifier, for: indexPath(from: 0)) as! T
    }
    
    /// 注册 `LoadViewProtocol` 类型的 UICollectionViewCell
    ///
    /// - Parameter cell: UICollectionViewCell
    func register<T: UICollectionViewCell>(_ cell: T.Type) where T: SKLoadViewProtocol {
        if let nib = T.nib {
            sectionView.register(nib, forCellWithReuseIdentifier: T.identifier)
        } else {
            sectionView.register(T.self, forCellWithReuseIdentifier: T.identifier)
        }
    }

    func register<T: UICollectionReusableView>(_ view: T.Type, for kind: SKSupplementaryKind) where T: SKLoadViewProtocol {
        if let nib = T.nib {
            sectionView.register(nib, forSupplementaryViewOfKind: kind.rawValue, withReuseIdentifier: T.identifier)
        } else {
            sectionView.register(T.self, forSupplementaryViewOfKind: kind.rawValue, withReuseIdentifier: T.identifier)
        }
    }
    
}
