# Rendering And Performance Recipes

Use this reference when a SectionUI task involves rendering performance, sizing, measurement, wrapper views, high-performance caches, SwiftUI hosting, nested sections, waterfall layout, or rendering debug checklists. Keep it generic: no downstream project paths, product names, business module names, source-file indexes, scan statistics, or page names.

## Contents

- [Sizing Model](#sizing-model)
- [Cell Safe Size](#cell-safe-size)
- [Supplementary Safe Size](#supplementary-safe-size)
- [High-Performance Cache](#high-performance-cache)
- [Fast-Path Fixed Sizes](#fast-path-fixed-sizes)
- [Wrapper Views](#wrapper-views)
- [Any View Cells](#any-view-cells)
- [SwiftUI Hosting](#swiftui-hosting)
- [Nested Sections](#nested-sections)
- [Waterfall Layout](#waterfall-layout)
- [Debug Checklist](#debug-checklist)
- [Framework Boundary](#framework-boundary)

## Sizing Model

1. Treat SectionUI sizing as a three-step contract: collection bounds produce `safeSize`, `cellSafeSize` transforms the measuring limit, and `Cell.preferredSize(limit:model:)` returns the final item size.

2. `safeSize(_:)` is the section-level measuring envelope. It subtracts collection content inset and section inset for vertical flow layouts.

3. `cellSafeSize(_:)` overrides only the cell measuring limit. It does not directly set the final item size unless the cell returns that limit from `preferredSize`.

4. Keep width clamping, tablet centering, and split-screen layout envelopes in safe-size providers. Do not duplicate width math inside every cell.

5. Keep model-specific height logic in `preferredSize(limit:model:)`. Safe-size providers should describe available space, not business content.

6. Always handle zero or negative limits defensively in `preferredSize`. SectionUI may return `.zero` before a collection is bound or sized.

7. Use `SKSafeSizeTransform.print(prefix:)` only as a temporary debug aid. Do not leave noisy size logging in shared skill examples.

8. If a layout depends on dynamic type, remote media ratio, or expand/collapse state, make that dependency explicit in model identity or cache invalidation.

9. Use stable dimensions for repeated rows. Rows whose size changes unpredictably during scroll are the most common source of jank.

10. Prefer one sizing source of truth per row. Avoid mixing Auto Layout fitting, manual constants, and external cached heights unless the contract is documented.

## Cell Safe Size

11. Use `cellSafeSize(.default)` when the cell should measure against the section's normal safe width and height.

12. Use `cellSafeSize(.fixed(size))` for carousel cards, icons, tiles, or rows where the measuring envelope is intentionally independent of collection width.

13. Use `cellSafeSize(.fraction(value))` for grids. It accounts for `minimumInteritemSpacing` and floors width to avoid fractional pixel churn.

14. For grids, set `minimumInteritemSpacing` before relying on fraction sizing so the measured width matches the real flow-layout row.

15. Use `cellSafeSize(.fraction { context in ... })` when the fraction depends on collection width or desired minimum item width.

16. Use `SKCCellFractionLayoutContext.count(of:)` to derive how many columns fit a target width instead of hard-coding device classes.

17. Use `.fixed(height:)` transform when item width is responsive but height is fixed.

18. Use `.height(asRatioOfWidth:)` when media or cards should keep a width-based aspect ratio.

19. Use `.fixed(width:)` or `.width(asRatioOfHeight:)` only when the section's flow layout can accept non-full-width rows.

20. Use `.offset(height:)` sparingly for known chrome such as labels below a media box. Prefer making the cell compute full height when content is dynamic.

21. If a row looks truncated, inspect the limit passed into `preferredSize` before editing cell constraints.

22. If cells in a grid drift by one point, check fraction rounding, interitem spacing, section inset, and device scale.

## Supplementary Safe Size

23. Use `supplementarySafeSize(.header, .default)` when header/footer should measure inside the same section envelope as cells.

24. Use `supplementarySafeSize(.header, .apple)` when a header should measure against the full collection bounds rather than the section-safe width.

25. Use `.apple` for full-width headers above inset cell groups. Pair it with supplementary inset/layout plugins when the visual frame should later be moved inside insets.

26. Keep header/footer visibility explicit with `hiddenHeaderWhenNoItem` and `hiddenFooterWhenNoItem`. Do not rely on zero-size models to represent visibility state.

27. If a supplementary view has a fixed height across all models, prefer `feature.highestHeaderSize` or `feature.highestFooterSize` only when that size is truly global for the section.

28. If a header/footer depends on dynamic content, avoid highest-size shortcuts and let the supplementary provider measure.

29. When a supplementary view changes size after state update, reload the section or relevant supplementary path so flow layout recalculates attributes.

30. If decoration backgrounds include headers/footers, verify supplementary safe size before tuning decoration insets.

## High-Performance Cache

31. Use `setHighPerformance(.init())` plus `highPerformanceID` for complex Auto Layout cells, large lists, or cells whose `preferredSize` is expensive.

32. `SKHighPerformanceStore` caches by `(id, limitSize)`. A width change naturally creates a different cache entry.

33. Choose `highPerformanceID` from stable render identity. Avoid row index when rows can be inserted, deleted, filtered, or reordered.

34. Include state that changes size in the cache identity, or explicitly remove the cache entry before refreshing that model.

35. Remove by id when one model's size-affecting content changes.

36. Remove by `(id, limit)` when only one width envelope is invalid.

37. Use `removeAll()` only for global changes such as dynamic type, theme typography, or a new layout width policy.

38. Share a high-performance store across related sections only when their IDs and size semantics cannot collide. Otherwise keep caches section-local.

39. Do not cache sizes for cells whose height changes from async image loading unless the image ratio is part of the model or cache invalidation.

40. When `reloadKind = .difference(by:)` preserves model identity but display content changes, refresh rows and invalidate cache for changed identities.

41. Keep cache invalidation near the state mutation that changes size. A future maintainer should see why the cached size is invalid.

42. If size cache produces stale layout after rotation, remove cache entries or rely on the changed `limitSize` to create new entries; then ensure old visible cells are refreshed.

## Fast-Path Fixed Sizes

43. `feature.highestItemSize` bypasses per-model item measurement. Use it only when every item in the section has exactly the same final size.

44. `feature.highestHeaderSize` and `feature.highestFooterSize` bypass supplementary measurement. Use them for truly fixed reusable supplementary views.

45. Do not use highest-size shortcuts for variable text, dynamic type, remote media, expanded/collapsed rows, or localized copy.

46. If a section has one fixed row type and one variable row type, split it into two sections or implement a custom heterogeneous section with explicit row sizing.

47. Prefer fixed-size fast paths for dense menus, icon grids, static settings rows, and short carousels.

48. Remove highest-size shortcuts before debugging Auto Layout measurement; they can hide the real cell sizing path.

## Wrapper Views

49. Use `View.wrapperToCollectionCell()` when a reusable `UIView` already conforms to `SKLoadViewProtocol` and `SKConfigurableView`.

50. Use `SKWrapperView<UIView, Model>` when the reusable unit is a plain view and SectionUI should provide insets, size, and configuration.

51. `SKWrapperView.Model` applies insets in both measurement and constraints. Keep inset math there instead of baking padding into the wrapped view.

52. Use wrapper views for simple labels, spacers, dividers, buttons, banners, and small reusable components.

53. Prefer a dedicated cell when the row needs cell-specific lifecycle, selection background, focus/edit/reorder support, or complex reuse cleanup.

54. Keep reusable view configuration idempotent. A wrapped view can be rebound many times during scrolling.

55. If the wrapped view owns Combine subscriptions, cancel them on reconfiguration or inside the view's own reuse-like reset method.

56. Do not create a custom section just to host one view. Use wrapper cell/view first.

## Any View Cells

57. Use `SKCAnyViewCell` for one-off runtime-provided views, migration bridges, prototypes, or screens where the view instance already exists.

58. Always provide an explicit `PreferredSize`. A raw view instance is not a sizing contract.

59. Prefer `.height(...)` for simple full-width rows. Add custom preferred-size logic only when the row genuinely measures from the limit.

60. Always provide a layout closure such as `.fill()`. Adding the view without deterministic constraints can cause ambiguous layout.

61. `SKCAnyViewCell` removes the previous model view and the incoming view from old parents before adding it. Avoid sharing one view instance across simultaneously visible rows.

62. Avoid `SKCAnyViewCell` for reusable row types that deserve typed models, size caching, event hooks, and tests.

63. If an any-view row starts accumulating special cases, graduate it into a real `SKConfigurableView` or cell.

64. Keep business state outside the view instance when possible. Recreate the model from state rather than treating the view as source of truth.

## SwiftUI Hosting

65. `SKCHostingSection` is iOS 16+ and wraps a SwiftUI `View` conforming to `SKExistModelProtocol` into an `STCHostingCell`.

66. Use hosting for SwiftUI-native rows, lightweight migration, or teams already maintaining the row as SwiftUI.

67. Do not use hosting as a shortcut for UIKit rows that already have stable cell/view implementations.

68. `STCHostingCell` uses `UIHostingConfiguration` with zero margins. Put padding in the SwiftUI view or section inset intentionally.

69. `SKCHostingSection.section` creates a new single-type section from the current models. Keep a stable section instance yourself when incremental updates, selection, or scroll targets matter.

70. Treat SwiftUI sizing as part of the row contract. Validate `sizeThatFits` behavior for dynamic type, multiline text, and async image placeholders.

71. Keep SwiftUI row models small and value-oriented. Avoid putting UIKit owners or long-lived side effects directly inside the model.

72. If a hosted row has frequent state changes, consider `SKPublishedValue` or a UIKit cell when full section replacement becomes too noisy.

73. Gate hosting code with availability checks. Provide a UIKit fallback when the screen supports older OS versions.

74. Do not mix radically different SwiftUI and UIKit sizing assumptions in the same section without a clear safe-size policy.

## Nested Sections

For exact `SKCSectionViewCell` model, sizing, lifecycle, and nested state reset contracts, read `nested-section-cell-recipes.md`.

75. Use `wrapperToHorizontalSection(height:insets:style:)` for a simple horizontal row made from one child section.

76. Use `SKCSectionViewCell.Model.horizontal(section:heightModel:insets:style:)` when the child section's cell type can provide height from a representative model.

77. Use `SKCSectionViewCell.Model(section:insets:scrollDirection:style:size:)` when nested content owns multiple sections or needs custom size logic.

78. Configure nested `SKCollectionView` only through the model `style` closure: scroll direction, indicators, background, content inset, and plugin modes belong there.

79. `SKCSectionViewCell` owns an inner `SKCollectionView` and reloads child sections in `config(_:)`. Reset child section state when the parent model changes.

80. Nested exposure, selection, prefetch, and scroll observers must be owned by the nested section or parent cell lifecycle. Clear stale subscriptions on rebinding.

81. Do not let an inner section directly mutate outer-controller state unless the relationship is intentional and documented.

82. For simple carousels, compute parent cell height from fixed child size plus insets. For variable child heights, compute the maximum intended child height before configuring the parent.

83. Avoid deeply nested vertical scrolling inside vertical scrolling. Prefer horizontal nested rows or controller-level paging.

84. If nested scrolling conflicts with outer scrolling, check inner scroll direction, gesture expectations, and whether the row should be a page/controller instead.

85. Keep inner section instances stable only when their state must survive parent cell reuse. Otherwise rebuild from parent model and reset state deliberately.

## Waterfall Layout

86. Treat `SKWaterfallLayout` as deprecated beta. Use it only after validating invalidation, supplementary layout, and size caching for the target screen.

87. `columnWidth(equalParts:)` creates equal ratios whose sum is `1.0`.

88. `columnWidth(ratios:)` asserts when ratios do not sum to `1.0`. Normalize ratios before passing them in.

89. `.aspectRatio` scales item height from layout column width and delegate-provided item size.

90. `.fixed` uses the delegate-provided item height. Use it only when heights are already final display heights.

91. Waterfall layout asks the collection delegate for item, header, footer, inset, and spacing values. Keep SectionUI section sizing and delegate values aligned.

92. It caches attributes until invalidation. Call layout invalidation when widths, ratios, spacing, item sizes, or section counts change.

93. Prefer high-performance size caching for expensive item size calculations used by waterfall layouts.

94. Validate empty sections and supplementary-only sections; waterfall layout skips item layout when the section has no items.

95. Do not mix waterfall with layout plugins that assume `UICollectionViewFlowLayout` attributes unless the plugin explicitly supports custom layouts.

## Debug Checklist

96. Cell width wrong: inspect collection bounds, content inset, section inset, `safeSize`, `cellSafeSize`, and transforms in that order.

97. Grid width off by spacing: verify `minimumInteritemSpacing` is set before fraction sizing and included in the fraction calculation.

98. Header width wrong: check `supplementarySafeSize(.apple)` versus `.default`, then supplementary inset plugins.

99. Cached height stale: remove the high-performance cache entry for the model id and current limit.

100. Rotation layout stale: invalidate layout, refresh visible rows, and confirm the changed `limitSize` reaches the cache key.

101. Dynamic type stale: clear size caches and avoid highest-size shortcuts for text-heavy rows.

102. Wrapped view clipped: verify `SKWrapperView.Model.size` includes insets and constraints match the same inset values.

103. Any-view row ambiguous: verify the layout closure creates complete constraints or frames.

104. Hosted SwiftUI row clipped: verify SwiftUI content has a deterministic layout under the provided limit and no hidden UIKit margin assumption.

105. Nested row shows old content: reset child sections, cancellables, exposure counters, and selection state when parent model changes.

106. Nested carousel height wrong: compute parent height from child preferred sizes plus model insets, not from the current visible cell frame.

107. Waterfall overlap: invalidate layout after data/width changes and confirm delegate item sizes are non-zero.

108. Scrolling jank: profile `preferredSize`, then add cache or fixed-size fast paths where measurement is hot.

## Framework Boundary

109. Promote a sizing/performance API into SectionUI only when it describes a reusable collection/list primitive.

110. Keep device-specific width presets, brand spacing, card aspect ratios, and product row factories in integration layers.

111. Prefer safe-size providers, wrapper views, `SKHighPerformanceStore`, and section factories before adding new framework surface.

112. Document rendering recipes as sizing contracts and lifecycle rules. Do not encode one downstream app's layout grid or visual language as a SectionUI convention.
