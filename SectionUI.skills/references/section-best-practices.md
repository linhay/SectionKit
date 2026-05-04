# Section Best Practices

This guide provides recommended patterns and best practices for working with `SKCSingleTypeSection`.

## Choose the Right Reload Strategy

Match your reload strategy to your use case for optimal performance and user experience.

### Strategy Comparison

```swift
// 1. Normal - Full reload
section.reloadKind = .normal
// ✅ Use for: Complete data replacement, initial load
// ❌ Avoid for: Frequent updates, real-time data

// 2. Config and Delete - Efficient updates
section.reloadKind = .configAndDelete
// ✅ Use for: Similar-sized data updates, filtering
// ❌ Avoid for: Large size changes

// 3. Difference - Animated changes
section.reloadKind = .difference(by: \.id)
// ✅ Use for: Real-time updates, insertions/deletions
// ❌ Avoid for: Very large datasets (performance impact)
```

### Use Case Examples

```swift
// Real-time chat or feed
chatSection.reloadKind = .difference(by: \.id)

// Search results
searchSection.reloadKind = .configAndDelete

// Page refresh
newsSection.reloadKind = .normal
```

## Use Weak References

Always use weak references to avoid retain cycles.

### Correct Patterns

```swift
// ✅ Event handlers
section.onCellAction(on: self, .selected) { strongSelf, context in
    strongSelf.handleSelection(model: context.model)
}

// ✅ Cell styling
section.setCellStyle(on: self) { strongSelf, context in
    context.view.backgroundColor = strongSelf.themeColor
}

// ✅ Supplementary actions
section.onSupplementaryAction(.willDisplay) { [weak self] context in
    guard let self = self else { return }
    self.trackHeaderDisplay()
}
```

### Common Mistakes

```swift
// ❌ Direct self capture - Creates retain cycle
section.onCellAction(.selected) { context in
    self.handleSelection(model: context.model)
}

// ❌ Strong self in closures
section.setCellStyle { context in
    context.view.backgroundColor = self.backgroundColor
}
```

## Type Erasure for Mixed Sections

When working with multiple section types, use `SKCSectionProtocol`.

### Basic Type Erasure

```swift
let headerSection = HeaderCell.wrapperToSingleTypeSection()
let contentSection = ContentCell.wrapperToSingleTypeSection()
let footerSection = FooterCell.wrapperToSingleTypeSection()

// Type-erase into single array
var sections: [SKCSectionProtocol] = [
    headerSection,
    contentSection,
    footerSection
]

manager.update(sections)
```

### Maintaining Type Safety

Keep strong references to sections when you need to modify them:

```swift
class ViewController: UIViewController {
    private let headerSection = HeaderCell.wrapperToSingleTypeSection()
    private let contentSection = ContentCell.wrapperToSingleTypeSection()
    
    func setupSections() {
        // Configure with type safety
        contentSection.config(models: items)
        contentSection.onCellAction(.selected) { context in
            // Handle selection
        }
        
        // Pass to manager as type-erased
        manager.update([headerSection, contentSection])
    }
    
    func updateContent(_ newItems: [ContentCell.Model]) {
        // Direct access maintains type safety
        contentSection.config(models: newItems)
    }
}
```

## Organize Section Configuration

Group related configurations together for clarity and maintainability.

### Recommended Structure

```swift
let section = MyCell.wrapperToSingleTypeSection()
    // 1. Data
    .config(models: items)
    
    // 2. Reload strategy
    .setSectionStyle(\.reloadKind, .difference(by: \.id))
    
    // 3. Layout
    .setSectionInset(.init(top: 16, left: 16, bottom: 16, right: 16))
    .setSectionStyle(\.minimumLineSpacing, 10)
    
    // 4. Styling
    .setCellStyle { context in
        context.view.layer.cornerRadius = 8
    }
    
    // 5. Events
    .onCellAction(.selected) { context in
        print("Selected: \(context.model)")
    }
    
    // 6. Supplementary views
    .setHeader(MyHeader.self, model: "Title")
```

### Extract Complex Configurations

For complex setups, extract to separate methods:

```swift
extension MyViewController {
    func createProductSection() -> SKCSingleTypeSection<ProductCell> {
        return ProductCell.wrapperToSingleTypeSection()
            .configured(with: products)
            .withLayout()
            .withEventHandlers(owner: self)
    }
    
    private func SKCSingleTypeSection<ProductCell>.configured(
        with models: [ProductCell.Model]
    ) -> Self {
        return self
            .config(models: models)
            .setSectionStyle(\.reloadKind, .difference(by: \.id))
    }
    
    private func SKCSingleTypeSection<ProductCell>.withLayout() -> Self {
        return self
            .setSectionInset(.init(top: 16, left: 16, bottom: 16, right: 16))
            .setSectionStyle(\.minimumLineSpacing, 10)
    }
    
    private func SKCSingleTypeSection<ProductCell>.withEventHandlers(
        owner: MyViewController
    ) -> Self {
        return self
            .onCellAction(on: owner, .selected) { owner, context in
                owner.handleSelection(context)
            }
    }
}
```

## Model Design

Design models that work well with SectionKit.

### Equatable Models

```swift
// ✅ Good - Equatable for difference-based updates
struct Item: Equatable {
    let id: String
    let title: String
    let isDraggable: Bool
    
    static func == (lhs: Item, rhs: Item) -> Bool {
        lhs.id == rhs.id
    }
}

section.reloadKind = .difference()
```

### KeyPath-based Comparison

```swift
// 🔄 Alternative - Use specific property for comparison
struct Item {
    let id: String
    let title: String
    let timestamp: Date
}

section.reloadKind = .difference(by: \.id)
```

### Immutable by Default

