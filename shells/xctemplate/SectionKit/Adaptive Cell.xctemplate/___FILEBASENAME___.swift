//___FILEHEADER___

import UIKit
import SectionUI

final class ___FILEBASENAMEASIDENTIFIER___: UICollectionViewCell, SKLoadViewProtocol, SKConfigurableAdaptiveView {
   
    typealias Model = <#ModelType#>

    static var adaptive: SKAdaptive<MKTextView> = .init(direction: .vertical)
    // static var adaptive: SKAdaptive<MKTextView> = .init(direction: .vertical, content: \.#<SubView>#)

    func config(_ model: Model) {
       
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
