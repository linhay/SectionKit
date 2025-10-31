//
//  SKCRectSelectionManager.swift
//  Test
//
//  Created by linhey on 8/29/25.
//

import UIKit

/**
 矩形框选管理器
 
 负责绘制选择框、计算选中项、管理选中状态。
 
 ## 特性
 - ✅ 可视化选择框
 - ✅ 智能选择模式（选中/取消选中）
 - ✅ 状态记忆与恢复
 - ✅ 性能优化（节流机制）
 
 ## 使用示例
 ```swift
 let manager = SKCRectSelectionManager(collectionView: collectionView)
 manager.delegate = self
 
 // 开始选择
 manager.beginSelection(at: startPoint)
 
 // 更新选择
 manager.updateSelection(to: currentPoint)
 
 // 结束选择
 manager.endSelection()
 ```
 
 - Warning: Beta 版本，API 可能会变化
 */
@available(iOS 13.0, *)
@available(*, deprecated, message: "[beta] 测试版，API 可能会变化")
@MainActor
public class SKCRectSelectionManager {
    
    // MARK: - Types
    
    /// 选择模式
    private enum SelectionMode {
        /// 选中模式：拖拽区域内的 cell 变为选中
        case selecting
        /// 取消选中模式：拖拽区域内的 cell 变为未选中
        case deselecting
        
        var description: String {
            switch self {
            case .selecting: return "选中模式"
            case .deselecting: return "取消模式"
            }
        }
    }
    
    /// 配置项
    public struct Configuration {
        /// 更新节流间隔（单位：秒）
        /// - Note: 控制选择区域更新的频率，避免过度计算
        public var updateThrottleInterval: TimeInterval
        
        /// 视觉更新节流间隔（单位：秒）
        /// - Note: 控制矩形框视觉更新的频率，应该比选择计算更频繁
        public var visualUpdateThrottleInterval: TimeInterval
        
        /// 是否启用调试日志
        public var enableDebugLogging: Bool
        
        public init(
            updateThrottleInterval: TimeInterval = 0.05,  // 20fps - cell 选择计算
            visualUpdateThrottleInterval: TimeInterval = 0.016,  // 60fps - 矩形框视觉更新
            enableDebugLogging: Bool = false
        ) {
            self.updateThrottleInterval = updateThrottleInterval
            self.visualUpdateThrottleInterval = visualUpdateThrottleInterval
            self.enableDebugLogging = enableDebugLogging
        }
    }
    
    // MARK: - Delegate
    
    /// 代理
    public weak var delegate: SKCRectSelectionDelegate?
    
    // MARK: - Properties
    
    /// 配置
    public var configuration = Configuration()
    
    /// CollectionView 弱引用
    private weak var collectionView: UICollectionView?
    
    /// 选择起始点
    private var selectionStartPoint: CGPoint?
    
    /// 选择覆盖层
    private var selectionOverlay: SKSelectionOverlayView?
    
    /// 初始选择模式
    private var initialSelectionMode: SelectionMode?
    
    /// Cell 的原始状态记录（用于恢复）
    private var cellsOriginalStates: [IndexPath: Bool] = [:]
    
    /// 上一次选择区域内的 IndexPath 集合
    private var previousSelectedIndexPaths: Set<IndexPath> = []
    
    /// 上次更新时间（用于节流）
    private var lastUpdateTime: TimeInterval = 0
    
    /// 上次视觉更新时间（用于矩形框节流）
    private var lastVisualUpdateTime: TimeInterval = 0
    
    /// 选择是否激活
    public var isSelectionActive: Bool {
        return selectionStartPoint != nil && selectionOverlay != nil
    }
    
    // MARK: - Initialization
    
    /// 初始化矩形选择管理器
    /// - Parameter collectionView: 目标 CollectionView
    public init(collectionView: UICollectionView) {
        self.collectionView = collectionView
    }
    
    // MARK: - Public Methods
    
    // MARK: - Public Methods
    
    /// 开始选择
    /// - Parameter point: 起始点（CollectionView 坐标系）
    public func beginSelection(at point: CGPoint) {
        guard let collectionView = collectionView else {
            SKLog("❌ CollectionView 为 nil", level: .error)
            return
        }
        
        SKLog("🎯 开始选择 - 位置: \(SKLogFormat(point: point))", level: .info)
        
        // 记录起始点
        selectionStartPoint = point
        
        // 清空之前的状态
        cellsOriginalStates.removeAll()
        previousSelectedIndexPaths.removeAll()
        
        // 确定初始选择模式
        determineInitialSelectionMode(at: point)
        
        // 创建并显示选择覆盖层
        createAndShowOverlay(at: point, in: collectionView)
    }
    
