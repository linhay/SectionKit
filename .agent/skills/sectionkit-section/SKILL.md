---
name: sectionkit-section
description: Master skill for scaffolding and configuring SKCSingleTypeSection with advanced features (Diff, Pagination, Performance, Style, Supplementary).
---

# sectionkit-section (Master)

Use this skill to create and fully configure `SKCSingleTypeSection` components. This master skill integrates all common professional patterns used in production.

## 1. Quick Scaffolding

### Standard Instance (Direct)
```swift
let section = SKCSingleTypeSection<MyCell>()
    .config(models: models)
```

### Wrapper Utilities (Recommended for Conciseness)
Use `wrapperToSingleTypeSection` directly on the Cell type. This is the most common way to create sections in SectionKit.

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

// 4. Async model loading
let section = try await MyCell.wrapperToSingleTypeSection {
    try await fetchModel()
}
```

### Advanced Wrappers & Chaining
Create and fully configure a section in a single fluent statement.

```swift
let section = MyCell.wrapperToSingleTypeSection(models)
    .setSectionStyle(\.sectionInset, .init(top: 8, left: 16, bottom: 8, right: 16))
    .setCellStyle(.separator(.bottom(insets: .init(top: 0, left: 16, bottom: 0, right: 16))))
    .onCellAction(on: self, .selected) { (self, context) in
        // Tracking & Navigation
        // Safe access to view controller via self
        self.navigationController?.pushViewController(...)
    }
    .set(decoration: SectionCornerRadiusView.self, 
         model: .init(backgroundColor: .white, cornerRadius: 12))
    .addLayoutPlugins(.left)
```

#### Shared Styling (Extension Pattern)
Define reusable styling chains for consistent UI across your app (Common in `OpenClass`).

```swift
extension SKCSingleTypeSection {
    func myAppCardStyle() -> Self {
        return self
            .setSectionStyle(\.sectionInset, .init(top: 8, left: 8, bottom: 0, right: 8))
            .set(decoration: SectionCornerRadiusView.self,
                 model: .init(backgroundColor: .white, cornerRadius: 12))
    }
}

// Usage
let section = MyCell.wrapperToSingleTypeSection(models).myAppCardStyle()
```

### Professional Subclass (Recommended for complex logic)
```swift
import SectionUI
import Combine

class <#SectionName#>Section: SKCSingleTypeSection<<#CellName#>> {
    
    private var cancellables = Set<AnyCancellable>()
    
    override init() {
        super.init()
        setupActions()
        setupStyling()
    }
    
    private func setupActions() {
        onCellAction(.selected) { [weak self] context in
             // Action logic
        }
    }
    
    private func setupStyling() {
        setItemStyleEvent.delegate(on: self) { (self, context) in
             context.cell.layer.cornerRadius = 12
             context.cell.clipsToBounds = true
        }
    }
}
```

## 2. Professional Features

### Animated Diff Refresh
Override `apply` to enable smooth transitions when data changes. Requires `Cell.Model` to be `Hashable`.

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
Optimized for complex layouts or text measurement.

```swift
override func itemSize(at row: Int) -> CGSize {
    guard let model = models.value(at: row) else { return .zero }
    return highPerformance.cache(by: model, limit: safeSizeProvider.size) { limit in
        return <#CellName#>.preferredSize(limit: limit, model: model)
    }
}
```

### Pagination & Preloading
Trigger next-page loading before the user hits the bottom.

```swift
override func item(willDisplay view: UICollectionViewCell, row: Int) {
    if row + 5 >= models.count {
        // Trigger preloading or beginRefreshing on footer
        // sectionView.mj_footer?.beginRefreshing()
    }
}
```

### Inline Supplementary Views
Quickly add a header or footer using an existing cell type.

```swift
section.setHeader(<#HeaderCellName#>.self, model: <#Model#>) { (header) in
    // configure header cell
}
```

### 5. Sticky Elements (Pinning)
Make headers, footers, or specific cells sticky. You can also listen to their distance from the viewport edge.

```swift
section.pinHeader { options in
    options.$distance.sink { value in
        // Transform UI based on distance from top (e.g. parallax)
    }.store(in: &cancellables)
}

section.pinCell(at: 0) { options in
    // Make the first cell sticky
}
```

### 6. Index Titles
Add alphabetical index support by setting the `indexTitle` property.

```swift
section.setSectionStyle { section in
    section.indexTitle = "A"
}
```

### 7. Section Inset Management
Fine-tune how headers and footers interact with section insets using attributes.

```swift
section.setSectionStyle(\.sectionInset, .init(top: 10, left: 10, bottom: 10, right: 10))
    .setAttributes(.reverseHeaderAndSectionInset) // Header extends to edges
    .setAttributes(.reverseFooterAndSectionInset) // Footer extends to edges
