# SKSelectionWrapper - 选择包装器

将任何类型包装为可选择对象 (`@propertyWrapper`)，本质上是 `SKSelectionProtocol` 的便捷实现：

## 基础用法

```swift
struct Item {
    let id: String
    let title: String
}

// 包装为可选择对象
let wrapper = SKSelectionWrapper(Item(id: "1", title: "Item 1"))
// 或者作为属性包装器
@SKSelectionWrapper var item = Item(id: "1", title: "Item 1")

// 切换选择状态
wrapper.toggle()

// 直接选中
wrapper.select(true)

// 检查状态
if wrapper.isSelected {
    print("已选中")
}
```

## 初始化 (Initialization)

`SKSelectionWrapper` 提供了多种初始化方式以适应不同场景：

```swift
// 1. 基础初始化 (自动生成 ID)
let wrapper1 = SKSelectionWrapper("Value")
// or
let wrapper2 = SKSelectionWrapper("Value", id: "custom-id")

// 2. 指定 SelectionState (可选)，详情参考 [SKSelectionState](selection-state.md)
let state = SKSelectionState(isSelected: true)
let wrapper3 = SKSelectionWrapper("Value", state)

// 3. 针对 Identifiable (且 ID 为 UUID) 的便捷初始化
struct UUIDItem: Identifiable {
    let id = UUID()
}
let uuidItem = UUIDItem()
// 自动使用 item.id.uuidString 作为 wrapper.id
let wrapper4 = SKSelectionWrapper(uuidItem)

// 4. 空值包装 (WrappedValue == Void)
// 仅作为可选择状态载体，不包装具体值
let wrapper5 = SKSelectionWrapper() 
```

## 监听状态变化

```swift
let wrapper = SKSelectionWrapper(item)

// 监听选择状态
wrapper.selectedPublisher
    .sink { isSelected in
        updateUI(isSelected)
    }
    .store(in: &cancellables)

// 监听所有状态变化 (isSelected, canSelect, isEnabled)
wrapper.changedPublisher
    .sink { state in
        print("状态变化：\(state.isSelected)")
    }
    .store(in: &cancellables)
```

## 控制选择能力

```swift
// 禁用选择
wrapper.canSelect = false  // 无法被选中

// 禁用整个项
wrapper.isEnabled = false  // 完全禁用
```
