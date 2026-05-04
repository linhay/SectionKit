# Selection Management (选择管理)

SectionUI 提供完整的选择状态管理系统，支持单选、多选和状态同步。

## 核心组件

### 1. 基础协议与状态

- **[SKSelectionState](selection-state.md)**: 核心状态容器，管理 `isSelected`, `canSelect`, `isEnabled` 及其 Publisher。
- **[SKSelectionProtocol](selection-protocol.md)**: 基础协议，定义了通过 `SKSelectionState` 代理实现选择能力的标准接口。

### 2. 包装器与序列

- **[SKSelectionWrapper](selection-wrapper.md)**: 通用包装器，将任意类型包装为可选择对象。
- **[SKSelectionSequence](selection-sequence.md)**: 管理一组对象（数组）的选择状态。
- **[SKSelectionIdentifiableSequence](selection-identifiable-sequence.md)**: 基于 ID 管理对象选择状态。

### 3. 高级交互

- **[SKCDragSelector](selection-drag-selector.md)**: 提供拖拽多选、自动滚动等交互功能。

## 在 Section 中使用选择

### 方式 1：使用 SKSelectionWrapper

```swift
struct Item {
    let title: String
}

class SelectableCell: UICollectionViewCell, SKLoadViewProtocol, SKConfigurableView {
    
    typealias Model = SKSelectionWrapper<Item>
    
    // 1. 存储 cancellable
    private var cancellable: AnyCancellable?
    
    func config(_ model: Model) {
        label.text = model.value.title
        
        // 2. 响应式更新 UI
        cancellable = model.selectedPublisher.sink { [weak self] isSelected in
            guard let self = self else { return }
            self.contentView.backgroundColor = isSelected ? .systemBlue : .white
        }
    }
    
    static func preferredSize(limit size: CGSize, model: Model?) -> CGSize {
        return CGSize(width: size.width, height: 44)
    }
}

// 创建可选择数据
let items = [Item(title: "A"), Item(title: "B")]
let selectableItems = items.map { SKSelectionWrapper($0) }

// 配置 Section
let section = SelectableCell.wrapperToSingleTypeSection()
    .config(models: selectableItems)
    .onCellAction(.selected) { context in
        // 点击时切换选择状态
        context.model.toggle()
        
        // 刷新 Cell
        context.section.reload(cell: context.cell)
    }
```

### 方式 2：模型直接遵循 SKSelectionProtocol

```swift
class SelectableItem: SKSelectionProtocol {
    let title: String
    // 必须实现 selection 属性
    let selection = SKSelectionState()
    
    init(title: String) {
        self.title = title
    }
    
    func toggle() {
        selection.isSelected.toggle()
    }
}
```

## 最佳实践

### 1. 选择状态 UI 反馈

```swift
func config(_ model: SKSelectionWrapper<Item>) {
    // 清晰的选中状态反馈
    contentView.backgroundColor = model.isSelected ? .systemBlue : .systemGray6
    checkmarkView.isHidden = !model.isSelected
    
    // 禁用状态
    contentView.alpha = model.isEnabled ? 1.0 : 0.5
}
```

### 2. 响应式更新

```swift
// Cell 中监听选择状态
class SelectableCell: UICollectionViewCell {
    
    private var cancellable: AnyCancellable?
    
    func config(_ model: SKSelectionWrapper<Item>) {
        // 取消之前的订阅
        cancellable?.cancel()
        
        // 订阅状态变化
        cancellable = model.selectedPublisher
            .sink { [weak self] isSelected in
                self?.updateSelectionUI(isSelected)
            }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cancellable?.cancel()
    }
}
```

### 3. 单选限制

```swift
let selectableItems = items.map { SKSelectionWrapper(value: $0) }

section.onCellAction(.selected) { context in
    // 取消其他项的选中
    selectableItems.forEach { wrapper in
        if wrapper !== context.model {
            wrapper.isSelected = false
        }
    }
    
    // 选中当前项
    context.model.select()
    
    // 刷新所有 Cell
    context.section.reload()
}
```

### 4. 批量操作确认

```swift
let selectedCount = selectableItems.filter { $0.isSelected }.count

if selectedCount > 0 {
    let alert = UIAlertController(
        title: "确认删除",
        message: "确定要删除 \(selectedCount) 个项目吗？",
        preferredStyle: .alert
    )
    // ...
}
```
