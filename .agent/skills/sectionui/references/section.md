# Section Management (SKCSingleTypeSection)

`SKCSingleTypeSection` is the most commonly used section type. It manages a homogenous list of data driven by a specific Cell type.

## Overview

A section represents a group of cells in a collection view. Each section:
- Manages its own data models
- Controls cell layout and spacing
- Handles cell events and interactions
- Supports headers and footers
- Can be configured independently

## Creation

It is recommended to use the **`wrapperToSingleTypeSection()`** static method to create Section instances. This approach leverages Swift's type inference, resulting in cleaner code and easier method chaining.

```swift
// ✅ Recommended: Create directly from the Cell type
let section = MyCell.wrapperToSingleTypeSection()
```

> [!TIP]
> **When to Create a Custom Section Class?**
> 
> You only need to define a custom, independent Section class adhering to `SKCSectionProtocol` when **a single Section needs to contain multiple different types of Cells**. See [./examples/MixedCellsSectionTemplate.swift](MixedCellsSectionTemplate.swift) for reference.
> For the vast majority of list scenarios (homogenous lists driven by the same Cell type), using `wrapperToSingleTypeSection()` is sufficient and avoids extra boilerplate.


## Basic Configuration

### Setting Data

Configure your section with data models:

```swift
let models = [MyCell.Model(title: "A"), MyCell.Model(title: "B")]
section.config(models: models)
```

### Quick Setup Example

Here's a complete example of creating and configuring a section:

```swift
// Create section
let section = ProductCell.wrapperToSingleTypeSection()
    .config(models: products)
    .onCellAction(.selected) { context in
        print("Selected: \(context.model.name)")
    }

// Add to manager
manager.update([section])
```

## Key Concepts

### Type Safety

Sections are strongly typed to their cell type:

```swift
// This section only works with ProductCell
let section = ProductCell.wrapperToSingleTypeSection()
```

### Fluent API

Most configuration methods return `self`, enabling method chaining:

```swift
section
    .config(models: items)
    .setSectionInset(.init(top: 10, left: 10, bottom: 10, right: 10))
    .onCellAction(.selected) { context in
        // Handle selection
    }
```

### Type Erasure

When working with multiple section types, use `SKCSectionProtocol`:

```swift
let sections: [SKCSectionProtocol] = [
    HeaderCell.wrapperToSingleTypeSection(),
    ProductCell.wrapperToSingleTypeSection(),
    FooterCell.wrapperToSingleTypeSection()
]
```

## Related Documentation

- **[Events & Actions](section-events.md)** - Handle cell lifecycle and user interactions
- **[Styling & Supplementary Views](section-styling.md)** - Customize appearance, headers, and footers
- **[Advanced Features](section-advanced.md)** - Combine, drag & drop, context menus, and layout
- **[Advanced Features (Part 2)](section-advanced-2.md)** - Display tracking, cell refresh, prefetching, and more
- **[Data Operations](section-data-operations.md)** - CRUD operations and reload strategies
- **[Best Practices](section-best-practices.md)** - Recommended patterns and optimization tips

## See Also

- **[Cell Implementation](cell.md)** - How to create custom cells
- **[Manager](manager.md)** - Section collection management
- **[Performance](performance.md)** - Optimization techniques
- **[Reactive Programming](reactive.md)** - Advanced Combine integration
