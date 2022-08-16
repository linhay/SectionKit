//
//  File.swift
//  
//
//  Created by linhey on 2022/8/11.
//

import UIKit
 
public protocol STCollectionActionProtocol: AnyObject {
    
    var sectionView: UICollectionView { get }
    var sectionInjection: STCollectionSectionInjection? { get set }
    func config(sectionView: UICollectionView)

}

public extension STCollectionActionProtocol {
    
    var sectionView: UICollectionView {
        guard let view = sectionInjection?.sectionView else {
            assertionFailure("can't find sectionView, before `SectionCollectionProtocol` into `Manager`")
            return UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        }
        return view
    }
    
    func config(sectionView: UICollectionView) {}
            
}


public extension STCollectionActionProtocol {
    
    func reload() {
        sectionInjection?.send(.reload)
    }
    
}
