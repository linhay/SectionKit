//___FILEHEADER___

import UIKit
import SnapKit
import SectionUI

class ___FILEBASENAMEASIDENTIFIER___: UICollectionViewCell, SKLoadViewProtocol, SKConfigurableView {
   
    typealias Model = <#ModelType#>
    
    static func preferredSize(limit size: CGSize, model: Model?) -> CGSize {
        guard let model = model else { return .zero }
        // return CGSize(width: size.width, height: 44)
    }
    
    func config(_ model: Model) {
       
    }

    private lazy var stack: UIStackView = {
        let view = UIStackView(arrangedSubviews: [<#Views#>])
        view.spacing = 0
        view.axis = .horizontal
        view.distribution = .fill
        view.alignment = .fill
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(stack)
        stack.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
