# SKSelectionProtocol

选择状态的基础协议，通过 `SKSelectionState` (详情参考 [SKSelectionState](selection-state.md)) 代理实现：

## 协议定义

```swift
public protocol SKSelectionProtocol {
    var selection: SKSelectionState { get }
}
```

## 功能扩展

协议扩展提供了便捷访问属性和 Publisher：

```swift
public extension SKSelectionProtocol {
    // 基础属性
    var isSelected: Bool { get }
    var canSelect: Bool { get set }
    var isEnabled: Bool { get set }
    
    // Publishers
    var selectedPublisher: AnyPublisher<Bool, Never> { get }
    var canSelectPublisher: AnyPublisher<Bool, Never> { get }
    var enabledPublisher: AnyPublisher<Bool, Never> { get }
    var changedPublisher: AnyPublisher<SKSelectionState, Never> { get }
    
    // 操作方法
    func toggle()
    func select(_ value: Bool) -> Bool
}
```

## 实现示例

### 1. 使用 SKSelectionWrapper

最简单的方式是使用 `SKSelectionWrapper` (详情参考 [SKSelectionWrapper](selection-wrapper.md))。

### 2. 手动实现

```swift
class SelectableItem: SKSelectionProtocol {
    let title: String
    // 必须实现 selection 属性
    let selection = SKSelectionState()
    
    init(title: String) {
        self.title = title
    }
}

// 使用
let item = SelectableItem(title: "Test")
item.isSelected = true
```
