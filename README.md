<p align="center">
  <img src="https://raw.githubusercontent.com/linhay/SectionKit/dev/Documentation/Images/icon.svg" width=450 />
</p>

<p align="center">
<a href="https://deepwiki.com/linhay/SectionKit"><img src="https://deepwiki.com/badge.svg" alt="Platforms"></a>
  <a href="https://cocoapods.org/pods/SectionUI"><img src="https://img.shields.io/cocoapods/v/SectionUI.svg?style=flat" alt="Pods Version"></a>
  <a href="https://instagram.github.io/SectionUI/"><img src="https://img.shields.io/cocoapods/p/SectionUI.svg?style=flat" alt="Platforms"></a>
</p>

---

**SectionUI** 是一个强大的数据驱动 `UICollectionView` 框架，用于构建快速灵活的列表界面。

|           | 主要特性                                  |
| --------- | ----------------------------------------- |
| &#127968; | 更好的可复用 Cell 和组件体系结构          |
| &#128288; | 创建具有多个数据类型的列表                |
| &#128241; | 简化并维持 `UICollectionView` 的核心特性 |
| &#9989;   | 超多的布局插件来帮助你构建更好的列表          |
| &#128038; | Swift 编写, 同时完全支持 SwiftUI 和 Combine |

## 安装

### Swift Package Manager

```swift
dependencies: [
    .package(url: "https://github.com/linhay/SectionKit", from: "2.5.0")
]
```

### CocoaPods

```ruby
# 完整功能（推荐）
pod 'SectionUI', '~> 2.5.0'

# 仅核心功能
pod 'SectionKit2', '~> 2.5.0'
```

### 前提条件

- Swift 5.8+
- iOS 13.0+

---

## 快速开始

### 1. 创建 Cell

```swift
class ItemCell: UICollectionViewCell, SKLoadViewProtocol, SKConfigurableView {
    struct Model {
        let title: String
        let subtitle: String
    }

    static func preferredSize(limit size: CGSize, model: Model?) -> CGSize {
        CGSize(width: size.width, height: 60)
    }

    func config(_ model: Model) {
        textLabel.text = model.title
        detailLabel.text = model.subtitle
    }
    
    private lazy var textLabel = UILabel()
    private lazy var detailLabel = UILabel()
}
```

### 2. 创建 Section 并绑定数据

```swift
class MyViewController: SKCollectionViewController {
    
    private lazy var section = ItemCell.wrapperToSingleTypeSection()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 配置事件
        section.onCellAction(.selected) { [weak self] context in
            print("选中: \(context.model.title)")
        }
        
        // 加载数据
        section.config(models: [
            .init(title: "Item 1", subtitle: "Description"),
            .init(title: "Item 2", subtitle: "Description"),
        ])
        
        manager.reload(section)
    }
}
```

---

## 代码示例

### 多组 Section

```swift
let headerSection = HeaderCell.wrapperToSingleTypeSection()
let contentSection = ContentCell.wrapperToSingleTypeSection()
let footerSection = FooterCell.wrapperToSingleTypeSection()

// 类型擦除后统一管理
var sections: [SKCSectionProtocol] = [
    headerSection,
    contentSection,
    footerSection
]

manager.update(sections)
```

### Combine 响应式绑定

```swift
class ViewModel {
    @SKPublished var items: [Item] = []
}

// 自动订阅数据变化
section.subscribe(models: viewModel.$items.eraseToAnyPublisher())

// 或使用 bind()
viewModel.$items.bind { [weak self] newItems in
    self?.section.config(models: newItems)
}.store(in: &cancellables)
```

### 设置 Header 和装饰视图

```swift
section
    .setHeader(MyHeader.self, model: "Section Title")
    .setFooter(MyFooter.self, model: "Footer Text")
    .setDecoration(BackgroundView.self) { context in
        context.view.backgroundColor = .systemGroupedBackground
        context.view.layer.cornerRadius = 12
    }
```

### 分页加载

```swift
// 监听加载更多
section.prefetch.loadMorePublisher
    .sink { [weak self] in
        self?.loadNextPage()
    }
    .store(in: &cancellables)

// 下拉刷新
sectionView.refreshControl = UIRefreshControl()
```

