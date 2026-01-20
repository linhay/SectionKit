# Performance Optimization (性能优化)

SectionUI 提供多种性能优化工具，用于处理大数据量和复杂布局。

## SKHighPerformanceStore - 尺寸缓存系统

自动缓存 Cell 尺寸计算结果，避免重复计算。

### 基础用法

```swift
section
    .setHighPerformance(.init())
    .highPerformanceID { context in
        // 返回每个 model 的唯一 ID
        return context.model.id
    }
```

### 工作原理

1. 首次计算尺寸时，使用 `ID + limitSize` 作为缓存键
2. 后续相同 ID 和 limitSize 的请求直接返回缓存值
3. 避免昂贵的 Auto Layout 计算

### 示例：列表性能优化

```swift
struct Item: Identifiable {
    let id: String
    let content: String
}

class MyCell: UICollectionViewCell, SKLoadViewProtocol, SKConfigurableView {
    // 复杂的 Auto Layout 布局...
}

let section = MyCell.wrapperToSingleTypeSection()
    .setHighPerformance(.init())
    .highPerformanceID { context in
        context.model.id  // 使用 Identifiable.id
    }
```

### 缓存失效

```swift
// 清除特定 ID 的缓存
section.highPerformanceStore?.removeValue(for: "item-123")

// 清除所有缓存
section.highPerformanceStore?.removeAll()
```

### 注意事项

- **ID 必须唯一且稳定**：相同数据应返回相同 ID
- **limitSize 变化会重新计算**：宽度改变时会自动重算
- **适用场景**：复杂 Auto Layout 布局、大数据量列表

## Prefetching - 数据预加载

提前加载即将显示的数据，提升滚动流畅度。

### 启用预加载

UICollectionView 默认支持预加载，只需订阅事件：

```swift
section.prefetch.prefetchPublisher
    .sink { [weak self] indexPaths in
        self?.preloadData(at: indexPaths)
    }
    .store(in: &cancellables)

section.prefetch.cancelPrefetchingPublisher
    .sink { [weak self] indexPaths in
        self?.cancelPreloading(at: indexPaths)
    }
    .store(in: &cancellables)
```

### 示例：图片预加载

```swift
class ImageListViewController: SKCollectionViewController {
    
    private var imageCache = [String: UIImage]()
    private var loadingTasks = [IndexPath: URLSessionDataTask]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 预加载图片
        section.prefetch.prefetchPublisher
            .sink { [weak self] indexPaths in
                indexPaths.forEach { indexPath in
                    self?.preloadImage(at: indexPath)
                }
            }
            .store(in: &cancellables)
        
        // 取消预加载
        section.prefetch.cancelPrefetchingPublisher
            .sink { [weak self] indexPaths in
                indexPaths.forEach { indexPath in
                    self?.cancelImageLoad(at: indexPath)
                }
            }
            .store(in: &cancellables)
    }
    
    private func preloadImage(at indexPath: IndexPath) {
        let model = models[indexPath.item]
        guard imageCache[model.imageURL] == nil else { return }
        
        let task = URLSession.shared.dataTask(with: URL(string: model.imageURL)!) { data, _, _ in
            if let data = data, let image = UIImage(data: data) {
                self.imageCache[model.imageURL] = image
            }
        }
        loadingTasks[indexPath] = task
        task.resume()
    }
    
    private func cancelImageLoad(at indexPath: IndexPath) {
        loadingTasks[indexPath]?.cancel()
        loadingTasks[indexPath] = nil
    }
}
```

### Load More - 分页加载

当滚动接近底部时自动触发：

```swift
section.prefetch.loadMorePublisher
    .sink { [weak self] in
        self?.loadNextPage()
    }
    .store(in: &cancellables)
```

完整示例见 `Example/Data/LoadAndPullViewController.swift`：

```swift
class LoadMoreViewController: SKCollectionViewController {
    
    private var currentPage = 1
    private var isLoading = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 加载更多
        section.prefetch.loadMorePublisher
            .sink { [weak self] in
                self?.loadNextPage()
            }
            .store(in: &cancellables)
        
        // 下拉刷新
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        sectionView.refreshControl = refreshControl
        
        loadPage(1)
    }
    
    private func loadNextPage() {
        guard !isLoading else { return }
        loadPage(currentPage + 1)
    }
    
    @objc private func refresh() {
        loadPage(1)
    }
    
    private func loadPage(_ page: Int) {
        isLoading = true
        
        fetchData(page: page) { [weak self] newItems in
            guard let self = self else { return }
            
            if page == 1 {
                // 刷新：重置数据
                self.section.config(models: newItems)
            } else {
                // 加载更多：追加数据
                self.section.append(newItems)
            }
            
            self.currentPage = page
            self.isLoading = false
            self.sectionView.refreshControl?.endRefreshing()
        }
    }
}
```

