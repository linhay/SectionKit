//___FILEHEADER___

import UIKit
import SectionUI

final class ___FILEBASENAMEASIDENTIFIER___: UICollectionViewCell, SKLoadViewProtocol, SKConfigurableView {
   
    typealias Model = <#ModelType#>
    
    static func preferredSize(limit size: CGSize, model: Model?) -> CGSize {
        guard let model = model else { return .zero }
        // return CGSize(width: size.width, height: 44)
    }
    
    func config(_ model: Model) {
       
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
