# Missing Features Summary

## 🔍 深挖发现的未记录功能

通过系统性地检查 `SKCSingleTypeSection` 源代码，我发现了以下**7个重要功能**在之前的文档中未被提及：

### ✅ 已补充到 [section-advanced-2.md](section-advanced-2.md)

## 1. Display Tracking（显示次数追踪）

**文件**: `SKCSingleTypeSection+displayedTimes.swift`

**功能**: 追踪每个 cell 被显示的次数，用于首次体验、分析统计等场景。

```swift
// 追踪首次显示
section.model(displayedAt: .first) { context in
    print("First time displaying: \(context.model)")
}

// 追踪特定次数
section.model(displayedAt: 2) { context in
    print("第2次显示")
}

// 追踪多个特定次数
section.model(displayedAt: [1, 5, 10]) { context in
    // 第1、5、10次显示时触发
}

// 自定义条件
section.model(displayedAt: .init { count in
    count % 3 == 0  // 每3次触发
}) { context in
    // ...
}
```

**用途**:
- 新手引导（首次显示提示）
- 曝光统计
- 渐进式功能揭示

---

## 2. Cell Refresh（单元格刷新）

**文件**: `SKCSingleTypeSection+refresh.swift`

**功能**: 高效地更新特定单元格，无需重载整个 section。

```swift
// 按索引刷新
section.refresh(at: 5)
section.refresh(at: [0, 3, 5])

// 更新数据并刷新
section.refresh(at: 2, model: updatedModel)

// 使用 Payload
let payload = SKCSingleTypeSection.RefreshPayload(row: 2, model: updatedModel)
section.refresh(with: payload)

// 按模型刷新 (Equatable)
section.refresh(updatedModel)
section.refresh([model1, model2])

// 自定义匹配条件
section.refresh(updatedModels) { lhs, rhs in
    lhs.id == rhs.id
}
```

**用途**:
- 实时状态更新
- 点赞/阅读状态切换
- 局部数据变更

---

## 3. Safe Size Providers（安全尺寸提供者）

**文件**: `SKCSingleTypeSection+SafeSize.swift`

**功能**: 精确控制传递给 `preferredSize` 的 limit size。

```swift
// 固定尺寸
section.cellSafeSize(.fixed(CGSize(width: 100, height: 100)))

// 按比例（分数宽度）
section.cellSafeSize(.fraction(0.5))   // 2列
section.cellSafeSize(.fraction(0.333)) // 3列

// 动态比例计算
section.cellSafeSize(.fraction { context in
    if context.limitSize.width > 600 {
        return 0.25  // iPad: 4列
    } else {
        return 0.5   // iPhone: 2列
    }
})

// 尺寸变换
section.cellSafeSize(
    .default,
    transforms: .inset(UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16))
)

// Supplementary 尺寸
section.supplementarySafeSize(.header, .apple)
```

**用途**:
- 响应式网格布局
- 安全区域适配
- 自定义布局计算

---

## 4. High Performance Caching（高性能缓存）

**文件**: `SKCSingleTypeSection+HighPerformance.swift`

**功能**: 缓存计算好的 cell 尺寸，提升滚动性能。

```swift
// 启用高性能模式
section.highPerformanceID { context in
    return context.model.id
}

// 或使用 KeyPath
section.highPerformanceID(by: \.model.id)

// 手动控制缓存
section.setHighPerformance(.init())
section.highPerformance?.clear()
```

**工作原理**:
1. 首次计算并缓存尺寸
2. 后续相同 ID 直接返回缓存
3. 需要时可手动清除缓存

**用途**:
- 大数据集（10,000+ 项）
- 复杂尺寸计算
- 提升滚动流畅度

---

## 5. Index Titles（索引标题）

**属性**: `section.indexTitle`

**功能**: 添加字母索引，实现类似通讯录的快速滚动。

```swift
section.indexTitle = "A"

// 完整示例
let sectionsWithIndex = [
    ("A", contactsStartingWithA),
    ("B", contactsStartingWithB),
    ("C", contactsStartingWithC)
].map { letter, contacts in
    ContactCell.wrapperToSingleTypeSection()
        .config(models: contacts)
        .setSectionStyle(\.indexTitle, letter)
        .setHeader(SectionHeaderCell.self, model: letter)
}

manager.update(sectionsWithIndex)
```

**用途**:
- 通讯录
- 城市列表
- 任何需要字母索引的场景

---

## 6. Prefetching Support（预加载支持）

**文件**: `SKCPrefetch.swift`