```

### 8. Deep Dive: Interactive Features

#### Drag & Drop (Reordering)
Enable cell reordering with a single line. The data source is automatically updated.

```swift
section.onCellShould(.move) { context in
    return true // Allow moving for this cell
}
```

#### Context Menu
Add iOS system Context Menus (long press).

```swift
section.onContextMenu { context in
    return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
        UIMenu(title: "Actions", children: [
            UIAction(title: "Delete", image: UIImage(systemName: "trash"), attributes: .destructive) { _ in
                context.section.delete(context.row)
            }
        ])
    }
}
```

#### Advanced Prefetching
Monitor data consumption to preload next pages intelligently. `SKCPrefetch` exposes a publisher for anticipated row indices.

```swift
// Get the publisher for anticipated rows
section.prefetch.prefetchPublisher
    .sink { rows in
        print("User is approaching rows: \(rows)")
    }
    .store(in: &cancellables)
```

### 9. Deep Dive: Layout & Performance Control

#### Advanced Cell Sizing (SKSafeSizeProvider)
Control the `limit size` passed to your cell's `preferredSize` calculation.

```swift
// 1. Fraction Layout (e.g., 2 columns)
section.cellSafeSize(.fraction(0.5))

// 2. Fixed Size (Force specific dimensions)
section.cellSafeSize(.fixed(.init(width: 100, height: 100)))

// 3. Dynamic Router (Switch strategy at runtime)
section.cellSafeSize(.router { 
    isLandscape ? .fraction(0.33) : .fraction(0.5)
})
```

#### Shared Environment Dependency
Inject services or configuration objects that can be accessed by the section at any time.

```swift
// 1. Inject
section.environment(of: MyAnalyticsService.shared)

// 2. Retrieve
let service = section.environment(of: MyAnalyticsService.self)
```

#### High-Performance Size Caching (Manual Control)
While `highPerformanceItemSize` is automatic, you can manually manage the cache store.

```swift
// Check or clear cache manually
section.highPerformance?.removeAll()
// section.highPerformance?.remove(by: someID)
```

## Professional Tips
- **Sticky Animations**: Combine `.pinHeader` with a Combine `.sink` to trigger transparency or size changes as the header reaches the top.
- **Decoration Events**: You can listen to lifecycle events on decoration views: `section.set(decoration: MyView.self) { $0.onAction(.willDisplay) { ... } }`.
- **Responsive Layouts**: Use `cellSafeSize(.fraction(0.5), transforms: .height(asRatioOfWidth: 1))` for a perfect 2-column square grid.
- **Batch Updates**: Always use `pick { ... }` when performing multiple insertions/deletions for synchronized animations.
- **Attributes**: Use `setAttributes` for specific behavior flags like reverse insets or custom layout behavior.

### 10. Advanced Layout Customization (FlowLayout)
Access the underlying `SKCollectionFlowLayout` for granular control, such as sticky headers or alignment.

#### Sticky Section Headers
Enable headers to float above the content while scrolling.

```swift
// In your UIViewController or setup code
if let layout = sectionView.collectionViewLayout as? SKCollectionFlowLayout {
    layout.sectionHeadersPinToVisibleBounds = true
}
```

#### Global Decoration Views
Register decorations globally on the layout plugins.

```swift
// Apply a background view to all sections
SKCLayoutPlugins.layout.add(decoration: MyBackgroundView.self, insets: .zero)
```

#### Layout Plugins Alignment
Control how items are aligned within a row/column.

```swift
// Align items to the left
section.addLayoutPlugins(.left)

// Center items vertically
section.addLayoutPlugins(.centerX)
```

### 11. Productivity Shortcuts
Use these built-in extensions to write less boilerplate code.

#### KeyPath Style Setting
Directly set properties on the cell or section context without opening a closure.

```swift
// Instead of: .setSectionStyle { $0.minimumLineSpacing = 10 }
.setSectionStyle(\.minimumLineSpacing, 10)

