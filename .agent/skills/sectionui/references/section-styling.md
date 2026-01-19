# Section Styling & Supplementary Views

This guide covers how to customize cell appearance and add headers/footers to sections.

## Cell Styling

Apply global styles to all cells without modifying cell implementation.

### Basic Styling

```swift
section.setCellStyle { context in
    context.view.backgroundColor = .systemGray6
    context.view.layer.cornerRadius = 8
    context.view.layer.masksToBounds = true
}
```

### Context-Aware Styling

The `SKCCellStyleContext` provides access to cell state:

```swift
section.setCellStyle { context in
    // Access model data
    if context.model.isImportant {
        context.view.backgroundColor = .systemYellow
    }
    
    // Access row index
    if context.row % 2 == 0 {
        context.view.backgroundColor = .systemGray6
    }
    
    // Access section reference
    context.section.sectionInset = .init(top: 10, left: 10, bottom: 10, right: 10)
}
```

### Using KeyPath for Simple Styles

```swift
section.setCellStyle(\.view.backgroundColor, .systemBlue)
```

### Chaining Multiple Styles

Styles are applied in order:

```swift
let baseStyle = SKCCellStyle<MyCell> { context in
    context.view.layer.cornerRadius = 8
}

section
    .setCellStyle(baseStyle)
    .setCellStyle { context in
        // Additional styling
        context.view.layer.borderWidth = 1
    }
```

### Weak Reference Pattern

Avoid retain cycles when capturing self:

```swift
section.setCellStyle(on: self) { strongSelf, context in
    context.view.backgroundColor = strongSelf.cellBackgroundColor
}
```

## Headers & Footers

Add header and footer views to your section with automatic size calculation.

### Basic Setup

```swift
class MyHeader: UICollectionReusableView, SKLoadViewProtocol, SKConfigurableView {
    typealias Model = String
    
    static func preferredSize(limit: CGSize, model: Model) -> CGSize {
        return CGSize(width: limit.width, height: 44)
    }
    
    func config(_ model: Model) {
        // Configure header with model
    }
}

section
    .setHeader(MyHeader.self, model: "Header Title")
    .setFooter(MyFooter.self, model: "Footer Text")
```

### Dynamic Header/Footer Models

Use closures for dynamic content:

```swift
var headerTitle = "Initial Title"

section.set(supplementary: .header, type: MyHeader.self, model: {
    return headerTitle  // Re-evaluated on each layout
})

// Update and reload
headerTitle = "Updated Title"
section.reload()
```

### Header/Footer Events

Subscribe to supplementary view lifecycle events:

```swift
section
    .onSupplementaryAction(.willDisplay) { context in
        print("Supplementary kind: \(context.kind)")  // .header or .footer
        let view = context.view()
        // Customize display
    }
    .onSupplementaryAction(.didEndDisplay) { context in
        // Clean up resources
    }
```

### Removing Supplementary Views

```swift
section.remove(supplementary: .header)
section.remove(supplementary: MyHeader.self)
```

### Auto-hiding Empty Sections

Control visibility when section has no items:

```swift
section.hiddenHeaderWhenNoItem = true  // Default: true
section.hiddenFooterWhenNoItem = true  // Default: true
```

## Layout Configuration

### Section Insets

Configure padding around the section content:

```swift
section.sectionInset = UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16)

// Or use fluent API
section.setSectionInset(.init(top: 10, left: 16, bottom: 10, right: 16))
```

### Item Spacing

Control spacing between cells:

```swift
// Vertical spacing (for vertical layouts)
section.minimumLineSpacing = 10

// Horizontal spacing (for horizontal/grid layouts)
section.minimumInteritemSpacing = 10
```

### Decoration Views

Add background views or other visual elements to the section using the simplified API.

See **[Decorations](decorations.md)** for detailed documentation on background decorations, borders, and custom decoration views.

## Common Styling Patterns

### Alternating Row Colors

```swift
section.setCellStyle { context in
    context.view.backgroundColor = context.row % 2 == 0 
        ? .systemGray6 
        : .white
}
```

### Conditional Highlighting

```swift
section.setCellStyle { context in
    if context.model.isNew {
        context.view.layer.borderColor = UIColor.systemBlue.cgColor
        context.view.layer.borderWidth = 2
    }
}
```

### Dynamic Theme Support

```swift
section.setCellStyle(on: self) { strongSelf, context in
    let isDarkMode = strongSelf.traitCollection.userInterfaceStyle == .dark
    context.view.backgroundColor = isDarkMode ? .black : .white
}
```

### Accessibility Styling

```swift
section.setCellStyle { context in
    context.view.isAccessibilityElement = true
    context.view.accessibilityLabel = context.model.title
    context.view.accessibilityTraits = .button
}
```

## Header/Footer Patterns

### Section Title Header

```swift
class SectionTitleHeader: UICollectionReusableView, SKLoadViewProtocol, SKConfigurableView {
    typealias Model = String
    
    private let titleLabel = UILabel()
    
    static func preferredSize(limit: CGSize, model: Model) -> CGSize {
        return CGSize(width: limit.width, height: 44)
    }
    
    func config(_ model: Model) {
        titleLabel.text = model
        titleLabel.font = .preferredFont(forTextStyle: .headline)
    }
}

section.setHeader(SectionTitleHeader.self, model: "Products")
```

### Item Count Footer

```swift
class ItemCountFooter: UICollectionReusableView, SKLoadViewProtocol, SKConfigurableView {
    typealias Model = Int
    
    private let countLabel = UILabel()
    
    static func preferredSize(limit: CGSize, model: Model) -> CGSize {
        return CGSize(width: limit.width, height: 30)
    }
    
    func config(_ model: Model) {
        countLabel.text = "\(model) items"
    }
}

section
    .config(models: items)
    .setFooter(ItemCountFooter.self, model: items.count)
```

### Void Model Headers

For headers that don't need data:

```swift
class DividerHeader: UICollectionReusableView, SKLoadViewProtocol, SKConfigurableView {
    typealias Model = Void
    
    static func preferredSize(limit: CGSize, model: Model) -> CGSize {
        return CGSize(width: limit.width, height: 1)
    }
    
    func config(_ model: Model) {
        backgroundColor = .separator
    }
}

section.set(supplementary: .header, type: DividerHeader.self)
```

## Performance Tips

- Keep style closures lightweight - they're called for every cell
- Use KeyPath syntax for simple property assignments
- Avoid creating new objects in style closures
- Cache complex calculations outside the closure

## Related Documentation

- **[Section Overview](section.md)** - Core concepts and creation
- **[Events & Actions](section-events.md)** - Handle cell interactions
- **[Decorations](decorations.md)** - Advanced decoration views
- **[Best Practices](section-best-practices.md)** - Recommended patterns