    /// 更新选择区域
    /// - Parameter point: 当前点（CollectionView 坐标系）
    public func updateSelection(to point: CGPoint) {
        guard let startPoint = selectionStartPoint,
              let overlay = selectionOverlay,
              let collectionView = collectionView else {
            SKLog("⚠️ 选择未开始或已结束", level: .warning)
            return
        }
        
        let now = Date().timeIntervalSince1970
        
        // 计算选择矩形
        let selectionRect = calculateSelectionRect(from: startPoint, to: point)
        
        // 视觉更新：使用更高的频率（60fps），保证流畅
        if now - lastVisualUpdateTime >= configuration.visualUpdateThrottleInterval {
            overlay.updateSelectionRect(selectionRect)
            lastVisualUpdateTime = now
        }
        
        // 选择计算：使用较低的频率（20fps），节省性能
        if now - lastUpdateTime >= configuration.updateThrottleInterval {
            SKLog("更新选择 -> \(SKLogFormat(point: point))", level: .verbose)
            updateCellsSelection(in: selectionRect)
            lastUpdateTime = now
        }
    }
    
    /// 结束选择
    public func endSelection() {
        SKLog("🏁 结束选择", level: .info)
        
        // 移除覆盖层
        selectionOverlay?.removeFromSuperview()
        selectionOverlay = nil
        
        // 清空状态
        selectionStartPoint = nil
        initialSelectionMode = nil
        cellsOriginalStates.removeAll()
        previousSelectedIndexPaths.removeAll()
        lastUpdateTime = 0
        lastVisualUpdateTime = 0
    }
    
    // MARK: - Private Methods - Setup
    
    /// 确定初始选择模式
    /// - Parameter point: 起始点
    private func determineInitialSelectionMode(at point: CGPoint) {
        guard let collectionView = collectionView else { return }
        
        // 检查起始点是否在某个 cell 上
        if let indexPath = collectionView.indexPathForItem(at: point),
           let isSelected = delegate?.rectSelectionManager(self, isSelectedAt: indexPath) {
            // 如果起始点在已选中的 cell 上，则为取消选中模式
            initialSelectionMode = isSelected ? .deselecting : .selecting
            SKLog("📍 起始于 cell[\(indexPath)] - \(initialSelectionMode?.description ?? "")", level: .info)
        } else {
            // 在空白区域开始拖拽，默认为选择模式
            initialSelectionMode = .selecting
            SKLog("📍 起始于空白区域 - 选中模式", level: .info)
        }
    }
    
    /// 创建并显示选择覆盖层
    /// - Parameters:
    ///   - point: 起始点
    ///   - collectionView: CollectionView
    private func createAndShowOverlay(at point: CGPoint, in collectionView: UICollectionView) {
        let overlay = SKSelectionOverlayView()
        
        // 允许代理自定义覆盖层样式
        delegate?.rectSelectionManager(self, willDisplay: overlay)
        
        // 添加到 CollectionView
        collectionView.addSubview(overlay)
        self.selectionOverlay = overlay
        
        // 初始显示一个小的选择区域
        let initialRect = CGRect(origin: point, size: CGSize(width: 1, height: 1))
        overlay.updateSelectionRect(initialRect)
    }
    
    // MARK: - Private Methods - Selection
    
    /// 计算选择矩形
    /// - Parameters:
    ///   - start: 起始点
    ///   - end: 结束点
    /// - Returns: 选择矩形
    private func calculateSelectionRect(from start: CGPoint, to end: CGPoint) -> CGRect {
        return CGRect(
            x: min(start.x, end.x),
            y: min(start.y, end.y),
            width: abs(end.x - start.x),
            height: abs(end.y - start.y)
        )
    }
    
