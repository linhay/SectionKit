//
//  File.swift
//  
//
//  Created by linhey on 2022/8/12.
//

import UIKit

class SKCViewDelegateFlowLayout: SKCDelegate, UICollectionViewDelegateFlowLayout {
    
    private let _section: (_ indexPath: IndexPath) -> SKCViewDelegateFlowLayoutProtocol?
    
    private func section(_ indexPath: IndexPath, function: StaticString = #function) -> SKCViewDelegateFlowLayoutProtocol? {
        debugPrint("delegate - \(indexPath) - \(function)")
        return _section(indexPath)
    }
    
    init(section: @escaping (_ indexPath: IndexPath) -> SKCViewDelegateFlowLayoutProtocol?,
         endDisplaySection: @escaping (_ indexPath: IndexPath) -> SKCDelegateProtocol?,
         sections: @escaping () -> [SKCDelegateProtocol]) {
        self._section = section
        super.init(section: section,
                   endDisplaySection: endDisplaySection,
                   sections: sections)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let section = self.section(indexPath) else {
            return .zero
        }
        let size = section.itemSize(at: indexPath.item)
        if indexPath.section == 0, indexPath.row == 0, size == .zero {
            return .init(width: 0.01, height: 0.01)
        } else {
            return size
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        guard let section = self.section(.init(row: 0, section: section)) else {
            return .zero
        }
        return section.sectionInset
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        guard let section = self.section(.init(row: 0, section: section)) else {
            return .zero
        }
        return section.minimumLineSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        guard let section = self.section(.init(row: 0, section: section)) else {
            return .zero
        }
        return section.minimumInteritemSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        guard let section = self.section(.init(row: 0, section: section)) else {
            return .zero
        }
        return section.headerSize
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        guard let section = self.section(.init(row: 0, section: section)) else {
            return .zero
        }
        return section.footerSize
    }
    
}
