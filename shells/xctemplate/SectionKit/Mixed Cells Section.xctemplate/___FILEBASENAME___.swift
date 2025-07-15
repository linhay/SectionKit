//___FILEHEADER___

import UIKit
import SectionUI

class ___FILEBASENAMEASIDENTIFIER___: SKCSectionProtocol, SKSafeSizeProviderProtocol {
    
    enum CellType {
        case cell(<#CellType#>.Model)
    }
    
    var sectionInjection: SKCSectionInjection?
    lazy var safeSizeProvider: SKSafeSizeProvider = defaultSafeSizeProvider
    var cellTypes: [CellType] = []
    var itemCount: Int { cellTypes.count }
        
    init() {
        // cellTypes.append(.cell(model))
    }
    
    func config(sectionView: UICollectionView) {
        register(<#CellType#>.self)
    }
    
    func itemSize(at row: Int) -> CGSize {
        switch cellTypes[row] {
        case .cell(let model):
            return <#CellType#>.preferredSize(limit: safeSizeProvider.size, model: model)
        }
    }
    
    func item(at row: Int) -> UICollectionViewCell {
        switch cellTypes[row] {
        case .cell(let model):
            let cell = dequeue(at: row) as <#CellType#>
            cell.config(model)
            return cell
        }
    }
    
    func item(selected row: Int) {
        switch cellTypes[row] {
        case .cell(let model):
            // action
            break
        }
    }
    
}