## Cell 复用优化

### 重置 Cell 状态

避免复用导致的状态残留：

```swift
class MyCell: UICollectionViewCell, SKLoadViewProtocol, SKConfigurableView {
    
    override func prepareForReuse() {
        super.prepareForReuse()
        // 重置状态
        imageView.image = nil
        label.text = nil
        cancellable?.cancel()
    }
    
    func config(_ model: Model) {
        // 配置新数据
    }
}
```

### 避免在 config() 中创建对象

```swift
// ❌ 不推荐 - 每次 config 都创建新对象
func config(_ model: Model) {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    label.text = formatter.string(from: model.date)
}

// ✅ 推荐 - 复用对象
private static let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    return formatter
}()

func config(_ model: Model) {
    label.text = Self.dateFormatter.string(from: model.date)
}
```

## Safe Size Providers - 智能尺寸计算

简化尺寸计算，提升性能。

### Fraction - 百分比布局

```swift
// 两列等宽
section.cellSafeSize(.fraction(0.5))

// 三列等宽
section.cellSafeSize(.fraction(1.0 / 3.0))

// 动态计算
section.cellSafeSize(.fraction { context in
    // 根据屏幕宽度动态调整列数
    let width = UIScreen.main.bounds.width
    let columns = width > 600 ? 4 : 2
    return 1.0 / CGFloat(columns)
})
```

### Transforms - 尺寸转换

```swift
// 固定高度
section.cellSafeSize(.fraction(0.5), transforms: .fixed(height: 100))

// 固定宽度
section.cellSafeSize(.default, transforms: .fixed(width: 80))

// 固定宽高比
section.cellSafeSize(.fraction(0.33), transforms: .aspectRatio(16/9))

// 组合多个转换
section.cellSafeSize(
    .fraction(0.5),
    transforms: [
        .aspectRatio(1.0),  // 正方形
        .inset(.init(top: 4, left: 4, bottom: 4, right: 4))  // 添加边距
    ]
)
```

### 示例：瀑布流布局

```swift
// 两列，等宽，高度自适应
section.cellSafeSize(
    .fraction(0.5),
    transforms: .aspectRatio { context in
        // 根据图片宽高比计算
        let image = context.model.image
        return image.size.width / image.size.height
    }
)
```

## Display Times Tracking - 显示次数跟踪

仅在特定显示次数时执行逻辑，避免重复操作。

### 基础用法

```swift
// 仅首次显示时执行
section.model(displayedAt: .first) { context in
    trackImpression(context.model)
}

// 仅第二次显示时执行
section.model(displayedAt: .at(2)) { context in
    showSecondVisitTip()
}

// 多个时机
section.model(displayedAt: [1, 3, 5]) { context in
    print("第 \(context.displayedTimes) 次显示")
}
```

### 示例：曝光统计

```swift
section.model(displayedAt: .first) { context in
    // 仅首次曝光时上报
    Analytics.track(event: "item_impression", properties: [
        "item_id": context.model.id,
        "position": context.indexPath.item
    ])
}
```

## 性能最佳实践

### 1. 合理使用 SKHighPerformanceStore

```swift
// ✅ 推荐 - 复杂布局
class ComplexCell: UICollectionViewCell, SKConfigurableAutoAdaptiveView {
    // 大量 Auto Layout 约束...
}

section
    .setHighPerformance(.init())
    .highPerformanceID { $0.model.id }

// ❌ 不必要 - 简单固定尺寸
static func preferredSize(limit size: CGSize, model: Model?) -> CGSize {
    return CGSize(width: size.width, height: 44)  // 计算成本很低
}
```

### 2. 延迟加载重资源

```swift
func config(_ model: Model) {
    // 先显示占位符
    imageView.image = placeholderImage
    
    // 异步加载真实图片
    ImageLoader.shared.loadImage(url: model.imageURL) { [weak self] image in
        self?.imageView.image = image
    }
}
```

### 3. 使用预加载 + 缓存

```swift
// 预加载数据
section.prefetch.prefetchPublisher
    .sink { indexPaths in
        indexPaths.forEach { loadData(at: $0) }
    }

// Cell 中直接使用缓存
func config(_ model: Model) {
    imageView.image = ImageCache.shared[model.imageURL] ?? placeholderImage
}
```

### 4. 避免频繁刷新

```swift
// ❌ 不推荐 - 频繁全量刷新
items.forEach { item in
    section.config(models: [item])
    manager.reload(section)
}

// ✅ 推荐 - 批量更新
section.config(models: items)
manager.reload(section)
```

### 5. 使用 Difference 算法

```swift
// 智能差异刷新（需要 Model: Equatable）
section.reload(.difference())

// 或按 ID 比较
section.reload(.difference(by: \.id))
```
