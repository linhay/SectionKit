//
//  PhotoPreviewContentPhotoView.swift
//  Example
//
//  Created by linhey on 11/27/24.
//

import SectionUI
import UIKit

class BrowerLabelView: UIView, BrowerItemViewProtocol, SKConfigurableView {
       
    typealias Model = BrowerItemModelProtocol
    
    static func preferredSize(limit size: CGSize, model: Model?) -> CGSize {
        return model?.size ?? .init()
    }
    
    func config(_ model: any Model) {
        self.label.text = model.id
    }
    
    private lazy var label: UILabel = {
        let view = UILabel()
        view.font = .systemFont(ofSize: 36, weight: .semibold)
        view.textColor = .white
        view.textAlignment = .center
        view.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        view.setContentHuggingPriority(.defaultHigh, for: .vertical)
        view.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        view.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .red
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.black.cgColor
        addSubview(label)
        label.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
