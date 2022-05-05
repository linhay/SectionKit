//
//  ReusableView.swift
//  Example
//
//  Created by linhey on 2022/5/5.
//

import UIKit
import SectionKit
import Stem

class ReusableView: UICollectionReusableView, SectionLoadViewProtocol, ConfigurableView {
    
    static func preferredSize(limit size: CGSize, model: String?) -> CGSize {
        return .init(width: size.width, height: 44)
    }
    
    func config(_ model: String) {
        backgroundColor = .clear
        layer.borderColor = UIColor.purple.cgColor
        layer.borderWidth = 1
        titleLabel.text = model
    }
    
    private lazy var titleLabel: UILabel = {
        let view = UILabel(frame: .zero)
        view.textColor = .black
        view.textAlignment = .center
        view.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.borderColor = UIColor.black.cgColor
        layer.borderWidth = 1
        backgroundColor = StemColor.random.convert()
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
