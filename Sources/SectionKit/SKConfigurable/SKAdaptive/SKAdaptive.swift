//
//  File.swift
//  
//
//  Created by linhey on 2023/4/25.
//

#if canImport(UIKit)
import UIKit

fileprivate extension UIView {
    
    var eraseToAnyUIView: UIView { self }
    
}

public struct SKAdaptiveFittingPriority {
    
    public let horizontal: UILayoutPriority
    public let vertical: UILayoutPriority
    
    public init(horizontal: UILayoutPriority, vertical: UILayoutPriority) {
        self.horizontal = horizontal
        self.vertical = vertical
    }
}

public struct SKAdaptive<AdaptiveView: UIView, Model> {
    
    // 适配方向
    public let direction: SKLayoutDirection
    // 适配的视图
    public let view: AdaptiveView
    // 适配视图内容视图的keyPath
    public let content: KeyPath<AdaptiveView, UIView>?
    // 视图周围的inset
    public let insets: UIEdgeInsets
    // 视图适配优先级
    public let fittingPriority: SKAdaptiveFittingPriority
    // 配置视图的闭包
    public let config: (_ view: AdaptiveView, _ size: CGSize, _ model: Model) -> Void
    
    public init<T: UIView>(view: AdaptiveView = .init(),
                           direction: SKLayoutDirection = .vertical,
                           content: KeyPath<AdaptiveView, T>? = nil,
                           insets: UIEdgeInsets = .zero,
                           fittingPriority: SKAdaptiveFittingPriority? = nil,
                           config: @escaping (_ view: AdaptiveView, _ size: CGSize, _ model: Model) -> Void) {
        self.view = view
        self.direction = direction
        self.content = content?.appending(path: \.eraseToAnyUIView)
        self.insets = insets
        self.config = config
        if let fittingPriority = fittingPriority {
            self.fittingPriority = fittingPriority
        } else {
            switch direction {
            case .horizontal:
                self.fittingPriority = .init(horizontal: .fittingSizeLevel, vertical: .required)
            case .vertical:
                self.fittingPriority = .init(horizontal: .required, vertical: .fittingSizeLevel)
            }
        }
    }
    
    public init<T: UIView>(view: AdaptiveView = .init(),
                           direction: SKLayoutDirection = .vertical,
                           content: KeyPath<AdaptiveView, T>? = nil,
                           insets: UIEdgeInsets = .zero,
                           fittingPriority: SKAdaptiveFittingPriority? = nil,
                           afterConfig: ((_ view: AdaptiveView, _ model: Model) -> Void)? = nil) where AdaptiveView: SKConfigurableView, AdaptiveView.Model == Model {
        self.init(view: view, direction: direction, content: content, insets: insets) { view, size, model in
            switch direction {
            case .horizontal:
                view.bounds.size = .init(width: 0, height: size.height)
            case .vertical:
                view.bounds.size = .init(width: size.width, height: 0)
            }
            view.config(model)
            afterConfig?(view, model)
        }
    }
    
}
#endif
