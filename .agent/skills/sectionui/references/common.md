---
name: sectionui-common
description: Master skill for universal utilities in SectionUI, covering View Wrapping, Reactive Bindings, and Conditional Logic.
---

# sectionkit-common (Master)

Use this skill for general-purpose SectionUI utilities that apply across all section types.

## 1. Universal View Wrapper (SKWrapperView)
Turn **any** `UIView` into a `SKConfigurableView` (Cell/Header/Footer compatible) without subclassing or creating new files.

### Basic Usage
### Basic Usage
```swift
// 1. Define a Configurable View
class ConfigurableLabel: UILabel, SKConfigurableView {
    typealias Model = String
    func config(_ model: String) { text = model }
}

// 2. Wrap it in a Cell using SKCWrapperCell
// SKCWrapperCell<T> wraps a T (UIView) into a UICollectionViewCell
let section = SKCWrapperCell<ConfigurableLabel>.wrapperToSingleTypeSection(["Hello", "World"])
```

### Protocol Conformance (Recommended)
If your view already conforms to `SKConfigurableView`, `SKWrapperView` automatically uses its `config` method.

```swift
class MyView: UIView, SKConfigurableView { ... }

// No styling block needed, uses MyView.config internally
let section = SKCSingleTypeSection<SKWrapperView<MyView, MyView.Model>>()
```

## 2. Reactive Bindings (SKBinding)
A lightweight, Combine-based property wrapper for two-way data binding. Similar to SwiftUI's `@Binding`.

### Creating Bindings
```swift
// 1. Constant
let binding = SKBinding.constant("Value")

// 2. From KeyPath (Reference types only)
let binding = SKBinding(on: self, keyPath: \.title)

// 3. From Combine Subject
let subject = CurrentValueSubject<String, Never>("Start")
let binding = SKBinding(subject)
```

### Observing Changes
```swift
binding.changedPublisher.sink { newValue in
    print("Value changed to: \(newValue)")
}.store(in: &cancellables)
```

## 3. Conditional Logic (SKWhen)
Build type-safe, chainable filtering logic. Useful for filtering models or handling business rules.

### Basic Filtering
```swift
let isAdult = SKWhen<User> { $0.age >= 18 }
let hasLicense = SKWhen<User> { $0.hasLicense }

// Combine Logic
let canDrive = isAdult.and(hasLicense)

// Use
let eligibleUsers = users.filter(canDrive.isIncluded)
```

### KeyPath Comparators
```swift
let isActive = SKWhen.equal(\User.status, .active)
let isHighScorer = SKWhen.compare(\User.score, 100, >)
```

## 4. Enhanced Publishing (SKPublished)
A supercharged version of `@Published` that supports initialization transforms, side-effects, and `weak` assignment.

### Basic Usage
```swift
class ViewModel {
    @SKPublished var count: Int = 0
}

// Observe (Automatic main thread receive)
viewModel.$count.bind { value in
    print("Value: \(value)")
}.store(in: &cancellables)
```

### With Transforms
Apply Combine operators directly at the property definition level.

```swift
@SKPublished(transform: [
    .removeDuplicates(),
    .filter { $0 > 0 },
    .dropFirst()
]) 
var data: [String] = []
```

### Weak Assignment
Avoid memory leaks when assigning to `self`.

```swift
$count.assign(onWeak: self, to: \.label.text)
```

