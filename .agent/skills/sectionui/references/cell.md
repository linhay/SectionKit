# Cell Creation & Configuration (Cell 创建与配置)

在 `SectionUI` 中，Cell 是构建列表的基本单元。要使 `UICollectionViewCell` 兼容框架的自动化功能，需遵循相关协议。

## 协议体系

### 核心协议

| 协议 | 功能 | 必需 |
|------|------|:----:|
| `SKConfigurableModelProtocol` | 定义 `config(_ model:)` 方法，用于绑定数据 | ✅ |
| `SKConfigurableLayoutProtocol` | 定义 `preferredSize(limit:model:)` 方法，用于计算尺寸 | ✅ |
| `SKConfigurableView` | 组合上述两个协议 | ✅ |
| `SKLoadViewProtocol` | 包含 `preferredSize`，用于 Cell 注册 | ✅ |

### 组合协议

```swift
// SKConfigurableView = SKConfigurableModelProtocol + SKConfigurableLayoutProtocol
public protocol SKConfigurableView: SKConfigurableModelProtocol & SKConfigurableLayoutProtocol {}
```

## 基础用法

### 标准 Cell 实现

```swift
class MyCell: UICollectionViewCell, SKLoadViewProtocol, SKConfigurableView {
    
    struct Model {
        let title: String
    }

    // 1. 计算尺寸
    static func preferredSize(limit size: CGSize, model: Model?) -> CGSize {
        return CGSize(width: size.width, height: 50)
    }

    // 2. 配置视图
    func config(_ model: Model) {
        label.text = model.title
    }
    
    private lazy var label = UILabel()
}
```

### 无 Model 的 Cell

当 Cell 不需要外部数据时，可以将 `Model` 设为 `Void`：

```swift
class SpacerCell: UICollectionViewCell, SKLoadViewProtocol, SKConfigurableView {
    
    typealias Model = Void
    
    static func preferredSize(limit size: CGSize, model: Model?) -> CGSize {
        return CGSize(width: size.width, height: 20)
    }
    
    // config 方法会自动提供空实现
}
```

## 进阶用法：自适应布局

对于使用 Auto Layout 的复杂 Cell，手动计算尺寸可能很繁琐。`SKAdaptive` 系列协议可以自动计算基于约束的尺寸。

### SKConfigurableAutoAdaptiveView（推荐）

最简单的自适应方式，自动缓存计算实例：

```swift
class AutoSizeCell: UICollectionViewCell, SKLoadViewProtocol, SKConfigurableAutoAdaptiveView {
    
    struct Model {
        let text: String
    }
    
    func config(_ model: Model) {
        label.text = model.text
    }
    
    // preferredSize 会自动基于 Auto Layout 约束计算
    // 无需手动实现
    
    private lazy var label: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(label)
        label.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(16)
        }
    }
}
```

### SKConfigurableAdaptiveView

需要自定义适配配置时使用：

```swift
class CustomAdaptiveCell: UICollectionViewCell, SKLoadViewProtocol, SKConfigurableAdaptiveView {
    
    struct Model {
        let text: String
    }
    
    // 定义适配器
    static var adaptive: SKAdaptive<CustomAdaptiveCell, Model> {
        SKAdaptive(
            view: CustomAdaptiveCell(),
            direction: .vertical,  // 垂直方向自适应
            insets: .init(top: 8, left: 16, bottom: 8, right: 16)
        )
    }
    
    func config(_ model: Model) {
        label.text = model.text
    }
    
    private lazy var label = UILabel()
}
```

### SKAdaptive 配置选项

| 参数 | 类型 | 说明 |
|------|------|------|
| `direction` | `SKLayoutDirection` | `.vertical`（固定宽度算高度）或 `.horizontal`（固定高度算宽度） |
| `insets` | `UIEdgeInsets` | 额外的边距 |
| `fittingPriority` | `SKAdaptiveFittingPriority` | 布局优先级（horizontal/vertical） |
| `content` | `KeyPath` | 指定内容视图（用于精确计算） |

```swift
// 水平方向自适应（固定高度，计算宽度）
static var adaptive: SKAdaptive<TagCell, Model> {
    SKAdaptive(
        direction: .horizontal,
        insets: .init(top: 4, left: 8, bottom: 4, right: 8)
    )
}
```

## 其他协议

### SKExistModelView

当视图需要在初始化时就传入 Model：

```swift
public protocol SKExistModelView: SKExistModelProtocol & SKConfigurableLayoutProtocol { }

// 需要实现 init(model:)
init(model: Model)
```

### RawRepresentable 支持

`SKConfigurableView` 自动支持 `RawRepresentable` 类型的配置：

```swift
enum CellType: String {
    case primary, secondary
}

// 如果 Model 是 String，可以直接传 CellType
cell.config(CellType.primary)  // 自动转换为 "primary"
```
