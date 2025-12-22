# SectionKit 使用教程

SectionKit 是一个数据驱动的 `UICollectionView` 框架，旨在提供快速、灵活且高度可复用的列表构建方式。

---

## 目录

- [第一部分：快速开始](#第一部分快速开始)
- [第二部分：核心概念](#第二部分核心概念)
- [第三部分：基础功能](#第三部分基础功能)
- [第四部分：中级功能](#第四部分中级功能)
- [第五部分：高级功能](#第五部分高级功能)
- [第六部分：专家技巧](#第六部分专家技巧)

---

# 第一部分：快速开始

本部分将帮助你在 5 分钟内运行起第一个 SectionKit 列表。

## 1.1 安装

**CocoaPods:**
```ruby
pod 'SectionUI', '~> 2.4.0'
```

**Swift Package Manager:**
```
https://github.com/linhay/SectionKit
```

## 1.2 Hello World

```swift
import SectionUI

// 1. 定义 Cell
class TextCell: UICollectionViewCell, SKLoadViewProtocol, SKConfigurableView {
    typealias Model = String
    
    private let label = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(label)
        label.frame = contentView.bounds
        label.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    func config(_ model: String) {
        label.text = model
    }
    
    static func preferredSize(limit size: CGSize, model: String?) -> CGSize {
        CGSize(width: size.width, height: 44)
    }
}

// 2. 创建 ViewController
class MyViewController: SKCollectionViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let items = ["Apple", "Banana", "Cherry"]
        let section = TextCell.wrapperToSingleTypeSection(items)
        manager.reload(section)
    }
}
```

恭喜！你已经创建了第一个 SectionKit 列表。

---

# 第二部分：核心概念

理解这些概念是掌握 SectionKit 的关键。

## 2.1 三个核心协议

| 协议 | 作用 |
|-----|------|
| `SKLoadViewProtocol` | 定义 Cell 的加载方式（纯代码 / XIB） |
| `SKConfigurableView` | 定义 Cell 的配置方法和尺寸计算 |
| `SKConfigurableModelProtocol` | 可选，用于约束 Model 类型 |

## 2.2 Section 是什么

Section 是 SectionKit 的核心单元。每个 Section 管理：
- 一组同类型的 Cell
- 该组 Cell 的数据源 (Models)
- 布局配置（间距、边距等）
- 事件回调（点击、显示等）

```swift
// 最常用的 Section 类型
let section = MyCell.wrapperToSingleTypeSection(models)
```

## 2.3 Manager 的作用

`SKCManager` 是 Section 的容器，负责：
- 管理多个 Section
- 处理 UICollectionView 的 DataSource / Delegate
- 协调 Section 间的交互

```swift
// 通过 SKCollectionViewController 自动获得 manager
class MyVC: SKCollectionViewController {
    func reload() {
        manager.reload([section1, section2])
    }
}
```

---

# 第三部分：基础功能

## 3.1 处理点击事件

```swift
let section = TextCell.wrapperToSingleTypeSection(items)
    .onCellAction(.selected) { context in
        print("点击了: \(context.model)")
    }
```

### 常用事件类型

| 事件 | 触发时机 |
|-----|---------|
| `.selected` | Cell 被点击 |
| `.willDisplay` | Cell 即将显示 |
| `.didEndDisplaying` | Cell 离开屏幕 |

## 3.2 添加 Header / Footer

```swift
section.set(supplementary: MyHeaderView.self) { context in
    context.view.config("标题")
}
```

## 3.3 配置 Section 样式

```swift
section.setSectionStyle { section in
    section.sectionInset = UIEdgeInsets(top: 10, left: 15, bottom: 10, right: 15)
    section.minimumLineSpacing = 10
    section.minimumInteritemSpacing = 10
}
```

## 3.4 多个 Section

```swift
let headerSection = HeaderCell.wrapperToSingleTypeSection([headerModel])
let listSection = ListCell.wrapperToSingleTypeSection(listModels)
let footerSection = FooterCell.wrapperToSingleTypeSection([footerModel])

manager.reload([headerSection, listSection, footerSection])
```

---

# 第四部分：中级功能

## 4.1 网格布局

使用 `cellSafeSize` 控制 Cell 尺寸：

```swift
// 一行 3 列
section.cellSafeSize(.fraction(1.0 / 3.0))

// 固定宽度 + 正方形
section.cellSafeSize(.fraction(0.5), transforms: .height(asRatioOfWidth: 1))
```

## 4.2 下拉刷新

```swift
SKCollectionViewController()
    .reloadSections(section)
    .refreshable {
        await viewModel.fetchData()
        section.config(models: viewModel.data)
    }
```

## 4.3 装饰视图（Section 背景）

```swift
section.set(decoration: BackgroundView.self, model: .white) { decoration in
    decoration.sectionInset = UIEdgeInsets(top: -8, left: -8, bottom: -8, right: -8)
    decoration.zIndex = -1
}
```

## 4.4 索引标题

```swift
section.setSectionStyle { $0.indexTitle = "A" }
```

## 4.5 SwiftUI 预览

```swift
#Preview {
    SKPreview.sections {
        TextCell.wrapperToSingleTypeSection(["A", "B", "C"])
    }
}
```

---

# 第五部分：高级功能

## 5.1 自适应高度 Cell

使用 `SKConfigurableAdaptiveMainView` 协议：

```swift
class AdaptiveCell: UICollectionViewCell, SKLoadViewProtocol, SKConfigurableAdaptiveMainView {
    static let adaptive = SpecializedAdaptive()
    
    func config(_ model: String) {
        contentConfiguration = UIHostingConfiguration {
            Text(model).padding()
        }.margins(.all, 0)
    }
}
```

## 5.2 响应式 Cell（精细化更新）

使用 `@SKPublished` 实现 Cell 级别的响应式更新：

```swift
class Model {
    @SKPublished var isSelected = false
}

class MyCell: UICollectionViewCell, SKLoadViewProtocol, SKConfigurableView {
    private var cancellables = Set<AnyCancellable>()
    
    func config(_ model: Model) {
        cancellables.removeAll()
        model.$isSelected.bind { [weak self] selected in
            self?.backgroundColor = selected ? .blue : .white
        }.store(in: &cancellables)
    }
}
```

## 5.3 选择状态管理

### 基础方式

```swift
class MySection: SKCSingleTypeSection<MyCell>, SKSelectionSequenceProtocol {
    var selectableElements: [MyCell.Model] { models }
    
    override func item(selected row: Int) {
        select(at: row, isUnique: true, needInvert: false)
    }
}
```

### 自动绑定方式

```swift
let selection = section.selectionSequence(isUnique: true)
selection.itemChangedPublisher.sink { change in
    print("选中变化: \(change.offset)")
}.store(in: &cancellables)
```

## 5.4 嵌套横向列表

```swift
let verticalSection = ItemCell.wrapperToSingleTypeSection(items)
let horizontalSection = verticalSection.wrapperToHorizontalSection(height: 120)
```

## 5.5 曝光埋点

```swift
section.model(displayedAt: 1) { context in
    Analytics.log("item_viewed", id: context.model.id)
}
```

---

# 第六部分：专家技巧

## 6.1 Diff 刷新

```swift
section.reloadKind = .difference(by: \.id)
```

## 6.2 布局插件

```swift
// 对齐方式
section.addLayoutPlugins(.left)
section.addLayoutPlugins(.centerX)
section.addLayoutPlugins(.right)

// 属性微调
section.setAttributes { context in
    context.attributes.alpha = 0.5
}
```

## 6.3 拖拽排序

```swift
class ReorderSection: SKCSingleTypeSection<MyCell> {
    override func item(canMove row: Int) -> Bool { true }
    
    override func move(from source: IndexPath, to destination: IndexPath) {
        super.move(from: source, to: destination)
    }
}
```

## 6.4 上下文菜单

```swift
section.onContextMenu { context in
    UIContextMenuConfiguration(actionProvider: { _ in
        UIMenu(children: [
            UIAction(title: "删除") { _ in /* ... */ }
        ])
    })
}
```

## 6.5 瀑布流布局

```swift
let layout = SKWaterfallLayout().columnWidth(equalParts: 2)
sectionController.sectionViewStyle { view in
    view.setCollectionViewLayout(layout, animated: false)
}
```

## 6.6 性能优化

### 高性能尺寸缓存

```swift
class MyCell: UICollectionViewCell, SKLoadViewProtocol, SKConfigurableView {
    static let sizeCache = SKHighPerformanceStore<String>()
    
    static func preferredSize(limit size: CGSize, model: Model?) -> CGSize {
        sizeCache.cache(by: model?.id ?? "", limit: size) { limit in
            // 复杂计算...
            return calculatedSize
        }
    }
}
```

### 性能调试

```swift
SKPerformance.shared.duration("布局计算") {
    // 你的代码
}
```

## 6.7 视图距离监听（吸顶效果）

```swift
section.pinHeader { options in
    options.$distance.sink { distance in
        // 根据距离调整透明度、缩放等
    }
}
```

## 6.8 包装器 Cell

### 任意 UIView 包装

```swift
let view = UIView()
let section = SKCAnyViewCell.wrapperToSingleTypeSection(
    .init(view: view, size: .height(100), layout: .fill())
)
```

### SwiftUI View 包装

```swift
struct MySwiftUIView: View, SKExistModelProtocol {
    var model: String
    var body: some View { Text(model) }
}

let section = MySwiftUIView.wrapperToCollectionCell()
    .wrapperToSingleTypeSection(["Hello"])
```

## 6.9 SwiftUI 集成

在 SwiftUI 中使用 SectionKit：

```swift
struct ContentView: View {
    var body: some View {
        UIViewController.sk.toSwiftUI {
            let vc = SKCollectionViewController()
            // 配置...
            return vc
        }
    }
}
```

---

# 附录

## 常用协议速查

| 协议 | 用途 |
|-----|------|
| `SKLoadViewProtocol` | 代码创建视图 |
| `SKLoadNibProtocol` | XIB 创建视图 |
| `SKConfigurableView` | 配置视图 + 尺寸计算 |
| `SKConfigurableAdaptiveMainView` | 自适应高度视图 |
| `SKSelectionProtocol` | 选择状态协议 |

## 下一步

- 查看 `Example` 目录获取更多示例
- 阅读 `SKPageViewController.md` 了解分页控制器
- 阅读 `SKSelection.md` 了解选择状态管理

---
