# Production Tips

This reference contains practical SectionUI tips distilled from repeated use in large apps. Keep every item generic: no downstream project paths, module names, business names, or source-file indexes.

## Section Composition

1. Prefer a section factory method when a screen has many optional modules:

```swift
func makeContentSection(_ model: Model) -> SKCSectionProtocol? {
    guard model.isVisible else { return nil }
    return Cell.wrapperToSingleTypeSection(model.items)
}
```

This keeps `manager.reload(sections)` readable and makes empty-state handling explicit.

2. Build the final section array before deriving layout plugins or decorations.

```swift
let sections = modules.compactMap(makeSection)
let decorations = sections.map { SKCollectionFlowLayout.Decoration(sectionIndex: .init($0), viewType: CardBackgroundView.self) }
manager.reload(sections)
sectionView.set(pluginModes: [.decorations(decorations)])
```

Avoid decoration indexes based on pre-filtered arrays.

3. Use `SKCSectionProtocol` for composition boundaries, but keep concrete section properties when you need incremental updates.

```swift
private let listSection = ItemCell.wrapperToSingleTypeSection()
private var dynamicSections: [SKCSectionProtocol] = []
```

4. If a section returns `nil`, that should mean "not rendered". If it renders an empty UI, use an explicit empty section.

5. Group small view-only rows as `SKWrapperView` sections instead of creating new cell types for labels, spacers, dividers, images, and simple buttons.

## Section API Choice

6. Use fluent `SKCSingleTypeSection` for homogeneous lists. Subclass only when the section owns persistent behavior: selection sequence, diff application, custom size cache, multi-cell dispatch, or a reusable render contract.

7. For "single optional model" screens, wrap a raw section in a render object:

```swift
final class OptionalSection<Cell: UICollectionViewCell & SKLoadViewProtocol & SKConfigurableView> {
    var model: Cell.Model?
    let rawSection = Cell.wrapperToSingleTypeSection()

    var render: SKCSectionProtocol? {
        guard let model else { return nil }
        rawSection.config(models: [model])
        return rawSection
    }
}
```

8. For mixed cell types inside one logical section, implement `SKCSectionProtocol` directly. Do this when rows share a layout contract, cache, exposure state, or domain ordering that would be awkward as separate sections.

9. For a reusable group of several sections, return `[SKCSectionProtocol]` from a helper instead of hiding multiple visual groups inside one section.

## Safe Size And Layout

10. `safeSize(_:)` controls the section's base measuring area. `cellSafeSize(_:)` controls the `limit` passed into `Cell.preferredSize(limit:model:)`. Use both deliberately.

11. Use `.safeSize(\.fixedWidth)` or an equivalent integration-level provider for tablet/centered layouts. Keep section insets and width clamping in the size provider, not scattered in each cell.

12. Use `cellSafeSize(.fraction(...))` for grids. It accounts for `minimumInteritemSpacing` and produces stable item widths.

```swift
section
    .cellSafeSize(.fraction(1.0 / 3.0), transforms: .fixed(height: 36))
    .setSectionStyle([\.minimumLineSpacing, \.minimumInteritemSpacing], 8)
```

13. Use `cellSafeSize(.fixed(...))` for horizontal cards when all items should share the same measurement envelope.

14. Use `cellSafeSize(.default, transforms: ...)` when the width should follow the section but height or aspect ratio is fixed.

15. If a custom section caches sizes, invalidate only the affected model ID before `refresh(at:)`.

```swift
let limit = safeSizeProvider.size(context: .cell(at: row, in: section))
highPerformance.remove(by: id, limit: limit)
refresh(at: [row])
```

16. Call `prepareForReuse`-style cache cleanup when replacing the entire model array in a custom section.

## Supplementary Views

17. Prefer `setHeader` / `setFooter` for constant models and `set(supplementary:type:model:)` with a closure for dynamic models.

```swift
section.set(supplementary: .header, type: HeaderView.self, model: { [weak store] in
    store?.headerModel
})
```

The closure form keeps header size and config in sync with the latest state.

18. Use `remove(supplementary:)` when the header/footer truly disappears. Do not return a zero-height model unless the reusable view must remain registered and participate in layout.

19. Use `onSupplementaryAction(.willDisplay)` for header/footer exposure, not cell `willDisplay`.

20. If a decoration or plugin changes supplementary size/insets, pair it with the relevant section attributes such as fixed supplementary sizing or reversed header/footer inset handling.

## Decorations And Plugins

21. Apply card backgrounds as decorations instead of making every cell draw the same rounded background.

22. If a decoration should cover a group, attach it to the first section that represents the group and tune decoration insets. If it should cover each section independently, derive one decoration per section.

23. Avoid mixing sticky/pin APIs from different layout systems on the same section. Choose either SectionUI pin options or the flow-layout plugin path for that screen.

24. Use decoration `willDisplay` only for decoration-specific effects. Use section/cell exposure APIs for business events.

