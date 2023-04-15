//
//  StringCell.swift
//  Example
//
//  Created by linhey on 2022/8/17.
//

#if canImport(UIKit)
import UIKit
import SectionKit
import StemColor

class StringCell: UICollectionViewCell, SKLoadViewProtocol, SKConfigurableView {
    
    struct Model {
        let text: String
        let size: CGSize
        let color: UIColor
        
        init(text: String, size: CGSize, color: UIColor = StemColor.random.convert()) {
            self.text = text
            self.size = size
            self.color = color
        }
    }
    
    static func preferredSize(limit size: CGSize, model: Model?) -> CGSize {
        return model?.size ?? .zero
    }

    func config(_ model: Model) {
        titleLabel.text = model.text
        contentView.backgroundColor = model.color
    }
    
    private lazy var titleLabel: UILabel = {
        let view = UILabel(frame: .zero)
        view.textColor = .black
        view.textAlignment = .center
        view.font = UIFont.preferredFont(forTextStyle: .body, compatibleWith: nil)
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

// MARK: - UI

extension StringCell {
    private func setupView() {
        contentView.layer.borderColor = UIColor.black.cgColor
        contentView.layer.borderWidth = 2
        contentView.layer.cornerRadius = 4
        contentView.layer.cornerCurve = .continuous

        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

#endif