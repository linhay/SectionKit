# Selection Management (选择管理)

SectionUI 提供完整的选择状态管理系统，支持单选、多选和状态同步。

## 核心协议：SKSelectionProtocol

选择状态的基础协议：

```swift
public protocol SKSelectionProtocol {
    var isSelected: Bool { get set }
    var canSelect: Bool { get set }
    var isEnabled: Bool { get set }
    
    var selectedPublisher: AnyPublisher<Bool, Never> { get }
    var canSelectPublisher: AnyPublisher<Bool, Never> { get }
    var enabledPublisher: AnyPublisher<Bool, Never> { get }
    var changedPublisher: AnyPublisher<Self, Never> { get }
    
    func toggle()
    func select()
}
```

## SKSelectionWrapper - 选择包装器

将任何类型包装为可选择对象：

### 基础用法

```swift
struct Item {
    let id: String
    let title: String
}

// 包装为可选择对象
let wrapper = SKSelectionWrapper(value: Item(id: "1", title: "Item 1"))

// 切换选择状态
wrapper.toggle()

// 直接选中
wrapper.select()

// 检查状态
if wrapper.isSelected {
    print("已选中")
}
```

### 监听状态变化

```swift
let wrapper = SKSelectionWrapper(value: item)

// 监听选择状态
wrapper.selectedPublisher
    .sink { isSelected in
        updateUI(isSelected)
    }
    .store(in: &cancellables)

// 监听任何属性变化
wrapper.changedPublisher
    .sink { wrapper in
        print("状态变化：\(wrapper)")
    }
    .store(in: &cancellables)
```

### 控制选择能力

```swift
// 禁用选择
wrapper.canSelect = false  // 无法被选中

// 禁用整个项
wrapper.isEnabled = false  // 完全禁用
```

## SKSelectionSequence - 选择集合

管理一组可选择对象：

### 创建集合

```swift
let items = [Item1, Item2, Item3]
let sequence = SKSelectionSequence(items.map { SKSelectionWrapper(value: $0) })
```

### 批量操作

```swift
// 全选
sequence.selectAll()

// 取消全选
sequence.deselectAll()

// 反选
sequence.toggleAll()

// 获取已选中的项
let selected = sequence.selectedItems  // [SKSelectionWrapper]
```

### 单选模式

```swift
let sequence = SKSelectionSequence<SKSelectionWrapper<Item>>()

// 设置为单选
sequence.maxSelectableCount = 1

// 当选择新项时，自动取消其他项的选中状态
```

## SKSelectionIdentifiableSequence - Identifiable 集合

基于 Identifiable 的选择管理：

```swift
struct Item: Identifiable {
    let id: String
    let title: String
}

let sequence = SKSelectionIdentifiableSequence<Item>()

// 按 ID 选择
sequence.select(id: "item-1")

// 按 ID 取消选择
sequence.deselect(id: "item-2")

// 检查是否选中
if sequence.isSelected(id: "item-1") {
    print("已选中")
}

// 获取所有选中的 ID
let selectedIDs = sequence.selectedIDs  // [String]
```

## 在 Section 中使用选择

### 方式 1：使用 SKSelectionWrapper

```swift
struct Item {
    let title: String
}

class SelectableCell: UICollectionViewCell, SKLoadViewProtocol, SKConfigurableView {
    
    typealias Model = SKSelectionWrapper<Item>
    
    func config(_ model: Model) {
        label.text = model.value.title
        
        // 更新选中状态 UI
        contentView.backgroundColor = model.isSelected ? .systemBlue : .white
    }
    
    static func preferredSize(limit size: CGSize, model: Model?) -> CGSize {
        return CGSize(width: size.width, height: 44)
    }
}

// 创建可选择数据
let items = [Item(title: "A"), Item(title: "B")]
let selectableItems = items.map { SKSelectionWrapper(value: $0) }

// 配置 Section
let section = SelectableCell.wrapperToSingleTypeSection()
    .config(models: selectableItems)
    .onCellAction(.selected) { context in
        // 点击时切换选择状态
        context.model.toggle()
        
        // 刷新 Cell
        context.section.reload(rows: [context.indexPath.item])
    }
```

### 方式 2：模型直接遵循 SKSelectionProtocol

