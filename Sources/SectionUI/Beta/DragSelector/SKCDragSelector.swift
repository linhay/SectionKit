//
//  SKCDragSelector.swift
//  Test
//
//  Created by linhey on 8/29/25.
//

import UIKit

/**
 拖拽多选管理器 - 核心协调器
 
 负责协调手势识别、意图分析、自动滚动和矩形选择等功能。
 
 ## 使用示例
 
 ```swift
 let selector = SKCDragSelector()
 
 // 设置 CollectionView 和代理
 do {
     try selector.setup(
         collectionView: myCollectionView,
         rectSelectionDelegate: self
     )
 } catch {
     print("设置失败: \(error)")
 }
 
 // 实现代理方法
 extension MyViewController: SKCRectSelectionDelegate {
     func rectSelectionManager(_ manager: SKCRectSelectionManager,
                               didUpdateSelection isSelected: Bool,
                               for indexPath: IndexPath) {
         // 处理选中状态变化
         dataSource[indexPath.item].isSelected = isSelected
         collectionView.reloadItems(at: [indexPath])
     }
 }
 
 // 清理
 selector.reset()
 ```
 
 ## 工作原理
 
 1. 通过 UIPanGestureRecognizer 监听拖拽手势
 2. 智能分析用户意图（滚动 vs 多选）
 3. 协调自动滚动和矩形选择两个子模块
 4. 处理手势冲突，确保流畅的用户体验
 
 - Warning: Beta 版本，API 可能会变化
 - Note: 需要 iOS 13.0 或更高版本
 */
@available(iOS 13.0, *)
@available(*, deprecated, message: "[beta] 测试版，API 可能会变化，使用前请充分测试")
@MainActor
public class SKCDragSelector: NSObject {
    
    // MARK: - Types
    
    /// 选择器状态
    public enum State {
        /// 空闲状态，未进行任何操作
        case idle
        /// 手势开始，正在分析用户意图
        case analyzing
        /// 正在进行多选操作
        case selecting
        /// 手势已识别但被判定为滚动意图
        case scrolling
        
        var description: String {
            switch self {
            case .idle: return "空闲"
            case .analyzing: return "分析中"
            case .selecting: return "选择中"
            case .scrolling: return "滚动中"
            }
        }
    }
    
    /// 设置错误类型
    public enum SetupError: LocalizedError {
        case collectionViewIsNil
        case delegateIsNil
        case alreadySetup
        
        public var errorDescription: String? {
            switch self {
            case .collectionViewIsNil:
                return "CollectionView 不能为 nil"
            case .delegateIsNil:
                return "Delegate 不能为 nil"
            case .alreadySetup:
                return "已经设置过，请先调用 reset() 再重新设置"
            }
        }
    }
    
    /// 配置项
    public struct Configuration {
        /// 启动多选需要的最小移动距离（单位：points）
        /// - Note: 建议值 8-15，过小会误触发，过大会降低响应速度
        public var minimumDistance: CGFloat
        
        /// 高速移动的速度阈值（单位：points/秒）
        /// - Note: 超过此值优先识别为滚动意图
        public var highSpeedThreshold: CGFloat
        
        /// 高速移动时垂直分量的最小值（单位：points/秒）
        /// - Note: 用于区分快速横向滑动和快速滚动
        public var highSpeedVerticalThreshold: CGFloat
        
        /// 快速滑动的速度阈值（单位：points/秒）
        /// - Note: 超过此值且方向主导性明显时识别为滚动
        public var fastScrollSpeedThreshold: CGFloat
        
        /// 慢速移动的速度阈值（单位：points/秒）
        /// - Note: 低于此值识别为精确选择操作
        public var slowMovementThreshold: CGFloat
        
        /// 横向移动距离阈值（单位：points）
        /// - Note: 横向移动超过此值倾向于识别为多选
        public var horizontalDistanceThreshold: CGFloat
        
        /// 方向主导性的倍数
        /// - Note: 用于判断某个方向是否占主导，建议值 1.2-2.0
        public var directionDominanceRatio: CGFloat
        
        /// 横向移动相对于垂直移动的最小比例
        /// - Note: 用于判断是否为横向主导移动
        public var horizontalToVerticalRatio: CGFloat
        /// 是否启用触觉反馈
        public var enableHapticFeedback: Bool
        
