//
//  TextCell.swift
//  Example
//
//  Created by linhey on 1/2/25.
//

import UIKit
import SectionUI

class TextCell: UICollectionViewCell, SKLoadViewProtocol, SKConfigurableView {
    
    struct Model {
        let text: String
        let color: UIColor
        let height: CGFloat?
        
        init(text: String, color: UIColor, height: CGFloat? = 44) {
            self.text = text
            self.color = color
            self.height = height
        }
    }
    
    static func preferredSize(limit size: CGSize, model: Model?) -> CGSize {
        if let height = model?.height {
            return .init(width: size.width, height: height)
        } else {
            return size
        }
    }
    
    func config(_ model: Model) {
        titleLabel.text = model.text
        descLabel.text = nil
        descLabel.isHidden = true
        contentView.backgroundColor = model.color.withAlphaComponent(0.5)
    }
    
    func desc(_ string: String) {
        descLabel.text = string
        descLabel.isHidden = false
    }

    private lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.font = .systemFont(ofSize: 18, weight: .regular)
        view.textColor = .black
        view.snp.makeConstraints { make in
            make.height.equalTo(20)
        }
        return view
    }()
    
    private lazy var descLabel: UILabel = {
        let view = UILabel()
        view.font = .systemFont(ofSize: 18, weight: .regular)
        view.textColor = .black.withAlphaComponent(0.6)
        view.snp.makeConstraints { make in
            make.height.equalTo(20)
        }
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
        contentView.addSubview(hStackView)
        hStackView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
