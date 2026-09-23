//
//  SKAutoScrollManager.swift
//  Test
//
//  Created by linhey on 8/29/25.
//

import UIKit

/**
 自动滚动管理器
 
 当用户拖拽到 ScrollView 边缘时，自动触发平滑的滚动效果。
 使用 CADisplayLink 实现高帧率滚动，支持 ProMotion 显示屏。
 
 ## 特性
 - ✅ 边缘检测和速度计算
 - ✅ 高帧率兼容（支持 60fps/120fps）
 - ✅ 平滑的加速度曲线
 - ✅ 边界安全处理
 
 ## 使用示例
 ```swift
 let scrollManager = SKAutoScrollManager(scrollView: collectionView)
 scrollManager.delegate = self
 scrollManager.start()
 
 // 在手势移动时更新
 scrollManager.updateAutoScroll(for: touchPoint)
 
 // 停止滚动
 scrollManager.stop()
 ```
 
 - Warning: Beta 版本，API 可能会变化
 */
@available(iOS 13.0, *)
@available(*, deprecated, message: "[beta] 测试版，API 可能会变化")
public class SKAutoScrollManager {
    
    // MARK: - Types
    
    /// 配置项
    public struct Configuration {
        /// 边缘触发区域大小（单位：points）
        /// - Note: 距离边缘多远开始触发自动滚动，建议 30-50pt
        public let edgeInset: CGFloat
        
        /// 最大滚动速度（单位：points/frame）
        /// - Note: 每帧最多滚动的距离，建议 8-15，值越大滚动越快
        public let maxSpeed: CGFloat
        
        /// 目标帧率（单位：fps）
        /// - Note: 建议 60fps，ProMotion 设备会自动适配到 120fps
        public let targetFPS: Int
        
        /// 创建默认配置
        public init(
            edgeInset: CGFloat = 40,
            maxSpeed: CGFloat = 12,
            targetFPS: Int = 60
        ) {
            self.edgeInset = edgeInset
            self.maxSpeed = maxSpeed
            self.targetFPS = targetFPS
        }
        
        /// 验证配置的有效性
        func validate() throws {
            guard edgeInset > 0 else {
                throw ConfigurationError.invalidValue("edgeInset 必须 > 0，当前值: \(edgeInset)")
            }
            guard maxSpeed > 0 else {
                throw ConfigurationError.invalidValue("maxSpeed 必须 > 0，当前值: \(maxSpeed)")
            }
            guard targetFPS >= 1 && targetFPS <= 120 else {
                throw ConfigurationError.invalidValue("targetFPS 必须在 1-120 之间，当前值: \(targetFPS)")
            }
        }
        
        enum ConfigurationError: LocalizedError {
            case invalidValue(String)
            
            var errorDescription: String? {
                switch self {
                case .invalidValue(let message):
                    return "配置错误: \(message)"
                }
            }
        }
    }
    
    // MARK: - Delegate
    
    /// 代理协议
    public weak var delegate: SKAutoScrollManagerDelegate?
    
    // MARK: - Properties
    
    /// 配置
    public var configuration: Configuration {
        didSet {
            do {
                try configuration.validate()
            } catch {
                print("[SKAutoScrollManager] ❌ 配置无效: \(error.localizedDescription)")
                configuration = oldValue
            }
        }
    }
    
    /// ScrollView 弱引用
    private weak var scrollView: UIScrollView?
    
    /// 显示链接（用于高帧率滚动）
    private var displayLink: CADisplayLink?
    
    /// 当前滚动速度向量
    private var scrollVelocity: CGVector = .zero
    
    /// 当前触摸点
    private var currentTouchPoint: CGPoint?
    
    /// 上次更新时间（用于帧率控制）
    private var lastUpdateTime: CFTimeInterval = 0
    
    /// 帧间隔时间（计算属性）
    private var frameInterval: CFTimeInterval {
        return 1.0 / Double(configuration.targetFPS)
    }
    
    /// 是否正在滚动
    public private(set) var isScrolling: Bool = false
    
    // MARK: - Initialization
    
    /// 初始化自动滚动管理器
    /// - Parameter scrollView: 目标 ScrollView
    public init(scrollView: UIScrollView) {
        self.scrollView = scrollView
        self.configuration = Configuration()
    }
    
    /// 使用自定义配置初始化
    /// - Parameters:
    ///   - scrollView: 目标 ScrollView
    ///   - configuration: 自定义配置
    public init(scrollView: UIScrollView, configuration: Configuration) {
        self.scrollView = scrollView
        self.configuration = configuration
        do {
            try configuration.validate()
        } catch {
            fatalError("配置无效: \(error.localizedDescription)")
        }
    }
    
    deinit {
        stop()
    }
    
    // MARK: - Public Methods
    
    // MARK: - Public Methods
    