        /// 创建默认配置
        public init(
            minimumDistance: CGFloat = 10,
            highSpeedThreshold: CGFloat = 3000,
            highSpeedVerticalThreshold: CGFloat = 2000,
            fastScrollSpeedThreshold: CGFloat = 400,
            slowMovementThreshold: CGFloat = 300,
            horizontalDistanceThreshold: CGFloat = 20,
            directionDominanceRatio: CGFloat = 1.2,
            horizontalToVerticalRatio: CGFloat = 0.8,
            enableHapticFeedback: Bool = true
        ) {
            self.minimumDistance = minimumDistance
            self.highSpeedThreshold = highSpeedThreshold
            self.highSpeedVerticalThreshold = highSpeedVerticalThreshold
            self.fastScrollSpeedThreshold = fastScrollSpeedThreshold
            self.slowMovementThreshold = slowMovementThreshold
            self.horizontalDistanceThreshold = horizontalDistanceThreshold
            self.directionDominanceRatio = directionDominanceRatio
            self.horizontalToVerticalRatio = horizontalToVerticalRatio
            self.enableHapticFeedback = enableHapticFeedback
        }
        
        /// 验证配置的有效性
        /// - Throws: 如果配置无效则抛出错误
        func validate() throws {
            guard minimumDistance > 0 else {
                throw ConfigurationError.invalidValue("minimumDistance 必须大于 0")
            }
            guard highSpeedThreshold > 0 else {
                throw ConfigurationError.invalidValue("highSpeedThreshold 必须大于 0")
            }
            guard highSpeedVerticalThreshold > 0 else {
                throw ConfigurationError.invalidValue("highSpeedVerticalThreshold 必须大于 0")
            }
            guard fastScrollSpeedThreshold > 0 else {
                throw ConfigurationError.invalidValue("fastScrollSpeedThreshold 必须大于 0")
            }
            guard slowMovementThreshold > 0 else {
                throw ConfigurationError.invalidValue("slowMovementThreshold 必须大于 0")
            }
            guard directionDominanceRatio >= 1.0 else {
                throw ConfigurationError.invalidValue("directionDominanceRatio 必须 >= 1.0")
            }
            guard horizontalToVerticalRatio >= 0 && horizontalToVerticalRatio <= 1.0 else {
                throw ConfigurationError.invalidValue("horizontalToVerticalRatio 必须在 0-1 之间")
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
    
    // MARK: - Properties
    
    // MARK: - Properties
    
    /// 当前配置
    public var configuration: Configuration {
        didSet {
            do {
                try configuration.validate()
            } catch {
                SKLog("配置验证失败: \(error.localizedDescription)", level: .error)
                configuration = oldValue // 恢复旧值
            }
        }
    }
    
    /// 当前状态
    private(set) public var state: State = .idle {
        didSet {
            guard oldValue != state else { return }
            SKLog("状态变化: \(oldValue.description) -> \(state.description)", level: .info)
            triggerHapticFeedbackIfNeeded(for: state)
        }
    }
    
    /// CollectionView 弱引用
    private weak var collectionView: UICollectionView?
    
    /// 手势识别器（懒加载，避免循环引用）
    private var gesture: UIPanGestureRecognizer?
    
    /// 矩形选择管理器
    private var multiSelectionManager: SKCRectSelectionManager?
    
    /// 自动滚动管理器
    private var autoScrollManager: SKAutoScrollManager?
    
    /// 触觉反馈生成器
    private lazy var impactFeedback = UIImpactFeedbackGenerator(style: .light)
    private lazy var selectionFeedback = UISelectionFeedbackGenerator()
    
    /// 设备方向变化监听器
    private var orientationObserver: NSObjectProtocol?
    
    /// 当前触摸点（用于自动滚动时保持矩形框在手指位置）
    private var currentTouchLocation: CGPoint?
    
    /// 是否已设置
    private var isSetup: Bool {
        return collectionView != nil && gesture != nil
    }
    
    // MARK: - Initialization
    
    public override init() {
        self.configuration = Configuration()
        super.init()
        setupOrientationObserver()
    }
    
    /// 使用自定义配置初始化
    /// - Parameter configuration: 自定义配置
    public init(configuration: Configuration) {
        self.configuration = configuration
        super.init()
        do {
            try configuration.validate()
        } catch {
            fatalError("配置无效: \(error.localizedDescription)")
        }
        setupOrientationObserver()
    }
    
    deinit {
        MainActor.assumeIsolated {
            reset()
            if let observer = orientationObserver {
                NotificationCenter.default.removeObserver(observer)
            }
        }
        debugPrint("SKCDragSelector 已释放")
    }
    
    // MARK: - Public Methods
    
    /// 设置并启动拖拽选择功能
    /// - Parameters:
    ///   - collectionView: 目标 CollectionView
    ///   - rectSelectionDelegate: 矩形选择代理
    /// - Throws: 如果参数无效或已设置则抛出错误
    public func setup(collectionView: UICollectionView, 
                     rectSelectionDelegate: SKCRectSelectionDelegate) throws {
        guard !isSetup else {
            throw SetupError.alreadySetup
        }
        
        // 验证参数
        guard collectionView.window != nil || collectionView.superview != nil else {
            throw SetupError.collectionViewIsNil
        }
        
        // 重置之前的状态
        reset()
        
        // 设置自动滚动管理器
        let autoScroll = SKAutoScrollManager(scrollView: collectionView)
        autoScroll.delegate = self
        self.autoScrollManager = autoScroll
        
        // 设置矩形选择管理器
        let rectSelection = SKCRectSelectionManager(collectionView: collectionView)
        rectSelection.delegate = rectSelectionDelegate
        self.multiSelectionManager = rectSelection
        
        // 设置手势识别器
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        panGesture.delegate = self
        panGesture.minimumNumberOfTouches = 1
        panGesture.maximumNumberOfTouches = 1
        panGesture.delaysTouchesBegan = false
        panGesture.delaysTouchesEnded = false
        panGesture.cancelsTouchesInView = false
        collectionView.addGestureRecognizer(panGesture)
        
        self.gesture = panGesture
        self.collectionView = collectionView
        
        SKLog("✅ 设置完成 - 手势识别器已添加", level: .info)
    }

    /// 重置并清理所有状态
    public func reset() {
        SKLog("开始重置...", level: .info)
        
        // 停止正在进行的操作
        if state == .selecting {
            endMultiSelection()
        }
        
        state = .idle
        
        // 清理自动滚动
        autoScrollManager?.stop()
        autoScrollManager = nil
        
        // 清理矩形选择
        multiSelectionManager?.endSelection()
        multiSelectionManager = nil
        
        // 移除手势识别器
        if let gesture = gesture, let collectionView = collectionView {
            collectionView.removeGestureRecognizer(gesture)
        }
        gesture = nil
        collectionView = nil
        
        SKLog("✅ 重置完成", level: .info)
    }
    
    // MARK: - Private Methods - Setup
    
    private func setupOrientationObserver() {
        orientationObserver = NotificationCenter.default.addObserver(
            forName: UIDevice.orientationDidChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.handleOrientationChange()
            }
        }
    }
    
    private func handleOrientationChange() {
        SKLog("检测到设备方向变化", level: .warning)
        
        // 如果正在选择，安全地终止
        if state == .selecting {
            SKLog("因设备旋转中断选择操作", level: .warning)
            endMultiSelection()
        }
    }
    
    // MARK: - Private Methods - Gesture Handling

    @objc func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        guard let collectionView = collectionView,
              let multiSelectionManager = multiSelectionManager else {
            SKLog("CollectionView 或 SelectionManager 为 nil", level: .error)
            return
        }
        
        let location = gesture.location(in: collectionView)
        let translation = gesture.translation(in: collectionView)
        let velocity = gesture.velocity(in: collectionView)
        
        SKLog("手势[\(gesture.state.rawValue)] 位置:\(SKLogFormat(point: location)) 速度:\(SKLogFormat(point: velocity))", level: .verbose)
        
        switch gesture.state {
        case .began:
            handleGestureBegan(at: location)
            
        case .changed:
            handleGestureChanged(
                location: location,
                translation: translation,
                velocity: velocity,
                multiSelectionManager: multiSelectionManager
            )
            
        case .ended, .cancelled, .failed:
            handleGestureEnded(state: gesture.state)
            
        default:
            break
        }
    }
    
