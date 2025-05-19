//
//  01-IntroductionView.swift
//  Example
//
//  Created by linhey on 1/2/25.
//

import SwiftUI
import SectionUI
import SnapKit

/**
 # 创建高兼容性 Cell
 > 高兼容性 Cell 是指代遵循 SKLoadViewProtocol, SKConfigurableView 两个协议的
 > 在 SectionKit 中可以只使用原始的 UICollectionViewCell, 但是一个高兼容性 Cell 可以带来更为遍历的使用体验, 并且 SectionKit 中围绕高兼容性 Cell 进行了大量优化和接口.
 
 # SKLoadViewProtocol
 > SKLoadViewProtocol 主要用于加载纯代码文件, 也可以用于加载代码创建的 Cell, 但是不推荐.
 
 
 在本文件中将演示:
 1. 如何创建一个由代码创建的高兼容性 Cell
 2. 如何创建一个由 XIB 创建的高兼容性 Cell
*/


/// 1. 由代码创建的高兼容性 Cell
class HighlyCompatibleByCodeCell: UICollectionViewCell, SKLoadViewProtocol, SKConfigurableView {
    
    typealias Model = UIColor
    
    static func preferredSize(limit size: CGSize, model: Model?) -> CGSize {
        return .init(width: size.width, height: 44)
    }
    
    func config(_ model: Model) {
        contentView.backgroundColor = model
    }
}

/// 2. 由 XIB 创建的高兼容性 Cell
class HighlyCompatibleByXIBCell: UICollectionViewCell, SKLoadNibProtocol, SKConfigurableView {
    
    typealias Model = Void
    
    static func preferredSize(limit size: CGSize, model: Model?) -> CGSize {
        return .init(width: size.width, height: 44)
    }
    
    func config(_ model: Model) {
       
    }
}


#Preview {
    
    SKPreview
        .sections {
        [
            HighlyCompatibleByCodeCell
                .wrapperToSingleTypeSection([.red, .green, .blue]),
            HighlyCompatibleByXIBCell
                .wrapperToSingleTypeSection(count: 3)
        ]
    }
}
