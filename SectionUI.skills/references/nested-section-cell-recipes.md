# Nested Section Cell Recipes

Use this reference when a SectionUI task involves `SKCSectionViewCell`, `SKCSingleSectionViewCell`, `wrapperToHorizontalSection`, embedded horizontal sections, section-in-cell patterns, nested collection lifecycle, or nested sizing. Keep it generic: no downstream project paths, product names, business module names, source-file indexes, scan statistics, page names, or business event names.

## Contents

- [When To Use](#when-to-use)
- [API Contracts](#api-contracts)
- [Sizing](#sizing)
- [Lifecycle And Reuse](#lifecycle-and-reuse)
- [State Ownership](#state-ownership)
- [Style And Layout](#style-and-layout)
- [Debug Checklist](#debug-checklist)
- [Framework Boundary](#framework-boundary)

## When To Use

1. Use `childSection.wrapperToHorizontalSection(height:insets:style:)` for a simple horizontal row made from one child section.

2. Use `SKCSectionViewCell.Model` when the embedded row owns multiple child sections, custom size logic, custom scroll direction, or collection-level style.

3. Use `SKCSingleSectionViewCell<Section>` when the parent section should expose a typed wrapper cell for one known child section type.

4. Use `SKPageManager` / `SKPageViewController` when the UI is controller-level paging with child view controllers. Do not use nested section cells for page-controller lifecycles.

5. Avoid vertical nested scrolling inside vertical scrolling unless the interaction is explicitly designed and tested. Horizontal child rows are the common safe shape.

## API Contracts

6. Prefer `wrapperToHorizontalSection(height:insets:style:)`. The older ViewCell-suffixed wrapper name is deprecated and should not be used in new examples.

```swift
let childSection = ItemCell.wrapperToSingleTypeSection(items)

let parentSection = childSection.wrapperToHorizontalSection(
    height: 120,
    insets: .init(top: 8, left: 16, bottom: 8, right: 16)
) { sectionView, section in
    sectionView.showsHorizontalScrollIndicator = false
}
```

7. `wrapperToHorizontalSection(_ model:)` wraps an `SKCSectionViewCell.Model` in `SKCSingleSectionViewCell<Self>.wrapperToSingleTypeSection(model)`.

8. `wrapperToHorizontalSection(_ models:)` creates multiple parent rows, where each row owns one nested `SKCSectionViewCell.Model`.

9. `SKCSectionViewCell.Model.SectionType` currently supports `.normal([any SKCBaseSectionProtocol])`; do not document additional section types unless the source adds them.

10. `SKCSectionViewCell.Model.horizontal(section:heightModel:insets:style:)` derives parent height from `Cell.preferredSize(limit:model:)` for a representative child model, then adds top and bottom insets.

```swift
let childSection = ItemCell.wrapperToSingleTypeSection(items)

let parentModel = SKCSectionViewCell.Model.horizontal(
    section: childSection,
    heightModel: items.first,
    insets: .init(top: 8, left: 16, bottom: 8, right: 16)
) { sectionView in
    sectionView.showsHorizontalScrollIndicator = false
}

let parentSection = SKCSectionViewCell.wrapperToSingleTypeSection(parentModel)
```

11. Use `SKCSectionViewCell.Model(section:height:insets:scrollDirection:style:)` for fixed-height embedded sections.

12. Use `SKCSectionViewCell.Model(section:insets:scrollDirection:style:size:)` when the parent size must be computed from the available limit, model insets, or external layout rules.

```swift
let parentModel = SKCSectionViewCell.Model(
    section: .normal([titleSection, itemSection]),
    insets: .init(top: 12, left: 0, bottom: 12, right: 0),
    scrollDirection: .horizontal,
    style: .set { sectionView in
        sectionView.showsHorizontalScrollIndicator = false
    },
    size: { limit, model in
        CGSize(width: limit.width, height: 160 + model.insets.top + model.insets.bottom)
    }
)
```

13. Do not subclass `SKCSectionViewCell` expecting an overridable section-setup hook. Current source passes child sections through the model and reloads them in `config(_:)`.

## Sizing

14. `SKCSectionViewCell.preferredSize(limit:model:)` returns `model.size(limit, model)` and returns `.zero` when the model is nil.

15. For simple horizontal carousels, prefer a fixed height when child rows have a stable visual envelope.

16. For variable child content, pass a representative `heightModel` to `Model.horizontal(...)` only when that model really represents the maximum or intended row height.

17. If multiple child sections contribute to height, use the custom `size` closure instead of deriving height from the currently visible inner cells.

18. Insets affect both parent size math and the inner collection constraints. Top and bottom insets must be included in the parent height.

19. Do not use the inner collection view's current frame as the source of truth for parent sizing. It may still be zero or stale during measurement.

20. Pair expensive child cells with `setHighPerformance(.init())` and stable `highPerformanceID` on the child section, not on the parent wrapper alone.

## Lifecycle And Reuse

21. `SKCSectionViewCell` creates one inner `SKCollectionView` per cell instance and keeps it across reuse.

22. `config(_:)` sets `sectionView.scrollDirection`, applies the model style, applies edge insets, and calls `sectionView.manager.reload(list)`.

23. The model `style` closure can run on every bind. Keep it idempotent and avoid accumulating observers, duplicated plugin state, or repeated side effects.

24. The inner manager sets `configuration.supportUnbindSection = false` to avoid fast-reuse unbind crashes. Do not rely on nested section unbind callbacks for cleanup.

25. Treat parent cell reuse as a hard rebinding boundary. Any nested subscriptions, display counters, selection stores, or scroll observers must be reset or replaced when the parent model changes.

26. Keep child section instances stable only when their state is intentionally shared across parent reloads. Otherwise build fresh child sections from the parent model.

27. If child sections are reused, reset state that is row-index based before rebinding a different model universe.

## State Ownership

28. Nested exposure is usually child-section state. Reset `displayedTimes` when the child section is reused for different parent content.

29. Nested selection should be owned by the child model or a child selection sequence. The parent row should only coordinate selection when cross-row exclusivity is required.

30. Nested prefetch publishers emit child-section-local row indexes. Map rows to child models immediately.

31. Nested scroll observers should be registered on the inner `sectionView.manager.scrollObserver`, not the outer manager.

32. If an inner row must update outer state, keep the callback at the parent assembly boundary and capture owners weakly.

33. Do not store visible inner cells as persistent state. Query the current context when handling a child action.

## Style And Layout

34. Configure inner collection appearance in the model `style` closure: indicators, background, content inset, deceleration, and plugin modes belong there.

35. The wrapper method already sets `scrollDirection: .horizontal`. Override direction only when constructing a custom `SKCSectionViewCell.Model`.

36. Use collection-level plugin modes on the inner `sectionView` when the plugin applies to all child sections in that embedded collection.

37. Use section-level layout plugins on child sections when the behavior belongs to one child section.

38. Do not encode outer collection spacing into child cell sizing. Keep outer row spacing in the parent section style and inner item spacing in the child section style.

39. Keep nested decorations local to the inner collection unless the visual background must span the whole parent row.

40. For gesture conflicts, first verify outer and inner scroll directions, then decide whether nested scrolling or page-controller structure is the right interaction.

## Debug Checklist

41. Old child content appears: child sections or subscriptions are reused without resetting them for the new parent model.

42. Exposure fires only once after content changes: reset child section `displayedTimes` when rebinding a new model universe.

43. Parent height is zero: `height` is nil/zero, `heightModel` is nil or measures zero, or the custom `size` closure returns zero.

44. Parent height clips content: top/bottom insets were not included, or the representative height model is too short.

45. Inner layout plugins do not run: plugin modes were configured on the wrong collection or after the reload path that needed them.

46. Scroll gestures feel wrong: verify inner `scrollDirection`, outer `scrollDirection`, simultaneous gesture expectations, and whether a page controller is the intended structure.

47. Context menus or prefetch use wrong rows: remember that nested row indexes are child-section-local.

48. Child selection leaks across parent rows: selection state is shared unintentionally; rebuild the selection sequence or key it by stable child identity.

## Framework Boundary

49. Keep generic nested section primitives in SectionUI: model-based child section embedding, sizing contracts, inner collection styling, and lifecycle documentation.

50. Keep app-specific carousel wrappers, analytics payloads, module ordering, request loading, and branded spacing in integration layers.
