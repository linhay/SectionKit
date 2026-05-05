# Advanced Production Tips

This reference captures lower-frequency SectionUI APIs that show up in complex screens. Keep it generic: no downstream project paths, product names, business module names, source-file indexes, or scan statistics.

## Layout Attribute Fixes

1. Use `setAttributes(.fixHeaderViewSize)`, `setAttributes(.fixFooterViewSize)`, or `setAttributes(.fixSupplementaryViewSize)` when a layout plugin changes supplementary attributes and the final header/footer size must still come from the section's registered supplementary size provider.

2. Use section-level `setAttributes(.fixSupplementaryViewSize)` when only a few sections need the correction. Use `sectionView.set(pluginModes: .fixSupplementaryViewSize)` only when the whole collection shares that layout contract.

3. Use `.reverseHeaderAndSectionInset` when a header should visually start after the section's top inset has been applied by layout math.

4. Use `.reverseFooterAndSectionInset` when a footer should visually move back by the section's bottom inset instead of sitting outside the intended visual group.

5. Pair reversed header/footer inset handling with fixed supplementary sizing when card backgrounds, grouped modules, or custom section insets make headers/footers drift.

6. Use `.zIndex(when:value:)` to resolve layering among cells, supplementary views, decorations, and sticky elements. Keep values sparse and local to the section that owns the visual conflict.

7. Prefer z-index adjustment over adding transparent spacer sections when the problem is visual overlap, not real layout spacing.

8. If a decoration background covers headers/footers incorrectly, first verify section insets, decoration insets, supplementary size, and z-index before introducing a custom layout.

9. Keep attribute fixes close to the section declaration. A future maintainer should be able to see why that section needs non-default layout behavior.

## Plugin Mode Ordering

10. Derive `decorations` after optional sections are filtered and ordered. Decoration `sectionIndex` should reference final section instances or final positions, not a pre-filtered module list.

11. Apply collection-level plugin modes once per render pass after `manager.reload(sections)` or immediately beside it, so layout state and section order stay readable.

12. Use flow-layout alignment modes such as `.left` or `.centerX` for row alignment problems. Avoid encoding alignment into cell width calculations unless each cell genuinely owns a different width rule.

13. Keep section-level `addLayoutPlugins` for behavior owned by one section. Keep `sectionView.set(pluginModes:)` for behavior that is a collection-wide layout rule.

14. Do not mix native `UICollectionViewFlowLayout` header/footer pinning with SectionUI pin APIs on the same screen. Pick one pin system for a collection.

## Scroll Observation

15. Use `manager.scrollObserver.add(scroll: "stable-id")` for replaceable observation blocks. Adding another handler with the same id replaces the previous observer block.

```swift
manager.scrollObserver.add(scroll: "navbar") { handle in
    handle.didScroll = { scrollView in
        updateNavigation(for: scrollView.contentOffset.y)
    }
}
```

16. Use `manager.scrollObserver.remove(id:)` for forward handlers that override delegate behavior. For observer blocks, prefer re-adding with the same id or owning a separate observer object whose lifecycle is explicit.

17. Add plain observers for side effects such as analytics, sticky state, navigation updates, or load-more triggers.

18. Add forward delegates only when the handler must decide the returned UIKit delegate value. Keep forward handlers rare because they affect downstream observer values.

19. When a reusable cell owns an inner `SKCollectionView`, attach scroll observers during cell configuration and clear or replace them when the cell is rebound to a new model.

20. For nested scroll views, keep outer and inner scroll observers separate. Do not let an inner row mutate outer controller state unless that coupling is intentional.

## Display Tracking

21. Use `SKCDisplayTracker` when visible section/cell state should drive a menu, tab highlight, table of contents, or exposure aggregation.

22. Register the tracker with `manager.scrollObserver.add(tracker)` before subscribing to its publishers.

23. Build `SKCDisplayTracker.TopSectionForVisibleAreaItem` from stable section instances, then rebuild the list after any render that replaces those section instances.

24. `TopSectionForVisibleAreaItem.section` is weak. Store the real sections elsewhere for the screen lifetime, or the tracker input can silently lose entries.

25. Use `topSectionForVisibleArea` for navigation sync, `sectionsForVisibleArea` for multi-section visibility, and `indexPathsForVisibleArea` when header/cell/footer distinction matters.

26. Subscribe after sections are bound to the collection. The tracker filters out sections that are not currently bound.

27. If a tracker appears stale after a full reload, check whether the tracked section array still points at old section instances.

## Pinning

28. Store the `AnyCancellable` returned by `pinHeader`, `pinFooter`, or `pinCell(at:)`. Releasing it disables the layout plugin.

```swift
section.pinHeader { options in
    options.padding = topInset
}.store(in: &cancellables)
```