    /// 启动自动滚动
    /// - Note: 启动后需要调用 updateAutoScroll(for:) 来更新滚动
    public func start() {
        guard scrollView != nil else {
            print("[SKAutoScrollManager] ⚠️ ScrollView 为 nil，无法启动")
            return
        }
        
        // 先停止之前的
        stop()
        
        // 创建并配置 DisplayLink
        let link = CADisplayLink(target: self, selector: #selector(performAutoScroll))
        configureFrameRate(for: link)
        link.add(to: .main, forMode: .common)
        
        displayLink = link
        lastUpdateTime = 0
        isScrolling = true
        
        #if DEBUG
        print("[SKAutoScrollManager] ✅ 已启动 (目标帧率: \(configuration.targetFPS)fps)")
        #endif
    }
    
    /// 停止自动滚动
    public func stop() {
        displayLink?.invalidate()
        displayLink = nil
        scrollVelocity = .zero
        currentTouchPoint = nil
        lastUpdateTime = 0
        isScrolling = false
        
        #if DEBUG
        print("[SKAutoScrollManager] ⏹️ 已停止")
        #endif
    }
    
    /// 更新自动滚动的触摸点
    /// - Parameter point: 当前触摸点（相对于 ScrollView 坐标系）
    public func updateAutoScroll(for point: CGPoint) {
        currentTouchPoint = point
        scrollVelocity = calculateScrollVelocity(for: point)
    }
    
    // MARK: - Private Methods - Frame Rate
    
    // MARK: - Private Methods - Frame Rate
    
    /// 配置 DisplayLink 的帧率
    /// - Parameter link: CADisplayLink 实例
    private func configureFrameRate(for link: CADisplayLink) {
        if #available(iOS 15.0, *) {
            // iOS 15+ 支持直接设置期望帧率范围
            // ProMotion 设备会自动在范围内选择最佳帧率
            link.preferredFrameRateRange = CAFrameRateRange(
                minimum: Float(configuration.targetFPS),
                maximum: Float(min(configuration.targetFPS * 2, 120)), // 最高120fps
                preferred: Float(configuration.targetFPS)
            )
        } else {
            // iOS 15 以下使用 preferredFramesPerSecond
            link.preferredFramesPerSecond = configuration.targetFPS
        }
    }
    
    // MARK: - Private Methods - Scrolling
    
    /// 执行自动滚动（DisplayLink 回调）
    @objc private func performAutoScroll() {
        guard let scrollView = scrollView,
              scrollVelocity != .zero else {
            return
        }
        
        // 计算时间修正系数
        guard let timeScale = calculateTimeScale() else {
            return // 帧率过高，跳过此帧
        }
        
        // 计算新的偏移量
        var newOffset = scrollView.contentOffset
        newOffset.x += scrollVelocity.dx * timeScale
        newOffset.y += scrollVelocity.dy * timeScale
        
        // 应用边界限制
        let clampedOffset = clampOffset(newOffset, for: scrollView)
        
        // 检查是否真的需要更新（避免无效更新）
        guard !clampedOffset.equalTo(scrollView.contentOffset) else {
            return
        }
        
        // 更新偏移量
        scrollView.contentOffset = clampedOffset
        
        // 通知代理
        if let touchPoint = currentTouchPoint {
            delegate?.autoScrollManager(self, didScrollToPoint: touchPoint)
        }
    }
    
    /// 计算时间修正系数
    /// - Returns: 时间修正系数，nil 表示应跳过此帧
    private func calculateTimeScale() -> CGFloat? {
        let currentTime = CACurrentMediaTime()
        
        // 初次运行，建立基准时间
        if lastUpdateTime == 0 {
            lastUpdateTime = currentTime
            return nil
        }
        
        let deltaTime = currentTime - lastUpdateTime
        
        // 帧率过高，跳过此帧（防止在 ProMotion 设备上更新过快）
        guard deltaTime >= frameInterval * 0.9 else { // 允许 10% 的误差
            return nil
        }
        
        lastUpdateTime = currentTime
        
        // 计算时间修正系数（补偿实际帧间隔）
        return CGFloat(deltaTime * Double(configuration.targetFPS))
    }
    
    /// 限制偏移量在有效范围内
    /// - Parameters:
    ///   - offset: 原始偏移量
    ///   - scrollView: ScrollView
    /// - Returns: 限制后的偏移量
    private func clampOffset(_ offset: CGPoint, for scrollView: UIScrollView) -> CGPoint {
        // 计算最大偏移量（考虑内容大小和可见区域）
        let maxX = max(0, scrollView.contentSize.width - scrollView.bounds.width + scrollView.contentInset.left + scrollView.contentInset.right)
        let maxY = max(0, scrollView.contentSize.height - scrollView.bounds.height + scrollView.contentInset.top + scrollView.contentInset.bottom)
        
        // 计算最小偏移量（考虑内容缩进）
        let minX = -scrollView.contentInset.left
        let minY = -scrollView.contentInset.top
        
        return CGPoint(
            x: max(minX, min(offset.x, maxX)),
            y: max(minY, min(offset.y, maxY))
        )
    }
    
