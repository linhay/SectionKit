//
//  ReusableView.swift
//  Example
//
//  Created by linhey on 2022/5/5.
//

import SectionKit
import Stem
import UIKit
import StemColor

class ReusableView: UICollectionReusableView, SKLoadViewProtocol, SKConfigurableView {
    static func preferredSize(limit size: CGSize, model _: String?) -> CGSize {
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

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
