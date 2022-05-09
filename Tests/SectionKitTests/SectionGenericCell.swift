//
//  File.swift
//  
//
//  Created by linhey on 2022/5/9.
//

import UIKit
import SectionKit

final class SectionGenericCell<Model>: UICollectionViewCell, SectionLoadViewProtocol {
    
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
extension SectionGenericCell {
    
}

// MARK: - ConfigurableView
extension SectionGenericCell: SectionConfigurableView {
    
    static func preferredSize(limit size: CGSize, model: Model?) -> CGSize {
        return .init(width: 100, height: 100)
    }
    
    func config(_ model: Model) {
        
    }
    
}

// MARK: - UI
extension SectionGenericCell {
    
    private func setupView() {
        
    }
    
}
