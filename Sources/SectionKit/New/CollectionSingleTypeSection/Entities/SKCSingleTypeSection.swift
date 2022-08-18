//
//  File.swift
//  
//
//  Created by linhey on 2022/8/18.
//

import UIKit

class SKCSingleTypeSection<Cell: UICollectionViewCell & SKConfigurableView>: SKCSingleTypeSectionProtocol {
    
    var models: [Model] = []
    var sectionInjection: SKCSectionInjection?

    func item(at row: Int) -> UICollectionViewCell {
       let cell = dequeue(at: row) as Cell
        cell.config(models[row])
        return cell
    }
    
    func itemSize(at row: Int) -> CGSize {
        guard models.indices.contains(row) else {
            return .zero
        }
        return Cell.preferredSize(limit: safeSizeProvider.size, model: models[row])
    }
    
}
