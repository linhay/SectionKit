//
//  SKUIController.swift
//  SectionUI
//
//  Created by linhey on 12/13/24.
//

import UIKit
import SwiftUI

/// SwiftUI 视图控制器包装器，用于在 SwiftUI 中使用 UIKit 视图控制器
/// SwiftUI view controller wrapper for using UIKit view controllers in SwiftUI
public struct SKUIController<Controller: UIViewController>: UIViewControllerRepresentable {
    
    /// 视图控制器类型别名
    /// View controller type alias
    public typealias UIViewControllerType = Controller
    
    /// 创建视图控制器的闭包类型
    /// Closure type for creating view controller
    public typealias MakeAction   = () -> Controller
    
    /// 更新视图控制器的闭包类型
    /// Closure type for updating view controller
    public typealias UpdateAction = (_ controller: Controller, _ context: Context) -> Void
    
    /// 创建视图控制器的闭包
    /// Closure for creating view controller
    public let make: MakeAction
    
    /// 更新视图控制器的闭包
    /// Closure for updating view controller
    public let update: UpdateAction
    
    /// 初始化方法
    /// Initialization method
    public init(make: @escaping MakeAction,
                update: @escaping UpdateAction = { _, _ in }) {
        self.make = make
        self.update = update
    }
    
    /// 创建 UIKit 视图控制器
    /// Create UIKit view controller
    public func makeUIViewController(context: Context) -> Controller {
        make()
    }
    
    /// 更新 UIKit 视图控制器
    /// Update UIKit view controller
    public func updateUIViewController(_ uiViewController: Controller, context: Context) {
        update(uiViewController, context)
    }
    
}
