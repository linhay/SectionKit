# Scroll Management (滚动管理)

SectionUI 提供强大的滚动监听和控制功能。

## SKScrollViewDelegateHandler - 结构化滚动事件

分阶段处理滚动事件，比直接实现 UIScrollViewDelegate 更清晰。

### 基础用法

```swift
manager.scrollObserver.add(scroll: "myObserver") { handler in
    handler
        .onChanged { scrollView in
            print("滚动中: \(scrollView.contentOffset)")
        }
        .onDrag(ended: { scrollView in
            print("拖拽结束")
        })
}
```

### 完整生命周期

```swift
manager.scrollObserver.add(scroll: "fullCycle") { handler in
    handler
        // 拖拽事件
        .onDrag(began: { scrollView in
            print("开始拖拽")
        })
        .onDrag(changed: { scrollView in
            print("拖拽中")
        })
        .onDrag(ended: { scrollView in
            print("拖拽结束")
        })
        
        // 减速事件
        .onDecelerate(began: { scrollView in
            print("开始减速")
        })
        .onDecelerate(changed: { scrollView in
            print("减速中")
        })
        .onDecelerate(ended: { scrollView in
            print("减速结束")
        })
        
        // 缩放事件（如果支持）
        .onZoom(began: { scrollView in
            print("开始缩放")
        })
        .onZoom(changed: { scrollView in
            print("缩放中")
        })
        .onZoom(ended: { scrollView in
            print("缩放结束")
        })
        
        // 动画结束
        .onAnimation { scrollView in
            print("动画结束")
        }
        
        // 任何变化
        .onChanged { scrollView in
            print("发生变化")
        }
}
```

### 移除监听

```swift
// 按名称移除
manager.scrollObserver.remove(scroll: "myObserver")

// 移除所有
manager.scrollObserver.removeAll()
```

## SKCDisplayTracker - 可见性追踪

追踪当前可见的 Cell、Header、Footer。

### 基础用法

```swift
let tracker = SKCDisplayTracker()
manager.scrollObserver.add(tracker)

// 监听可见 Cell
tracker.$displayedCellIndexPaths
    .sink { indexPaths in
        print("可见 Cell: \(indexPaths)")
    }
    .store(in: &cancellables)

// 监听可见 Header
tracker.$displayedSupplementaryIndexPaths
    .sink { indexPaths in
        print("可见 Header/Footer: \(indexPaths)")
    }
    .store(in: &cancellables)
```

### 获取顶部 Section

```swift
if let topSection = tracker.topSectionForVisibleArea() {
    print("顶部 Section 索引: \(topSection)")
    updateNavigationTitle(forSection: topSection)
}
```

### 实战示例：滚动监控

参考 `Example/Interaction/ScrollObserverViewController.swift`：

```swift
class ScrollObserverViewController: SKCollectionViewController {
    
    private let tracker = SKCDisplayTracker()
    private var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 添加追踪器
        manager.scrollObserver.add(tracker)
        
        // 监听顶部 Section 变化
        tracker.$displayedCellIndexPaths
            .compactMap { [weak self] _ in
                self?.tracker.topSectionForVisibleArea()
            }
            .removeDuplicates()
            .sink { [weak self] sectionIndex in
                self?.updateTitle(forSection: sectionIndex)
            }
            .store(in: &cancellables)
        
        // 添加滚动监听
        manager.scrollObserver.add(scroll: "offset") { handler in
            handler
                .onChanged { [weak self] scrollView in
                    self?.updateHeaderAlpha(scrollView.contentOffset.y)
                }
                .onDrag(ended: { scrollView in
                    print("拖拽结束在: \(scrollView.contentOffset)")
                })
        }
    }
    
    private func updateTitle(forSection index: Int) {
        title = "Section \(index)"
    }
    
    private func updateHeaderAlpha(_ offset: CGFloat) {
        let alpha = min(1, max(0, offset / 100))
        navigationController?.navigationBar.alpha = alpha
    }
}
```

## Section 滚动控制

直接控制 Section 的滚动位置。

### 滚动到顶部/底部

```swift
// 滚动到 Section 顶部
section.scrollToTop(animated: true)

// 滚动到 Section 底部
section.scrollToBottom(animated: true)
```

### 滚动到特定行

```swift
// 滚动到第 10 行，顶部对齐
section.scroll(to: 10, at: .top, animated: true)

// 滚动到第 5 行，居中对齐
section.scroll(to: 5, at: .centeredVertically, animated: true)

// 滚动到最后一行，底部对齐
let lastRow = section.modelCount - 1
section.scroll(to: lastRow, at: .bottom, animated: true)
```

