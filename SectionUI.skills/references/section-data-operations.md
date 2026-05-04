# Section Data Operations

This guide covers all data manipulation operations for `SKCSingleTypeSection`.

## Adding Items

### Append Items

Add items to the end of the section:

```swift
// Append single item
section.append(newModel)

// Append multiple items
section.append([model1, model2, model3])
```

### Insert Items

Insert items at specific positions:

```swift
// Insert single item
section.insert(at: 0, newModel)  // Insert at beginning

// Insert multiple items
section.insert(at: 2, [model1, model2])
```

## Removing Items

### Remove by Index

```swift
// Remove single item
section.remove(3)

// Remove multiple items
section.remove([0, 2, 5])
```

### Remove by Predicate

```swift
section.remove(where: { model in
    model.isExpired
})
```

**Examples:**

```swift
// Remove completed tasks
section.remove(where: { $0.isCompleted })

// Remove items older than 30 days
section.remove(where: { $0.createdDate.daysAgo > 30 })

// Remove items matching criteria
section.remove(where: { $0.category == "archived" && !$0.isPinned })
```

### Remove by Value (Equatable)

```swift
// Single item
section.remove(specificModel)  // where Model: Equatable

// Multiple items
section.remove([model1, model2])  // where Model: Equatable
```

### Remove by Reference (AnyObject)

```swift
// For class-based models
section.remove(objectModel)  // where Model: AnyObject
section.remove([object1, object2])
```

### Delete vs Remove

Both methods work identically - `delete` is an alias for `remove`:

```swift
section.delete(3)           // Same as remove(3)
section.delete(where: { })  // Same as remove(where:)
```

## Updating Data

### Replace All Data

```swift
// Replace entire dataset
let newModels = [MyCell.Model(title: "A"), MyCell.Model(title: "B")]
section.config(models: newModels)

// Or use apply (same effect)
section.apply(newModels)
```

### Reload Strategies

Control how data updates are applied:

```swift
// 1. Normal (default) - Full reload
section.reloadKind = .normal

// 2. Config and Delete - Efficient for similar data sizes
section.reloadKind = .configAndDelete

// 3. Difference-based - Animated insertions/deletions (Equatable)
section.reloadKind = .difference()  // where Model: Equatable

// 4. Custom difference logic
section.reloadKind = .difference(by: \.id)  // Compare by specific property

section.reloadKind = .difference { lhs, rhs in
    lhs.id == rhs.id  // Custom equality logic
}
```

**Reload Strategy Guide:**
- **`.normal`**: Use for complete data changes (default)
- **`.configAndDelete`**: Best when data sizes are similar, avoids full reload
- **`.difference()`**: Provides smooth animations for insertions/deletions

### Strategy Selection Examples

```swift
// Real-time chat messages - use difference for smooth animations
chatSection.reloadKind = .difference(by: \.messageId)

// Periodic full refresh - use normal
newsSection.reloadKind = .normal

// Live filtering results - use configAndDelete
searchSection.reloadKind = .configAndDelete
```

## Accessing Data

### Get All Models

```swift
let allModels = section.models
```

### Find Items (Equatable Models)

```swift
// Find first matching item
if let row = section.firstRow(of: targetModel) {
    print("Found at index: \(row)")
}

// Find last matching item
if let row = section.lastRow(of: targetModel) {
    print("Found at index: \(row)")
}

// Find all matching items
let rows = section.rows(with: targetModel)
let rows = section.rows(with: [model1, model2])
```

### Access Visible Cells

```swift
// Get all visible cells
let visibleCells = section.visibleCells

// Get cell at specific row
if let cell = section.cellForItem(at: 5) {
    // Do something with cell
}

// Get cells for specific model (Equatable)
let cells = section.cellForItem(of: targetModel)
```

### Layout Attributes

Get layout information for cells:

```swift
// Get layout attributes for specific row
if let attributes = section.layoutAttributesForItem(at: 3) {
    print("Frame: \(attributes.frame)")
}

// Get all layout attributes for a model (Equatable)
let allAttributes = section.layoutAttributesForItem(of: targetModel)
```

## Scrolling

### Scroll to Index

```swift
section.scroll(to: 10, at: .top, animated: true)
```