    /// 更新选择区域内 cell 的状态
    /// - Parameter rect: 选择矩形
    private func updateCellsSelection(in rect: CGRect) {
        guard let collectionView = collectionView else { return }
        
        // 获取选择区域内的所有 cell（使用 layout 的方法，可以正确获取自定义 layout 调整后的位置）
        // 注意：这里会使用你的自定义 FlowLayout 重写的 layoutAttributesForElements(in:) 方法
        var viewRect = rect
        viewRect.origin.x = 0
        viewRect.size.width = collectionView.bounds.width
        let attributes = collectionView.collectionViewLayout
            .layoutAttributesForElements(in: viewRect)?
            .filter { attribute in
                attribute.frame.intersects(rect)
            } ?? []
        let currentIndexPathsInRect = Set(attributes.map(\.indexPath))
        
        SKLog("选择区域内有 \(currentIndexPathsInRect.count) 个 cells", level: .verbose)
        
        // 如果选择区域没有变化，跳过更新
        guard currentIndexPathsInRect != previousSelectedIndexPaths else {
            return
        }
        
        // 记录新 cell 的原始状态
        recordOriginalStates(for: currentIndexPathsInRect)
        
        // 确定目标选择状态
        let targetState = determineTargetSelectionState(for: currentIndexPathsInRect)
        
        // 更新当前区域内的 cells
        updateCells(currentIndexPathsInRect, toState: targetState)
        
        // 恢复离开选择区域的 cells
        restoreCellsOutsideSelection(currentIndexPathsInRect)
        
        // 更新记录
        previousSelectedIndexPaths = currentIndexPathsInRect
    }
    
    /// 记录 cell 的原始状态
    /// - Parameter indexPaths: IndexPath 集合
    private func recordOriginalStates(for indexPaths: Set<IndexPath>) {
        for indexPath in indexPaths where cellsOriginalStates[indexPath] == nil {
            let isSelected = delegate?.rectSelectionManager(self, isSelectedAt: indexPath) ?? false
            cellsOriginalStates[indexPath] = isSelected
        }
    }
    
    /// 确定目标选择状态
    /// - Parameter indexPaths: IndexPath 集合
    /// - Returns: 目标选择状态
    private func determineTargetSelectionState(for indexPaths: Set<IndexPath>) -> Bool {
        // 始终根据初始选择模式决定目标状态
        // 这样可以保证整个拖拽过程中选择行为的一致性
        return initialSelectionMode == .selecting
    }
    
    /// 更新 cells 到指定状态
    /// - Parameters:
    ///   - indexPaths: IndexPath 集合
    ///   - state: 目标状态
    private func updateCells(_ indexPaths: Set<IndexPath>, toState state: Bool) {
        for indexPath in indexPaths {
            delegate?.rectSelectionManager(self, didUpdateSelection: state, for: indexPath)
        }
    }
    
    /// 恢复离开选择区域的 cells
    /// - Parameter currentIndexPaths: 当前选择区域内的 IndexPath 集合
    private func restoreCellsOutsideSelection(_ currentIndexPaths: Set<IndexPath>) {
        let cellsToRestore = previousSelectedIndexPaths.subtracting(currentIndexPaths)
        
        for indexPath in cellsToRestore {
            if let originalState = cellsOriginalStates[indexPath] {
                delegate?.rectSelectionManager(self, didUpdateSelection: originalState, for: indexPath)
            }
        }
    }
}

// MARK: - Delegate Protocol

/// 矩形选择代理协议
@MainActor
public protocol SKCRectSelectionDelegate: AnyObject {
    /// 选择状态发生变化时调用
    /// - Parameters:
    ///   - manager: 矩形选择管理器
    ///   - isSelected: 新的选中状态
    ///   - indexPath: Cell 的 IndexPath
    func rectSelectionManager(
        _ manager: SKCRectSelectionManager,
        didUpdateSelection isSelected: Bool,
        for indexPath: IndexPath
    )
    
    /// 查询 cell 的选中状态
    /// - Parameters:
    ///   - manager: 矩形选择管理器
    ///   - indexPath: Cell 的 IndexPath
    /// - Returns: 是否选中
    func rectSelectionManager(
        _ manager: SKCRectSelectionManager,
        isSelectedAt indexPath: IndexPath
    ) -> Bool
    
    /// 将要显示选择覆盖层时调用（可用于自定义样式）
    /// - Parameters:
    ///   - manager: 矩形选择管理器
    ///   - overlayView: 覆盖层视图
    func rectSelectionManager(
        _ manager: SKCRectSelectionManager,
        willDisplay overlayView: SKSelectionOverlayView
    )
}
