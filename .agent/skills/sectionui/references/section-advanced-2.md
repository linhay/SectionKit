# Advanced Section Features (Part 2)

This document covers additional advanced features that provide powerful capabilities for specific use cases.

## Display Tracking

Track how many times each cell has been displayed, perfect for analytics and first-time experiences.

### Basic Display Tracking

```swift
// Track first display
section.model(displayedAt: .first) { context in
    print("First time displaying: \(context.model)")
    // Show tutorial, track impression, etc.
}

// Track specific display count
section.model(displayedAt: 2) { context in
    print("Second time displaying: \(context.model)")
}

// Track multiple specific times
section.model(displayedAt: [1, 5, 10]) { context in
    print("Displayed at times: 1, 5, or 10")
}
```

### Custom Display Predicates

```swift
// Track every 3rd display
section.model(displayedAt: .init { count in
    count % 3 == 0
}) { context in
    print("Every 3rd display: \(context.model)")
}

// Track displays after threshold
section.model(displayedAt: .init { count in
    count > 5
}) { context in
    print("Displayed more than 5 times")
}
```

### Use Cases

#### First-Time Tutorial

```swift
section.model(displayedAt: .first) { context in
    // Show tooltip only on first display
    showTooltip(for: context.view)
}
```

#### Impression Tracking

```swift
section.model(displayedAt: .first) { context in
    Analytics.trackImpression(
        itemId: context.model.id,
        position: context.row
    )
}
```

#### Progressive Disclosure

```swift
section.model(displayedAt: [1, 3, 5]) { context in
    // Show different hints at different times
    switch context.displayCount {
    case 1: showBasicHint()
    case 3: showIntermediateHint()
    case 5: showAdvancedHint()
    default: break
    }
}
```

### Reset Display Counts

```swift
// Reset all display counts
section.displayedTimes.reset()

// Reset specific row
section.displayedTimes.reset(row: 3)
```

## Cell Refresh (Partial Updates)

Efficiently update specific cells without reloading the entire section.

### Refresh Single Cell

```swift
// Refresh by index
section.refresh(at: 5)

// Refresh multiple cells
section.refresh(at: [0, 3, 5])
```

### Refresh with New Model

```swift
// Update model and refresh cell
section.refresh(at: 2, model: updatedModel)

// Using RefreshPayload
let payload = SKCSingleTypeSection.RefreshPayload(row: 2, model: updatedModel)
section.refresh(with: payload)

// Multiple updates
let payloads = [
    SKCSingleTypeSection.RefreshPayload(row: 0, model: model1),
    SKCSingleTypeSection.RefreshPayload(row: 3, model: model2)
]
section.refresh(with: payloads)
```

### Refresh by Model (Equatable)

```swift
// Refresh single model
section.refresh(updatedModel)  // where Model: Equatable

// Refresh multiple models
section.refresh([model1, model2, model3])
```

### Refresh with Custom Predicate

```swift
section.refresh(updatedModels) { lhs, rhs in
    lhs.id == rhs.id
}
```

### Use Cases

#### Real-Time Status Updates

```swift
func updateOrderStatus(_ order: Order) {
    var updated = order
    updated.status = .shipped
    
    // Only refresh this specific cell
    section.refresh(updated)
}
```

#### Toggle Read State

```swift
section.onCellAction(.selected) { context in
    var updated = context.model
    updated.isRead = true
    
    // Refresh just this cell
    context.section.refresh(at: context.row, model: updated)
}
```

#### Live Counter Updates

```swift
func incrementLikeCount(for item: Item) {
    var updated = item
    updated.likeCount += 1
    
    section.refresh(updated)
}
```

## Safe Size Providers

Control the limit size passed to `preferredSize` for precise layout control.

### Fixed Size

```swift
// All cells get fixed limit size
section.cellSafeSize(.fixed(CGSize(width: 100, height: 100)))
```

### Fractional Width

```swift
// Half width (2 columns)
section.cellSafeSize(.fraction(0.5))

// One third width (3 columns)
section.cellSafeSize(.fraction(0.333))

// Custom fractional calculation
section.cellSafeSize(.fraction { context in
    // context.limitSize - available space
    // context.minimumInteritemSpacing - spacing between items
    
    if context.limitSize.width > 600 {
        return 0.25  // 4 columns on iPad
    } else {
        return 0.5   // 2 columns on iPhone
    }
})
```

### Size Transforms

Apply transformations to limit sizes:

```swift
// Reduce width by padding
section.cellSafeSize(
    .default,
    transforms: .inset(UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16))
)

// Subtract fixed value
section.cellSafeSize(
    .default,
    transforms: .subtract(width: 32, height: 0)
)

// Multiple transforms
section.cellSafeSize(.default, transforms: [
    .inset(UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)),
    .subtract(width: 0, height: 20)
])
```

### Supplementary Safe Sizes

```swift
// Header uses full collection view width
section.supplementarySafeSize(.header, .apple)

// Footer uses default
section.supplementarySafeSize(.footer, .default)
```

### Use Cases

#### Responsive Grid