```swift
class SelectableItem: SKSelectionProtocol {
    let title: String
    var isSelected: Bool = false
    var canSelect: Bool = true
    var isEnabled: Bool = true
    
    // Publishers...
    private let selectedSubject = CurrentValueSubject<Bool, Never>(false)
    var selectedPublisher: AnyPublisher<Bool, Never> {
        selectedSubject.eraseToAnyPublisher()
    }
    // ... 其他 publishers
    
    init(title: String) {
        self.title = title
    }
    
    func toggle() {
        isSelected.toggle()
        selectedSubject.send(isSelected)
    }
    
    func select() {
        isSelected = true
        selectedSubject.send(isSelected)
    }
}
```

## 拖拽多选：SKCDragSelector (Beta)

高级拖拽选择功能，类似桌面文件选择。

### 功能特性

- 智能意图分析（区分滚动和选择）
- 边缘自动滚动
- 可视化选择覆盖层
- 触觉反馈
- 可配置的手势阈值

### 设置

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
        
        // 配置选项
        dragSelector.isEnabled = true
        dragSelector.minimumPressDuration = 0.2  // 长按时长
        dragSelector.movementThreshold = 5.0     // 移动阈值
    }
}

// 实现代理
extension SelectViewController: SKCRectSelectionDelegate {
    
    func rectSelectionManager(
        _ manager: SKCRectSelectionManager,
        didUpdateSelection isSelected: Bool,
        for indexPath: IndexPath
    ) {
        // 更新模型选择状态
        models[indexPath.item].isSelected = isSelected
        
        // 刷新 Cell UI
        section.reload(rows: [indexPath.item])
    }
    
    func rectSelectionManager(
        _ manager: SKCRectSelectionManager,
        shouldSelectItemAt indexPath: IndexPath
    ) -> Bool {
        // 返回是否允许选择该项
        return models[indexPath.item].canSelect
    }
}
```

### 配置选项

```swift
// 调整手势灵敏度
dragSelector.movementThreshold = 10.0  // 默认 5.0

// 调整长按时长
dragSelector.minimumPressDuration = 0.5  // 默认 0.2

// 禁用/启用
dragSelector.isEnabled = false

// 调整自动滚动速度
dragSelector.autoScrollManager.scrollSpeed = 200  // 默认 150
```

### 完整示例

参考 `Example/Data/SelectTextViewController.swift`：

```swift
class SelectTextViewController: SKCollectionViewController {
    
    private var items: [SelectableItem] = []
    private let dragSelector = SKCDragSelector()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 初始化数据
        items = (0..<100).map { SelectableItem(title: "Item \($0)") }
        
        // 配置 Section
        section.config(models: items.map { SKSelectionWrapper(value: $0) })
        manager.reload(section)
        
        // 启用拖拽选择
        try? dragSelector.setup(
            collectionView: collectionView,
            rectSelectionDelegate: self
        )
        
        // 添加工具栏按钮
        setupToolbar()
    }
    
    private func setupToolbar() {
        let selectAllButton = UIBarButtonItem(
            title: "全选",
            style: .plain,
            target: self,
            action: #selector(selectAll)
        )
        
        let deselectAllButton = UIBarButtonItem(
            title: "取消全选",
            style: .plain,
            target: self,
            action: #selector(deselectAll)
        )
        
        toolbarItems = [selectAllButton, deselectAllButton]
        navigationController?.setToolbarHidden(false, animated: false)
    }
    
    @objc private func selectAll() {
        items.forEach { $0.select() }
        section.reload()
    }
    
    @objc private func deselectAll() {
        items.forEach { $0.isSelected = false }
        section.reload()
    }
}

extension SelectTextViewController: SKCRectSelectionDelegate {
    
    func rectSelectionManager(
        _ manager: SKCRectSelectionManager,
        didUpdateSelection isSelected: Bool,
        for indexPath: IndexPath
    ) {
        items[indexPath.item].isSelected = isSelected
        section.reload(rows: [indexPath.item])
    }
    
    func rectSelectionManager(
        _ manager: SKCRectSelectionManager,
        shouldSelectItemAt indexPath: IndexPath
    ) -> Bool {
        return items[indexPath.item].canSelect
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