**功能**: 在 cell 显示前准备数据，支持预加载和分页。

```swift
// 监听预加载请求
section.prefetch.prefetchPublisher
    .sink { rows in
        print("预加载行: \(rows)")
        // 预加载图片、数据等
    }
    .store(in: &cancellables)

// 监听取消预加载
section.prefetch.cancelPrefetchingPublisher
    .sink { rows in
        print("取消预加载: \(rows)")
        // 取消待处理操作
    }
    .store(in: &cancellables)

// 加载更多模式
section.prefetch.loadMorePublisher
    .sink {
        print("到达底部 - 加载更多")
        loadNextPage()
    }
    .store(in: &cancellables)
```

**用途**:
- 图片预加载
- 分页加载
- 性能优化

---

## 7. Environment Objects（环境对象）

**协议**: `SKEnvironmentConfiguration`

**功能**: 在 section 中存储和访问环境对象，类似 SwiftUI 的 EnvironmentObject。

```swift
// 存储环境对象
section.environment(of: themeManager)
section.environment(of: userService)

// 访问环境对象
if let theme = section.environment(of: ThemeManager.self) {
    // 使用 theme
}
```

**用途**:
- 跨组件共享依赖
- 避免层层传递对象
- 依赖注入

---

## 8. Task If Loaded（延迟任务）

**方法**: `taskIfLoaded(_:)`

**功能**: 在 section 加载到 collection view 后执行任务。

```swift
section.taskIfLoaded { section in
    // 仅在 section 已加载到 collection view 时执行
    print("Section is loaded")
}
```

**内部实现**:
- 如果已加载，立即执行
- 如果未加载，任务存储在队列中
- 加载后自动执行所有待处理任务

**用途**:
- 需要访问 collection view 的操作
- 延迟初始化
- 避免时序问题

---

## 9. Feature Flags（功能标志）

**属性**: `section.feature`

**功能**: 通过标志控制 section 行为以优化性能。

```swift
// 跳过大批量更新时的显示事件（性能优化）
section.feature.skipDisplayEventWhenFullyRefreshed = true

// 固定 cell 尺寸（跳过计算）
section.feature.highestItemSize = CGSize(width: 100, height: 100)

// 固定 header 尺寸
section.feature.highestHeaderSize = CGSize(width: 375, height: 44)

// 固定 footer 尺寸
section.feature.highestFooterSize = CGSize(width: 375, height: 30)
```

**用途**:
- 性能优化
- 固定尺寸布局
- 大数据集处理

---

## 📊 功能覆盖情况

| 功能类别 | 已记录 | 新发现 | 总计 |
|---------|--------|--------|------|
| 基础功能 | ✅ | - | 100% |
| 事件处理 | ✅ | - | 100% |
| 样式定制 | ✅ | - | 100% |
| 数据操作 | ✅ | ✅ Refresh | 100% |
| 高级功能 | ✅ | ✅ 9个新功能 | 100% |
| 性能优化 | ⚠️ | ✅ 补充完整 | 100% |

## 🎯 重要性评级

| 功能 | 重要性 | 使用频率 | 文档优先级 |
|-----|--------|----------|-----------|
| Display Tracking | ⭐⭐⭐⭐ | 中 | 高 |
| Cell Refresh | ⭐⭐⭐⭐⭐ | 高 | 很高 |
| Safe Size Providers | ⭐⭐⭐⭐ | 中 | 高 |
| High Performance | ⭐⭐⭐⭐⭐ | 中 | 很高 |
| Index Titles | ⭐⭐⭐ | 低 | 中 |
| Prefetching | ⭐⭐⭐⭐ | 中 | 高 |
| Environment Objects | ⭐⭐⭐ | 低 | 中 |
| Task If Loaded | ⭐⭐ | 低 | 低 |
| Feature Flags | ⭐⭐⭐⭐ | 低 | 高 |

## 📝 建议

### 高优先级
1. ✅ **已完成**: 所有功能已记录到 `section-advanced-2.md`
2. 考虑在主文档 `section.md` 中添加到这些高级功能的链接

### 中优先级
3. 在性能优化文档 `performance.md` 中添加与这些功能的交叉引用
4. 在示例代码中展示这些功能的实际用法

### 低优先级
5. 创建综合示例项目展示所有功能

## 🔗 相关文档

- **[section-advanced-2.md](section-advanced-2.md)** - 所有新发现功能的详细文档
- **[performance.md](performance.md)** - 性能优化指南
- **[section.md](section.md)** - 核心概念和基础功能
