# Advanced Section Features

This guide covers advanced functionality including reactive programming, drag & drop, and context menus.

## Reactive Data Binding (Combine)

Bind Combine publishers to automatically update section data.

### Basic Publisher Binding

```swift
let modelsPublisher: AnyPublisher<[MyCell.Model], Never> = viewModel.$items
    .eraseToAnyPublisher()

section.subscribe(models: modelsPublisher)
// Section automatically updates when publisher emits new values
```

### Single Model Publisher

```swift
let modelPublisher: AnyPublisher<MyCell.Model, Never> = viewModel.$selectedItem
    .eraseToAnyPublisher()

section.subscribe(models: modelPublisher)
// Converts single model to array [model]
```

### Optional Model Publisher

```swift
let optionalPublisher: AnyPublisher<MyCell.Model?, Never> = viewModel.$maybeItem
    .eraseToAnyPublisher()

section.subscribe(models: optionalPublisher)
// nil -> [], some(model) -> [model]
```

### Observing Cell Events

Subscribe to cell action events as Combine publishers:

```swift
section.publishers.cellActionPulisher
    .filter { $0.type == .selected }
    .sink { context in
        print("Selected: \(context.model)")
    }
    .store(in: &cancellables)
```

### Observing Model Changes

```swift
section.publishers.modelsPulisher
    .sink { models in
        print("Models updated: \(models.count) items")
    }
    .store(in: &cancellables)
```

### Lifecycle Events

```swift
section.publishers.lifeCyclePulisher
    .sink { lifecycle in
        switch lifecycle {
        case .loadedToSectionView(let collectionView):
            print("Section loaded to: \(collectionView)")
        }
    }
    .store(in: &cancellables)
```

### Advanced Combine Patterns

#### Debounced Search

```swift
let searchPublisher = searchTextField.textPublisher
    .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
    .map { searchText in
        products.filter { $0.name.contains(searchText) }
    }

section.subscribe(models: searchPublisher)
```

#### Merged Data Sources

```swift
let combinedPublisher = Publishers.CombineLatest(
    localDataPublisher,
    remoteDataPublisher
)
.map { local, remote in
    return local + remote
}

section.subscribe(models: combinedPublisher)
```

## Drag & Drop

Enable interactive drag and drop reordering.

### Enable Drag & Drop

```swift
// Allow all cells to be moved
section.onCellShould(.canMove, true)

// Or use a closure for conditional logic
section.onCellShould(.canMove) { context in
    return context.model.isDraggable
}
```

### Handle Move Completion

The section automatically updates its models when items are moved:

```swift
section.onCellShould(.canMove, true)

// Models are automatically reordered
// Access updated order via section.models
```

### Programmatic Swap

Swap items manually:

```swift
// Swap items at indices i and j
section.swapAt(0, 5)

// With animation (if section is attached to collection view)
if section.sectionInjection?.sectionView != nil {
    section.swapAt(i, j)  // Animated
}
```

### Cross-Section Moves

When moving between sections, the framework handles data updates automatically:

```swift
// No additional code needed
// Just ensure both sections have .canMove enabled
```

### Drag & Drop with Persistence

```swift
section
    .onCellShould(.canMove, true)
    .onCellAction(.didEndDisplay) { context in
        // Save reordered data
        UserDefaults.save(context.section.models)
    }
```

## Context Menu

Add iOS 13+ context menus with long-press interactions.

### Basic Context Menu

```swift
section.onContextMenu { context in
    let action = UIAction(title: "Delete", image: UIImage(systemName: "trash")) { _ in
        context.remove()
    }
    
    return .init(
        configuration: UIContextMenuConfiguration(
            identifier: nil,
            previewProvider: nil,
            actionProvider: { _ in
                UIMenu(title: "", children: [action])
            }
        )
    )
}
```

### Conditional Context Menus

Show menus only for specific cells:

```swift
section.onContextMenu(where: { context in
    return context.model.allowsContextMenu
}) { context in
    // Return menu configuration
    return .init(/* ... */)
}
```

### Multiple Actions

```swift
section.onContextMenu { context in
    let edit = UIAction(title: "Edit", image: UIImage(systemName: "pencil")) { _ in
        // Handle edit
    }
    
    let share = UIAction(title: "Share", image: UIImage(systemName: "square.and.arrow.up")) { _ in
        // Handle share
    }
    
    let delete = UIAction(
        title: "Delete", 
        image: UIImage(systemName: "trash"),
        attributes: .destructive
    ) { _ in
        context.remove()
    }
    
    return .init(
        configuration: UIContextMenuConfiguration(
            identifier: nil,
            previewProvider: nil,
            actionProvider: { _ in
                UIMenu(title: "", children: [edit, share, delete])
            }
        )
    )
}
```

### Custom Preview

```swift
section.onContextMenu { context in
    return .init(
        configuration: UIContextMenuConfiguration(
            identifier: nil,
            previewProvider: {
                // Return preview view controller
                let vc = DetailViewController()
                vc.model = context.model
                return vc
            },
            actionProvider: { _ in
                UIMenu(title: "", children: [/* actions */])
            }
        ),
        highlightPreview: /* custom preview */,
        dismissalPreview: /* custom preview */
    )
}
```

### Nested Menus

```swift
section.onContextMenu { context in
    let editMenu = UIMenu(
        title: "Edit Options",
        children: [
            UIAction(title: "Quick Edit") { _ in },
            UIAction(title: "Full Edit") { _ in }
        ]
    )
    
    let shareMenu = UIMenu(
        title: "Share Options",
        children: [
            UIAction(title: "Share as Link") { _ in },
            UIAction(title: "Share as Image") { _ in }
        ]
    )
    
    return .init(
        configuration: UIContextMenuConfiguration(
            identifier: nil,
            previewProvider: nil,
            actionProvider: { _ in
                UIMenu(title: "", children: [editMenu, shareMenu])
            }
        )
    )
}
```

### Clearing Context Menus

```swift
section.clearContextMenuActions()
```

## Layout Plugins

For advanced layout customization beyond basic spacing, use layout plugins.

See **[Layout Plugins](layout-plugins.md)** for detailed documentation on:
- Waterfall layouts
- Pinterest-style grids
- Custom flow layouts
- Sticky headers
- And more

## Performance Optimization

### High Performance Mode

For large datasets, enable high performance caching:

```swift
section.highPerformance = .init()
section.highPerformanceID = { context in
    return context.model.id
}
```

### Skip Display Events

For very large data changes:

```swift
section.feature.skipDisplayEventWhenFullyRefreshed = true
```

### Fixed Size Optimization

If all cells have the same size:

```swift
section.feature.highestItemSize = CGSize(width: 100, height: 100)
```

See **[Performance](performance.md)** for comprehensive optimization techniques.

## Related Documentation

- **[Section Overview](section.md)** - Core concepts and creation
- **[Events & Actions](section-events.md)** - Handle cell interactions
- **[Data Operations](section-data-operations.md)** - Working with section data
- **[Reactive Programming](reactive.md)** - Advanced Combine patterns
- **[Performance](performance.md)** - Optimization techniques
