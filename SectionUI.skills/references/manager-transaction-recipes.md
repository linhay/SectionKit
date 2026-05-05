# Manager Transaction Recipes

This reference captures production recipes for SectionUI manager binding, section identity, section transactions, row mutations, section injection, pending requests, and reload configuration. Keep it generic: no downstream project paths, product names, business module names, source-file indexes, scan statistics, or page names.

## Contents

- [Manager Ownership](#manager-ownership)
- [Binding Semantics](#binding-semantics)
- [Section Identity](#section-identity)
- [Manager Operations](#manager-operations)
- [Row Operations](#row-operations)
- [Reload Strategy](#reload-strategy)
- [Section Injection](#section-injection)
- [Pending Requests](#pending-requests)
- [Bound Section Access](#bound-section-access)
- [Configuration Flags](#configuration-flags)
- [Integration Recipes](#integration-recipes)
- [Debug Checklist](#debug-checklist)
- [Framework Boundary](#framework-boundary)

## Manager Ownership

1. Treat `SKCManager` as the owner of the collection view's SectionUI data source, delegate, flow-layout delegate, prefetch delegate, and scroll observer chain.

2. Do not replace the collection view's `delegate`, `dataSource`, or `prefetchDataSource` after manager setup unless you are intentionally bypassing SectionUI.

3. Use `SKCollectionView` or `SKCollectionViewController` when possible because they create and hold the manager for the collection surface.

4. Keep one manager per collection view. Sharing a manager across collection views breaks weak `sectionView`, forwarding, and section injection assumptions.

5. Keep screen-owned section references only when later code must refresh, scroll, select, observe, or mutate that same section instance.

6. If a section is built only for one render pass, avoid storing it and use full `manager.reload(sections)` for the render output.

## Binding Semantics

7. `manager.reload(sections)` creates a new section view provider, clears display-end bookkeeping, binds every section, sends `sectionsPublisher`, runs `config(sectionView:)`, then calls `reloadData`.

8. Binding assigns `section.sectionInjection` with the current section index, collection view provider, and manager.

9. `config(sectionView:)` is where single-type sections register their cells and supplementary views and drain `taskIfLoaded` work.

10. A section can be configured before binding, but view-dependent work must wait until binding.

11. `sectionsPublisher` is a current-value stream of bound section instances. Use it for observers that need the final rendered section list.

12. `manager.sections` returns the current publisher value. It is useful for diagnostics and derived integration state, not as a replacement for typed section references.

13. Do not cache integer section indexes across `reload`. Section indexes are rewritten during binding.

14. After a render that changes section order, rederive display trackers, decoration bindings, pin targets, and scroll targets from the final bound sections.

15. When `supportUnbindSection` is true, sections that leave the bound list have `sectionInjection` cleared.

16. An unbound section should not be used for visible cells, layout attributes, scroll, or index-path creation.

## Section Identity

17. Manager insert/remove/delete operations compare section object identity, not semantic ids.

18. `insert(_:before:)` and `insert(_:after:)` do nothing when the reference section is not the same instance currently bound by the manager.

19. `remove(_:)` removes all currently bound sections whose object identity appears in the input list.

20. Recreating section instances every render is compatible with full reloads, but not with later identity-based manager operations on old references.

21. Use long-lived section instances when a feature needs incremental section insert/delete, persistent selection state, display count retention, or scroll-by-section.

22. Use fresh section instances when a render state change should clear actions, styles, cancellables, displayed counters, environment objects, and selection stores.

23. When wrapping sections with `SKCAnySectionProtocol`, make sure the wrapper's `.section` identity is stable if downstream code relies on identity.

24. Do not implement semantic section diffing by passing newly created sections into `manager.insert` or `remove`. Build a diff at the app layer or perform a full reload.

## Manager Operations

25. `manager.reload(section)` is a full manager reload with one section, not a row refresh.

26. `manager.reload(sections)` is the clean boundary for rendering from canonical screen state.

27. `manager.append` calls `insert` at the current section count.

28. `manager.insert(input, at:)` binds inserted sections using the target offset before applying the collection update.

29. `manager.insert(input, at:)` does not clamp the target index. Validate the index in integration code when it comes from user or async state.

30. `manager.remove` unbinds input sections before either deleting sections or falling back to reload.

31. If removing sections leaves an empty section list, manager falls back to `reload([])`.

32. Use `manager.pick { ... }` to group collection mutations that must be one `performBatchUpdates` transaction.

33. Do not mix an outer `manager.pick` with unrelated async model changes inside the update block.

34. Keep all model-array mutations that back UIKit item operations inside the same batch update block as the UIKit operation.

35. If a manager operation falls back to `reloadData`, do not expect section insert/delete animations.

## Row Operations

36. Use `section.refresh(at:)` only when the model has already been updated or visible reconfiguration is enough.

37. Use `section.refresh(at:model:)` or `section.refresh(with:)` when replacing row models and reloading those rows.

38. `refresh(with:)` validates bounds in DEBUG, filters invalid rows, writes models, then reloads the affected rows.

39. `refresh(_ models, predicate:)` scans existing rows and prepares replacement payloads for rows whose old model matches a new model.

40. For predicate refresh, make the predicate identity-based. A content-equality predicate can fail to update changed content.

41. Equatable refresh uses `==`; object refresh uses identity (`===`) for `AnyObject` overloads.

42. `section.append` and `section.insert` mutate `models` and call collection item insertions when the section is bound.

43. When a section is unbound, row insertions and removals mutate only the section's model array.

44. `section.remove(rows)` deduplicates rows, filters out-of-bounds rows, sorts descending, stores deleted models, deletes items, then reloads trailing rows after completion.

45. The trailing-row reload after removal helps row-position styles, separators, and first/last visuals recover.

46. `section.remove(rows, applySectionView: false)` currently returns without mutating. Do not use it as a model-only removal helper.

47. `delete` is an alias-style API over `remove`; use the wording that matches the feature's intent.

48. `context.reload()`, `context.remove()`, and `context.delete()` use the current row from the action context. Avoid using them after async row movement.

49. If an async action may outlive the row offset, store model identity and resolve the row again before mutating.

50. For row swaps, `swapAt` uses collection moves when bound and direct model swap when unbound.

## Reload Strategy

51. `ReloadKind.normal` replaces models and reloads the whole section.

52. `ReloadKind.configAndDelete` is a narrow optimization for visible cell reconfiguration and simple deletion cases.

53. Use `configAndDelete` only when cell size, supplementary visibility, decorations, and layout plugins do not need full recalculation.

54. `ReloadKind.difference(by:)` computes a collection difference between new and old model arrays.

55. The difference predicate describes identity equivalence, not full content equality.

56. For `.difference(by:)`, unchanged identities with changed display content still need explicit row refresh or a model update path that reconfigures visible cells.

57. When old or new model arrays are empty, difference reload falls back to section reload.

58. During difference updates, removals and insertions are applied inside `sectionInjection.pick`.

59. Avoid calling `apply` again while a difference batch is in progress.

60. For large reshuffles or sort mode changes, prefer full reload unless animation has clear user value.

## Section Injection

61. `SKCSectionInjection` is the bridge between a section and its bound collection view, manager, and current index.

62. Feature code should not assign `sectionInjection` directly.

63. Use `manager.converts.sectionInjection` only for integration-level customization of binding.

64. `SKCSectionInjection.task(_:)` applies action converts before dispatching to the section view provider's event table.

65. `SKCSectionInjection.configuration.converts` can remap actions such as item reload, item insert, item delete, section reload, section delete, and reload data.

66. Keep action remapping local and documented. It can change the semantics of every section action.

67. `indexPath(from:)` uses the current injection index. It asserts and falls back to section `0` when a section is unbound.

68. Use `isBindSectionView` before optional view work and `taskIfLoaded` for work that should run after binding.

69. `taskIfLoaded` runs immediately when bound and queues the task otherwise.

70. Queued `taskIfLoaded` tasks are drained in `config(sectionView:)` and then cleared.

## Pending Requests

71. `manager.scroll(to:)` first attempts to scroll immediately.

72. If immediate scroll fails because layout or view sizing is not ready, manager creates an `SKRequestID` with id `"scroll"`.

73. A non-nil `SKRequestID` means the scroll is queued until a later layout-subviews signal.

74. The request performs only when the retry succeeds; then it cancels itself.

75. Calling `cancel()` prevents future retries.

76. Setting a new request with the same id replaces previous non-cancelled requests of that id.

77. Requests are retried only after the request view publishes layout-subviews events with non-zero frame size.

78. Layout-subviews retries are throttled on the main run loop.

79. Store the request when user intent may be superseded by another scroll or navigation event.

80. Clear or cancel pending scroll intent when the target section or row disappears.

## Bound Section Access

81. `section.sectionView` asserts and returns a placeholder collection view when unbound. Prefer `isBindSectionView` for optional flows.

82. `cellForItem(at:)` returns a visible cell only. It is nil for offscreen rows.

83. `visibleCells` and visible indexes are derived from the collection view's current visible index paths and filtered to the section's current index.

84. Layout-attribute helpers require the collection layout to have computed attributes for the requested item, supplementary, or decoration.

85. Use layout attributes for geometry, not visible cells. Attributes can exist for offscreen items when the layout provides them.

86. Use visible cells for immediate visual tweaks only. Persist state in models or section state.

87. Section scroll helpers require a bound section, visible window, non-zero frame, valid row, and layout attributes.

88. Scroll without offset temporarily disables collection paging when needed, calls `scrollToItem`, then restores paging.

89. Scroll with offset computes content offset from layout attributes and collection bounds.

90. Default scroll position follows flow-layout direction: vertical uses `.top`, horizontal uses `.left`.

## Configuration Flags

91. `skipDisplayEventWhenFullyRefreshed` controls whether full manager reloads record old sections for display-end behavior.

92. `replaceReloadWithReloadData` exists in configuration but manager reload already calls `reloadData`; do not rely on it as a section-level reload policy.

93. `replaceInsertWithReloadData` defaults to true, so manager insert usually becomes a full reload.

94. `replaceDeleteWithReloadData` defaults to false, so manager delete can animate when the result is non-empty.

95. `supportUnbindSection` defaults to true and clears injection for sections that leave the manager.

96. Prefer screen-local manager configuration. Global configuration changes should be rare and documented because every new manager copies the static defaults.

97. If an integration remaps section injection actions, document how it interacts with manager configuration flags.

## Integration Recipes

98. For state-driven screens, render a final section array and call `manager.reload(sections)` once.

99. For append-only pagination inside one section, mutate rows through the section, not manager section operations.

100. For adding or removing a whole module, use manager section operations only if the module section instance is stable and currently bound.

101. For modal/edit states that should reset all handlers and counters, rebuild sections and full reload.

102. For local row toggles, update the model and refresh the row. Do not full-reload the manager unless layout structure changes.

103. For row deletion from actions, mutate selection/toolbars before or inside the row deletion transaction.

104. For dynamic headers/footers after row changes, reload the section or rebuild the section when supplementary visibility can change.

105. For animated updates, keep the UIKit operation, model mutation, selection updates, and cache invalidation in one clear transaction.

106. For async render results, discard stale results before applying manager operations. A delayed insert/remove against old section identity will do nothing or target the wrong state.

## Debug Checklist

107. Insert before/after does nothing: verify the anchor section is the exact bound instance.

108. Remove does nothing: verify object identity and that the section is currently in `manager.sections`.

109. Unexpected full reload: inspect `replaceInsertWithReloadData`, `replaceDeleteWithReloadData`, and action converts.

110. Section view access asserts: the section is unbound; use `isBindSectionView` or defer with `taskIfLoaded`.

111. Row refresh does nothing: verify the row is in bounds and the model was written before `refresh(at:)`.

112. Row deletion leaves stale separators: verify trailing rows were reloaded or manually refresh row-position styles.

113. Difference update animates wrong rows: verify the predicate is stable identity, not mutable content.

114. Pending scroll never fires: verify the collection view conforms to the request protocol and emits layout-subviews events with non-zero size.

115. Scroll target wrong after render: resolve section and row after the final render, not before.

116. Old actions fire after state change: either clear handlers or use a fresh section instance for that state.

117. Display-end events are missing after full reload: inspect manager and section skip-display-event flags.

118. Cell access returns nil: the row is offscreen, unbound, or the visible index path no longer matches the section.

## Framework Boundary

119. SectionUI can coordinate binding, forwarding, section identity operations, row transactions, pending scroll retries, and injection-driven collection actions.

120. The app layer owns semantic diffing, stale async result cancellation, durable identity, business state transitions, undo/redo, and product-specific animation policy.

121. Keep transaction examples anonymous and framework-level. Do not encode business routes, event names, module names, product states, downstream source locations, or scan statistics into this skill.
