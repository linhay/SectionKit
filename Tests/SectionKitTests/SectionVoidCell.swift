//
//  File.swift
//  
//
//  Created by linhey on 2022/4/21.
//

import UIKit
import SectionKit

final class SectionVoidCell: UICollectionViewCell, SectionLoadViewProtocol {
    
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
extension SectionVoidCell {
    
}

// MARK: - ConfigurableView
extension SectionVoidCell: ConfigurableView {
    
    typealias Model = Void
    
    static func preferredSize(limit size: CGSize, model: Void?) -> CGSize {
        return size
    }
    
}

// MARK: - UI
extension SectionVoidCell {
    
    private func setupView() {
        
    }
}
