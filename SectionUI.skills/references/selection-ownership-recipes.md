# Selection Ownership Recipes

Use this reference when a SectionUI task involves `SKSelectionState`, `SKSelectionProtocol`, `SKSelectionWrapper`, `SKSelectionSequence`, `SKSelectionIdentifiableSequence`, single selection, select-all controls, or selection state surviving reloads.

## Core Contract

`SKSelectionState` is a reference object. `SKSelectionWrapper` is a value wrapper around a raw model plus a selection state reference. Equality and hashing for `SKSelectionWrapper` use its `id`, not the wrapped value.

`SKSelectionProtocol` exposes:

- read-only `isSelected`,
- mutable `canSelect` and `isEnabled`,
- publishers for selected, can-select, enabled, and combined state changes,
- `toggle()` and `select(_:)`.

Change selected state through `select(_:)`, `toggle()`, or `selection.isSelected`; do not assign to `isSelected`.

## Wrapper Ownership

Use `SKSelectionWrapper` when the domain model should not own UI selection state.

```swift
struct Item {
    let id: String
    let title: String
}

let model = Item(id: "item-1", title: "Title")
let wrapper = SKSelectionWrapper(model, id: model.id)

wrapper.select(true)
wrapper.toggle()
```

Read the underlying model through `wrappedValue`, `rawValue`, or dynamic member lookup:

```swift
label.text = wrapper.title
let item = wrapper.wrappedValue
```

If the wrapped value conforms to `Identifiable` with `UUID` ID, the convenience initializer uses `value.id.uuidString` as the wrapper id. Otherwise pass an explicit id when identity must survive reloads.

## Cell Binding

Cells should cancel old selection subscriptions during reuse and bind to the current model.

```swift
final class SelectableCell: UICollectionViewCell, SKLoadViewProtocol, SKConfigurableView {
    typealias Model = SKSelectionWrapper<Item>

    private var cancellable: AnyCancellable?

    func config(_ model: Model) {
        cancellable?.cancel()
        label.text = model.title
        updateSelectionUI(model.isSelected)

        cancellable = model.selectedPublisher
            .sink { [weak self] isSelected in
                self?.updateSelectionUI(isSelected)
            }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        cancellable?.cancel()
        cancellable = nil
    }
}
```

After toggling a model from a cell action, refresh the affected row or let the cell's publisher update visible UI if no layout change is needed.

## SKSelectionSequence

Use `SKSelectionSequence` when row offset is the natural selection identity.

```swift
let sequence = section.selectionSequence(isUnique: true)

sequence.itemChangedPublisher
    .sink { change in
        section.refresh(at: change.offset)
    }
    .store(in: &cancellables)
```

Observation is lazy: `itemChangedPublisher` creates per-item subscriptions only when the publisher is first used. `reloadPublisher` is also lazy and emits only after it has been subscribed.

`section.selectionSequence(isUnique:)` subscribes to the section's model publisher and reloads the sequence whenever section models are replaced.

Manual `SKSelectionSequence.append(_:)`, `insert(at:_:)`, and `remove(at:)` mutate the store. If you need reliable per-item change callbacks after manual structural mutation, call `reload(_:)` with the final store or manage observation through the section-driven sequence.

When `isUnique == true`, `selectAll()` will not leave every item selected; uniqueness enforcement means only one item can remain selected. Use `isUnique: false` for real multi-select and select-all flows.

## SKSelectionIdentifiableSequence

Use `SKSelectionIdentifiableSequence` when stable ID matters more than row offset: filtering, sorting, reordering, or selection that spans multiple section renders.

```swift
let sequence = SKSelectionIdentifiableSequence(
    SKSelectionWrapper<Item>.self,
    id: \.id,
    isUnique: false
)

let wrapper = SKSelectionWrapper(item, id: item.id)
sequence.update(wrapper, by: \.id)
sequence.select(id: item.id)
```

`update(_:by:)` replaces the element for that ID and installs a selected-state subscription. `reload(_:)` clears all items and subscriptions before updating. `remove(id:)` clears both store and subscription for that ID.

`values` is created from dictionary values, so do not rely on its order for UI rendering. Keep a separate ordered model list for section display and use the identifiable sequence for selection ownership.

## Single vs Multiple Selection

- Use `isUnique: true` for radio-style selection.
- Use `isUnique: false` for checkbox-style multi-select.
- Use `canSelect = false` when an item cannot become selected.
- Use `isEnabled = false` when the entire selectable item should appear disabled and ignore user intent at the UI layer.

`select(true)` returns false when `canSelect` is false. `select(false)` always clears selection and returns true.

## Debug Checklist

- Cell shows stale selected state: cancel subscriptions in `prepareForReuse` and call `updateSelectionUI(model.isSelected)` before subscribing.
- Tap changes model but UI does not refresh: refresh the row or bind the cell to `selectedPublisher`.
- Select-all only leaves one item selected: sequence is unique; use `isUnique: false`.
- Selection changes stop after manual append: reload the sequence or use `section.selectionSequence(isUnique:)`.
- Selection lost after reload: preserve wrapper IDs and selection state references, or move ownership to `SKSelectionIdentifiableSequence`.
- ID-based selected order is unstable: do not render from dictionary-backed `values`; render from an ordered source.

## Framework Boundary

Keep selection guidance generic. Document state ownership, sequence identity, publisher lifecycle, reuse binding, and single/multi-select rules. Do not encode downstream permission rules, business statuses, page names, source paths, scan counts, or project indexes into the skill.
