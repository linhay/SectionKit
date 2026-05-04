# SKSelectionSequence - 选择集合

管理一组实现了 `SKSelectionProtocol` 的可选择对象。

## 创建集合

```swift
let items = [Item1, Item2, Item3]
// 假设 items 已经是实现了 SKSelectionProtocol 的对象（如 SKSelectionWrapper）
let sequence = SKSelectionSequence(items: items, isUnique: true)
```

## 核心特性

- **isUnique**: 控制是单选 (`true`) 还是多选 (`false`)。
- **Store**: 内部维护一个数组存储元素。

## 常用操作

### 批量操作

```swift
// 全选 (仅当 isUnique = false 时有效，否则只选中最后一个)
sequence.selectAll()

// 取消全选
sequence.deselectAll()

// 重新加载数据
sequence.reload(newItems)

// 追加数据
sequence.append(moreItems)
```

### 状态获取

```swift
// 获取已选中的项
let selected = sequence.selectedItems

// 获取第一个/最后一个选中的项
let first = sequence.firstSelectedItem
let last = sequence.lastSelectedItem

// 获取选中的索引
let indices = sequence.selectedIndexs
```

### 单项操作

可以通过索引直接操作：

```swift
// 选中
sequence.select(at: 0)

// 取消选中
sequence.deselect(at: 0)

// 切换
sequence.toggle(at: 0)
```

## 响应式支持

```swift
// 监听任意元素的选中状态变化
sequence.itemChangedPublisher
    .sink { change in
        print("Changed item at \(change.offset): \(change.element.isSelected)")
    }
```
