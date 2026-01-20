# Decorations (装饰视图)

装饰视图允许你在 Section 或 Cell 后面添加视觉元素（如背景）。

## 基本用法：Section 背景

为 Section 添加简单的背景颜色或视图：

1.  **创建装饰视图**：必须遵循 `SKCDecorationView` 协议（它是 `UICollectionReusableView` 的子类型）。
2.  **应用到 Section**：使用 `set(decoration:)` API。

```swift
class MyBackgroundView: UICollectionReusableView, SKCDecorationView {
    // 实现标准 init
}

// 1. 基础背景
section.set(decoration: MyBackgroundView.self)

// 2. 带样式的背景
section.set(decoration: MyBackgroundView.self, model: myModel) 
```

## 进阶用法

### 1. 跨多个 Section

如果要创建跨越多个 Section 的装饰视图（例如，用卡片背景包裹多个列表），需要手动指定 `from` 和 `to`。

```swift
// 应用到第一个 Section（或逻辑上相关的 Section）
section.set(decoration: MyBackgroundView.self, model: myModel) { decoration in
    decoration.to = .init(toSection)
}
```

### 2. 自定义边界计算 (Mode / Layout)

#### Layout（布局元素）

`layout` 属性指定装饰视图应该覆盖哪些布局元素。可选值：

- **`.header`**：包含 Section Header 区域。
- **`.cells`**：包含所有 Cell 区域。
- **`.footer`**：包含 Section Footer 区域。

默认值为 `[.header, .cells, .footer]`，即覆盖整个 Section。

```swift
section.set(decoration: MyBackgroundView.self) { decoration in
    // 只覆盖 Cells 区域，不包含 Header 和 Footer
    decoration.from.layout = [.cells]
}
```

#### Mode（边界计算模式）

`modes` 属性控制装饰视图边界的计算方式，**默认值为 `.visibleView`**。

- **`.visibleView`** (默认)：边界匹配当前可见的 Cells/Headers/Footers 的并集（动态，适合粘性 Header）。
- **`.section`**：边界匹配整个逻辑 Section 区域。**如果需要包含 `sectionInset` 区域，必须切换为此模式**。
- **`.useSectionInsetWhenNotExist([.header, .footer, .cells])`**：如果指定的元素不存在，使用 `sectionInset` 来填充边界。

#### 使用场景 (Usage Scenarios)

| 场景 | 推荐 Mode | 说明 |
|------|-----------|------|
| **常规背景** | `.visibleView` | 默认模式，性能较优，背景紧贴可见内容。 |
| **包含 Section Insets** | `.section` | 如果 Section 设置了 `insets` 且希望背景覆盖这些留白区域，必须使用 `.section`。 |
| **Sticky Header** | `.visibleView` | 背景会正确跟随吸顶 Header 移动。 |

```swift
section.set(decoration: MyBackgroundView.self, model: myModel) { decoration in
    decoration.from.modes = [.section, .useSectionInsetWhenNotExist([.header, .footer])]
}
```

### 3. 多装饰视图与层级

可以为同一个 Section 添加多个装饰视图（例如，背景色和边框叠加层），通过多次调用 `addLayoutPlugins` 或传入数组实现。使用 `zIndex` 控制层级。

```swift
section
.set(decoration: MyBackgroundView.self, model: myModel) { decoration in
    decoration.zIndex = -1
}
.set(decoration: MyBackgroundView.self, model: myModel) { decoration in
    decoration.zIndex = -2
}
```

### 4. 生产环境常见模式

以下是处理常见需求的真实案例。

#### 扩展背景（负 Insets）
如果希望背景扩展到 Section 内容区域之外（例如，覆盖 padding 区域），可以使用负 insets。

```swift
section.set(decoration: SectionCornerRadiusView.self,
            model: .init(backgroundColor: Colors.n1.color, cornerRadius: 12)) { decoration in
   // 向左/右/下扩展 12pt 以覆盖 padding
   decoration.insets = .init(top: 0, left: -12, bottom: -24, right: -12)
}
```
### 5. 生命周期事件 (onAction)

使用 `onAction` 监听装饰视图的生命周期事件，可以在显示时动态配置视图。

#### 可用事件类型

- **`.willDisplay`**：装饰视图即将显示时触发。
- **`.didEndDisplaying`**：装饰视图结束显示时触发。

#### 使用场景

**1. 动态配置视图**

当装饰视图是通用类型（如 `SectionCornerRadiusView`）时，可以在显示时配置其样式：

```swift
section.set(decoration: SectionCornerRadiusView.self) { decoration in
    decoration.onAction(.willDisplay) { context in
        context.view.config(backgroundColor: .white, cornerRadius: 12)
    }
}
```

**2. 跟踪显示状态**

```swift
section.set(decoration: MyBackgroundView.self) { decoration in
    decoration.onAction(.willDisplay) { context in
        print("装饰视图开始显示: section \(context.indexPath.section)")
    }
    decoration.onAction(.didEndDisplaying) { context in
        print("装饰视图结束显示")
    }
}
```

#### Context 属性

`onAction` 回调提供的 `context` 包含：

| 属性 | 类型 | 说明 |
|------|------|------|
| `type` | `SKCSupplementaryActionType` | 事件类型 |
| `kind` | `SKSupplementaryKind` | 装饰视图的标识符 |
| `indexPath` | `IndexPath` | 装饰视图所在的位置 |
| `view` | `View` | 装饰视图实例（已类型转换） |

## 示例

- **[装饰视图实现](../examples/DecorationViews.swift)**：装饰视图的示例实现。
- **[使用示例控制器](../examples/DecorationExampleViewController.swift)**：展示如何应用装饰视图的完整控制器。