    // MARK: - Private Methods - Velocity Calculation
    
    // MARK: - Private Methods - Velocity Calculation
    
    /// 计算滚动速度向量
    /// - Parameter point: 触摸点（ScrollView 坐标系）
    /// - Returns: 滚动速度向量
    private func calculateScrollVelocity(for point: CGPoint) -> CGVector {
        guard let scrollView = scrollView else {
            return .zero
        }
        
        // 将触摸点转换到 ScrollView 的父视图坐标系
        // 这样可以准确判断触摸点相对于 ScrollView frame 的位置
        guard let pointInSuperview = scrollView.superview?.convert(point, from: scrollView) else {
            return .zero
        }
        
        let frame = scrollView.frame
        let bounds = scrollView.bounds
        let contentSize = scrollView.contentSize
        let edgeInset = configuration.edgeInset
        let maxSpeed = configuration.maxSpeed
        
        // 检查是否有可滚动内容
        guard contentSize.width > bounds.width || contentSize.height > bounds.height else {
            return .zero // 内容不足，无需滚动
        }
        
        // 计算横向滚动速度
        let velocityX = calculateDirectionalVelocity(
            position: pointInSuperview.x,
            frameStart: frame.minX,
            frameEnd: frame.maxX,
            currentOffset: scrollView.contentOffset.x,
            contentSize: contentSize.width,
            boundsSize: bounds.width,
            contentInset: scrollView.contentInset.left + scrollView.contentInset.right,
            edgeInset: edgeInset,
            maxSpeed: maxSpeed
        )
        
        // 计算纵向滚动速度
        let velocityY = calculateDirectionalVelocity(
            position: pointInSuperview.y,
            frameStart: frame.minY,
            frameEnd: frame.maxY,
            currentOffset: scrollView.contentOffset.y,
            contentSize: contentSize.height,
            boundsSize: bounds.height,
            contentInset: scrollView.contentInset.top + scrollView.contentInset.bottom,
            edgeInset: edgeInset,
            maxSpeed: maxSpeed
        )
        
        return CGVector(dx: velocityX, dy: velocityY)
    }
    
    /// 计算单方向的滚动速度
    /// - Parameters:
    ///   - position: 触摸点位置
    ///   - frameStart: Frame 起始位置
    ///   - frameEnd: Frame 结束位置
    ///   - currentOffset: 当前偏移量
    ///   - contentSize: 内容大小
    ///   - boundsSize: 可见区域大小
    ///   - contentInset: 内容缩进
    ///   - edgeInset: 边缘触发区域
    ///   - maxSpeed: 最大速度
    /// - Returns: 单方向速度（负值表示向起始方向滚动，正值表示向结束方向滚动）
    private func calculateDirectionalVelocity(
        position: CGFloat,
        frameStart: CGFloat,
        frameEnd: CGFloat,
        currentOffset: CGFloat,
        contentSize: CGFloat,
        boundsSize: CGFloat,
        contentInset: CGFloat,
        edgeInset: CGFloat,
        maxSpeed: CGFloat
    ) -> CGFloat {
        // 计算触发区域边界
        let startTrigger = frameStart + edgeInset
        let endTrigger = frameEnd - edgeInset
        
        // 计算最大可滚动偏移量
        let maxOffset = max(0, contentSize - boundsSize + contentInset)
        let minOffset = -contentInset
        
        // 检查是否在起始边缘触发区域（向负方向滚动）
        if position <= startTrigger && currentOffset > minOffset {
            let distance = max(0, startTrigger - position)
            let ratio = min(1, distance / edgeInset)
            // 使用缓动函数使速度变化更平滑
            return -maxSpeed * easeOutQuad(ratio)
        }
        
        // 检查是否在结束边缘触发区域（向正方向滚动）
        if position >= endTrigger && currentOffset < maxOffset {
            let distance = max(0, position - endTrigger)
            let ratio = min(1, distance / edgeInset)
            // 使用缓动函数使速度变化更平滑
            return maxSpeed * easeOutQuad(ratio)
        }
        
        return 0
    }
    
    /// 缓动函数：二次方缓出
    /// - Parameter t: 进度值 (0-1)
    /// - Returns: 缓动后的值 (0-1)
    private func easeOutQuad(_ t: CGFloat) -> CGFloat {
        return t * (2 - t)
    }
}

// MARK: - Delegate Protocol

/// 自动滚动管理器代理协议
public protocol SKAutoScrollManagerDelegate: AnyObject {
    /// 滚动到新位置时调用
    /// - Parameters:
    ///   - manager: 自动滚动管理器
    ///   - point: 当前触摸点
    func autoScrollManager(_ manager: SKAutoScrollManager, didScrollToPoint point: CGPoint)
}
