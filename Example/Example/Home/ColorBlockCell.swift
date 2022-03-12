//
//  ColorBlockCell.swift
//  Example
//
//  Created by linhey on 2022/3/12.
//

import UIKit
import SectionKit

final class ColorBlockCell: UICollectionViewCell, LoadViewProtocol {
    
    private lazy var titleLabel: UILabel = {
        let view = UILabel(frame: .zero)
        view.textColor = .black
        view.textAlignment = .center
        view.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
}

// MARK: - Actions
extension ColorBlockCell {
    
}

// MARK: - ConfigurableView
extension ColorBlockCell: ConfigurableView {
    
    struct Model {
        let color: UIColor
        let text: String
        let size: CGSize
    }
    
    static func preferredSize(limit size: CGSize, model: Model?) -> CGSize {
        guard let model = model else {
            return .zero
        }
        return model.size
    }
    
    func config(_ model: Model) {
        contentView.backgroundColor = model.color
        titleLabel.text = model.text
        
    }
    
}

// MARK: - UI
extension ColorBlockCell {
    
    private func setupView() {
        contentView.layer.borderColor = UIColor.black.cgColor
        contentView.layer.borderWidth = 2
        contentView.layer.cornerRadius = 2
        contentView.layer.cornerCurve = .continuous
        
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
}