// Instead of: .setCellStyle { $0.model = newVal } 
.setCellStyle(\.model, newVal)
```

#### Async Action Handling
Native `async/await` support in cell actions.

```swift
.onAsyncCellAction(.selected) { context in
    let detail = try await fetchDetail(id: context.model.id)
    // ... navigate
}
```

#### DSL Result Builder
Build sections declaratively, similar to SwiftUI.

```swift
MyCell.wrapperToSingleTypeSection {
    Model(title: "First")
    Model(title: "Second")
}
```

#### Safe Weak Self Binding
Avoid strict `[weak self]` dances by passing the object to retain weakly.

```swift
.onCellAction(on: self, .selected) { (self, context) in
    self.handleSelection(context.model)
}
```


### 16. Advanced Scrolling (Delegate Forwarding)
Intercept scroll events without subclassing or taking over the delegate. Multiple observers can be registered.

```swift
// Register a scroll observer
manager.scrollObserver.add(scroll: "unique_id") { handle in
    handle.scrollViewDidScroll = { scrollView in
        print("Scrolled to: \(scrollView.contentOffset)")
    }
}

// Remove observer
manager.scrollObserver.remove(id: "unique_id")
```

### 17. Custom Layout Plugins (SKCLayoutPlugins)
Extend `FlowLayout` logic without subclassing. Use `SKCPluginAdjustAttributes` to modify attributes.

```swift
// Create a custom attribute adjuster
let stickyPlugin = SKCPluginAdjustAttributes { context in
    // Modify attributes context.attributes
    for attributes in context.attributes {
        if attributes.representedElementKind == UICollectionView.elementKindSectionHeader {
            // Implement sticky header logic here
            var frame = attributes.frame
            frame.origin.y = max(context.contentOffset.y, frame.origin.y)
            attributes.frame = frame
            attributes.zIndex = 100
        }
    }
    return context.attributes
}

// Apply to section
section.sectionInjection?.add(plugin: .attributes(stickyPlugin))
```

### 15. Advanced Supplementary Views
Beyond standard Headers and Footers, you can register custom supplementary views (e.g., decorations, section separators).

#### Custom Kinds
```swift
// Register a custom background decoration
section.set(supplementary: .custom("Background"), type: BgView.self, model: .red)

// Removing
section.remove(supplementary: .custom("Background"))
```

#### Supplementary Actions
Handle events on headers/footers/custom views.

```swift
section.onSupplementaryAction(.click) { context in
    if context.kind == .header {
        // Handle header click
    }
}
```

### 14. Data & Analytics (Deep Dive)

#### Reactive Subscriptions (Combine)
Directly bind your ViewModel's publisher to the section. The section will automatically `apply` updates.

```swift
// Bind to an array publisher
section.subscribe(models: viewModel.$items)

// Bind to a single optional model
section.subscribe(models: viewModel.$currentItem)
```

#### Impression Tracking (Analytics)
Track when a cell is displayed, useful for exposure logging.

```swift
// Trigger when the first cell is displayed
section.model(displayedAt: .first) { context in
    Analytics.log(event: "view_item", id: context.model.id)
}

// Custom predicate (e.g., every 5th item)
section.model(displayedAt: .init { $0 % 5 == 0 }) { context in
    // ...
}
```

#### Granular Refreshing
Update specific items without reloading the entire section or relying on Diffing.

```swift
// Update model at row 0 and refresh cell
section.refresh(at: 0, model: newModel)

// Find and update specific models
section.refresh([updatedModel], predicate: { old, new in old.id == new.id })
```

### 12. Manager Capabilities (SKCManager)
The `SKCManager` controls the lifecycle, updates, and scrolling of all sections.

#### Section Updates
Perform batch updates (Insert/Delete) or full reloads.

```swift
// Full Reload
manager.reload([sectionA, sectionB])

// Batch Updates
manager.insert(newSection, after: existingSection)
manager.delete(oldSection)
manager.append(footerSection)
```

#### Safe Scrolling
Scroll to a specific section or row, handling async layout automatically.

```swift
manager.scroll(to: section, row: 0, at: .top, animated: true)
```

#### Configuration
Customize behavior, for example, forcing `reloadData` instead of batch updates for stability.

```swift
manager.configuration.replaceDeleteWithReloadData = true
```

### 13. Hosting & Integration

#### Standard Controller (SKCollectionViewController)
The standard way to host sections.

```swift
class MyViewController: SKCollectionViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        manager.reload(TextCell.wrapperToSingleTypeSection(["Data"]))
    }
}
```

#### Waterfall Layout
Switch to a Waterfall layout easily.

```swift
// In viewDidLoad
let layout = SKWaterfallLayout().columnWidth(equalParts: 2)
sectionView.setCollectionViewLayout(layout, animated: false)
```

#### SwiftUI Integration
Embed your SectionKit controller into a SwiftUI View.

```swift
struct MyView: View {
    var body: some View {
        UIViewController.sk.toSwiftUI {
            SKCollectionViewController()
        }
    }
}
```

