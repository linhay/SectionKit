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

public struct SKAdaptive<Self: SKConfigurableView> {
    
    let direction: SKLayoutDirection
    let view: Self
    let content: KeyPath<Self, UIView>?
    let insets: UIEdgeInsets
    
    public init<T: UIView>(view: Self = .init(),
                           direction: SKLayoutDirection,
                           content: KeyPath<Self, T>?,
                           insets: UIEdgeInsets = .zero) {
        self.view = view
        self.direction = direction
        self.content = content?.appending(path: \.eraseToAnyUIView)
        self.insets = insets
    }
    
    public init(view: Self = .init(), direction: SKLayoutDirection, insets: UIEdgeInsets = .zero) {
        self.view = view
        self.direction = direction
        self.content = nil
        self.insets = insets
    }
    
}

public protocol SKConfigurableAdaptiveView: SKConfigurableView {
    static var adaptive: SKAdaptive<Self> { get }
}

public extension SKConfigurableAdaptiveView {
    
    static func preferredSize(limit size: CGSize, model: Model?) -> CGSize {
        guard let model = model else { return .zero }
        var horizontalFittingPriority: UILayoutPriority = .required
        var verticalFittingPriority: UILayoutPriority = .required
        
        if adaptive.direction.contains(.horizontal) {
            horizontalFittingPriority = .fittingSizeLevel
        }
        
        if adaptive.direction.contains(.vertical) {
            verticalFittingPriority = .fittingSizeLevel
        }
        
        adaptive.view.config(model)
        var size = adaptive.view.systemLayoutSizeFitting(size,
                                                          withHorizontalFittingPriority: horizontalFittingPriority,
                                                          verticalFittingPriority: verticalFittingPriority)
        adaptive.view.bounds.size = size
        if let content = adaptive.content {
            adaptive.view.layoutIfNeeded()
            let view = adaptive.view[keyPath: content]
            let contentSize = view.frame.size
            if horizontalFittingPriority == .fittingSizeLevel {
                size.width = contentSize.width
            }
            if verticalFittingPriority == .fittingSizeLevel {
                size.height = contentSize.height
            }
        }
        
        return .init(width: size.width + adaptive.insets.left + adaptive.insets.right,
                     height: size.height + adaptive.insets.top + adaptive.insets.bottom)
    }
    
}

#endif