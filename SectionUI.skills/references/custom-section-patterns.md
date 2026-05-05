# Custom Section Patterns

Use this reference when a feature cannot be expressed cleanly with `SKCSingleTypeSection`, wrapper views, nested sections, or section factories. Keep it generic: no downstream project paths, product names, business module names, source-file indexes, or scan statistics.

## When To Implement A Custom Section

1. Prefer `SKCSingleTypeSection` for one cell type and one model type.

2. Prefer multiple small sections when rows are visually separate modules and do not need shared ordering, cache, or selection behavior.

3. Implement `SKCSectionProtocol` directly when heterogeneous rows share one logical order, one section inset, one background decoration, one exposure policy, or one snapshot builder.

4. A custom section is justified when splitting into many sections would make row ordering, row indexes, or cross-row mutations harder to reason about.

5. Do not create a custom section only to avoid writing a small `SKConfigurableView` or wrapper cell. Use `wrapperToCollectionCell()` for that.

## Row Enum Shape

6. Model heterogeneous rows as an enum with associated view models.

```swift
final class MixedSection: SKCSectionProtocol, SKSafeSizeProviderProtocol {
    enum Row {
        case title(TitleCell.Model)
        case item(ItemCell.Model)
        case divider(DividerCell.Model)
    }

    var sectionInjection: SKCSectionInjection?
    lazy var safeSizeProvider = defaultSafeSizeProvider
    private(set) var rows: [Row] = []

    var itemCount: Int { rows.count }
}
```

7. Keep enum cases named by UI role, not by business source. This makes the section reusable when the same row shape appears elsewhere.

8. Store already-rendered row view models in the enum. Avoid doing network/domain transformation in `item(at:)` or `itemSize(at:)`.

9. Keep row building in a `reload(model:)`, `render(_:)`, or snapshot builder method. The UICollectionView callbacks should only read the prepared rows.

10. If several enum cases share the same cell type, keep them as separate cases only when behavior or sizing differs.

11. Use a separate raw model array only when the section must map between domain objects and rendered rows for refresh, deletion, exposure, or selection.

## Required Protocol Surface

12. A direct `SKCSectionProtocol` implementation must provide `sectionInjection`, `itemCount`, `config(sectionView:)`, `itemSize(at:)`, and `item(at:)`.

13. Conform to `SKSafeSizeProviderProtocol` when size calculations need the default safe-size provider.

14. Conform to `SKCSectionLayoutPluginProtocol` when this custom section owns decorations, attribute fixes, pinning, or alignment plugins.

15. Register every possible cell type in `config(sectionView:)`. Do not lazily register from `item(at:)`.

16. Register supplementary views in `config(sectionView:)` if the section returns custom headers or footers.

17. Use `dequeue(at:for:)` or typed `dequeue(at:)` so the failure mode stays close to SectionUI's registration/dequeue helpers.

18. Keep `itemCount` derived from the rendered row list. Do not let it depend on a separate source that can diverge from `item(at:)`.

## Sizing

19. Use `safeSizeProvider.size` as the base limit for custom row sizing unless the section intentionally owns a different safe-size contract.

20. Keep `itemSize(at:)` and `item(at:)` switching over the same enum cases in the same order. If they drift, cells and sizes become inconsistent.

21. For repeated fixed rows such as dividers or spacers, return constant sizes directly instead of asking Auto Layout.

22. For expensive dynamic rows, add a small section-owned size cache keyed by row identity and limit size, or reuse `SKHighPerformanceStore`.

23. Invalidate only affected cached rows when an expandable row, remote image ratio, or dynamic text changes.

24. If a custom section supports grid-like rows, centralize column width math in a helper and use the same helper from every relevant enum case.

25. Do not read visible cells to calculate size. Size must be derivable from model plus safe-size limit.

## Cell Configuration

26. `item(at:)` should dequeue, configure, apply any row-local style, and return the cell. Keep side effects such as logging out of configuration.

27. Use row enum helpers when switch blocks become large.

