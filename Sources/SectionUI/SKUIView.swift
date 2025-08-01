//
//  SKUIView.swift
//  SectionUI
//
//  Created by linhey on 1/3/25.
//

import UIKit
import SwiftUI

/// SwiftUI UIView 包装器，用于在 SwiftUI 中使用 UIKit 视图
/// SwiftUI UIView wrapper for using UIKit views in SwiftUI
public struct SKUIView<View: UIView>: UIViewRepresentable {
    
    /// UIView 类型别名
    /// UIView type alias
    public typealias UIViewType = View
    
    /// 创建视图的闭包类型
    /// Closure type for creating view
    public typealias MakeAction   = (_ context: Context) -> View
    
    /// 更新视图的闭包类型
    /// Closure type for updating view
    public typealias UpdateAction = (_ view: View, _ context: Context) -> Void
    
    /// 创建视图的闭包
    /// Closure for creating view
    public let make: MakeAction
    
    /// 更新视图的闭包
    /// Closure for updating view
    public let update: UpdateAction
    
    /// 初始化方法
    /// Initialization method
    public init(make: @escaping MakeAction,
                update: @escaping UpdateAction = { _, _ in }) {
        self.make = make
        self.update = update
    }
    
    /// 创建 UIKit 视图
    /// Create UIKit view
    public func makeUIView(context: Context) -> View {
        make(context)
    }
    
    /// 更新 UIKit 视图
    /// Update UIKit view
    public func updateUIView(_ uiView: View, context: Context) {
        update(uiView, context)
    }
    
}