**Scroll positions:**
- `.top` - Scroll so item is at the top
- `.centeredVertically` - Center the item vertically
- `.centeredHorizontally` - Center the item horizontally
- `.bottom` - Scroll so item is at the bottom
- `.left` - Scroll so item is at the left
- `.right` - Scroll so item is at the right

### Scroll to Model (Equatable)

```swift
// Scroll to first occurrence
section.scroll(toFirst: targetModel, at: .centeredVertically, animated: true)

// Scroll to last occurrence
section.scroll(toLast: targetModel, at: .bottom, animated: true)
```

### Scroll Examples

```swift
// Scroll to newly added item
section.append(newItem)
section.scroll(to: section.models.count - 1, at: .bottom, animated: true)

// Scroll to search result
if let foundRow = section.firstRow(of: searchResult) {
    section.scroll(to: foundRow, at: .centeredVertically, animated: true)
}
```

## Batch Operations

### Performant Bulk Updates

When making multiple changes, disable animations during updates:

```swift
// Multiple individual operations
section.insert(at: 0, newItem1)
section.insert(at: 1, newItem2)
section.remove(5)

// Better: Use batch replacement
var updatedModels = section.models
updatedModels.insert(newItem1, at: 0)
updatedModels.insert(newItem2, at: 1)
updatedModels.remove(at: 5)
section.apply(updatedModels)
```

### Filtering

```swift
// Filter current data
let filteredModels = section.models.filter { $0.isVisible }
section.apply(filteredModels)
```

### Sorting

```swift
// Sort current data
let sortedModels = section.models.sorted { $0.priority > $1.priority }
section.apply(sortedModels)
```

### Transforming

```swift
// Transform data
let transformedModels = section.models.map { model in
    var updated = model
    updated.isRead = true
    return updated
}
section.apply(transformedModels)
```

## Common Patterns

### Infinite Scroll

```swift
section.onCellAction(.willDisplay) { context in
    // Load more when approaching end
    if context.row >= context.section.models.count - 5 {
        loadMoreData()
    }
}

func loadMoreData() {
    fetchNextPage { newItems in
        section.append(newItems)
    }
}
```

### Pull to Refresh

```swift
func refresh() {
    fetchLatestData { newData in
        section.reloadKind = .difference(by: \.id)
        section.apply(newData)
    }
}
```

### Real-time Updates

```swift
// WebSocket message received
func onMessageReceived(_ message: Message) {
    var models = section.models
    
    if let index = models.firstIndex(where: { $0.id == message.id }) {
        // Update existing
        models[index] = message
    } else {
        // Insert new at top
        models.insert(message, at: 0)
    }
    
    section.reloadKind = .difference(by: \.id)
    section.apply(models)
}
```

### Optimistic Updates

```swift
func deleteItem(_ item: Model) {
    // Remove immediately (optimistic)
    section.remove(item)
    
    // Revert if API call fails
    deleteFromServer(item) { success in
        if !success {
            section.insert(at: originalIndex, item)
        }
    }
}
```

### Search & Filter

```swift
var allItems: [Model] = []

func search(_ query: String) {
    let results = allItems.filter { 
        $0.title.localizedCaseInsensitiveContains(query) 
    }
    
    section.reloadKind = .difference(by: \.id)
    section.apply(results)
}
```

## Error Handling

### Safe Index Access

```swift
// Check bounds before accessing
guard section.models.indices.contains(index) else {
    print("Invalid index")
    return
}

let model = section.models[index]
```

### Validation Before Update

```swift
func updateSection(with newData: [Model]) {
    guard !newData.isEmpty else {
        print("Cannot update with empty data")
        return
    }
    
    section.apply(newData)
}
```

## Performance Tips

1. **Use appropriate reload strategies** - `.difference()` for smooth animations, `.normal` for bulk changes
2. **Batch operations** - Combine multiple changes into single apply call
3. **Avoid frequent full reloads** - Use targeted updates when possible
4. **Set skipDisplayEventWhenFullyRefreshed** for very large datasets

```swift
section.feature.skipDisplayEventWhenFullyRefreshed = true
```

## Related Documentation

- **[Section Overview](section.md)** - Core concepts and creation
- **[Events & Actions](section-events.md)** - Handle cell interactions
- **[Advanced Features](section-advanced.md)** - Combine, drag & drop, context menus
- **[Best Practices](section-best-practices.md)** - Recommended patterns
- **[Performance](performance.md)** - Optimization techniques