```swift
// ✅ Prefer immutable structs
struct Product {
    let id: String
    let name: String
    let price: Double
}

// Update by creating new instances
var updated = product
// Error: Cannot assign to property - use 'var' or make properties 'var'
```

### Value Semantics

```swift
// ✅ Use value types (structs) for models
struct Message {
    let id: String
    var text: String
    var isRead: Bool
}

// ❌ Avoid reference types unless necessary
class Message { // Requires extra care with equality
    let id: String
    var text: String
}
```

## Performance Optimization

### 1. Choose Appropriate Reload Strategies

```swift
// Large datasets - avoid frequent difference updates
if items.count > 1000 {
    section.reloadKind = .normal
} else {
    section.reloadKind = .difference(by: \.id)
}
```

### 2. Use Config and Delete for Filtering

```swift
// Efficient for filtering/searching
searchSection.reloadKind = .configAndDelete
```

### 3. Skip Display Events for Bulk Updates

```swift
section.feature.skipDisplayEventWhenFullyRefreshed = true
```

### 4. Cache Fixed Sizes

```swift
// If all cells have the same size
section.feature.highestItemSize = CGSize(width: 100, height: 100)
```

### 5. Enable High Performance Mode

```swift
section.highPerformance = .init()
section.highPerformanceID = { context in
    return context.model.id // Unique identifier for caching
}
```

See **[Performance](performance.md)** for comprehensive optimization techniques.

## Error Prevention

### Validate Data Before Updates

```swift
func updateSection(with newData: [Model]) {
    guard !newData.isEmpty else {
        print("Warning: Attempting to update with empty data")
        return
    }
    
    section.apply(newData)
}
```

### Safe Index Access

```swift
// ❌ Unsafe
let model = section.models[index]

// ✅ Safe
guard section.models.indices.contains(index) else {
    return
}
let model = section.models[index]
```

### Prevent Zombie Cell Access

```swift
// ❌ Don't store cell references
var storedCell: MyCell?

section.onCellAction(.willDisplay) { context in
    storedCell = context.view() // Cell may be reused!
}

// ✅ Access cells through section
section.onCellAction(.selected) { context in
    let cell = context.view() // Always get current cell
    // Use cell immediately
}
```

## Code Organization

### Separate Concerns

```swift
class ProductListViewController: UIViewController {
    // MARK: - Properties
    private let section = ProductCell.wrapperToSingleTypeSection()
    private var products: [Product] = []
    
    // MARK: - Setup
    func setupSection() {
        section
            .config(models: products)
            .applyStyling()
            .applyLayout()
            .bindEvents(to: self)
    }
    
    // MARK: - Data
    func loadProducts() {
        // Data loading logic
    }
    
    // MARK: - Actions
    @objc func handleProductSelection(_ product: Product) {
        // Selection handling
    }
}

// MARK: - Section Configuration
private extension ProductListViewController {
    func SKCSingleTypeSection<ProductCell>.applyStyling() -> Self {
        // Styling logic
    }
    
    func SKCSingleTypeSection<ProductCell>.applyLayout() -> Self {
        // Layout logic
    }
    
    func SKCSingleTypeSection<ProductCell>.bindEvents(
        to owner: ProductListViewController
    ) -> Self {
        // Event binding
    }
}
```

## Testing

### Testable Section Configuration

```swift
// Make section creation testable
protocol ProductSectionFactory {
    func createSection() -> SKCSingleTypeSection<ProductCell>
}

class DefaultProductSectionFactory: ProductSectionFactory {
    func createSection() -> SKCSingleTypeSection<ProductCell> {
        return ProductCell.wrapperToSingleTypeSection()
            .config(models: [])
            .setSectionStyle(\.reloadKind, .difference(by: \.id))
    }
}

// Test with mock factory
class MockProductSectionFactory: ProductSectionFactory {
    func createSection() -> SKCSingleTypeSection<ProductCell> {
        return ProductCell.wrapperToSingleTypeSection()
    }
}
```

## Common Pitfalls

### 1. Forgetting to Update Manager

```swift
// ❌ Manager doesn't know about changes
section.append(newItem)

// ✅ Tell manager to refresh if needed
section.append(newItem)
manager.reload() // If necessary
```

### 2. Modifying Models Directly

```swift
// ❌ Don't modify section.models directly
section.models.append(newItem) // This won't trigger UI update!

// ✅ Use section methods
section.append(newItem)
```

### 3. Mixing Reload Strategies

```swift
// ❌ Don't change reload strategy frequently
func updateData() {
    section.reloadKind = .difference()
    section.apply(newData)
}

func refresh() {
    section.reloadKind = .normal // Changed strategy!
    section.apply(refreshedData)
}

// ✅ Set once during initialization
func setupSection() {
    section.reloadKind = .difference(by: \.id)
}
```

## Summary Checklist

- [ ] Choose appropriate reload strategy for your use case
- [ ] Use weak references for all closures that capture self
- [ ] Type-erase mixed sections with SKCSectionProtocol
- [ ] Organize configuration in logical groups
- [ ] Design models with Equatable or use KeyPath comparison
- [ ] Enable performance optimizations for large datasets
- [ ] Validate data before updates
- [ ] Separate concerns in your code organization
- [ ] Test section configurations
- [ ] Avoid common pitfalls

## Related Documentation

- **[Section Overview](section.md)** - Core concepts and creation
- **[Events & Actions](section-events.md)** - Handle cell interactions
- **[Styling](section-styling.md)** - Cell styling and supplementary views
- **[Advanced Features](section-advanced.md)** - Combine, drag & drop, context menus
- **[Data Operations](section-data-operations.md)** - Working with section data
- **[Performance](performance.md)** - Comprehensive optimization guide