29. Use `padding` for navigation bars, segmented controls, or other fixed overlays above the collection.

30. Use `options.$isPinned` for UI state that depends on the pin boundary, such as changing a header shadow after it sticks.

31. Use `options.$distance` when the UI needs progressive behavior before the pin point, such as fading, scaling, or translating.

32. Use `customAdjust` only for attribute-level visual adjustment. Keep business state changes in `$isPinned` / `$distance` subscriptions.

33. Use `options.isEnabled = false` to temporarily disable pinning without rebuilding the section.

34. Prefer `pinCell(at:)` for sticky menu rows or filter rows that are real cells. Prefer `pinHeader` / `pinFooter` when the sticky element is structurally supplementary.

35. When multiple sticky elements stack, assign padding based on the height of earlier pinned elements instead of relying on z-index alone.

36. If the pinned item flickers or disappears near viewport edges, verify it has real layout attributes. SectionUI can append missing attributes, but the section, row, and supplementary kind must still be valid.

## Wrapping Views

37. Use `SKWrapperView<UIView, Model>` when the underlying view is the reusable unit and SectionUI should only provide collection sizing/configuration.

38. Use `View.wrapperToCollectionCell()` when the view already conforms to `SKLoadViewProtocol` and `SKConfigurableView`; this keeps the view reusable outside collection cells.

39. Use `View.wrapperToCollectionReusableView()` for simple headers/footers built from reusable views.

40. Use `SKCAnyViewCell` for one-off runtime-provided views, temporary integration, or screens where the view instance already exists. Avoid it for reusable row types that deserve type-safe models.

41. When using `SKCAnyViewCell`, always provide explicit `PreferredSize` and layout. A view instance alone is not a sizing contract.

42. Prefer a small wrapper view over a custom cell when the cell would contain exactly one reusable view and no cell-specific lifecycle behavior.

## Nested Sections And Pages

43. Use `wrapperToHorizontalSection(height:insets:style:)` for a simple horizontal row containing one child section.

44. Use `SKCSectionViewCell.Model` when an embedded collection owns multiple child sections, custom style, or a size closure.

45. Configure inner collection style in the `style` closure: scroll direction, indicators, content inset, background, and plugin modes belong there.

46. Recompute nested section models in `config(_:)` and reset nested exposure or selection state when the parent model changes.

47. Use `SKPageManager` / `SKPageViewController` when the UI is controller-level paging with child view controllers. Do not use it for a simple horizontal collection row.

48. Keep page identity stable. Use explicit ids for child pages when selection, restoration, or analytics depend on page identity.

## Prefetch And Load More

49. `prefetchPublisher` emits section-local row indexes. Map them to models immediately while the section's model array is still in sync.

50. `cancelPrefetchingPublisher` should cancel work keyed by row or model identity. Prefer model identity for network/image tasks that can survive row movement.

51. `loadMorePublisher` fires when a prefetched row reaches the current last model. Gate it with an `isLoading` flag or request state to avoid duplicate pagination.

```swift
section.prefetch.loadMorePublisher
    .filter { !state.isLoadingMore }
    .sink { loadNextPage() }
    .store(in: &cancellables)
```

52. Enable prefetch-driven loading only after the first page has a stable model count. Empty sections can otherwise make load-more semantics unclear.

53. When replacing all models, cancel outstanding prefetch tasks for old identities before subscribing work for the new list.

## Context Menu And Reorder

54. Use `onContextMenu` when menu actions are row/model-specific and belong next to the section's event wiring.

55. Use `onContextMenu(where:)` to keep conditional menu logic declarative instead of returning `nil` from a large menu builder.

56. Clear old context menu actions before rebinding a reusable section to a substantially different menu policy.

57. Enable movement with `onCellShould(.move, true)` or a predicate. Keep movement eligibility in the section, because UIKit asks the data source by index path.

58. The default same-section `move(from:to:)` swaps models. Override or wrap the section when the desired behavior is insertion-style reorder rather than swap.

59. For cross-section moves, update the source and destination models explicitly. The default single-type section removes from the source and asserts if asked to accept into a destination it does not own.

60. After a user reorder, immediately synchronize the source-of-truth array with the displayed section models. Otherwise a later render will undo the user's order.

61. Do not use drag reorder as a side effect to mutate unrelated sections. Keep reorder operations scoped, then render dependent sections from the updated source of truth.

## Boundary For Framework Changes

62. Promote a pattern into SectionUI only if it is a reusable collection/list primitive, not a screen-specific convention.

63. Keep wrappers around brand spacing, colors, copywriting, analytics names, or product-specific layout groups in the integration layer.

64. When a behavior can be expressed as a section factory, wrapper view, `SKCCellStyle`, layout plugin, or `SKPublishedValue`, prefer that over adding a new framework API.
