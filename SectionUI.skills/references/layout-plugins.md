# Layout Plugins (布局插件)

布局插件用于自定义 UICollectionView 的布局行为，无需子类化 UICollectionViewFlowLayout。

## 垂直对齐插件

解决 Flow Layout 中 Cell 默认底部对齐的问题。

### Left - 左对齐

```swift
section.addLayoutPlugins(.left)
```

### Center - 居中对齐

```swift
section.addLayoutPlugins(.centerX)

// 应用到整个 collection
sectionView.set(pluginModes: .centerX)
```

### Right - 右对齐

```swift
section.addLayoutPlugins(.right)
```

### 实战示例：标签云

```swift
class TagCell: UICollectionViewCell, SKLoadViewProtocol, SKConfigurableView {
    struct Model {
        let text: String
    }
    
    static func preferredSize(limit size: CGSize, model: Model?) -> CGSize {
        guard let model = model else { return .zero }
        
        // 根据文本长度计算宽度
        let width = model.text.size(
            withAttributes: [.font: UIFont.systemFont(ofSize: 14)]
        ).width + 24
        
        return CGSize(width: width, height: 32)
    }
    
    func config(_ model: Model) {
        label.text = model.text
    }
}

let section = TagCell.wrapperToSingleTypeSection()
    .config(models: tags)
    .addLayoutPlugins(.left)  // 左对齐，类似 Flexbox
```

## 水平对齐插件

### Equal Spacing - 等间距

```swift
section.addLayoutPlugins(.horizontalAlignment(.equalSpacing))
```

适用于每行 Cell 数量不固定，需要均匀分布的场景。

## Supplementary View 插件

修复 Header/Footer 的布局问题。

### Fix Inset - 修复边距

```swift
sectionView.set(pluginModes: .fixSupplementaryViewInset(.horizontal))
sectionView.set(pluginModes: .fixSupplementaryViewInset(.vertical))
```

### Fix Size - 确保尺寸生效

```swift
sectionView.set(pluginModes: .fixSupplementaryViewSize)
```

### Adjust Size - 条件调整

```swift
sectionView.set(pluginModes: .adjustSupplementaryViewSize(.including([
    .init(section: SKBindingKey(headerSection), kind: .header)
])))
```

## 自定义属性插件

直接操作 `UICollectionViewLayoutAttributes`。

### 基础用法

```swift
section.setAttributes(.set { context in
    guard context.attributes.representedElementCategory == .cell else {
        return context
    }
    context.attributes.alpha = 0.8
    context.attributes.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
    return context
})
```

### 实战示例：卡片堆叠效果

```swift
section.setAttributes(.set { context in
    let offsetY = context.attributes.frame.origin.y
    let scrollOffset = context.plugin.collectionView.contentOffset.y
    let distance = offsetY - scrollOffset

    if distance < 100 {
        let scale = 1 - (100 - distance) / 1000
        context.attributes.transform = CGAffineTransform(scaleX: scale, y: scale)
        context.attributes.zIndex = -Int(distance)
    }

    return context
})
```

## SKWaterfallLayout - 瀑布流布局 (Beta)

Pinterest 风格的瀑布流/瀑布流布局。

### 基础用法

```swift
let layout = SKWaterfallLayout()
    .columnWidth(equalParts: 2)  // 两列等宽
    .heightCalculationMode(.aspectRatio)  // 根据宽高比计算高度

sectionView.collectionViewLayout = layout
```

### 列宽配置

```swift
// 等宽列
layout.columnWidth(equalParts: 3)  // 三列

// 自定义比例
layout.columnWidth(ratios: [0.3, 0.7])  // 30% 和 70%

// 混合
layout.columnWidth(ratios: [0.25, 0.25, 0.5])  // 1:1:2, ratios must sum to 1.0
```

### 高度计算模式

```swift
// 模式 1: 固定宽高比
layout.heightCalculationMode(.aspectRatio)

// 模式 2: 固定高度
layout.heightCalculationMode(.fixed)
```

### Cell 实现

```swift
class WaterfallCell: UICollectionViewCell, SKLoadViewProtocol, SKConfigurableView {
    
    struct Model {
        let image: UIImage
        let aspectRatio: CGFloat  // 宽/高
    }
    
    static func preferredSize(limit size: CGSize, model: Model?) -> CGSize {
        guard let model = model else { return .zero }
        
        // 宽度由 Layout 提供，计算高度
        let height = size.width / model.aspectRatio
        
        return CGSize(width: size.width, height: height)
    }
    
    func config(_ model: Model) {
        imageView.image = model.image
    }
}
```

### 完整示例

参考 `Example/Layout/WaterfallViewController.swift`：

```swift
class WaterfallViewController: UIViewController {
    
    private lazy var layout: SKWaterfallLayout = {
        let layout = SKWaterfallLayout()
        layout.columnWidth(equalParts: 2)
        layout.heightCalculationMode(.aspectRatio)
        layout.minimumLineSpacing = 8
        layout.minimumInteritemSpacing = 8
        layout.sectionInset = .init(top: 8, left: 8, bottom: 8, right: 8)
        return layout
    }()
    
    private lazy var collectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        return view
    }()
    
    private lazy var section = WaterfallCell.wrapperToSingleTypeSection()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let models = generateRandomImages()  // 生成随机宽高比的图片
        section.config(models: models)
        
        let manager = SKCManager(sectionView: collectionView)
        manager.reload(section)
    }
}
```

### 注意事项

- 瀑布流布局计算较复杂，建议启用 `SKHighPerformanceStore`
- 图片加载建议使用预加载和缓存
- 列数过多会影响性能

## 组合使用插件

```swift
section
    .addLayoutPlugins(.left)
    .setAttributes(.fixSupplementaryViewSize)
    .setAttributes(.set { context in
        context.attributes.alpha = 0.95
        return context
    })
```

## 插件优先级

插件按 mode priority 执行，不按添加顺序执行；多个 attribute 调整会合并到同一个 priority 中：

```swift
section
    .setAttributes(.set { context in
        context.attributes.alpha = 0.95
        return context
    })
    .setAttributes(.fixSupplementaryViewSize)
```

## 最佳实践

### 1. 只在需要时使用插件

```swift
// ✅ 需要时使用
section.addLayoutPlugins(.left)  // 标签云场景

// ❌ 不必要
section.addLayoutPlugins(.left)  // 单列列表
```

### 2. 性能考虑

```swift
// ✅ 轻量级插件
section.setAttributes(.set { context in
    context.attributes.alpha = 0.9
    return context
})

// ❌ 重量级计算
section.setAttributes(.set { context in
    let complex = performExpensiveCalculation()
    context.attributes.transform = complex
    return context
})
```

### 3. 瀑布流优化

```swift
let section = WaterfallCell.wrapperToSingleTypeSection()
    .setHighPerformance(.init())  // 缓存尺寸计算
    .highPerformanceID(by: { $0.model.id })

// 预加载图片
section.prefetch.prefetchPublisher
    .sink { rows in
        rows.forEach { preloadImage(at: $0) }
    }
    .store(in: &cancellables)
```