### 网格布局

```swift
// 两列等宽
section.cellSafeSize(.fraction(0.5))

// 三列等宽 + 固定宽高比
section.cellSafeSize(.fraction(1.0 / 3.0), transforms: .aspectRatio(1.0))
```

---

## 高阶用法

### 高性能模式 (尺寸缓存)

对于复杂 Auto Layout 布局，启用尺寸缓存可显著提升滚动性能：

```swift
section
    .setHighPerformance(.init())
    .highPerformanceID { context in
        context.model.id  // 每个 model 的唯一标识
    }
```

### 差异刷新算法

智能计算数据差异，实现流畅的插入/删除动画：

```swift
// 基于 ID 比较
section.reloadKind = .difference(by: \.id)

// 基于 Equatable
section.reloadKind = .difference()
```

### 固定 Header/Footer (Sticky)

```swift
section.pinHeader { options in
    options.padding = 16
}

section.pinFooter { options in
    options.pinToVisibleBounds = true
}
```

### 选择状态管理

```swift
// 包装模型以支持选择
let selectableItems = items.map { SKSelectionWrapper(value: $0) }
section.config(models: selectableItems)

// 监听选择状态
wrapper.selectedPublisher
    .sink { isSelected in
        updateUI(isSelected)
    }
    .store(in: &cancellables)
```

### SwiftUI 集成

```swift
@available(iOS 16.0, *)
let section = SKCHostingSection(
    cell: MySwiftUIView.self,
    models: viewModels
)
```

### 瀑布流布局

```swift
let layout = SKWaterfallLayout()
    .columnWidth(equalParts: 2)
    .heightCalculationMode(.aspectRatio)
```

### 曝光统计

```swift
section.model(displayedAt: .first) { context in
    Analytics.track(event: "item_impression", properties: [
        "item_id": context.model.id,
        "position": context.indexPath.item
    ])
}
```

---

## 最佳实践

| 规则 | 说明 |
|------|------|
| **使用 SKCManager** | 始终通过 `manager` 操作 Section (reload, insert, delete) |
| **链式配置** | 使用流畅 API (`.onCellAction`, `.setHeader`) 替代子类化 |
| **分解复杂列表** | 将复杂列表拆分为多个小型 Section |
| **响应式绑定** | 使用 Combine 和 `SKPublished` 自动更新 UI |
| **缓存尺寸** | 对复杂布局使用 `SKHighPerformanceStore` |
| **弱引用捕获** | 闭包中始终使用 `[weak self]` 避免循环引用 |

---

## AI Skills 文档包

我们为 AI 编码助手（如 Antigravity、Copilot、Claude）提供了详细的技能文档包。

### 下载

在 [GitHub Releases](https://github.com/linhay/SectionKit/releases) 页面下载 `sectionui-skills.zip`。

### 包含内容

| 文档 | 说明 |
|------|------|
| `cell.md` | Cell 创建与配置 |
| `section.md` | Section 管理与事件处理 |
| `reactive.md` | 响应式编程与 Combine 集成 |
| `performance.md` | 性能优化技巧 |
| `selection.md` | 选择状态管理 |
| `pin.md` | 固定 Header/Footer |
| `decorations.md` | 装饰视图 |
| `layout-plugins.md` | 布局插件 |
| `page.md` | 分页视图控制器 |

### 集成到项目

```bash
# 解压到项目目录
unzip sectionui-skills.zip -d .agent/skills/

# 或者直接从仓库克隆
git clone https://github.com/linhay/SectionKit.git
cp -r SectionKit/.agent/skills/sectionui .agent/skills/
```

### 快速链接 (其他 AI 助手)

**GitHub Copilot:**
```bash
mkdir -p .github && ln -s ../.agent/skills .github/skills
```

**Claude Desktop:**
```bash
mkdir -p .claude && ln -s ../.agent/skills .claude/skills
```

---

## 相关链接

- [完整文档](./Documentation/)
- [示例项目](./Example/)
- [DeepWiki](https://deepwiki.com/linhay/SectionKit)

## License

`SectionUI` 遵循 [Apache License](./LICENSE)。
