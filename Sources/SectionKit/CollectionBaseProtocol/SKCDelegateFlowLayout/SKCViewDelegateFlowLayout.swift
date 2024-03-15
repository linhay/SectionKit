//
//  File.swift
//  
//
//  Created by linhey on 2022/8/12.
//

#if canImport(UIKit)
import UIKit

class SKCViewDelegateFlowLayout: SKCDelegateFlowLayoutForwardProtocol {
    
    private let section: (_ indexPath: IndexPath) -> SKCViewDelegateFlowLayoutProtocol?
    
    init(section: @escaping (_ indexPath: IndexPath) -> SKCViewDelegateFlowLayoutProtocol?) {
        self.section = section
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> SKHandleResult<CGSize> {
        guard let section = self.section(indexPath) else {
            return .next
        }
        
        var size = section.itemSize(at: indexPath.item)
        
        if size.width < 0 || size.height < 0 {
            assertionFailure("Negative sizes are not supported in the flow layout, \(section)")
            size = .init(width: max(size.width, 0), height: max(size.height, 0))
        }
        
        if indexPath.section == 0,
           indexPath.row == 0,
           size == .zero {
            size = .init(width: 0.01, height: 0.01)
        }
        
        return .handle(size)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> SKHandleResult<UIEdgeInsets> {
        .handleable(self.section(.init(row: 0, section: section))?.sectionInset)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> SKHandleResult<CGFloat> {
        .handleable(self.section(.init(row: 0, section: section))?.minimumLineSpacing)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> SKHandleResult<CGFloat> {
        .handleable(self.section(.init(row: 0, section: section))?.minimumInteritemSpacing)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> SKHandleResult<CGSize> {
        .handleable(self.section(.init(row: 0, section: section))?.headerSize)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> SKHandleResult<CGSize> {
        .handleable(self.section(.init(row: 0, section: section))?.footerSize)
    }
    
}

#endif
