# Supplementary Recipes

Use this reference when a SectionUI task involves headers, footers, `setHeader`, `setFooter`, `set(supplementary:type:model:)`, dynamic supplementary models, `remove(supplementary:)`, `hiddenHeaderWhenNoItem`, `hiddenFooterWhenNoItem`, supplementary lifecycle actions, or supplementary sizing.

Keep it generic: no downstream project paths, product names, business module names, source-file indexes, scan statistics, page names, route names, analytics events, or design-system component names.

## Contents

- [Registration And Storage](#registration-and-storage)
- [Constant Models](#constant-models)
- [Dynamic Models](#dynamic-models)
- [Sizing](#sizing)
- [Visibility](#visibility)
- [Removal](#removal)
- [Lifecycle Actions](#lifecycle-actions)
- [Custom Kinds](#custom-kinds)
- [Examples](#examples)
- [Debug Checklist](#debug-checklist)
- [Framework Boundary](#framework-boundary)

## Registration And Storage

1. Supplementary definitions are stored in `section.supplementaries` by `SKSupplementaryKind`.

2. `setHeader` is a convenience wrapper over `set(supplementary: .header, ...)`.

3. `setFooter` is a convenience wrapper over `set(supplementary: .footer, ...)`.

4. `set(supplementary:type:model:config:)` with a constant model wraps that model in a closure.

5. `set(supplementary:type:config:size:)` is the low-level API for custom sizing closures.

6. `set(...)` queues registration through `taskIfLoaded`, stores the supplementary definition, then calls `reload()`.

7. It is safe to set header/footer before the section is bound. Registration is performed after binding.

8. Setting or replacing a supplementary view reloads the section. Account for that when chaining several supplementary changes.

9. Replacing a supplementary for the same kind overwrites the previous definition.

10. A supplementary view type must conform to `UICollectionReusableView`, `SKLoadViewProtocol`, and `SKConfigurableView`.

11. Registration uses `View.identifier` and `View.nib` from `SKLoadViewProtocol`.

## Constant Models

12. Use `setHeader(View.self, model:)` and `setFooter(View.self, model:)` when the model is known at section declaration time.

13. Constant model overloads keep size and config stable until the supplementary definition is replaced.

14. The optional `config` closure runs after `view.config(model)`.

15. Use the `View.Model == Void` overload for static chrome that has no model.

16. Keep supplementary models structural: title, count, filter state, summary, or section chrome.

17. Do not hide whole feature states inside header/footer models when they should be rendered as explicit sections.

## Dynamic Models

18. Use the closure model overload when the supplementary model should be evaluated at layout/config time.

19. The model closure returns `View.Model?`.

20. If the model closure returns nil, the config path skips `view.config` and the size closure returns `.zero`.

21. Closure-based models keep header size and config aligned with the latest state.

22. The closure can be evaluated during sizing and dequeue/config. Keep it cheap and side-effect free.

23. Capture owners weakly in dynamic supplementary model closures.

24. If the dynamic model changes, call `section.reload()` or rebuild the section so supplementary size is recalculated.

25. Prefer `remove(supplementary:)` when the supplementary has left the section contract. Prefer nil dynamic model only for lightweight optional content that may come back under the same registered kind.

26. The `SKBinding<View.Model?>` overload is deprecated. Prefer the closure overload.

## Sizing

27. `headerSize` returns `.zero` when `hiddenHeaderWhenNoItem` is true and `models` is empty.

28. `footerSize` returns `.zero` when `hiddenFooterWhenNoItem` is true and `models` is empty.

29. If no supplementary definition exists for the kind, header/footer size is `.zero`.

30. If `feature.highestHeaderSize` or `feature.highestFooterSize` is set, that fixed size wins.

31. Otherwise SectionUI builds `SKSafeSizeProvider.Context(kind:indexPath:)` using row `0` and calls the supplementary's size closure with `fetchSafeSize`.

32. `View.preferredSize(limit:model:)` receives the supplementary safe-size limit, not necessarily the same limit as cells.

33. Use `supplementarySafeSize(.header, .apple)` when a header should measure against collection bounds rather than section-safe size.

34. Use `supplementarySafeSize(.footer, .default)` when footer measurement should follow the normal section-safe envelope.

35. Align supplementary size with layout plugins that fix or adjust supplementary size/insets.

36. Return `.zero` only when the supplementary should not take layout space.

## Visibility

37. `hiddenHeaderWhenNoItem` defaults to true.

38. `hiddenFooterWhenNoItem` defaults to true.

39. Set hidden flags to false for static chrome that should remain visible in empty sections.

40. Reload the section after toggling hidden flags.

41. For empty, loading, or error screens, prefer explicit state sections when the visual state is not structurally a header/footer.

42. Header/footer visibility is size-based. If size is `.zero`, UIKit may not ask for a reusable view.

## Removal

43. Use `remove(supplementary: .header)` to remove a normal header.

44. Use `remove(supplementary: .footer)` to remove a normal footer.

45. `remove(supplementary kind:)` clears the stored supplementary for that kind and calls `reload()`.

46. `remove(supplementary: View.self)` constructs `SKSupplementaryKind(rawValue: View.identifier)`.

47. `remove(supplementary: View.self)` does not remove a normal `.header` or `.footer` unless that kind was originally registered under the view identifier as a custom kind.

48. Prefer explicit kind removal for headers and footers.

49. When changing both header and footer, consider rebuilding the section or grouping changes so repeated reloads do not create unnecessary work.

## Lifecycle Actions

50. `onSupplementaryAction(.willDisplay)` observes supplementary display.

51. `onSupplementaryAction(.didEndDisplay)` observes supplementary end display.

52. `SKCSupplementaryActionContext` includes `section`, `type`, `kind`, `row`, and `view`.

53. `context.view` returns the reusable supplementary view when it is still available.

54. Use supplementary actions for header/footer exposure, visual lifecycle, and cleanup.

55. Use cell actions for row exposure. Do not report header exposure from cell `willDisplay`.

56. `onAsyncSupplementaryAction` launches an unowned `Task`.

57. Handle errors inside async supplementary work. Do not rely on the caller to observe thrown errors.

58. Gate async supplementary work by current section state when the task can outlive the displayed view.

59. Keep supplementary display callbacks lightweight; scrolling can call them often.

## Custom Kinds

60. `SKSupplementaryKind.header` maps to `UICollectionView.elementKindSectionHeader`.

61. `SKSupplementaryKind.footer` maps to `UICollectionView.elementKindSectionFooter`.

62. `SKSupplementaryKind.cell` maps to `"UICollectionViewCell"`.

63. `SKSupplementaryKind.custom(value)` maps directly to that raw value.

64. `SKCSingleTypeSection.supplementary(kind:at:)` returns only header and footer by default.

65. A single-type section storing a `.custom` supplementary will not return it unless a subclass or custom section overrides supplementary lookup.

66. Use custom supplementary kinds only when the layout/data-source path explicitly asks for that custom kind.

67. For most section chrome, use header/footer instead of custom kinds.

## Examples

Constant header and footer:

```swift
section
    .setHeader(TitleHeader.self, model: .init(title: "Title"))
    .setFooter(SummaryFooter.self, model: .init(count: items.count))
```

Dynamic optional header:

```swift
section.set(supplementary: .header, type: TitleHeader.self, model: { [weak store] in
    store?.headerModel
})
```

Static divider header:

```swift
section.set(supplementary: .header, type: DividerHeader.self)
```

Remove normal headers and footers by kind:

```swift
section.remove(supplementary: .header)
section.remove(supplementary: .footer)
```

Async lifecycle work with local error handling:

```swift
section.onAsyncSupplementaryAction(.willDisplay) { context in
    do {
        try await tracker.markDisplayed(kind: context.kind)
    } catch {
        logger.record(error)
    }
}
```

## Debug Checklist

68. Header missing: check `hiddenHeaderWhenNoItem`, empty models, nil dynamic model, zero size, and registration.

69. Footer missing in an empty list: set `hiddenFooterWhenNoItem = false` and reload.

70. Header size wrong: inspect `supplementarySafeSize`, `View.preferredSize`, fixed supplementary layout plugins, and `feature.highestHeaderSize`.

71. Header config stale: verify the dynamic model closure returns the latest model and the section was reloaded.

72. Removing by view type did not remove a header: use `remove(supplementary: .header)`.

73. Custom supplementary never appears: `SKCSingleTypeSection` only returns header/footer by default.

74. Async supplementary error disappears: catch inside the async action.

75. Header exposure fires repeatedly: display lifecycle follows UIKit visibility. Deduplicate by section state if needed.

76. Header overlaps decoration: align supplementary size/inset plugins with decoration frame rules.

77. Dynamic nil model still leaves spacing: verify the size closure returns `.zero` and no layout plugin later fixes a positive supplementary size.

## Framework Boundary

78. Promote supplementary helpers into SectionUI only when they describe generic header/footer lifecycle, sizing, or registration mechanics.

79. Keep business grouping, copy, analytics taxonomy, and design-system component names outside generic supplementary recipes.

80. Document supplementary behavior as section chrome and lifecycle, not as a downstream page structure.
