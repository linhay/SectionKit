---
name: sectionui-page
description: Master skill for memory-efficient paginated view management using SKPageViewController and SKPageManager.
---

# sectionkit-page (Master)

Use this skill to implement high-performance paginated controllers (like TikTok or Tabbed views). It provides bidirectional synchronization and smart memory management for children.

## 1. Core Implementation

### Standard Page View
```swift
import SectionUI

let controller = SKPageViewController()
controller.manager.spacing = 10
controller.manager.scrollDirection = .horizontal

// Define children using lazy initialization
controller.manager.setChilds([1, 2, 3].map { id in
    .init(id: "\(id)") { context in
        return MyChildController(id: id)
    }
})
```

## 2. Professional Features

### Reactive Selection Tracking
Sync the current page index with your Business Logic or UI (e.g. a Tab Bar).

```swift
controller.manager.$selection
    .removeDuplicates()
    .sink { index in
        print("Now showing page: \(index)")
    }.store(in: &controller.cancellables)
```

### Dynamic Page Management
Insert or delete pages on the fly without breaking current navigation.

```swift
// Append more pages
controller.manager.addChilds(newPages)

// Jump to specific page
controller.manager.select(index: 5, animated: true)
```

### Delayable Binding
Bind the manager later if the controller is being initialized asynchronously.

```swift
let manager = SKPageManager()
// ... configure manager ...
controller.bind(manager)
```

### View-Only Pages (Lightweight)
You don't always need a `UIViewController`. Pass a `UIView` maker directly.

```swift
controller.manager.addChild(
    .init(id: "view_page") { context in
        let view = UIView()
        view.backgroundColor = .red
        return view
    }
)
```

### Fluent Configuration
Configure the manager in a single chain before binding.

```swift
controller.manager
    .configure { mgr in
        mgr.scrollDirection = .vertical
        mgr.spacing = 20
    }
    .setChilds([page1, page2])
```


## Professional Tips
- **Memory Optimization**: `SKPageViewController` automatically manages children lifecycle. It keeps 3-5 pages in memory and deinits others to save resources.
- **Scrolling Style**: Toggle `isPagingEnabled` on the underlying scroll view for custom paging behavior.
- **Direction**: Supports both `.horizontal` and `.vertical` (ideal for feed-style videos).
- **Synchronization**: Use `controller.manager.$selection` to drive external UI elements like segment controls.
