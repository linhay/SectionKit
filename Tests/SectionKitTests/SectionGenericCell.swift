//
//  File.swift
//
//
//  Created by linhey on 2022/5/9.
//

import SectionKit
#if canImport(UIKit)
import UIKit

final class SectionGenericCell<Model>: UICollectionViewCell, SKLoadViewProtocol {
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

extension SectionGenericCell {}

// MARK: - ConfigurableView

extension SectionGenericCell: SKConfigurableView {
    static func preferredSize(limit _: CGSize, model _: Model?) -> CGSize {
        return .init(width: 100, height: 100)
    }

    func config(_: Model) {}
}

// MARK: - UI

extension SectionGenericCell {
    private func setupView() {}
}

#endif