### 滚动到 Header/Footer

```swift
// 滚动到 Header
section.scroll(to: .header, at: .top, animated: true)

// 滚动到 Footer
section.scroll(to: .footer, at: .bottom, animated: true)
```

### Manager 滚动控制

```swift
// 滚动到特定 Section 的特定行
manager.scroll(
    to: section,
    row: 10,
    at: .top,
    animated: true
)
```

## 实用场景

### 1. 导航栏渐变

```swift
manager.scrollObserver.add(scroll: "navBar") { handler in
    handler.onChanged { [weak self] scrollView in
        let offset = scrollView.contentOffset.y
        let alpha = min(1, max(0, offset / 150))
        
        self?.navigationController?.navigationBar.backgroundColor = 
            UIColor.systemBackground.withAlphaComponent(alpha)
    }
}
```

### 2. 无限滚动

```swift
manager.scrollObserver.add(scroll: "infinite") { handler in
    handler.onDecelerate(ended: { [weak self] scrollView in
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.height
        
        // 距离底部小于 100 时加载更多
        if contentHeight - offsetY - height < 100 {
            self?.loadMoreData()
        }
    })
}
```

### 3. 返回顶部按钮

```swift
private var showBackToTopButton = false {
    didSet {
        UIView.animate(withDuration: 0.3) {
            self.backToTopButton.alpha = self.showBackToTopButton ? 1 : 0
        }
    }
}

override func viewDidLoad() {
    super.viewDidLoad()
    
    manager.scrollObserver.add(scroll: "backToTop") { [weak self] handler in
        handler.onChanged { scrollView in
            self?.showBackToTopButton = scrollView.contentOffset.y > 500
        }
    }
    
    backToTopButton.addTarget(self, action: #selector(scrollToTop), for: .touchUpInside)
}

@objc private func scrollToTop() {
    collectionView.setContentOffset(.zero, animated: true)
}
```

### 4. 视差效果

参考 `Example/Interaction/ParallaxViewController.swift`：

```swift
manager.scrollObserver.add(scroll: "parallax") { handler in
    handler.onChanged { [weak self] scrollView in
        let offset = scrollView.contentOffset.y
        
        // 背景视差
        self?.backgroundImageView.frame.origin.y = -offset * 0.5
        
        // 标题视差
        self?.titleLabel.transform = CGAffineTransform(
            translationX: 0,
            y: -offset * 0.3
        )
    }
}
```

### 5. 曝光统计

```swift
let tracker = SKCDisplayTracker()
manager.scrollObserver.add(tracker)

var exposedItems = Set<IndexPath>()

tracker.$displayedCellIndexPaths
    .sink { [weak self] indexPaths in
        let newExposures = indexPaths.filter { !self?.exposedItems.contains($0) ?? false }
        
        newExposures.forEach { indexPath in
            self?.trackExposure(at: indexPath)
            self?.exposedItems.insert(indexPath)
        }
    }
    .store(in: &cancellables)
```

## 最佳实践

### 1. 避免频繁更新

```swift
// ✅ 推荐 - 使用 throttle 或 debounce
manager.scrollObserver.add(scroll: "throttled") { handler in
    handler.onChanged { scrollView in
        // 会被频繁调用
    }
}

// 在外部使用 Combine 操作符
tracker.$displayedCellIndexPaths
    .throttle(for: 0.3, scheduler: RunLoop.main, latest: true)
    .sink { indexPaths in
        // 限流后的更新
    }
    .store(in: &cancellables)
```

### 2. 使用弱引用

```swift
// ✅ 始终使用 [weak self]
manager.scrollObserver.add(scroll: "safe") { [weak self] handler in
    handler.onChanged { scrollView in
        self?.updateUI(scrollView.contentOffset.y)
    }
}
```

### 3. 及时移除监听

```swift
class MyViewController: SKCollectionViewController {
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // 移除不需要的监听
        manager.scrollObserver.remove(scroll: "myObserver")
    }
}
```

### 4. 组合多个监听器

```swift
// 为不同功能使用不同的监听器名称
manager.scrollObserver.add(scroll: "navBar") { ... }
manager.scrollObserver.add(scroll: "analytics") { ... }
manager.scrollObserver.add(scroll: "loadMore") { ... }

// 便于管理和移除
```
