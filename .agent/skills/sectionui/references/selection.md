---
name: sectionui-selection
description: Master skill for selection management, covering single/multiple selection, drag-to-select, and reactive state binding.
---

# sectionkit-selection (Master)

Use this skill to implement robust selection logic, from simple single-taps to complex drag-to-select multi-selection systems.

## 1. Core State Management

### Using SKSelectionSequence (Ordered)
Manage a sequence of models where selection state is tracked.

```swift
import SectionUI

// 1. Wrap models
let models = ["A", "B", "C"].map { SKSelectionWrapper($0) }

// 2. Initialize sequence (Single/Multiple)
let selection = SKSelectionSequence(models, selectMode: .single)

// 3. Bind to section
section.config(models: selection.models)
```

### Using SKSelectionIdentifiableSequence (ID-based)
Best for unordered lists or where persistence/ID identification is preferred.

```swift
let selection = SKSelectionIdentifiableSequence(models, 
                                                 selectMode: .multi, 
                                                 identifier: { $0.id })
```

## 2. UI Integration

### Reactive Cell Binding
Cells should subscribe to the `selectedPublisher` to update their visual state (e.g., background color).

```swift
final class MyCell: UICollectionViewCell, SKConfigurableView {
    typealias Model = SKSelectionWrapper<String>
    private var sub: AnyCancellable?
    
    func config(_ model: Model) {
        sub = model.selectedPublisher.sink { [weak self] isSelected in
            self?.contentView.backgroundColor = isSelected ? .blue : .gray
        }
    }
}
```

### Drag-to-Select (Master)
Enable "Rect" selection by dragging over cells.

```swift
class MyReducer: SKCRectSelectionDelegate {
    lazy var dragSelector = SKCDragSelector()
    
    func setup() {
        try? dragSelector.setup(collectionView: collectionView, 
                                 rectSelectionDelegate: self)
    }
    
    // Delegate methods
    func rectSelectionManager(_ manager: SKCRectSelectionManager, didUpdateSelection isSelected: Bool, for indexPath: IndexPath) {
        models[indexPath.row].select(isSelected)
    }
    
    func rectSelectionManager(_ manager: SKCRectSelectionManager, isSelectedAt indexPath: IndexPath) -> Bool {
        models[indexPath.row].isSelected
    }
}
```

## Professional Tips
- **Single vs Multiple**: Toggle `selection.selectMode` to change behavior dynamically.
- **Deselection**: Use `selection.deselectAll()` to reset state.
- **Lookup**: Use `selection.selectedModels` to get only the currently active data.
- **Persistence**: `SKSelectionIdentifiableSequence` is safer when the underlying list reorders or updates via Diff.
