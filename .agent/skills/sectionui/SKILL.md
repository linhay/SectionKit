---
name: SectionUI
description: Master skill for SectionUI (SectionKit), a powerful data-driven framework for building complex UICollectionView layouts in Swift. Use when working with UICollectionView, building list interfaces, implementing reactive data binding with Combine, optimizing collection view performance, managing selection state, implementing sticky headers/footers, creating waterfall layouts, integrating SwiftUI views, handling scroll events, or implementing page-based navigation. Covers cells, sections, managers, layout plugins, decorations, performance optimization, reactive programming, selection management, scroll observation, and page view controllers.
---

# SectionUI Skill

`SectionUI` (formerly SectionKit) is a powerful, data-driven framework for building complex `UICollectionView` layouts in Swift. It abstracts away the complexity of `UICollectionViewDataSource` and `UICollectionViewDelegate`, allowing you to focus on composable **Sections** and **Cells**.

## Core Components

1.  **SKCManager**: The central coordinator that manages sections and binds them to the `UICollectionView`.
2.  **SKCollectionView**: A subclass of `UICollectionView` optimized for use with `SectionUI`.
3.  **SKCSingleTypeSection**: A generic section type for displaying a list of identical cells (homogenous data).
4.  **SKLoadViewProtocol & SKConfigurableView**: Protocols that Cells must conform to for automatic registration and configuration.

## Reference Documentation

### Core Components
- **[Cell Creation & Configuration](references/cell.md)** - SKLoadViewProtocol, SKConfigurableView, Auto Layout integration, adaptive cells
- **[Section Management](references/section.md)** - SKCSingleTypeSection basics, event handling, headers/footers, styling
- **[Manager & CollectionView](references/manager.md)** - SKCManager, SKCollectionView, SKCollectionViewController

### Advanced Features
- **[Advanced Sections](references/advanced-sections.md)** - SKCHostingSection (SwiftUI), SKCAnyViewCell, SKCSectionViewCell (nested sections)
- **[Reactive Programming](references/reactive.md)** - SKPublished, data subscription, prefetch publishers, selection publishers
- **[Performance Optimization](references/performance.md)** - SKHighPerformanceStore (size caching), prefetching, display times tracking, safe size providers
- **[Selection Management](references/selection.md)** - SKSelectionProtocol, SKSelectionWrapper, SKCDragSelector (multi-select)
- **[Pin Functionality](references/pin.md)** - Sticky headers/footers/cells, distance tracking, custom animations
- **[Scroll Management](references/scroll.md)** - SKScrollViewDelegateHandler, SKCDisplayTracker, scroll control
- **[Layout Plugins](references/layout-plugins.md)** - Vertical/horizontal alignment, SKWaterfallLayout, custom attribute plugins
- **[Decorations](references/decorations.md)** - Background decorations, custom decoration views
- **[Page View Controller](references/page.md)** - SKPageManager, SKPageViewController, nested scrolling

### Examples
- [Basic List](examples/BasicListViewController.swift)
- [Decorations](examples/DecorationExampleViewController.swift)

## Quick Start Guide

### 1. Basic Setup
Use `SKCollectionViewController` or `SKCollectionView` to get started quickly.

```swift
class MyViewController: SKCollectionViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // Setup sections here
        manager.reload(mySection)
    }
}
```

### 2. Creating a Cell
Cells must conform to `SKLoadViewProtocol` and `SKConfigurableView`:

```swift
class MyCell: UICollectionViewCell, SKLoadViewProtocol, SKConfigurableView {
    struct Model {
        let title: String
    }

    static func preferredSize(limit size: CGSize, model: Model?) -> CGSize {
        return CGSize(width: size.width, height: 50)
    }

    func config(_ model: Model) {
        label.text = model.title
    }
    
    private lazy var label = UILabel()
}
```

### 3. Creating a Section
The most common pattern is using `wrapperToSingleTypeSection` on your Cell type.

```swift
let section = MyCell.wrapperToSingleTypeSection()
    .onCellAction(.selected) { context in
        print("Selected: \(context.model)")
    }

section.config(models: [Model1, Model2, ...])
manager.reload(section)
```

### 4. Reactive Updates
`SectionUI` works seamlessly with Combine:

```swift
@SKPublished var items: [Model] = []

$items.bind { [weak self] newItems in
    self?.section.config(models: newItems)
}.store(in: &cancellables)

// Or subscribe directly
section.subscribe(models: $items.eraseToAnyPublisher())
```

## Common Usage Patterns

### Performance Optimization
```swift
section
    .setHighPerformance(.init())
    .highPerformanceID { $0.model.id }
```

### Sticky Headers
```swift
section.pinHeader { options in
    options.padding = 16
}
```

### Selection Management
```swift
let selectableItems = items.map { SKSelectionWrapper(value: $0) }
section.config(models: selectableItems)
```

### Waterfall Layout
```swift
let layout = SKWaterfallLayout()
    .columnWidth(equalParts: 2)
    .heightCalculationMode(.aspectRatio)
```

### SwiftUI Integration
```swift
@available(iOS 16.0, *)
let section = SKCHostingSection(
    cell: MySwiftUIView.self,
    models: viewModels
)
```

## Best Practices
- **Prefer `SKCManager`**: Always use `SKCManager` to manipulate sections (reload, insert, delete).
- **Fluent Configuration**: Use the chainable generic methods on `SKCSingleTypeSection` (`onCellAction`, `setSectionSeparators`, etc.) instead of subclassing whenever possible.
- **Decomposition**: Break complex lists into multiple small Sections.
- **Use Reactive Binding**: Leverage Combine and `SKPublished` for automatic UI updates.
- **Cache Sizes**: Use `SKHighPerformanceStore` for complex Auto Layout calculations.
- **Weak References**: Always use `[weak self]` in closures to avoid retain cycles.