    private func handleGestureBegan(at location: CGPoint) {
        state = .analyzing
        SKLog("手势开始 - 位置: \(SKLogFormat(point: location))", level: .info)
    }
    
    private func handleGestureChanged(
        location: CGPoint,
        translation: CGPoint,
        velocity: CGPoint,
        multiSelectionManager: SKCRectSelectionManager
    ) {
        // 保存当前触摸位置
        currentTouchLocation = location
        
        // 计算移动距离
        let distance = sqrt(translation.x * translation.x + translation.y * translation.y)
        
        // 如果还在分析状态，且移动距离足够大，开始判断意图
        if state == .analyzing && distance > configuration.minimumDistance {
            let shouldStartSelection = evaluateSelectionIntent(
                velocity: velocity,
                translation: translation
            )
            
            if shouldStartSelection {
                state = .selecting
                startMultiSelection(at: location)
            } else {
                state = .scrolling
                SKLog("识别为滚动意图，不启动多选", level: .info)
            }
        }
        
        // 如果正在选择，更新选择区域
        if state == .selecting {
            updateMultiSelection(to: location)
        }
    }
    
    private func handleGestureEnded(state gestureState: UIGestureRecognizer.State) {
        let stateDesc = gestureState == .ended ? "结束" : 
                       gestureState == .cancelled ? "取消" : "失败"
        SKLog("手势\(stateDesc)", level: .info)
        
        if state == .selecting {
            endMultiSelection()
        }
        
        state = .idle
        currentTouchLocation = nil  // 清除触摸位置
    }
    
