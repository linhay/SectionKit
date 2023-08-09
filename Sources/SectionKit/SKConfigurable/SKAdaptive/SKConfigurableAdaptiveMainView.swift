//
//  ConfigurableAdaptiveMainView.swift
//  
//
//  Created by linhey on 2023/8/9.
//

#if canImport(UIKit)
import UIKit

/** 适配主视图协议, 以当前视图作为 AdaptiveView 进行内容调整
 
 final class CustomCell: UIView, SKConfigurableAdaptiveMainView {
     typealias Model = Void
     static var adaptive: SpecializedAdaptive = .init()
 }
 
 */
public protocol SKConfigurableAdaptiveMainView: SKConfigurableAdaptiveView where AdaptiveView == Self {
    // 关联类型别名,用于适配视图结构体
    typealias SpecializedAdaptive = SKAdaptive<AdaptiveView, Model>
    // 要求提供适配视图结构体
    static var adaptive: SpecializedAdaptive { get }
}
#endif


