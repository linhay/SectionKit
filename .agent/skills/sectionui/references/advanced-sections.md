# Advanced Sections (高级 Section 类型)

除了标准的 `SKCSingleTypeSection`，SectionUI 提供多种特殊 Section 类型。

## SKCHostingSection - SwiftUI 集成

在 UICollectionView 中嵌入 SwiftUI View。

### 系统要求

```swift
@available(iOS 16.0, *)
```

### 基础用法

```swift
import SwiftUI

// 1. 定义 SwiftUI View
struct MySwiftUIView: View {
    let model: Model
    
    var body: some View {
        HStack {
            Image(systemName: "star.fill")
            Text(model.title)
            Spacer()
        }
        .padding()
        .background(Color.blue.opacity(0.1))
        .cornerRadius(8)
    }
}

// 2. 创建 HostingSection
@available(iOS 16.0, *)
let section = SKCHostingSection(
    cell: MySwiftUIView.self,
    models: viewModels,
    style: { section in
        section.sectionInset = .init(top: 16, left: 16, bottom: 16, right: 16)
        section.minimumLineSpacing = 8
    }
)

manager.reload(section)
```

### 动态更新

```swift
@available(iOS 16.0, *)
class MyViewController: SKCollectionViewController {
    
    @Published var items: [Model] = []
    
    private lazy var section = SKCHostingSection(
        cell: MySwiftUIView.self,
        models: items,
        style: { $0.sectionInset = .init(...) }
    )
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 订阅数据变化
        $items
            .sink { [weak self] newItems in
                self?.section.config(models: newItems)
                self?.section.reload()
            }
            .store(in: &cancellables)
        
        manager.reload(section)
    }
}
```

### 注意事项

- SwiftUI View 会自动包装在 `UIHostingController` 中
- 尺寸根据 SwiftUI 的 `sizeThatFits` 自动计算
- 性能优于手动创建 `UIHostingController`

## SKCAnyViewCell - 通用 UIView 容器

将任意 UIView 包装为 Cell，无需创建 Cell 类。

### 基础用法

```swift
// 创建自定义 View
let customView = MyCustomView()
customView.configure(with: data)

// 包装为 Cell Model
let cellModel = SKCAnyViewCell.Model(
    view: customView,
    size: .height(100),        // 固定高度
    layout: .fill()            // 填充布局
)

// 创建 Section
let section = SKCAnyViewCell.wrapperToSingleTypeSection()
section.config(models: [cellModel])
```

### 尺寸策略

```swift
// 固定高度，宽度自适应
.size(.height(80))

// 固定宽度，高度自适应
.size(.width(120))

// 固定宽高
.size(.fixed(CGSize(width: 100, height: 100)))

// 基于 View 的 intrinsicContentSize
.size(.intrinsic)

// 自定义计算
.size(.custom { limitSize in
    return CGSize(width: limitSize.width, height: 150)
})
```

### 布局策略

```swift
// 填充整个 Cell
.layout(.fill())

// 居中，带边距
.layout(.center(insets: .init(top: 8, left: 8, bottom: 8, right: 8)))

// 自定义布局
.layout(.custom { view, bounds in
    view.frame = bounds.insetBy(dx: 16, dy: 16)
})
```

### 实战示例：快速原型

```swift
// 快速创建列表，无需定义 Cell 类
let items = ["Item 1", "Item 2", "Item 3"]

let models = items.map { title in
    let label = UILabel()
    label.text = title
    label.font = .systemFont(ofSize: 18)
    
    return SKCAnyViewCell.Model(
        view: label,
        size: .height(44),
        layout: .fill(insets: .init(top: 0, left: 16, bottom: 0, right: 16))
    )
}

let section = SKCAnyViewCell.wrapperToSingleTypeSection()
section.config(models: models)
manager.reload(section)
```

## SKCSectionViewCell - 嵌套 Section

将整个 Section 嵌入到另一个 Section 的 Cell 中，实现复杂的嵌套布局。

