---
name: sectionui-container-layout
description: Documentation for SectionUI containers, managers, and advanced layout orchestration.
---

# Section Management & Orchestration

While `SKCSingleTypeSection` defines individual sections, SectionUI provides several tools for managing these sections within a container and controlling the overall layout behavior.

## 1. Manager Capabilities (SKCManager)

The `SKCManager` is the brain of your collection view. It manages the lifecycle, section order, and updates.

### Section Updates
```swift
// Full Reload
manager.reload([sectionA, sectionB])

// Batch Updates
manager.insert(newSection, after: existingSection)
manager.append(footerSection)
```

### Safe Scrolling
```swift
manager.scroll(to: section, row: 0, at: .top, animated: true)
```

## 2. Advanced Layout Orchestration

### SKCollectionFlowLayout
Access the underlying flow layout for granular control.

```swift
if let layout = sectionView.collectionViewLayout as? SKCollectionFlowLayout {
    layout.sectionHeadersPinToVisibleBounds = true
}
```

### Layout Plugins (SKCLayoutPlugins)
Extend layout logic without subclassing.

```swift
// Apply a background view to all sections
SKCLayoutPlugins.layout.add(decoration: MyBackgroundView.self, insets: .zero)

// Align items
section.addLayoutPlugins(.left)
```

## 3. Containers & Hosting

### SKCollectionViewController
The standard UIViewController subclass for SectionUI.

```swift
class MyViewController: SKCollectionViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        manager.reload([section])
    }
}
```

### SwiftUI Integration
```swift
UIViewController.sk.toSwiftUI {
    SKCollectionViewController()
}
```

### Scroll Observers
Intercept scroll events safely.

```swift
manager.scrollObserver.add(scroll: "id") { handle in
    handle.scrollViewDidScroll = { _ in ... }
}
```

---

## See Also
- **[SKCSingleTypeSection](./single-type-section.md)**: Documentation for the most common section type.
