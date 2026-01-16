# Section Management (SKCSingleTypeSection)

`SKCSingleTypeSection` is the most commonly used section type. It manages a homogenous list of data driven by a specific Cell type.

## Creation

Use the fluent API extension on your Cell type to create a section instance:

```swift
let section = MyCell.wrapperToSingleTypeSection()
```

## Configuration

### Setting Data
```swift
let models = [MyCell.Model(title: "A"), MyCell.Model(title: "B")]
section.config(models: models)
```

### Handling Actions (Event Subscription)
You can subscribe to cell lifecycle and interaction events directly on the section.

```swift
section
    // Selection
    .onCellAction(.selected) { context in
        print("Selected index: \(context.indexPath.item)")
        print("Model: \(context.model)")
    }
    // Display
    .onCellAction(.willDisplay) { context in
        // Track impression
    }
```

## Advanced Usage

### 1. Headers & Footers
You can easily add headers and footers to your section.

```swift
class MyHeader: UICollectionReusableView, SKLoadViewProtocol, SKConfigurableView { ... }

section
    .setHeader(MyHeader.self, model: "Header Title")
    .setFooter(MyFooter.self, model: "Footer Text")
```

### 2. Cell Styling
You can apply global styles to all cells in the section without modifying the cell code itself.

```swift
section.setCellStyle { context in
    context.view.backgroundColor = .red
    context.view.layer.cornerRadius = 8
}
```

### 3. Reactive Data Binding (Combine)
If you are using Combine, you can bind a publisher directly to the section.

```swift
// Assuming specific Model type
let publisher: AnyPublisher<[Model], Never> = ...

section.subscribe(models: publisher)
```

### 4. Drag & Drop
Enable drag and drop with a simple closure.

```swift
section.onCellShould(.canMove) { context in
    return true
}
```

### 5. Context Menu
Add context menus (long-press actions) easily.

```swift
section.onCellAction(.contextMenuConfiguration) { context in
    // Return UIContextMenuConfiguration
}
```

### 6. Decorations & Insets

#### Section Insets
Configure the padding around the section content.

```swift
section.setSectionInset(.init(top: 10, left: 10, bottom: 10, right: 10))
```

#### Decoration Views

Add background views or other visual elements to the section using the simplified API.

See **[Decorations](decorations.md)** for detailed documentation.