## Events And Exposure

25. Multiple `onCellAction(.selected)` registrations can be useful when separating navigation and analytics, but keep each closure focused. If ordering matters, combine them into one closure.

26. Use `onCellAction(on: self, ...)` and `setCellStyle(on: self, ...)` helpers when available. They make the weak-owner contract explicit.

27. Use `.onCellAction(.willDisplay)` for simple one-time viewport hooks where a separate display counter is not needed.

28. Use `model(displayedAt: .first)` for first exposure per model row.

29. Use `model(displayedAt: 2)` or array/predicate forms when repeated exposure has meaning.

```swift
section.model(displayedAt: [1, 3, 5]) { context in
    trackRepeatedExposure(context.model, row: context.row)
}
```

30. Reset `displayedTimes` when reusing an embedded collection section for a new parent model; otherwise nested exposure can be suppressed by stale counters.

31. When logging row indexes, use `context.row` from the action context, not a captured loop index.

## Selection

32. Put selection state in the model via `SKSelectionProtocol` when cells render selected/unselected states.

33. Use `SKSelectionWrapper` when the domain model should stay immutable or shared across flows.

34. Use `SKSelectionIdentifiableSequence` when stable identity matters more than current row offset.

35. Keep a `SKSelectionSequence` next to the section and reload it whenever section models are replaced.

```swift
section.config(models: models)
selection.reload(section.models)
selection.select(at: 0)
```

36. Subscribe to `itemChangedPublisher.filter(\.element.isSelected)` for selection-driven scrolling or page switching.

37. For reusable selected sections, own the sequence inside a section subclass and override `item(selected:)` so controllers do not duplicate selection mechanics.

## Reactive State

38. Use `@SKPublished(kind: .passThrough)` for events and `@SKPublished` default current-value mode for state.

39. Prefer `bind` when UI must render the current value immediately; prefer `sink` when only future changes matter.

40. Use transforms at the property boundary:

```swift
@SKPublished(transform: [.removeDuplicates(), .receiveOnMainQueue()])
var state: State = .idle
```

41. `SKPublishedValue<T>` is a useful model field for child views/cells that should observe a value without replacing the whole section model.

42. Use `replace(...)`-style APIs to inject a shared `SKPublishedValue` into reusable controls.

43. Use `SKAnimationBox<Value>` when a state change needs to carry both the new value and animation/delegate behavior.

```swift
@SKPublished var selection: SKAnimationBox<Int> = 0
selection = .init(value: index, animation: true, isEnabled: false)
```

44. Clear old cancellables before rebinding a section or manager to a new data source.

## Incremental Updates

45. Use `config(models:)` for full replacement and `append`, `insert`, `delete`, `delete(where:)`, or `refresh(at:)` for local changes.

46. For diffable behavior, keep it in a small reusable section wrapper that computes `CollectionDifference` and performs `delete` / `insert` inside `pick { ... }`.

47. Use `pick { ... }` when several section mutations should be batched as one collection update.

48. After deleting a model from external state, also delete it from the displayed section or re-render the section from the source of truth. Do not let them diverge.

49. For a custom section with derived view models, update both raw models and derived cell models before calling `refresh(at:)`.

## Nested Sections

50. Use `wrapperToHorizontalSection(height:insets:style:)` for a simple horizontal row made from one child section.

51. Use `SKCSectionViewCell.Model` when the embedded collection owns multiple child sections or needs a custom size closure.

52. Configure the nested `SKCollectionView` through the `style` closure: scroll direction, indicators, insets, background, and plugin modes belong there.

53. In nested collection cells, reset child section exposure state when the parent model changes.

54. Compute parent cell height from child cell models before configuring child sections when every horizontal card must align to the tallest item.

## Styling

55. Use `setCellStyle` for row-dependent visual rules such as separators, selected backgrounds, rounded first/last rows, and hidden trailing separators.

56. Prefer reusable `SKCCellStyle` factories for separator and corner-radius conventions. Give styles stable IDs when duplicate application should replace previous style.

57. Use `setSectionStyle([\.minimumLineSpacing, \.minimumInteritemSpacing], value)` for shared spacing. It is easier to scan than two separate calls when values are identical.

58. Keep card background, cell corner radius, and separators as separate concerns: decoration for group background, `setCellStyle` for per-row shape/separator.

## When To Add A Framework API

59. Add to SectionUI only when the primitive is UI-framework-level and reusable across independent products.

60. Keep app/design-system conveniences outside SectionUI when they encode brand spacing, colors, product-specific decorations, or business-specific actions.

61. Before adding a new abstraction, check if it can be expressed as:

- a `SKCSingleTypeSection` fluent chain
- a reusable `SKCCellStyle`
- a small `SKCSectionProtocol` wrapper
- an integration-level helper around `safeSize`
- a `SKPublishedValue` injected into a reusable view

Only promote it when those options create repeated friction.
