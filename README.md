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

manager.reload(sections)
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

### Cell ViewModel 局部状态更新

对于进度、状态文案、按钮可用态等不影响行高和列表结构的高频变化，保持同一个引用类型模型实例，只更新它的 `@SKPublished` 字段。这样 Cell 可以自己响应变化，不需要反复 `manager.reload` 或 `section.refresh`。

```swift
import Combine

final class DownloadRowViewModel {
    let id: String
    let title: String

    @SKPublished var progressText = "0%"
    @SKPublished var isEnabled = true

    init(id: String, title: String) {
        self.id = id
        self.title = title
    }
}

final class DownloadCell: UICollectionViewCell, SKLoadViewProtocol, SKConfigurableView {
    typealias Model = DownloadRowViewModel

    private var cancellables = Set<AnyCancellable>()
    private let titleLabel = UILabel()
    private let progressLabel = UILabel()

    override func prepareForReuse() {
        super.prepareForReuse()
        cancellables.removeAll()
    }

    func config(_ model: DownloadRowViewModel) {
        cancellables.removeAll()
        titleLabel.text = model.title

        model.$progressText.bind { [weak self] value in
            self?.progressLabel.text = value
        }.store(in: &cancellables)

        model.$isEnabled.bind { [weak self] value in
            self?.contentView.alpha = value ? 1 : 0.45
        }.store(in: &cancellables)
    }
}

let rows = files.map { DownloadRowViewModel(id: $0.id, title: $0.name) }
let section = DownloadCell.wrapperToSingleTypeSection(rows)
manager.reload(section)

// 后续只改同一个 row view model 的可视状态
rows[index].progressText = "80%"
rows[index].isEnabled = false
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

核心宗旨：绑定完成后，业务只管理数据和状态，UI 变化由 SectionUI 从模型、选择状态、publisher 与 section mutation 自然派生。

| 规则 | 说明 |
|------|------|
| **绑定后只管理数据** | 完成 section / manager / view 绑定后，通过模型、publisher、selection state 和 section mutation 驱动 UI，避免直接操作可见 cell |
| **使用 SKCManager** | 始终通过 `manager` 操作 Section (reload, insert, delete) |
| **链式配置** | 使用流畅 API (`.onCellAction`, `.setHeader`) 替代子类化 |
| **分解复杂列表** | 将复杂列表拆分为多个小型 Section |
| **响应式绑定** | 使用 Combine 和 `SKPublished` 自动更新 UI |
| **缓存尺寸** | 对复杂布局使用 `SKHighPerformanceStore` |
| **弱引用捕获** | 闭包中始终使用 `[weak self]` 避免循环引用 |

---

## AI Skill 包

我们支持通过 SectionUI skills 给 AI agent 开发 SectionUI/SectionKit 功能。Codex、Claude Code、Gemini CLI 等编码助手可以安装 `sectionui.skill.zip`，按 `SKILL.md -> TASK_MAP/API_MAP -> INDEX -> reference` 读取最小上下文，生成、审查和调试数据驱动的列表页面。

### 下载

在 [GitHub Releases](https://github.com/linhay/SectionKit/releases) 页面下载 `sectionui.skill.zip`。包内包含 `BUILD_INFO.json`，记录 skill 版本、release tag 和 git commit。

### 包含内容

| 入口 | 说明 |
|------|------|
| `SKILL.md` | Agent 使用规则、版本、边界和路由入口 |
| `VERSION.md` | 当前 skill 版本和发布元数据说明 |
| `UPDATE.md` | 安装、替换、升级和本地软链开发说明 |
| `references/TASK_MAP.md` | 按任务选择最小 reference |
| `references/API_MAP.md` | 按具体 API / 类型名定位 reference |
| `references/INDEX.md` | 全部 reference 路径索引 |
| `references/*-recipes.md` | 生产使用 recipe，覆盖数据、布局、选择、性能、SwiftUI hosting 等 |
| `examples/*.swift` | 可复制的基础模板和示例 |
| `ISSUE_GUIDE.md` | 反馈流程、场景表单、复现字段和脱敏规则 |
| `BUILD_INFO.json` | 打包元数据 |

### 集成到项目

```bash
# Codex 项目级安装
mkdir -p .agents/skills/sectionui
unzip sectionui.skill.zip -d .agents/skills/sectionui

# 或者从仓库软链
git clone https://github.com/linhay/SectionKit.git
mkdir -p "$HOME/.agents/skills"
ln -s "$(pwd)/SectionKit/SectionUI.skills" "$HOME/.agents/skills/sectionui"
```

### 维护命令

```bash
python3 SectionUI.skills/scripts/package_skill.py --output sectionui.skill.zip --json
python3 SectionUI.skills/scripts/sync_release_version.py --version 2.5.4
python3 SectionUI.skills/scripts/reference_compat.py --json
python3 SectionUI.skills/scripts/verify_skill_package.py --output sectionui.skill.zip --json
python3 -m unittest discover -s SectionUI.skills/tests
```

### 发布流程

发布走 GitHub Actions。常规发布在 Actions 页面手动运行 `.github/workflows/release-sectionui-skill.yml`，留空 `release_tag`，选择 `version_bump=patch|minor|major`。workflow 会从最新裸 semver tag 自增版本，更新 `SectionKit2.podspec`、`SectionUI.podspec` 和 `SectionUI.skills/SKILL.md`，提交版本变更并推送新 tag。

新 tag 推送后，同一个 workflow 会自动校验 reference、运行 skill tests、生成 `sectionui.skill.zip`，并上传到对应 GitHub Release。也可以手动填写已有 `release_tag` 重新发布资产。保留直接推送 `*.*.*` / `v*.*.*` tag 的触发方式，但 CocoaPods source 依赖裸 tag，完整 pod 发布优先使用 `2.5.4` 这种 tag。

同一个 workflow 也会发布 CocoaPods：先发布 `SectionKit2.podspec`，等待 CocoaPods CDN 同步，再发布依赖它的 `SectionUI.podspec`。仓库需要配置 `COCOAPODS_TRUNK_TOKEN` secret；手动触发时可选择 `pod_publish=sectionui-only` 恢复中断发布，或 `pod_publish=skip` 只重发 skill release 资产。

### 反馈流程

当 skill 输出存在 API 过期、示例失效、recipe 缺口、打包安装问题或真实框架行为异常时，先按 `SectionUI.skills/ISSUE_GUIDE.md` 复现和脱敏，再选择 `.github/ISSUE_TEMPLATE/` 下对应的 GitHub Issue 表单提交。反馈中应保留 API 名、reference/source 路径、版本、最小复现代码和验证命令；不要提交私有业务代码、用户数据、内部路径、完整生产日志或未脱敏截图。

---

## 相关链接

- [完整文档](./Documentation/)
- [示例项目](./Example/)
- [DeepWiki](https://deepwiki.com/linhay/SectionKit)

## License

`SectionUI` 遵循 [Apache License](./LICENSE)。
