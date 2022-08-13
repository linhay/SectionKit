//
//  File.swift
//  
//
//  Created by linhey on 2022/8/13.
//

import UIKit
import Combine

public class STCollectionSectionContext {
    
    class SectionViewProvider {
        
        var sectionView: UICollectionView?
        
        init(_ sectionView: UICollectionView?) {
            self.sectionView = sectionView
        }
        
    }
    
    let index: Int
    var sectionViewProvider: SectionViewProvider
    var sectionView: UICollectionView? { sectionViewProvider.sectionView }
    
    init(index: Int, sectionView: SectionViewProvider) {
        self.sectionViewProvider = sectionView
        self.index = index
    }
    
}
