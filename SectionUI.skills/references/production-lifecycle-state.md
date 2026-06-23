# Production Lifecycle And State Tips

Use this reference when a SectionUI task involves lifecycle timing, loaded-state checks, manager binding, section identity, model publishers, reload strategy, render states, selection state, high-performance cache, or pending scroll requests. Keep it generic: no downstream project paths, product names, business module names, source-file indexes, or scan statistics.

## Section Collection And Rendering

1. Use `SKCSectionCollector` when a screen is assembled from many optional modules. It keeps conditional rendering readable and avoids a long chain of `if let` section appends.

```swift
let collector = SKCSectionCollector()
collector.append(headerSection)
collector.append(optionalModule, section: \.section)
for module in listModules {
    collector.append(module, section: \.section) { $0.shouldRender }
}
manager.reload(collector.sections)
```

2. Treat the collector as a render builder, not persistent state. Store long-lived section instances separately when later refresh, selection, tracking, or scrolling needs the same section identity.

3. Use `append(_:section:when:)` when a wrapper object owns the section. It keeps the render condition attached to the wrapper instead of leaking that condition into controller layout code.

4. Use the returned `Bool` from `append(_:section:when:)` only for render-time decisions such as whether to add a decoration or spacer. Do not use it as durable business state.

5. Build the final section list once, then derive decorations, display tracker items, and scroll targets from that final list.

6. Keep placeholder, loading, empty, and content sections as explicit render states. Avoid a section that silently means different states based only on an empty model array.

## Manager Binding And Section Identity

7. `manager.reload(sections)` rebinds section injections and reloads the collection. Any code that depends on `sectionIndex`, layout attributes, or `sectionView` should run after binding.

8. `manager.insert`, `manager.append`, and `manager.delete/remove` operate by section object identity. Keep stable section instances when using those APIs.

9. If you recreate section instances for every render, prefer full `manager.reload(sections)` over object-identity incremental section operations.

10. When removing sections, remember that unbound sections should no longer be used for scroll, visible-cell access, or layout attribute queries.

11. Use `manager.publishers.sectionsPublisher` when a coordinator needs to observe the bound section list. Use `manager.sections` only for immediate synchronous inspection.

12. Prefer holding typed section references from the render builder. If you must inspect manager state, derive from `manager.sections` or `manager.publishers.sectionsPublisher`; avoid hard-coded section offsets unless the list is truly static.

13. If a screen needs a custom `SKCSectionInjection`, use `manager.converts.sectionInjection` at integration boundaries. Do not mutate `sectionInjection` directly from feature code.

14. Keep manager-level configuration such as `replaceInsertWithReloadData`, `replaceDeleteWithReloadData`, and `supportUnbindSection` screen-local unless the whole app shares that tradeoff.

## Loaded Lifecycle

15. `section.sectionView` asserts when the section is not bound. Check `isBindSectionView` before accessing visible cells, layout attributes, or the collection view.

16. Use `taskIfLoaded` for setup that must wait until the section has registered into a collection view.

17. Use `publishers.lifeCyclePulisher` for one-time work that depends on `.loadedToSectionView`, such as wiring a subview after registration.

18. `lifeCyclePulisher` is delayed. Do not use it for logic that must happen synchronously inside the same render pass.

19. Supplementary registration through `setHeader`, `setFooter`, or `set(supplementary:)` is safe before binding because the section queues loaded work.

20. When reusing a section across screens or embedded collections, clear old cancellables and lifecycle subscriptions before binding it to a new owner.

## Model Binding And Publishers

21. `section.models` is backed by a current-value subject. Assigning models sends `modelsPulisher`.

22. Use `publishers.modelsPulisher` when other UI should react to the section's model count or emptiness.

23. Avoid writing back to the same section from an unguarded `modelsPulisher` sink. If a sink mutates models again, add `removeDuplicates`, a state guard, or move the derived update outside the section.

24. `subscribe(models:)` receives on the main run loop and calls `apply`. Use it for a section whose models are wholly owned by a publisher.

25. Do not combine `subscribe(models:)` with manual `append`, `insert`, or `delete` unless the publisher remains the source of truth. The next publisher emission will overwrite local mutations.

26. Use the optional-model overload of `subscribe(models:)` for a single optional row. It maps `nil` to an empty section; pair it with explicit empty-state sections when the UI should still show content.

27. `cellActionPulisher` and `supplementaryActionPulisher` are good for cross-cutting observation. Prefer `onCellAction` / `onSupplementaryAction` for local screen behavior.

28. Keep event sinks close to the section owner and store cancellables there. A section should not accidentally retain an old controller through event publishers.

## Reload Strategy

29. Use `apply` / `config(models:)` for full replacement when model identity is not stable or when all rows visually change together.

30. Use `reloadKind = .difference(by:)` when insert/delete animation matters and a stable identity or equality predicate is available.

31. Use `.difference(by:)` carefully: the predicate defines identity, not full content equality. If the same identity has changed content, follow with `refresh` for changed rows when needed.

32. Use `.configAndDelete` for lists whose count usually stays the same and where visible cells can be reconfigured in place.

