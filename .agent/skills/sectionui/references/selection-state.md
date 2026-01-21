# SKSelectionState - 选择状态核心

`SKSelectionState` 是选择系统的核心状态容器，负责管理选择状态、能力限制和可用性，并提供 Combine 发布者用于响应式更新。

## 核心属性

```swift
public class SKSelectionState: Equatable, Hashable, Identifiable {
    
    // 状态属性 (修改这些属性会自动触发对应的 Publisher)
    public var isSelected: Bool
    public var canSelect: Bool
    public var isEnabled: Bool
    
    // 初始化
    public init(isSelected: Bool = false,
                canSelect: Bool = true,
                isEnabled: Bool = true)
}
```

## 响应式支持 (Reactive Support)

`SKSelectionState` 提供了丰富的 `AnyPublisher` 用于状态监听：

```swift
// 单一属性监听
state.selectedPublisher   // 监听 isSelected
state.canSelectPublisher  // 监听 canSelect
state.enabledPublisher    // 监听 isEnabled

// 综合监听
// 当任意属性变化时发送当前的 state 对象
state.changedPublisher
    .sink { state in
        print("State changed: \(state.isSelected)")
    }
```

## 使用场景

1. **独立使用**：作为 ViewModel 的一部分管理状态。
2. **配合 SKSelectionProtocol**：作为协议的核心实现要求。
3. **传递状态**：在不同组件间共享同一个 `SKSelectionState` 实例以实现状态同步。