### 基础用法

```swift
// 1. 创建内部 Section
class InnerCell: UICollectionViewCell, SKLoadViewProtocol, SKConfigurableView {
    struct Model { let text: String }
    // ...
}

let innerSection = InnerCell.wrapperToSingleTypeSection()
innerSection.config(models: innerModels)

// 2. 创建包装 Cell
class SectionCell: SKCSectionViewCell {
    override func setupSection() -> any SKCSectionProtocol {
        return innerSection
    }
}

// 3. 使用
let outerSection = SectionCell.wrapperToSingleTypeSection()
outerSection.config(models: [/* models for each nested section */])
```

### 泛型版本

```swift
// 使用泛型明确 Section 类型
typealias MySectionCell = SKCSingleSectionViewCell<
    SKCSingleTypeSection<InnerCell>
>

let section = MySectionCell.wrapperToSingleTypeSection()
```

### 实战示例：分组列表

```swift
struct Group {
    let title: String
    let items: [Item]
}

class GroupSectionCell: SKCSectionViewCell {
    
    var group: Group?
    
    override func setupSection() -> any SKCSectionProtocol {
        let section = ItemCell.wrapperToSingleTypeSection()
        
        if let group = group {
            section.config(models: group.items)
        }
        
        return section
    }
    
    static func preferredSize(limit size: CGSize, model: Group?) -> CGSize {
        guard let model = model else { return .zero }
        
        // 计算内部 Section 的总高度
        let itemHeight: CGFloat = 44
        let totalHeight = CGFloat(model.items.count) * itemHeight
        
        return CGSize(width: size.width, height: totalHeight)
    }
}

// 使用
let groups = [
    Group(title: "Group 1", items: [item1, item2]),
    Group(title: "Group 2", items: [item3, item4])
]

let section = GroupSectionCell.wrapperToSingleTypeSection()
section.config(models: groups)
```

## 对比与选择

| Section 类型 | 适用场景 | 优势 | 限制 |
|-------------|---------|------|------|
| **SKCSingleTypeSection** | 标准列表 | 类型安全、高性能 | 需定义 Cell 类 |
| **SKCHostingSection** | SwiftUI 集成 | 快速开发、声明式 | iOS 16+、SwiftUI 限制 |
| **SKCAnyViewCell** | 快速原型、动态内容 | 无需定义 Cell、灵活 | 类型不安全、难以复用 |
| **SKCSectionViewCell** | 复杂嵌套布局 | 强大的组合能力 | 性能开销、复杂度高 |

## 最佳实践

### 1. SwiftUI 性能优化

```swift
// ✅ 推荐 - 缓存 View
@available(iOS 16.0, *)
struct CachedSwiftUIView: View {
    let model: Model
    
    var body: some View {
        HStack { ... }
            .id(model.id)  // 帮助 SwiftUI 优化
    }
}

// ❌ 避免 - 每次重新创建复杂 View
struct HeavyView: View {
    var body: some View {
        ForEach(0..<100) { ... }  // 避免在 Cell 中使用
    }
}
```

### 2. AnyViewCell 复用

```swift
// ❌ 不推荐 - 每次创建新 View
let models = items.map { item in
    SKCAnyViewCell.Model(
        view: createComplexView(item),  // 频繁创建
        size: .height(100)
    )
}

// ✅ 推荐 - 复用 View 池
class ViewPool {
    private var pool: [MyView] = []
    
    func dequeue() -> MyView {
        pool.popLast() ?? MyView()
    }
    
    func enqueue(_ view: MyView) {
        pool.append(view)
    }
}
```

### 3. 嵌套 Section 性能

```swift
// ✅ 使用 HighPerformanceStore
class SectionCell: SKCSectionViewCell {
    override func setupSection() -> any SKCSectionProtocol {
        let section = InnerCell.wrapperToSingleTypeSection()
            .setHighPerformance(.init())  // 缓存尺寸
            .highPerformanceID { $0.model.id }
        
        return section
    }
}
```
