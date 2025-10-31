//
//  SKSelectionOverlayView.swift
//  Test
//
//  Created by linhey on 8/29/25.
//

import UIKit

/**
 选择覆盖层视图
 
 用于可视化显示拖拽选择的矩形区域。
 
 ## 特性
 - ✅ 自定义填充色和边框色
 - ✅ 圆角支持
 - ✅ 无动画更新（性能优化）
 - ✅ 不拦截用户交互
 
 ## 自定义样式
 
 ```swift
 let overlay = SKSelectionOverlayView()
 overlay.style = SKSelectionOverlayView.Style(
     fillColor: .systemBlue.withAlphaComponent(0.2),
     strokeColor: .systemBlue,
     lineWidth: 2,
     cornerRadius: 8,
     dashPattern: [5, 3]
 )
 ```
 
 - Warning: Beta 版本，API 可能会变化
 */
@available(iOS 13.0, *)
@available(*, deprecated, message: "[beta] 测试版，API 可能会变化")
public class SKSelectionOverlayView: UIView {
    
    // MARK: - Types
    
    /// 覆盖层样式配置
    public struct Style {
        /// 填充颜色
        public var fillColor: UIColor
        
        /// 边框颜色
        public var strokeColor: UIColor
        
        /// 边框宽度
        public var lineWidth: CGFloat
        
        /// 圆角半径
        public var cornerRadius: CGFloat
        
        /// 虚线样式（可选）
        /// - Note: 例如 [5, 3] 表示 5pt 实线，3pt 空白
        public var dashPattern: [NSNumber]?
        
        /// 默认样式（蓝色主题）
        public static var `default`: Style {
            Style(
                fillColor: .systemBlue.withAlphaComponent(0.2),
                strokeColor: .systemBlue.withAlphaComponent(0.6),
                lineWidth: 1.5,
                cornerRadius: 4,
                dashPattern: nil
            )
        }
        
        /// 创建自定义样式
        public init(
            fillColor: UIColor = .systemBlue.withAlphaComponent(0.2),
            strokeColor: UIColor = .systemBlue.withAlphaComponent(0.6),
            lineWidth: CGFloat = 1.5,
            cornerRadius: CGFloat = 4,
            dashPattern: [NSNumber]? = nil
        ) {
            self.fillColor = fillColor
            self.strokeColor = strokeColor
            self.lineWidth = lineWidth
            self.cornerRadius = cornerRadius
            self.dashPattern = dashPattern
        }
    }
    
    // MARK: - Properties
    
    /// 样式配置
    public var style: Style = .default {
        didSet {
            applyStyle()
        }
    }
    
    /// 形状层
    public private(set) var shapeLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        return layer
    }()
    
    // MARK: - Initialization
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayer()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayer()
    }
    
    // MARK: - Setup
    
    private func setupLayer() {
        backgroundColor = .clear
        isUserInteractionEnabled = false
        layer.addSublayer(shapeLayer)
        applyStyle()
    }
    
    private func applyStyle() {
        shapeLayer.fillColor = style.fillColor.cgColor
        shapeLayer.strokeColor = style.strokeColor.cgColor
        shapeLayer.lineWidth = style.lineWidth
        shapeLayer.lineDashPattern = style.dashPattern
        
        // 更新路径以应用新的圆角
        updatePath()
    }
    
    // MARK: - Public Methods
    
    /// 更新选择矩形
    /// - Parameter rect: 新的矩形区域
    public func updateSelectionRect(_ rect: CGRect) {
        // 使用 CATransaction 禁用隐式动画，提升性能
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        frame = rect
        updatePath()
        
        CATransaction.commit()
    }
    
    // MARK: - Private Methods
    
    private func updatePath() {
        let bezierPath: UIBezierPath
        
        if style.cornerRadius > 0 {
            bezierPath = UIBezierPath(
                roundedRect: bounds,
                cornerRadius: style.cornerRadius
            )
        } else {
            bezierPath = UIBezierPath(rect: bounds)
        }
        
        shapeLayer.path = bezierPath.cgPath
    }
}