33. Use `.normal` for large wholesale changes, sort-mode changes, or cases where difference animation creates more noise than value.

34. `remove(_:)` sorts rows descending and reloads trailing rows after deletion. This is useful for row-dependent styles such as separators or first/last rounding.

35. `refresh(with:)` updates section models before reloading rows. Prefer it over `refresh(at:)` when the row model changed.

36. `refresh(_ models, predicate:)` matches existing models to new models. Make the predicate identity-based and deterministic.

37. Use `pick { ... }` when several section or item mutations must become one collection update transaction.

38. Do not call `reload()` inside every cell event when a row-level `refresh(with:)`, `delete`, or `insert` is sufficient.

39. For full replacement of very large sections, consider `feature.skipDisplayEventWhenFullyRefreshed = true` when exact `didEndDisplay` replay is not required.

## Empty Supplementary Views

40. `hiddenHeaderWhenNoItem` and `hiddenFooterWhenNoItem` default to `true`. Set them to `false` for static headers/footers that should remain visible in an empty section.

41. Prefer an explicit empty section when the body is empty but the screen still needs an explanation, CTA, or skeleton. Do not overload an empty header/footer to represent a full empty state.

42. When toggling `hiddenHeaderWhenNoItem` or `hiddenFooterWhenNoItem`, reload the section so supplementary sizes are recalculated.

43. Use `supplementarySafeSize(.header, .apple)` or `.footer` when a supplementary view should measure against the full collection bounds rather than the section's normal safe size.

44. Keep header/footer size shortcuts such as `feature.highestHeaderSize` and `feature.highestFooterSize` only for truly fixed-size reusable views.

## High-Performance Size Cache

45. `SKHighPerformanceStore` caches by `(id, limitSize)`. If the same model appears under a different width, it gets a different cache entry.

46. Choose `highPerformanceID` from stable render identity. Avoid row index when rows can be inserted, deleted, moved, or filtered.

47. Remove cache entries by id when content that affects size changes.

48. Remove cache entries by `(id, limit)` when only one size envelope is invalid. Remove all entries only for global typography, width, or layout-rule changes.

49. `feature.highestItemSize` bypasses per-model measurement. Use it only when every item has exactly the same size.

50. If dynamic type, remote image aspect ratio, or expanded/collapsed state changes size, invalidate the high-performance cache before refreshing rows.

## Selection State

51. `section.selectionSequence(isUnique:)` follows `modelsPulisher`, so it stays in sync when the section's models are replaced.

52. Subscribe to `itemChangedPublisher` before expecting per-item change events. The sequence creates item observation lazily when that publisher is used.

53. Use `reloadPublisher` when controls such as submit buttons or "select all" states need to update after the whole selection store is replaced.

54. `SKSelectionSequence` observes selection by offset. Reload it after inserts, deletes, or full model replacement when you manage it manually.

55. `SKSelectionIdentifiableSequence` observes by id. Use it when the same selectable model can move between positions or across filtered lists.

56. For `SKSelectionIdentifiableSequence`, call `update` for incremental model replacement and `remove(id:)` when the item leaves the selectable universe.

57. `selectedItemsPublisher` on identifiable selection emits after any observed selection change. Use it for toolbar enablement instead of polling selected ids.

58. In unique selection mode, selecting one item will deselect others. Avoid doing manual deselect loops around `select` unless there is extra domain logic.

## Scroll Requests

59. Prefer `section.scroll(to:row:)` when you already hold a stable section instance. Prefer `manager.scroll(to:section:)` when the scroll target might need to wait for layout.

60. `manager.scroll(to:)` returns an `SKRequestID?` only when the first scroll attempt could not run and was queued until layout. Store it if the pending request may need cancellation.

61. Section scroll APIs return `false` when the collection is not in a window, has zero size, or lacks layout attributes. Treat `false` as "try after layout" rather than as a hard failure.

62. Use supplementary-kind scrolling (`.header`, `.footer`, `.cell`) for menu/table-of-contents jumps where the exact row may be less stable than the section boundary.

63. Use `offset` for fixed overlays. Do not bake overlay heights into section insets just to make scroll targets align.

64. When paging is enabled, SectionUI temporarily disables paging for direct item scroll. If a custom scroll helper bypasses SectionUI, handle paging the same way.

## Beta And Platform-Specific APIs

65. Treat `SKWaterfallLayout` as beta/deprecated. Use it only after validating invalidation, supplementary layout, and size caching for that screen.

66. For waterfall layouts, prefer `heightCalculationMode(.aspectRatio)` when cell model sizes represent natural media dimensions. Use `.fixed` only when provided heights are already final display heights.

67. Keep waterfall column ratios summing to `1.0`; the layout asserts when they do not.

68. `SKCHostingSection` is iOS 16+ and creates a section from a SwiftUI view type plus models. Use it for SwiftUI rows, but keep lifecycle and performance expectations aligned with SwiftUI hosting.

69. Do not use `SKCHostingSection` as a shortcut for UIKit rows that already have stable `UIView`/cell implementations.

70. Treat `SKCDragSelector` as beta. Own it from the view controller or feature coordinator, call `reset()` before re-setup, and validate gesture conflicts with normal scrolling.