    // MARK: - Private Methods - Intent Evaluation
    
    /// 评估用户的选择意图
    /// - Parameters:
    ///   - velocity: 手势速度
    ///   - translation: 手势位移
    /// - Returns: true 表示应该启动多选，false 表示是滚动意图
    private func evaluateSelectionIntent(velocity: CGPoint, translation: CGPoint) -> Bool {
        let analyzer = IntentAnalyzer(configuration: configuration)
        let intent = analyzer.analyze(velocity: velocity, translation: translation)
        
        SKLog(intent.debugDescription, level: .info)
        
        return intent.shouldStartSelection
    }
    
    // MARK: - Private Methods - Selection Management
    
    private func startMultiSelection(at point: CGPoint) {
        SKLog("🎯 启动多选 - 位置: \(SKLogFormat(point: point))", level: .info)
        
        // 准备触觉反馈
        impactFeedback.prepare()
        
        // 禁用 CollectionView 的滚动
        collectionView?.isScrollEnabled = false
        
        // 启动自动滚动
        autoScrollManager?.start()
        
        // 开始矩形选择
        multiSelectionManager?.beginSelection(at: point)
    }
    
    private func updateMultiSelection(to point: CGPoint) {
        SKLog("更新选择 -> \(SKLogFormat(point: point))", level: .verbose)
        
        // 更新自动滚动
        autoScrollManager?.updateAutoScroll(for: point)
        
        // 更新矩形选择
        multiSelectionManager?.updateSelection(to: point)
    }
    
    private func endMultiSelection() {
        SKLog("🏁 结束多选", level: .info)
        
        // 恢复 CollectionView 的滚动
        collectionView?.isScrollEnabled = true
        
        // 停止自动滚动
        autoScrollManager?.stop()
        
        // 结束矩形选择
        multiSelectionManager?.endSelection()
    }
    
    // MARK: - Private Methods - Haptic Feedback
    
    private func triggerHapticFeedbackIfNeeded(for state: State) {
        guard configuration.enableHapticFeedback else { return }
        
        switch state {
        case .selecting:
            impactFeedback.impactOccurred()
        case .idle:
            selectionFeedback.selectionChanged()
        default:
            break
        }
    }
}

// MARK: - Intent Analyzer (意图分析器)

/// 用于分析用户手势意图的策略类
private struct IntentAnalyzer {
    let configuration: SKCDragSelector.Configuration
    
    struct AnalysisResult {
        let shouldStartSelection: Bool
        let reason: String
        let velocityMagnitude: CGFloat
        let isHorizontalDominant: Bool
        let isVerticalDominant: Bool
        
        var debugDescription: String {
            let decision = shouldStartSelection ? "✅ 多选" : "❌ 滚动"
            return "\(decision) | 速度:\(Int(velocityMagnitude)) | H:\(isHorizontalDominant) V:\(isVerticalDominant) | \(reason)"
        }
    }
    
