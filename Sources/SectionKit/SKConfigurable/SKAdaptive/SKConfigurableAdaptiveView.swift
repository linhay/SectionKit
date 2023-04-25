//
//  File.swift
//  
//
//  Created by linhey on 2023/3/9.
//

#if canImport(UIKit)
import UIKit

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
