# Section Events & Actions

This guide covers how to handle cell lifecycle events and user interactions in `SKCSingleTypeSection`.

## Event Subscription with onCellAction

You can subscribe to cell lifecycle and interaction events directly on the section using `onCellAction`.

### Available Event Types

- `.selected` - Cell was tapped/selected
- `.deselected` - Cell was deselected
- `.willDisplay` - Cell is about to appear on screen
- `.didEndDisplay` - Cell has disappeared from screen
- `.config` - Cell configuration completed

### Context Properties

The `CellActionContext` provides access to:
- `section`: Reference to the parent section
- `type`: The action type that triggered this callback
- `model`: The data model for this cell
- `row`: The row index (Int)
- `indexPath`: The full IndexPath
- `view()`: Method to access the actual cell view

## Basic Usage

### Handling Selection

```swift
section.onCellAction(.selected) { context in
    print("Selected index: \(context.indexPath.item)")
    print("Model: \(context.model)")
    
    // Access the actual cell view if needed
    let cell = context.view()
    cell.backgroundColor = .systemBlue
}
```

### Tracking Display Events

```swift
section
    // Track when cells appear
    .onCellAction(.willDisplay) { context in
        print("Cell \(context.row) will display")
        // Perfect for analytics/impression tracking
    }
    
    // Clean up when cells disappear
    .onCellAction(.didEndDisplay) { context in
        print("Cell \(context.row) ended display")
        // Cancel pending operations, release resources
    }
```

### Handling Deselection

```swift
section.onCellAction(.deselected) { context in
    let cell = context.view()
    cell.backgroundColor = .clear
}
```

### Post-Configuration Hook

```swift
section.onCellAction(.config) { context in
    // Called after cell.config(model) completes
    // Useful for additional setup that depends on configured state
}
```

## Data Manipulation in Events

The context provides helper methods for common operations:

```swift
section.onCellAction(.selected) { context in
    // Reload this specific cell with updated model
    context.reload()
    
    // Update with a new model
    let updatedModel = MyCell.Model(title: "Updated")
    context.refresh(with: updatedModel)
    
    // Remove this cell from the section
    context.remove()
    
    // Insert new items
    context.insert(after: newModel)
    context.insert(before: [model1, model2])
}
```

## Async Handling

For async operations, use `onAsyncCellAction`:

```swift
section.onAsyncCellAction(.selected) { context in
    await downloadData(for: context.model)
    context.reload()
}
```

## Weak Reference Pattern

To avoid retain cycles when capturing `self`:

```swift
section.onCellAction(on: self, .selected) { strongSelf, context in
    strongSelf.handleSelection(model: context.model)
}
```

**Why this matters:**

```swift
// ❌ Wrong - Creates retain cycle
section.onCellAction(.selected) { context in
    self.handleSelection(model: context.model)  // Captures self strongly
}

// ✅ Correct - Uses weak reference
section.onCellAction(on: self, .selected) { strongSelf, context in
    strongSelf.handleSelection(model: context.model)
}
```

## Chaining Multiple Actions

You can chain multiple action subscriptions:

```swift
section
    .onCellAction(.selected) { context in
        print("Selected: \(context.model)")
    }
    .onCellAction(.willDisplay) { context in
        print("Will display: \(context.row)")
    }
    .onCellAction(.didEndDisplay) { context in
        print("Did end display: \(context.row)")
    }
```

## Managing Event Handlers

### Clearing Actions

Remove all registered actions for a specific type:

```swift
section.clearCellAction(.selected)
```

This is useful when you need to:
- Reset event handlers dynamically
- Clean up before reconfiguring a section
- Change behavior based on state

## Common Patterns

### Analytics Tracking

```swift
section.onCellAction(.willDisplay) { context in
    Analytics.trackImpression(
        item: context.model.id,
        position: context.row
    )
}
```

### Conditional Actions

```swift
section.onCellAction(.selected) { context in
    guard context.model.isEnabled else { return }
    
    // Handle selection only for enabled items
    context.section.navigate(to: context.model)
}
```

### State Management

```swift
section.onCellAction(.selected) { context in
    // Toggle selection state
    var updatedModel = context.model
    updatedModel.isSelected.toggle()
    
    // Update the cell
    context.refresh(with: updatedModel)
}
```

### Resource Cleanup

```swift
section.onCellAction(.didEndDisplay) { context in
    // Cancel any pending operations
    ImageLoader.shared.cancel(for: context.model.imageURL)
    
    // Clear cached data
    context.view().clearCachedContent()
}
```

## Event Lifecycle

Understanding when events fire:

1. **`.config`** - Fired after `cell.config(model)` is called
2. **`.willDisplay`** - Fired just before cell appears on screen
3. **`.selected`** - Fired when user taps the cell
4. **`.deselected`** - Fired when cell loses selection
5. **`.didEndDisplay`** - Fired after cell disappears from screen

## Performance Considerations

- Event handlers are called synchronously on the main thread
- Avoid heavy computation in event handlers
- Use `.willDisplay` for lazy loading, not `.config`
- Use `.didEndDisplay` to cancel pending operations

## Related Documentation

- **[Section Overview](section.md)** - Core concepts and creation
- **[Data Operations](section-data-operations.md)** - Working with section data
- **[Best Practices](section-best-practices.md)** - Recommended patterns
