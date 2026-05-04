# Pin Functionality (固定/粘性功能)

Pin 功能允许在滚动时将 Header、Footer 或特定 Cell 固定在特定位置（类似导航栏）。

## 功能特性

- 固定 Header（吸顶）
- 固定 Footer（吸底）
- 固定特定 Cell
- 距离追踪（离固定位置的距离）
- 自定义动画和属性调整

## 固定 Header

### 基础用法

```swift
section.pinHeader()
```

### 带配置

```swift
section.pinHeader { options in
    // 设置内边距
    options.padding = 16
    
    // 监听距离变化
    options.$distance
        .sink { distance in
            print("距离顶部: \(distance)")
        }
        .store(in: &cancellables)
    
    // 监听是否固定
    options.$isPinned
        .sink { isPinned in
            print("是否固定: \(isPinned)")
        }
        .store(in: &cancellables)
}
```

## 固定 Footer

```swift
section.pinFooter { options in
    options.padding = 20
}
```

## 固定特定 Cell

将列表中的某个 Cell 固定（如聊天的时间戳）：

```swift
// 固定第 5 个 Cell
section.pinCell(at: 5) { options in
    options.padding = 8
}
```

## 高级：自定义属性调整

在固定时自定义布局属性（如高度动画）：

```swift
section.pinHeader { options in
    options.customAdjust = { opts, attributes in
        // 根据距离调整高度
        let maxHeight: CGFloat = 100
        let minHeight: CGFloat = 44
        
        let distance = opts.distance
        let progress = max(0, min(1, distance / 50))
        
        let height = minHeight + (maxHeight - minHeight) * (1 - progress)
        attributes.size.height = height
        
        // 调整其他属性
        attributes.alpha = 1 - progress * 0.3
    }
}
```

## 实战示例：导航栏效果

参考 `Example/Layout/PinIndexViewController.swift`：

```swift
class PinViewController: SKCollectionViewController {
    
    private var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 创建 Header
        let headerSection = HeaderCell
            .wrapperToSingleTypeSection()
            .config(models: [HeaderModel(title: "固定标题")])
        
        // 固定 Header 并添加动画
        headerSection.pinHeader { options in
            options.padding = 0
            
            // 距离监听 - 实现渐变效果
            options.$distance
                .sink { [weak self] distance in
                    self?.updateHeaderAlpha(distance)
                }
                .store(in: &self.cancellables)
            
            // 自定义布局调整
            options.customAdjust = { opts, attributes in
                let baseHeight: CGFloat = 200
                let minHeight: CGFloat = 64
                let collapseDistance: CGFloat = 100
                
                let progress = min(1, opts.distance / collapseDistance)
                let height = maxHeight - (maxHeight - minHeight) * progress
                
                attributes.size.height = height
            }
        }
        
        manager.reload([headerSection, contentSection])
    }
    
    private func updateHeaderAlpha(_ distance: CGFloat) {
        // 根据距离调整透明度
        let alpha = min(1, max(0, 1 - distance / 50))
        // 更新 UI...
    }
}
```

## 多 Section 固定

每个 Section 可以独立设置固定：

```swift
// Section 1 - 固定 Header
section1.pinHeader { options in
    options.padding = 0
}

// Section 2 - 固定 Header
section2.pinHeader { options in
    options.padding = 60  // 考虑上一个 Section 的高度
}

manager.reload([section1, section2])
```

## 注意事项

### 1. Padding 计算

```swift
// ✅ 正确 - 考虑安全区域
let topInset = view.safeAreaInsets.top
section.pinHeader { options in
    options.padding = topInset
}

// ❌ 错误 - 可能被刘海遮挡
section.pinHeader()  // padding 默认为 0
```

### 2. 多个固定元素叠加

```swift
// Header 1
section1.pinHeader { $0.padding = 0 }

// Header 2 - 避免重叠
section2.pinHeader { $0.padding = section1HeaderHeight }
```

### 3. 性能优化

```swift
// ✅ 使用 customAdjust 进行平滑动画
options.customAdjust = { opts, attributes in
    attributes.size.height = calculateHeight(opts.distance)
}

// ❌ 避免在距离变化回调中频繁刷新整个列表
options.$distance.sink { distance in
    section.reload()  // 不推荐
}
```

## 实用场景

### 1. 分段标题吸顶

```swift
sections.forEach { section in
    section.pinHeader()
}
```

### 2. 聊天时间戳固定

```swift
// 固定每 20 条消息的时间戳
for index in stride(from: 0, to: messages.count, by: 20) {
    messageSection.pinCell(at: index)
}
```

### 3. 导航栏渐变

```swift
section.pinHeader { options in
    options.customAdjust = { opts, attributes in
        // 背景渐变
        let progress = opts.distance / 100
        attributes.alpha = 1 - progress
        
        // 高度压缩
        attributes.size.height = max(44, 100 - progress * 56)
    }
}
```

### 4. 悬浮操作栏

```swift
section.pinFooter { options in
    options.padding = view.safeAreaInsets.bottom
    
    // 监听是否接近底部
    options.$isPinned
        .sink { isPinned in
            showFloatingActionButton(!isPinned)
        }
        .store(in: &cancellables)
}
```