```swift
private extension MixedSection.Row {
    var reuseCell: (UICollectionViewCell.Type) { ... }
}
```

28. Avoid force-unwrapping domain data in `item(at:)`. The row enum should already represent only renderable states.

29. If a row owns a callback closure, store the closure in the row view model only when the closure is UI-local and captures weakly. Prefer section-level event dispatch for navigation and analytics.

30. For nested collection rows, reset the child section or child manager when the parent row model changes.

## Events

31. Override `item(selected:)` for row-specific selection behavior in a custom section.

32. Convert row selection into a typed section event or delegate call instead of exposing raw row indexes to the controller.

33. If the custom section also needs generic `onCellAction`-style chaining, wrap actions in your own small event group rather than mixing unrelated callbacks into cells.

34. Keep exposure updates in `item(willDisplay:row:)` and end-display cleanup in `item(didEndDisplaying:row:)` when implementing those hooks.

35. If the section has row enum cases that are not business-visible, explicitly exclude them from exposure and analytics.

36. Use `indexPath(from:)`, `cellForItem(at:)`, and layout attribute helpers from `SKCSectionActionProtocol` rather than reconstructing index paths manually.

## Updates

37. Give the custom section a single render method that replaces the row snapshot and calls `reload()` or a targeted update.

38. Use `refresh(at:)` only after the row payload has already been updated.

39. For row replacement, update the row in the snapshot first, then call `refresh(at:)`.

40. For insert/delete, mutate the snapshot inside the same operation that performs collection updates. Avoid changing rows before a later unrelated reload.

41. If row indexes after deletion affect separator, corner, or grouping style, reload the trailing affected rows after delete.

42. For diff-like custom sections, compute a `CollectionDifference` over stable row identities and apply inserts/deletes inside `pick { ... }`.

43. When enum rows contain associated values, define a stable `identity` property for diffing. Do not diff by the whole enum unless all associated values are identity.

44. Keep raw domain state and rendered row state synchronized after user actions such as reorder, delete, toggle, or inline edit.

## Supplementary Views

45. Use header/footer supplementary views for structural section chrome. Use row enum cases for content that should participate in normal row ordering.

46. Return `.zero` header/footer size when the supplementary view is absent. Do not return a reusable view without a matching positive size.

47. If a custom section has empty-state headers or footers, make the empty behavior explicit with a property or render state.

48. Register custom supplementary kinds with `SKSupplementaryKind.custom` only when the layout plugin or layout system expects that kind.

## Snapshot Builders

49. Use a nested snapshot/builder type when row construction has many conditional branches.

```swift
struct Snapshot {
    var rows: [MixedSection.Row] = []

    mutating func appendTitle(_ model: TitleCell.Model?) {
        guard let model else { return }
        rows.append(.title(model))
    }
}
```

50. Keep snapshot builders pure: input model in, rows out. The section then owns applying those rows to the collection.

51. Use snapshot builders to group spacing, divider, and header decisions near the rows they affect.

52. Avoid hidden index constants in snapshot builders. If a controller must jump to a row, expose a typed lookup such as `row(for:)`.

53. When a row can be absent, expose optional row lookup rather than assuming fixed offsets.

54. Keep snapshot builder names generic enough to survive copy/paste across features.

## API Boundary

55. If a custom section pattern repeats across unrelated screens, extract a reusable section wrapper.

For wrappers around one underlying `SKCSingleTypeSection`, prefer the raw-section wrapper contract in `raw-section-wrapper-recipes.md` before implementing a direct mixed-row section.

56. If the pattern encodes brand spacing, product copy, or business actions, keep it outside SectionUI.

57. If the pattern is a generic heterogeneous section primitive, consider adding a framework-level helper only after multiple independent implementations show the same contract.

58. Before promoting a custom section into the framework, check whether `SKCSectionCollector`, multiple `SKCSingleTypeSection`s, `SKWrapperView`, or `SKCSectionViewCell` already expresses it with less surface area.
