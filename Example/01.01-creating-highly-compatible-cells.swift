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
 > SKLoadViewProtocol 主要用于加载纯代码视图.
 > SKSKLoadNibProtocol 主要用于加载 XIB 视图.
 
 # SKConfigurableView
 > SKConfigurableView 主要用于定义 / 配置 Cell 的 Model, 以及确定配置完 Model 后 Cell 的尺寸.
 
 在本文件中将演示:
 1. 如何创建一个由代码创建的高兼容性 Cell
 2. 如何创建一个由 XIB 创建的高兼容性 Cell
 3. 如何创建一个适应高度的高兼容性 Cell, 使用 SKConfigurableView 的高级变体 SKConfigurableAdaptiveMainView
    - 记得添加 final 标记
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

/// 3. 适应高度的高兼容性 Cell
/// > 使用 SKConfigurableAdaptiveMainView, 记得添加 final 标记
final class HighlyCompatibleWithAdaptiveCell: UICollectionViewCell, SKLoadViewProtocol, SKConfigurableAdaptiveMainView {
    
    static let adaptive = SpecializedAdaptive()
    typealias Model = String
        
    func config(_ model: Model) {
        self.contentConfiguration = UIHostingConfiguration(content: {
            ZStack {
                Color.black.ignoresSafeArea()
                VStack {
                    Text(model)
                        .foregroundStyle(.white)
                }
            }
        })
        .margins(.vertical, 4)
        .margins(.horizontal, 0)
        .background(.clear)
    }
    
}

#Preview {
    SKPreview
        .sections {
        [
            HighlyCompatibleByCodeCell
                .wrapperToSingleTypeSection([.red, .green, .blue]),
            HighlyCompatibleByXIBCell
                .wrapperToSingleTypeSection(count: 3),
            HighlyCompatibleWithAdaptiveCell
                .wrapperToSingleTypeSection([
                "HighlyCompatibleWithAdaptiveCell",
                "HighlyCompatibleWithAdaptiveCell\nHighlyCompatibleWithAdaptiveCell",
                "HighlyCompatibleWithAdaptiveCell\nHighlyCompatibleWithAdaptiveCell\nHighlyCompatibleWithAdaptiveCell",
                ])
                
        ]
    }
}
