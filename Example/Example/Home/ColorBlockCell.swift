//
//  ColorBlockCell.swift
//  Example
//
//  Created by linhey on 2022/3/12.
//

import SectionKit
import UIKit

final class ColorBlockCell: UICollectionViewCell, SectionLoadViewProtocol {
    private lazy var titleLabel: UILabel = {
        let view = UILabel(frame: .zero)
        view.textColor = .black
        view.textAlignment = .center
        view.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        return view
    }()

    private var model: Model?

    override init(frame _: CGRect) {
        super.init(frame: .zero)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
}

// MARK: - Actions

extension ColorBlockCell {}

// MARK: - ConfigurableView

extension ColorBlockCell: ConfigurableView {
    struct Model: Equatable {
        let color: UIColor
        var text: String
        let size: CGSize
    }

    static func preferredSize(limit _: CGSize, model: Model?) -> CGSize {
        guard let model = model else {
            return .zero
        }
        return model.size
    }

    func config(_ model: Model) {
        self.model = model
        contentView.backgroundColor = model.color
        titleLabel.text = model.text
        contentView.layer.borderColor = UIColor.black.cgColor
        contentView.layer.cornerRadius = 2
    }

    override var isSelected: Bool {
        get {
            super.isSelected
        }
        set {
            super.isSelected = newValue
            titleLabel.text = newValue ? "$ \(model!.text) $" : model!.text
        }
    }

    override var isHighlighted: Bool {
        get {
            super.isSelected
        }
        set {
            super.isSelected = newValue
            if newValue {
                contentView.backgroundColor = .blue.withAlphaComponent(0.4)
            } else {
                contentView.backgroundColor = model?.color
            }
        }
    }

    func update(text: String) {
        titleLabel.text = text
        model?.text = text
    }
}

// MARK: - UI

extension ColorBlockCell {
    private func setupView() {
        contentView.layer.borderWidth = 2
        contentView.layer.cornerCurve = .continuous
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
