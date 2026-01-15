---
name: sectionui-single-type-section
description: Detailed documentation for SKCSingleTypeSection, the most frequently used section type in SectionUI.
---

# SKCSingleTypeSection

`SKCSingleTypeSection` is the primary building block for creating collection view sections that display a single type of cell. It provides a rich set of fluent APIs for configuration, actions, and advanced layout features.

## 1. Quick Scaffolding

### Standard Instance (Direct)
```swift
let section = SKCSingleTypeSection<MyCell>()
    .config(models: models)
```

### Wrapper Utilities (Recommended)
Use `wrapperToSingleTypeSection` directly on the Cell type.

```swift
// 1. From an array of models
let section = MyCell.wrapperToSingleTypeSection(models)

// 2. From a single model
let section = MyCell.wrapperToSingleTypeSection(singleModel)

// 3. Using ResultBuilder (DSL style)
let section = MyCell.wrapperToSingleTypeSection {
    modelA
    modelB
}
```

### Advanced Wrappers & Chaining
```swift
let section = MyCell.wrapperToSingleTypeSection(models)
    .setSectionStyle(\.sectionInset, .init(top: 8, left: 16, bottom: 8, right: 16))
    .setCellStyle(.separator(.bottom(insets: .init(top: 0, left: 16, bottom: 0, right: 16))))
    .onCellAction(on: self, .selected) { (self, context) in
        self.navigationController?.pushViewController(...)
    }
```

## 2. Professional Features

### Animated Diff Refresh
Override `apply` to enable smooth transitions. Requires `Cell.Model` to be `Hashable`.

```swift
override func apply(_ models: [Model]) {
    if self.models.isEmpty || models.isEmpty {
        super.apply(models)
    } else {
        let difference = models.difference(from: self.models)
        pick {
            for change in difference {
                switch change {
                case let .remove(offset, _, _): delete(offset)
                case let .insert(offset, element, _): insert(at: offset, element)
                }
            }
        }
    }
}
```

### High-Performance Size Caching
```swift
override func itemSize(at row: Int) -> CGSize {
    guard let model = models.value(at: row) else { return .zero }
    return highPerformance.cache(by: model, limit: safeSizeProvider.size) { limit in
        return <#CellName#>.preferredSize(limit: limit, model: model)
    }
}
```

### Pagination & Preloading
```swift
override func item(willDisplay view: UICollectionViewCell, row: Int) {
    if row + 5 >= models.count {
        // Trigger preloading
    }
}
```

### Sticky Elements (Pinning)
```swift
section.pinHeader { options in
    options.$distance.sink { value in
        // Parallax or UI changes
    }.store(in: &cancellables)
}
```

## 3. Interaction & Analytics

### Drag & Drop
```swift
section.onCellShould(.move) { context in
    return true
}
```

### Impression Tracking (Exposure)
Track when a cell is displayed, useful for analytics.
```swift
// Trigger when the first cell is displayed
section.model(displayedAt: .first) { context in
    Analytics.log(event: "view_item", id: context.model.id)
}
```

### Reactive Subscriptions (Combine)
Directly bind your ViewModel's publisher to the section.
```swift
// Bind to an array publisher
section.subscribe(models: viewModel.$items)

// Bind to a single model
section.subscribe(models: viewModel.$currentItem)
```

## 4. Advanced Management

### Granular Refreshing
Update specific items without reloading the entire section.
```swift
// 1. Refesh specific row with new model
section.refresh(at: 0, model: newModel)

// 2. Find and update models matching a predicate
section.refresh([updatedModel]) { old, new in old.id == new.id }

// 3. Batch updates using ResultBuilder
section.pick {
    section.delete(0)
    section.insert(at: 1, newModel)
}
```

### Section Decoration (Backgrounds/Corners)
Apply backgrounds, borders, or corner radii to the entire section.
```swift
section.set(
    decoration: SectionCornerRadiusView.self,
    model: .init(backgroundColor: .white, cornerRadius: 12)
)
```

### Horizontal Nesting (Carousel Pattern)
Wrap a vertical section into a horizontally scrolling cell with one line.
```swift
// Creates a new section containing a single cell that hosts 'section' horizontally
let carouselSection = section.wrapperToHorizontalSection(height: 120)
```

### Environment Injection (DI)
Inject services or configuration that can be accessed by the section at any time.
```swift
// 1. Inject
section.environment(of: MyAnalyticsService.shared)

// 2. Retrieve (later in a delegate or action)
let service = section.environment(of: MyAnalyticsService.self)
```


## 5. Layout & Performance

### Cell Sizing (SKSafeSizeProvider)
```swift
section.cellSafeSize(.fraction(0.5)) // 2 columns
```

### Performance Optimization for Large Data
```swift
// Skip recording display events during full refresh to save CPU
section.feature.skipDisplayEventWhenFullyRefreshed = true

// Force reload instead of batch updates for stability if needed
manager.configuration.replaceDeleteWithReloadData = true
```

## 6. Productivity Shortcuts

### Safe Weak Self Binding
Avoid `[weak self]` boilerplate in actions.
```swift
.onCellAction(on: self, .selected) { (vc, context) in
    vc.navigationController?.pushViewController(...)
}
```

### Async Action Handling
```swift
.onAsyncCellAction(.selected) { context in
    let detail = try await fetchDetail(id: context.model.id)
}
```