    func analyze(velocity: CGPoint, translation: CGPoint) -> AnalysisResult {
        let velocityMagnitude = sqrt(velocity.x * velocity.x + velocity.y * velocity.y)
        let absVelocityX = abs(velocity.x)
        let absVelocityY = abs(velocity.y)
        let absTranslationX = abs(translation.x)
        let absTranslationY = abs(translation.y)
        
        // 计算方向主导性
        let isHorizontalDominant = absVelocityX > absVelocityY * configuration.directionDominanceRatio
        let isVerticalDominant = absVelocityY > absVelocityX * configuration.directionDominanceRatio
        
        // 规则 1: 高速移动且有明显垂直分量 -> 滚动
        if velocityMagnitude > configuration.highSpeedThreshold && 
           absVelocityY > configuration.highSpeedVerticalThreshold {
            return AnalysisResult(
                shouldStartSelection: false,
                reason: "高速垂直移动",
                velocityMagnitude: velocityMagnitude,
                isHorizontalDominant: isHorizontalDominant,
                isVerticalDominant: isVerticalDominant
            )
        }
        
        // 规则 2: 垂直方向快速滑动 -> 滚动
        if isVerticalDominant && 
           velocityMagnitude > configuration.fastScrollSpeedThreshold &&
           absVelocityY > absVelocityX * configuration.directionDominanceRatio {
            return AnalysisResult(
                shouldStartSelection: false,
                reason: "垂直快速滑动",
                velocityMagnitude: velocityMagnitude,
                isHorizontalDominant: isHorizontalDominant,
                isVerticalDominant: isVerticalDominant
            )
        }
        
        // 规则 3: 快速横向移动 -> 多选
        if isHorizontalDominant && velocityMagnitude <= configuration.highSpeedThreshold {
            return AnalysisResult(
                shouldStartSelection: true,
                reason: "横向主导移动",
                velocityMagnitude: velocityMagnitude,
                isHorizontalDominant: isHorizontalDominant,
                isVerticalDominant: isVerticalDominant
            )
        }
        
        // 规则 4: 慢速垂直移动 -> 多选（精确选择）
        if isVerticalDominant && velocityMagnitude <= configuration.fastScrollSpeedThreshold {
            return AnalysisResult(
                shouldStartSelection: true,
                reason: "慢速精确移动",
                velocityMagnitude: velocityMagnitude,
                isHorizontalDominant: isHorizontalDominant,
                isVerticalDominant: isVerticalDominant
            )
        }
        
        // 规则 5: 横向移动距离较大 -> 多选
        if absTranslationX > configuration.horizontalDistanceThreshold &&
           absTranslationX > absTranslationY * configuration.horizontalToVerticalRatio {
            return AnalysisResult(
                shouldStartSelection: true,
                reason: "横向移动距离大",
                velocityMagnitude: velocityMagnitude,
                isHorizontalDominant: isHorizontalDominant,
                isVerticalDominant: isVerticalDominant
            )
        }
        
        // 规则 6: 整体很慢的移动 -> 多选
        if velocityMagnitude < configuration.slowMovementThreshold {
            return AnalysisResult(
                shouldStartSelection: true,
                reason: "整体移动缓慢",
                velocityMagnitude: velocityMagnitude,
                isHorizontalDominant: isHorizontalDominant,
                isVerticalDominant: isVerticalDominant
            )
        }
        
        // 默认: 无法确定 -> 不启动多选
        return AnalysisResult(
            shouldStartSelection: false,
            reason: "无法确定意图",
            velocityMagnitude: velocityMagnitude,
            isHorizontalDominant: isHorizontalDominant,
            isVerticalDominant: isVerticalDominant
        )
    }
}

// MARK: - UIGestureRecognizerDelegate

// MARK: - UIGestureRecognizerDelegate

extension SKCDragSelector: UIGestureRecognizerDelegate {
    
    public func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        // 如果正在进行多选，阻止其他手势
        if state == .selecting {
            SKLog("多选激活中，阻止其他手势: \(type(of: otherGestureRecognizer))", level: .info)
            return false
        }
        
        // 如果是系统滚动手势，在分析阶段允许同时识别
        if otherGestureRecognizer is UIPanGestureRecognizer {
            SKLog("允许与滚动手势同时识别", level: .verbose)
            return true
        }
        
        // 其他手势默认不同时识别，避免冲突
        SKLog("拒绝与其他手势同时识别: \(type(of: otherGestureRecognizer))", level: .verbose)
        return false
    }
    
    public func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldReceive touch: UITouch
    ) -> Bool {
        guard let collectionView = collectionView else {
            SKLog("CollectionView 为 nil，拒绝接收触摸", level: .error)
            return false
        }
        
        let location = touch.location(in: collectionView)
        let collectionBounds = collectionView.bounds
        
        // 扩大有效区域，包含边缘（允许 5pt 误差）
        let expandedBounds = collectionBounds.insetBy(dx: -5, dy: -5)
        let isInBounds = expandedBounds.contains(location)
        
        if !isInBounds {
            SKLog("触摸超出有效区域: \(SKLogFormat(point: location))", level: .verbose)
        }
        
        return isInBounds
    }
    
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        // 确保 CollectionView 可用
        guard collectionView != nil else {
            SKLog("CollectionView 不可用，阻止手势开始", level: .error)
            return false
        }
        
        SKLog("手势准备开始", level: .verbose)
        return true
    }
}

// MARK: - SKAutoScrollManagerDelegate

@MainActor
extension SKCDragSelector: SKAutoScrollManagerDelegate {
    
    public func autoScrollManager(_ manager: SKAutoScrollManager, didScrollToPoint point: CGPoint) {
        // 自动滚动时，使用当前保存的触摸位置来更新选择区域
        // 这样矩形框会停留在手指位置，而不是跟随滚动
        if let touchLocation = currentTouchLocation {
            multiSelectionManager?.updateSelection(to: touchLocation)
        }
    }
}
