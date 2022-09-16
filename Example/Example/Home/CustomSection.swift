//
//  File.swift
//  
//
//  Created by linhey on 2022/9/16.
//

import UIKit
import SectionKit

class CustomSection: SKCSectionProtocol {
    
    var sectionInjection: SKCSectionInjection?
    
    var minimumLineSpacing: CGFloat = 10
    var minimumInteritemSpacing: CGFloat = 10
    var sectionInset: UIEdgeInsets = .init(top: 20, left: 20, bottom: 20, right: 20)
    
    var itemCount: Int { 0 }
    
    func config(sectionView: UICollectionView) {
        register(StringCell.self)
    }
    
    func itemSize(at row: Int) -> CGSize {
        return .init(width: 44, height: 44)
    }
    
    func item(at row: Int) -> UICollectionViewCell {
        let cell = dequeue(at: row) as StringCell
        return cell
    }
    
    func item(selected row: Int) {}
    func item(willDisplay view: UICollectionViewCell, row: Int) {}
    func item(didEndDisplaying view: UICollectionViewCell, row: Int) {}
    func item(didBeginMultipleSelectionInteraction row: Int) {}
    /// ...
}
