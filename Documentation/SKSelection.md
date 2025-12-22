---
description: 可选元素集合管理
---

# SKSelection

> 可选元素集合管理

## 核心协议与类型

- **SKSelectionProtocol**: 定义了选择行为的基本协议。
- **SKSelectionState**: 管理选择状态（`isSelected`, `canSelect`, `isEnabled`）及其变更通知。
- **SKSelectionWrapper<T>**: 一个通用的包装器，使任意类型符合 `SKSelectionProtocol`。

## SKSelectionSequence

> 有序序列管理实例，通常用于数组类型的集合管理。

### 基础用法

```swift
// 1. 创建可选元素数组
let elements = [1, 1, 2, 2, 3, 3].map { SKSelectionWrapper($0) }

// 2. 初始化序列管理 (isUnique: true 表示单选模式)
let sequence = SKSelectionSequence(items: elements, isUnique: true)

// 3. 基础操作
sequence.select(at: 0)   // 选中第0个元素
sequence.deselect(at: 0) // 取消选中第0个元素
sequence.toggle(at: 0)   // 切换第0个元素的状态

// 全选与反选
sequence.selectAll()     // 全选 (注意: 单选模式下可能只选中最后一个或无效，取决于实现细节)
sequence.deselectAll()   // 全不选
```

### 高级查找与选择

支持 `Equatable` 或 `RawRepresentable` 元素的便捷操作。

```swift
let elementValue = SKSelectionWrapper(1)

// 选中全部与 elementValue 相等的元素
sequence.selectAll(elementValue)

// 选中最后一个与 elementValue 相等的元素
sequence.selectLast(elementValue)

// 选中第一个与 elementValue 相等的元素
sequence.selectFirst(elementValue)
```

### 状态监听

提供了 `itemChangedPublisher` 来监听选中项的变化。

```swift
sequence.itemChangedPublisher
    .sink { change in
        // change.offset: 变更元素的索引
        // change.element: 变更的元素
        print("Index: \(change.offset), Selected: \(change.element.isSelected)")
    }
    .store(in: &cancellables)
```

## SKSelectionIdentifiableSequence

> 基于 ID 的无序序列管理，适用于需要通过唯一标识符操作的场景。

### 初始化

```swift
let elements = [1, 2, 3].map { SKSelectionWrapper($0) }

// 需要指定作为 ID 的 KeyPath
// 例如这里使用 SKSelectionWrapper 自带的 id (UUID string)
let sequence = SKSelectionIdentifiableSequence(items: elements, id: \.id, isUnique: true)
```

### 基础操作

```swift
// 选择/取消选择
if let targetID = elements.first?.id {
    sequence.select(id: targetID)
    sequence.deselect(id: targetID)
}

// 全选/全不选
sequence.selectAll()
sequence.deselectAll()

// 状态查询
let isAll = sequence.isSelectedAll
let selectedItems = sequence.selectedItems // [Element]
let selectedIDs = sequence.selectedIDs     // [ID]
```

### 数据管理

```swift
// 刷新数据源
sequence.reload(newElements)

// 更新/新增元素 (基于 KeyPath 提取 ID)
sequence.update(newElement, by: \.id)
// 批量更新
sequence.update(newElements, by: \.id)

// 删除元素
sequence.remove(id: targetID)
sequence.removeAll()

// 检查包含
sequence.contains(id: targetID)
```

### 状态监听

```swift
// 监听变更 (每次变更都会发送 Sequence 实例自身)
sequence.itemChangedPublisher
    .sink { seq in
        print("Current selected count: \(seq.selectedItems.count)")
    }
    .store(in: &cancellables)

// 仅监听选中项列表的变化
sequence.selectedItemsPublisher
    .sink { items in
        print("Selected items changed: \(items)")
    }
    .store(in: &cancellables)
```

## 与 Section 结合使用

SectionKit 提供了便捷方法将 Section 的数据与 `SKSelectionSequence` 绑定。

```swift
import UIKit
import SectionUI
import Combine

// 1. 定义的模型需要符合 SKSelectionProtocol
// 这里直接使用 SKSelectionWrapper 包装 Int
typealias Model = SKSelectionWrapper<Int>

class CustomCell: UICollectionViewCell, SKLoadViewProtocol, SKConfigurableView {
    
    private var cancellable: AnyCancellable?
    
    func config(_ model: Model) {
        // 2. 在 Cell 中监听选中状态来更新 UI
        cancellable = model.selectedPublisher.sink(receiveValue: { [weak self] isSelected in
            self?.contentView.backgroundColor = isSelected ? .red : .blue
        })
    }
    
    // ... preferredSize implementation
}

// 3. 创建 Section
let models = [1, 2, 3].map { Model($0) }
let section = SKCSingleTypeSection<CustomCell>(models)

// 4. 获取 SelectionSequence
// 该 Sequence 会自动同步 Section 数据源的变化
let selectionManager = section.selectionSequence(isUnique: true)

// 5. 操作 SelectionSequence
// 选中第一个 Item，Cell 的 UI 会自动响应变为红色
selectionManager.select(at: 0)

// 6. 监听用户交互或其他来源导致的选中变化
selectionManager.itemChangedPublisher.sink { change in
    print("Item selected index: \(change.offset)")
}.store(in: &cancellables)
```