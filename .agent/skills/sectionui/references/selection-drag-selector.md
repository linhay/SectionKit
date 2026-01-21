# SKCDragSelector - 拖拽多选 (Beta)

提供高级拖拽选择功能，类似桌面操作系统的文件框选体验。

## 核心特性

- **智能意图分析**：自动区分滚动意图和框选意图。
- **边缘自动滚动**：当拖拽至边缘时自动滚动列表。
- **可视化反馈**：提供可视化的选择框覆盖层。
- **触觉反馈**：操作时的震动反馈。
- **高度可配置**：支持调整灵敏度、阈值等参数。

## 快速开始

```swift
import SectionUI

class SelectViewController: SKCollectionViewController {
    
    private let dragSelector = SKCDragSelector()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 设置拖拽选择
        try? dragSelector.setup(
            collectionView: collectionView,
            rectSelectionDelegate: self
        )
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // 清理资源
        dragSelector.reset()
    }
}
```

## 代理实现 (SKCRectSelectionDelegate)

```swift
extension SelectViewController: SKCRectSelectionDelegate {
    
    // 状态更新回调
    func rectSelectionManager(
        _ manager: SKCRectSelectionManager,
        didUpdateSelection isSelected: Bool,
        for indexPath: IndexPath
    ) {
        // 1. 更新数据模型
        let wrapper = models[indexPath.item]
        if wrapper.isSelected != isSelected {
            wrapper.isSelected = isSelected
            // 2. 刷新 UI
            section.reload(rows: [indexPath.item])
        }
    }
    
    // 状态查询
    func rectSelectionManager(
        _ manager: SKCRectSelectionManager,
        isSelectedAt indexPath: IndexPath
    ) -> Bool {
        return models[indexPath.item].isSelected
    }
    
    // 样式自定义 (可选)
    func rectSelectionManager(
        _ manager: SKCRectSelectionManager,
        willDisplay overlayView: SKSelectionOverlayView
    ) {
        overlayView.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.2)
        overlayView.layer.borderColor = UIColor.systemBlue.cgColor
        overlayView.layer.borderWidth = 1
    }
}
```

## 配置指南

通过 `SKCDragSelector.Configuration` 可以精细控制行为：

```swift
var config = SKCDragSelector.Configuration()

// 基础配置
config.enableHapticFeedback = true      // 启用触觉反馈
config.minimumDistance = 10             // 启动多选的最小拖拽距离 (pt)

// 意图分析阈值 (用于区分滚动及多选)
config.highSpeedThreshold = 3000        // 速度超过此值优先视为滚动
config.fastScrollSpeedThreshold = 400   // 快速滑动阈值
config.slowMovementThreshold = 300      // 慢速移动阈值 (利于精确选择)

// 方向判断
config.directionDominanceRatio = 1.2    // 主导方向判定倍率
config.horizontalDistanceThreshold = 20 // 横向移动触发阈值

// 应用配置
dragSelector.configuration = config
```
