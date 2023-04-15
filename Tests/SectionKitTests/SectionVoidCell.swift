//
//  File.swift
//
//
//  Created by linhey on 2022/4/21.
//

import SectionKit
#if canImport(UIKit)
import UIKit

final class SectionVoidCell: UICollectionViewCell, SKLoadViewProtocol {
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

extension SectionVoidCell {}

// MARK: - ConfigurableView

extension SectionVoidCell: SKConfigurableView {
    typealias Model = Void

    static func preferredSize(limit size: CGSize, model _: Void?) -> CGSize {
        return size
    }
}

// MARK: - UI

extension SectionVoidCell {
    private func setupView() {}
}

#endif