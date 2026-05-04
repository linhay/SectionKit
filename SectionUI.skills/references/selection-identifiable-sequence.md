# SKSelectionIdentifiableSequence - Identifiable 集合

基于 Identifiable 或 KeyPath ID 的选择管理，适用于需要通过 ID 来查找和操作元素的场景。

## 创建集合

```swift
struct Item {
    let id: String
    let title: String
}

// 方式 1: 直接初始化
// items: 初始数据
// id: 标识唯一 ID 的 KeyPath
// isUnique: 是否单选
let sequence = SKSelectionIdentifiableSequence(items: [], id: \.id, isUnique: true)

// 方式 2: 类型推断初始化
let sequence = SKSelectionIdentifiableSequence(Item.self, id: \.id, isUnique: true)
```

## 数据操作

### 更新数据

`SKSelectionIdentifiableSequence` 使用字典存储 (`[ID: Element]`)，需要显式更新数据：

```swift
let item = Item(id: "item-1", title: "Title")
let wrapper = SKSelectionWrapper(item)

// 更新单个元素
sequence.update(wrapper, by: \.id)

// 批量更新
sequence.update([wrapper1, wrapper2], by: \.id)

// 重新加载（清空并重新填充）
sequence.reload([wrapper])
```

## 选择操作

可以通过 ID 直接操作：

```swift
// 按 ID 选择
sequence.select(id: "item-1")

// 按 ID 取消选择
sequence.deselect(id: "item-1")

// 全选
sequence.selectAll()

// 取消全选
sequence.deselectAll()
```

## 状态获取

```swift
// 获取所有选中的元素
let selectedItems = sequence.selectedItems

// 获取所有选中的 ID
let selectedIDs = sequence.selectedIDs

// 检查某个 ID 是否被选中
let isSelected = sequence.contains(id: "item-1") && sequence.store["item-1"]?.isSelected == true
```
