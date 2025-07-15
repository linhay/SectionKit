//
//  TextReusableView.swift
//  Example
//
//  Created by linhey on 1/2/25.
//

import UIKit
import SectionUI

class TextReusableView: UICollectionReusableView, SKLoadViewProtocol, SKConfigurableView {
   
    struct Model {
        let text: String
        let color: UIColor
        var alignment: NSTextAlignment
        init(text: String, color: UIColor, alignment: NSTextAlignment = .left) {
            self.text = text
            self.color = color
            self.alignment = alignment
        }
    }
    
    static func preferredSize(limit size: CGSize, model: Model?) -> CGSize {
        return .init(width: size.width, height: 44)
    }
    
    func config(_ model: Model) {
        titleLabel.text = model.text
        titleLabel.textAlignment = model.alignment
        descLabel.text = nil
        descLabel.isHidden = true
        backgroundColor = model.color
    }
    
    func desc(_ string: String) {
        descLabel.text = string
        descLabel.isHidden = false
    }

    lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.font = .systemFont(ofSize: 18, weight: .regular)
        view.textColor = .black
        view.setContentHuggingPriority(.defaultHigh, for: .vertical)
        view.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        view.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        view.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        return view
    }()
    
    private lazy var descLabel: UILabel = {
        let view = UILabel()
        view.font = .systemFont(ofSize: 18, weight: .regular)
        view.textColor = .black.withAlphaComponent(0.6)
        view.setContentHuggingPriority(.defaultHigh, for: .vertical)
        view.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        view.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        view.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        return view
    }()
    
    private lazy var hStackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [titleLabel, descLabel])
        view.spacing = 12
        view.axis = .horizontal
        view.distribution = .fill
        view.alignment = .center
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(hStackView)
        layer.borderWidth = 1
        layer.borderColor = UIColor.white.cgColor
        hStackView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
        
}