```swift
section.cellSafeSize(.fraction { context in
    let width = context.limitSize.width
    
    switch width {
    case 0..<375:   return 1.0   // 1 column (small phone)
    case 375..<768: return 0.5   // 2 columns (phone)
    case 768..<1024: return 0.333 // 3 columns (small tablet)
    default:         return 0.25  // 4 columns (large tablet)
    }
})
```

#### Accounting for Safe Area

```swift
section.cellSafeSize(
    .default,
    transforms: .inset(view.safeAreaInsets)
)
```

## High Performance Caching

Cache calculated cell sizes for improved scrolling performance.

### Enable High Performance Mode

```swift
// Enable with ID block
section.highPerformanceID { context in
    return context.model.id
}

// Or use KeyPath
section.highPerformanceID(by: \.model.id)
```

### Manual Cache Control

```swift
// Set custom cache
section.setHighPerformance(.init())

// Clear cache when needed
section.highPerformance?.clear()
```

### How It Works

When enabled, `preferredSize` results are cached by ID:
1. First calculation is performed and cached
2. Subsequent calls with same ID return cached size
3. No recalculation until cache is cleared

### Use Cases

#### Large Datasets

```swift
// Cache sizes for 10,000+ items
section
    .highPerformanceID(by: \.model.id)
    .config(models: largeDataset)
```

#### Dynamic Content with Stable IDs

```swift
struct Message: Identifiable {
    let id: String
    var text: String
    var isRead: Bool
}

section.highPerformanceID { context in
    // Cache by message ID
    // Size doesn't change even if isRead changes
    return context.model.id
}
```

#### Clear Cache on Data Change

```swift
func updateData(_ newData: [Model]) {
    section.highPerformance?.clear()
    section.apply(newData)
}
```

## Index Titles

Add alphabet index for quick scrolling (like Contacts app).

### Set Index Title

```swift
// Set index title for section
section.indexTitle = "A"
```

### Complete Example

```swift
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
// Index appears on right side of collection view
```

## Prefetching Support

Prepare data before cells are displayed.

### Access Prefetch Publishers

```swift
// Observe prefetch requests
section.prefetch.prefetchPublisher
    .sink { rows in
        print("Prefetching rows: \(rows)")
        // Preload images, data, etc.
    }
    .store(in: &cancellables)

// Observe cancellations
section.prefetch.cancelPrefetchingPublisher
    .sink { rows in
        print("Cancelled prefetching: \(rows)")
        // Cancel pending operations
    }
    .store(in: &cancellables)

// Load more pattern
section.prefetch.loadMorePublisher
    .sink {
        print("Reached end - load more")
        loadNextPage()
    }
    .store(in: &cancellables)
```

### Use Cases

#### Image Prefetching

```swift
section.prefetch.prefetchPublisher
    .sink { [weak section] rows in
        guard let section = section else { return }
        
        for row in rows {
            let model = section.models[row]
            ImageLoader.shared.prefetch(url: model.imageURL)
        }
    }
    .store(in: &cancellables)

section.prefetch.cancelPrefetchingPublisher
    .sink { [weak section] rows in
        guard let section = section else { return }
        
        for row in rows {
            let model = section.models[row]
            ImageLoader.shared.cancelPrefetch(url: model.imageURL)
        }
    }
    .store(in: &cancellables)
```

#### Pagination

```swift
section.prefetch.loadMorePublisher
    .sink { [weak self] in
        guard let self = self else { return }
        self.loadNextPage()
    }
    .store(in: &cancellables)

func loadNextPage() {
    guard !isLoading else { return }
    
    isLoading = true
    API.fetchNextPage { [weak self] newItems in
        self?.section.append(newItems)
        self?.isLoading = false
    }
}
```

## Section Features Configuration

Fine-tune section behavior with feature flags.

### Available Features

```swift
// Skip display events for bulk updates (performance)
section.feature.skipDisplayEventWhenFullyRefreshed = true

// Fixed item size (skip calculation)
section.feature.highestItemSize = CGSize(width: 100, height: 100)

// Fixed header size
section.feature.highestHeaderSize = CGSize(width: 375, height: 44)

// Fixed footer size
section.feature.highestFooterSize = CGSize(width: 375, height: 30)
```

### When to Use

```swift
// Very large dataset updates
if models.count > 10000 {
    section.feature.skipDisplayEventWhenFullyRefreshed = true
}

// Uniform grid layout
section.feature.highestItemSize = CGSize(width: 100, height: 100)

// Static header
section.feature.highestHeaderSize = CGSize(width: collectionView.bounds.width, height: 44)
```

## Summary

These advanced features provide:

1. **Display Tracking** - First-time experiences and analytics
2. **Cell Refresh** - Efficient partial updates
3. **Safe Size Providers** - Precise layout control
4. **High Performance** - Size caching for large datasets
5. **Index Titles** - Quick navigation
6. **Prefetching** - Data preparation and pagination
7. **Feature Flags** - Performance optimization

## Related Documentation

- **[Section Overview](section.md)** - Core concepts
- **[Events & Actions](section-events.md)** - Event handling
- **[Advanced Features](section-advanced.md)** - Combine, drag & drop
- **[Data Operations](section-data-operations.md)** - CRUD operations
- **[Performance](performance.md)** - Comprehensive optimization guide
