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
section.addLayoutPlugins(.verticalAlignment(.center))

// 指定应用到哪些 Section
section.addLayoutPlugins(.verticalAlignment(.center, sections: [.all]))
```

### Right - 右对齐

```swift
section.addLayoutPlugins(.verticalAlignment(.right))
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
section.addLayoutPlugins(.fixSupplementaryViewInset(.horizontal))
section.addLayoutPlugins(.fixSupplementaryViewInset(.vertical))
```

### Fix Size - 确保尺寸生效

```swift
section.addLayoutPlugins(.fixSupplementaryViewSize)
```

### Adjust Size - 条件调整

```swift
section.addLayoutPlugins(.adjustSupplementaryViewSize { attributes in
    // 自定义调整逻辑
    if attributes.representedElementKind == UICollectionView.elementKindSectionHeader {
        attributes.size.height = 60
    }
})
```

## 自定义属性插件

直接操作 `UICollectionViewLayoutAttributes`。

### 基础用法

```swift
struct MyAttributePlugin: SKCPluginAdjustAttributesProtocol {
    
    func adjustAttributes(
        _ attributes: UICollectionViewLayoutAttributes,
        in collectionView: UICollectionView
    ) {
        // 修改属性
        attributes.alpha = 0.8
        attributes.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
    }
}

section.addLayoutPlugins(.attributes([MyAttributePlugin()]))
```

### 实战示例：卡片堆叠效果

```swift
struct StackPlugin: SKCPluginAdjustAttributesProtocol {
    
    func adjustAttributes(
        _ attributes: UICollectionViewLayoutAttributes,
        in collectionView: UICollectionView
    ) {
        let offsetY = attributes.frame.origin.y
        let scrollOffset = collectionView.contentOffset.y
        
        // 计算距离顶部的距离
        let distance = offsetY - scrollOffset
        
        if distance < 100 {
            // 越接近顶部，缩放越小
            let scale = 1 - (100 - distance) / 1000
            attributes.transform = CGAffineTransform(scaleX: scale, y: scale)
            attributes.zIndex = -Int(distance)
        }
    }
}

section.addLayoutPlugins(.attributes([StackPlugin()]))
```

## SKWaterfallLayout - 瀑布流布局 (Beta)

Pinterest 风格的瀑布流/瀑布流布局。

### 基础用法

```swift
let layout = SKWaterfallLayout()
    .columnWidth(equalParts: 2)  // 两列等宽
    .heightCalculationMode(.aspectRatio)  // 根据宽高比计算高度

collectionView.collectionViewLayout = layout
```

### 列宽配置

```swift
// 等宽列
layout.columnWidth(equalParts: 3)  // 三列

// 自定义比例
layout.columnWidth(ratios: [0.3, 0.7])  // 30% 和 70%

// 混合
layout.columnWidth(ratios: [1, 1, 2])  // 1:1:2
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
    .addLayoutPlugins(.fixSupplementaryViewSize)
    .addLayoutPlugins(.attributes([CustomPlugin()]))
```

## 插件优先级

插件按添加顺序执行：

```swift
// 先执行 Plugin A，再执行 Plugin B
section
    .addLayoutPlugins(.attributes([PluginA()]))
    .addLayoutPlugins(.attributes([PluginB()]))
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
struct SimplePlugin: SKCPluginAdjustAttributesProtocol {
    func adjustAttributes(_ attributes: UICollectionViewLayoutAttributes, in collectionView: UICollectionView) {
        attributes.alpha = 0.9  // 简单属性修改
    }
}

// ❌ 重量级计算
struct HeavyPlugin: SKCPluginAdjustAttributesProtocol {
    func adjustAttributes(_ attributes: UICollectionViewLayoutAttributes, in collectionView: UICollectionView) {
        // 避免复杂计算
        let complex = performExpensiveCalculation()
        attributes.transform = complex
    }
}
```

### 3. 瀑布流优化

```swift
let section = WaterfallCell.wrapperToSingleTypeSection()
    .setHighPerformance(.init())  // 缓存尺寸计算
    .highPerformanceID { $0.model.id }

// 预加载图片
section.prefetch.prefetchPublisher
    .sink { indexPaths in
        indexPaths.forEach { preloadImage(at: $0) }
    }
    .store(in: &cancellables)
```
