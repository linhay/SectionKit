# Reactive Programming (响应式编程)

SectionUI 深度集成 Combine 框架，提供强大的响应式数据流管理。

## SKPublished - 增强型属性包装器

`SKPublished` 是自定义属性包装器，类似于 `@Published`，但提供了更多功能。

### 基础用法

```swift
class ViewModel {
    @SKPublished var items: [Model] = []
    
    func setup() {
        // bind() 会立即调用一次，然后监听后续变化
        $items.bind { [weak self] newItems in
            self?.section.config(models: newItems)
        }.store(in: &cancellables)
    }
}
```

### 两种模式

```swift
// PassThrough 模式 - 不保存当前值
@SKPublished(kind: .passThrough) var event: Event?

// CurrentValue 模式 - 保存当前值（默认）
@SKPublished(kind: .currentValue) var data: [Model] = []
```

### 内置转换 (Transforms)

SKPublished 支持链式转换，在属性定义时配置：

```swift
// 去重
@SKPublished(transform: .removeDuplicates()) 
var count: Int = 0

// 打印调试
@SKPublished(transform: .print("Items changed"))
var items: [Model] = []

// 过滤
@SKPublished(transform: .filter { $0.isNotEmpty })
var validItems: [Model] = []

// 组合多个转换
@SKPublished(
    transform: .dropFirst()
        .removeDuplicates()
        .receiveOnMainQueue()
)
var networkData: Data?
```

### 可用转换

| 转换 | 说明 |
|------|------|
| `.removeDuplicates()` | 去除连续重复值（需要 Equatable） |
| `.dropFirst(count)` | 跳过前 N 个值 |
| `.filter { }` | 过滤值 |
| `.receiveOnMainQueue()` | 切换到主线程 |
| `.print(prefix)` | 打印调试信息 |
| `.onChanged { old, new in }` | 变化回调，可访问新旧值 |

### 监听变化

```swift
@SKPublished var state: State = .idle

// 方式 1: bind() - 立即触发 + 后续变化
$state.bind { newState in
    updateUI(newState)
}.store(in: &cancellables)

// 方式 2: sink() - 仅后续变化
$state.sink { newState in
    logChange(newState)
}.store(in: &cancellables)
```

### 弱引用赋值

避免循环引用的便捷方法：

```swift
publisher
    .assign(onWeak: self, to: \.selectedItem)
    .store(in: &cancellables)
```

## Section 数据订阅

直接将 Publisher 绑定到 Section：

### 订阅模型数组

```swift
let dataPublisher: AnyPublisher<[Model], Never> = fetchData()

section.subscribe(models: dataPublisher)

// Section 会自动刷新当 Publisher 发出新值
```

### 订阅单个模型

```swift
let singleModelPublisher: AnyPublisher<Model, Never> = ...

section.subscribe(models: singleModelPublisher)
// 自动包装为单元素数组
```

### 订阅可选模型

```swift
let optionalPublisher: AnyPublisher<Model?, Never> = ...

section.subscribe(models: optionalPublisher)
// nil 时显示空列表，非 nil 时显示单元素
```

### 示例：完整流程

参考 `Example/Data/SubscribeDataWithCombineViewController.swift`：

```swift
class MyViewController: SKCollectionViewController {
    
    @SKPublished var items: [Item] = []
    private var cancellables = Set<AnyCancellable>()
    
    private lazy var section = ItemCell.wrapperToSingleTypeSection()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 订阅数据变化
        section.subscribe(models: $items.eraseToAnyPublisher())
        manager.reload(section)
        
        // 模拟数据更新
        Timer.publish(every: 2.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.items.append(Item.random())
            }
            .store(in: &cancellables)
    }
}
```

## Prefetch Publishers

监听预加载和加载更多事件：

### loadMorePublisher - 触发加载更多

当滚动接近底部时自动触发：

```swift
section.prefetch.loadMorePublisher
    .sink { [weak self] in
        self?.loadNextPage()
    }
    .store(in: &cancellables)
```

### prefetchPublisher - 即将显示的行

获取即将显示的 IndexPath 列表：

```swift
section.prefetch.prefetchPublisher
    .sink { indexPaths in
        // 预加载图片等资源
        preloadImages(at: indexPaths)
    }
    .store(in: &cancellables)
```

### cancelPrefetchingPublisher - 取消预加载

当预加载被取消时触发：

```swift
section.prefetch.cancelPrefetchingPublisher
    .sink { indexPaths in
        cancelImageLoading(at: indexPaths)
    }
    .store(in: &cancellables)
```

## Manager Publishers

监听 Section 集合变化：

```swift
manager.publishers.sectionsPublisher
    .sink { sections in
        print("当前 Section 数量: \(sections.count)")
    }
    .store(in: &cancellables)
```

## Selection Publishers

选择状态变化监听（见 [Selection](selection.md)）：

```swift
let wrapper = SKSelectionWrapper(value: item)

wrapper.selectedPublisher
    .sink { isSelected in
        updateBadge(isSelected)
    }
    .store(in: &cancellables)

wrapper.changedPublisher
    .sink { wrapper in
        // 任何状态变化
        syncToServer(wrapper)
    }
    .store(in: &cancellables)
```

## 最佳实践

### 1. 使用 bind() 而非 sink()

当需要立即响应当前值时：

```swift
// ✅ 推荐 - 立即调用一次
$items.bind { items in
    section.config(models: items)
}.store(in: &cancellables)

// ❌ 不推荐 - 需要手动调用一次
section.config(models: items)
$items.sink { items in
    section.config(models: items)
}.store(in: &cancellables)
```

### 2. 使用 Transform 而非手动转换

```swift
// ✅ 推荐
@SKPublished(transform: .removeDuplicates())
var count: Int = 0

// ❌ 不推荐
@SKPublished var count: Int = 0
$count.removeDuplicates().sink { ... }
```

### 3. 避免循环引用

```swift
// ✅ 使用 [weak self]
$items.bind { [weak self] items in
    self?.updateUI(items)
}.store(in: &cancellables)

// ✅ 或使用 assign(onWeak:)
$selectedIndex.assign(onWeak: self, to: \.currentIndex)
```

### 4. 统一管理 Cancellables

```swift
class ViewModel {
    private var cancellables = Set<AnyCancellable>()
    
    func setup() {
        // 所有订阅都存储到同一个集合
        $data.bind { ... }.store(in: &cancellables)
        $state.bind { ... }.store(in: &cancellables)
    }
    
    deinit {
        // 自动取消所有订阅
    }
}
```
