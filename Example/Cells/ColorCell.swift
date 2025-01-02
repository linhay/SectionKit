//
//  ColorCell.swift
//  Example
//
//  Created by linhey on 1/3/25.
//

import UIKit
import SectionUI

class ColorCell: UICollectionViewCell, SKLoadViewProtocol, SKConfigurableView {
    
    struct Model {
        let text: String
        let color: UIColor?
    }
    
    static func preferredSize(limit size: CGSize, model: Model?) -> CGSize {
        return size
    }
    
    func config(_ model: Model) {
        titleLabel.text = model.text
        contentView.backgroundColor = model.color?.withAlphaComponent(0.5) ?? .clear
    }

    private lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.font = .systemFont(ofSize: 18, weight: .regular)
        view.textColor = .black
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
