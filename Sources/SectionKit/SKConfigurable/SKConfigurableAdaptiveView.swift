//
//  File.swift
//  
//
//  Created by linhey on 2023/3/9.
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
    
    public let direction: SKLayoutDirection
    public let view: AdaptiveView
    public let content: KeyPath<AdaptiveView, UIView>?
    public let config: (_ view: AdaptiveView, _ size: CGSize, _ model: Model) -> Void
    public let insets: UIEdgeInsets
    public let fittingPriority: SKAdaptiveFittingPriority
    
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
                           fittingPriority: SKAdaptiveFittingPriority? = nil) where AdaptiveView: SKConfigurableView, AdaptiveView.Model == Model {
        self.init(view: view, direction: direction, content: content, insets: insets) { view, size, model in
            switch direction {
            case .horizontal:
                view.bounds.size = .init(width: 0, height: size.height)
            case .vertical:
                view.bounds.size = .init(width: size.width, height: 0)
            }
            view.config(model)
        }
    }
    
}

public protocol SKConfigurableAdaptiveView: SKConfigurableView {
    associatedtype AdaptiveView: UIView
    static var adaptive: SKAdaptive<AdaptiveView, Model> { get }
}

public extension SKConfigurableAdaptiveView {
    
    static func preferredSize(limit size: CGSize, model: Model?) -> CGSize {
        guard let model = model else { return .zero }
        var size = size
        
        adaptive.config(adaptive.view, size, model)
        size = adaptive.view.systemLayoutSizeFitting(adaptive.view.bounds.size,
                                                     withHorizontalFittingPriority: adaptive.fittingPriority.horizontal,
                                                     verticalFittingPriority: adaptive.fittingPriority.vertical)
        if let content = adaptive.content {
            adaptive.view.layoutIfNeeded()
            let view = adaptive.view[keyPath: content]
            let contentSize = view.frame.size
            if adaptive.fittingPriority.horizontal == .fittingSizeLevel {
                size.width = contentSize.width
            }
            if adaptive.fittingPriority.vertical == .fittingSizeLevel {
                size.height = contentSize.height
            }
        }
        
        let result = CGSize(width: size.width + adaptive.insets.left + adaptive.insets.right,
                            height: size.height + adaptive.insets.top + adaptive.insets.bottom)
        
        if result.width == 0 || result.height == 0 {
            return .zero
        }
        
        return result
    }
    
}


#endif
