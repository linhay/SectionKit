---
name: sectionui-cell
description: Master skill for scaffolding and configuring UICollectionViewCell with robust protocols (SKLoadViewProtocol, SKConfigurableView, SKLoadNibProtocol, SKAdaptive).
---

# sectionkit-cell (Master)

Use this skill to create production-ready cells that are highly compatible and performance-optimized across standard and adaptive layouts.

## 1. Scaffolding

### Programmatic View (Standard)
```swift
class MyCell: UICollectionViewCell, SKLoadViewProtocol, SKConfigurableView {
    typealias Model = <#ModelType#>
    
    static func preferredSize(limit size: CGSize, model: Model?) -> CGSize {
        return .init(width: size.width, height: 44)
    }

    func config(_ model: Model) {
        // Update UI
    }
}
```

### Adaptive SwiftUI (Professional)
```swift
final class MySwiftUICell: UICollectionViewCell, SKLoadViewProtocol, SKConfigurableAdaptiveMainView {
    typealias Model = <#ModelType#>
    
    func config(_ model: Model) {
        contentConfiguration = UIHostingConfiguration {
             <#SwiftUIView#>(model: model)
        }.margins(.all, 0)
    }
}
```

## 2. Advanced Techniques

### SKAdaptive (Auto-Sizing)
Use `SKAdaptive` to calculate height based on cell constraints or content.

```swift
static let adaptive = SKAdaptive(view: MyCell())

static func preferredSize(limit size: CGSize, model: Model?) -> CGSize {
    return adaptive.adaptiveHeightFittingSize(limit: size, model: model)
}
```

### Multi-View Protocol Support
Implement both code-based and NIB-based protocols for maximum flexibility.

```swift
class HybridCell: UICollectionViewCell, SKLoadNibProtocol, SKConfigurableView {
    // Falls back to class-based if XIB is missing
}
```

### View Wrapper (SKCWrapperCell)
Turn any `UIView` into a Cell without subclassing `UICollectionViewCell`.

```swift
// 1. View conforms to SKConfigurableView
class MyView: UIView, SKConfigurableView { ... }

// 2. Use SKCWrapperCell to wrap it
let section = SKCWrapperCell<MyView>.wrapperToSingleTypeSection(models)
```

## Professional Tips
- **Reuse Identifier**: Protocols automatically generate `static var identifier` from class name.
- **Layout Caching**: For complex cells, wrap size calculation in `sectionkit-section`'s `highPerformance.cache`.
- **SwiftUI Performance**: Always use `final` class for `SKConfigurableAdaptiveMainView` cells to optimize Swift dispatch.
- **Auto Layout**: Ensure your `contentView` constraints are robust if using `adaptiveHeightFittingSize`.
