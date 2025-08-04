//
//  ColorCell.swift
//  Example
//
//  Created by linhey on 1/3/25.
//

import UIKit
import SectionUI

class ColorCell: UICollectionViewCell, SKLoadViewProtocol, SKConfigurableView {
    
    class Model: Equatable {
        static func == (lhs: ColorCell.Model, rhs: ColorCell.Model) -> Bool {
            lhs === rhs
        }
                
        let text: String
        let color: UIColor?
        let alignment: NSTextAlignment
        init(text: String, color: UIColor?, alignment: NSTextAlignment = .center) {
            self.text = text
            self.color = color
            self.alignment = alignment
        }
        
        deinit { print("[deinit]", Self.self) }
        
    }
    
    static func preferredSize(limit size: CGSize, model: Model?) -> CGSize {
        return size
    }
    
    func config(_ model: Model) {
        titleLabel.text = model.text
        titleLabel.textAlignment = model.alignment
        contentView.backgroundColor = model.color ?? .clear
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
            make.edges.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
