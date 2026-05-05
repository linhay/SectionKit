# Interaction And State Recipes

This reference captures production recipes for SectionUI cell events, exposure tracking, selection state, incremental updates, prefetching, context menus, and reorder. Keep it generic: no downstream project paths, product names, business module names, source-file indexes, scan statistics, or page names.

## Contents

- [Action Ownership](#action-ownership)
- [Action Context And Ordering](#action-context-and-ordering)
- [Exposure Tracking](#exposure-tracking)
- [Mutations From Events](#mutations-from-events)
- [Reload And Diff Recipes](#reload-and-diff-recipes)
- [Selection Recipes](#selection-recipes)
- [Prefetch And Load More](#prefetch-and-load-more)
- [Context Menu And Reorder](#context-menu-and-reorder)
- [Publishers And Cross-Cutting Observers](#publishers-and-cross-cutting-observers)
- [Debug Checklist](#debug-checklist)
- [Framework Boundary](#framework-boundary)

## Action Ownership

1. Keep navigation, logging, selection, and row mutation near the section that owns the row. `onCellAction` is usually easier to maintain than forwarding every `UICollectionViewDelegate` event back to a controller switch.

2. Use `onCellAction(on: owner, ...)` when a controller or coordinator is captured. It makes weak ownership explicit and avoids repeating `[weak self]` boilerplate.

3. Multiple `onCellAction` handlers for the same kind run in registration order. Use this only when the concerns are independent; combine them into one handler when order is part of the behavior.

4. Use `clearCellAction(_:)` before rebinding a reusable section to a different action policy. Otherwise old handlers remain in the section's event group.

5. Use `onAsyncCellAction` for async work that belongs to the event, but remember it starts a `Task`. Gate duplicate taps and handle cancellation at the feature layer when the operation can outlive the cell.

6. Keep heavy work out of `.config`, `.willDisplay`, and `.selected` handlers. Emit intent from the handler, then let a view model or coordinator perform slow work.

7. Prefer `setCellStyle(on:owner, ...)` for visual-only row styling. Prefer `onCellAction` for events and side effects.

8. Do not let cells own navigation or analytics routing. Cells should render model state and emit UI events through SectionUI.

9. When a section is reused across screens, clear old actions, context menu actions, cancellables, displayed counters, and selection stores before assigning the new owner.

10. For reusable section subclasses, expose small intent closures or publishers instead of letting each controller stack unrelated `onCellAction` handlers.

## Action Context And Ordering

11. `.config` fires after `cell.config(model)` and after `setCellStyle` has applied styles. Use it for final UI adjustment that needs the configured cell.

12. `.willDisplay` fires before the cell becomes visible and then increments `displayedTimes` for that row.

13. `.didEndDisplay` uses `deletedModels` when a row was removed before UIKit ends display. This preserves the model for cleanup and exposure end events.

14. `.selected` and `.deselected` callbacks may not include a live cell view. Use `context.model` and `context.row` as the source of truth; call `context.view()` only for immediate visible-cell work.

15. `SKCContextMenuContext` intentionally does not support `view()`. Build menus from model and row state, not from visible views.

16. `context.row` is section-local. Convert to an `IndexPath` through `context.indexPath` only when UIKit APIs require it.

17. Avoid capturing loop indexes in action closures. Use `context.row` because rows can shift after inserts, deletes, or filtering.

18. If an action can run after a full reload, prefer model identity over row offset when talking to external state.

19. Do not mutate unrelated sections from inside a row event unless the screen owns a clear coordinator. Cross-section effects should usually render from shared state after the event.

20. Use `publishers.cellActionPulisher` for cross-cutting observation only. For local screen behavior, `onCellAction` remains the clearer default.

## Exposure Tracking

21. Use `.onCellAction(.willDisplay)` for simple viewport side effects where repeated display does not matter.

22. Use `model(displayedAt: .first)` for first exposure per row.

23. Use integer, array, or predicate `SKModelDisplayedAt` forms when second, third, or custom repeated exposure has product meaning.

24. `displayedTimes` is row-index based for `SKCSingleTypeSection`. Reset it when replacing the model universe or reusing a section for a new parent model.

25. Reset nested section `displayedTimes` when a parent cell is rebound to a different model. Nested horizontal rows are especially likely to carry stale exposure counters.

26. For custom sections, own a counted store only when the section can define a stable exposure key. Row-based counting is fragile when rows are virtual, filtered, or heterogeneous.

27. Use `displayedTimes.maxCount` when repeated updates past a threshold would create noisy callbacks.

28. Do not use exposure callbacks as the only place to prepare cell data. Exposure can be skipped by fast reloads, offscreen updates, or disabled display-event replay.

29. If exact `didEndDisplay` replay is not needed for a very large refresh, `feature.skipDisplayEventWhenFullyRefreshed = true` can reduce work, but it changes display-end semantics.

30. For business exposure logs, record stable model identity and visible row separately. Row is diagnostic context, not durable identity.

## Mutations From Events

31. Use `context.reload()` for "same model, reconfigure visible row" cases.

32. Use `section.refresh(at:model:)` or `section.refresh(with:)` when the row model changed and only that row needs reload.

33. Use `section.insert`, `section.append`, `section.delete`, or `section.remove` for real collection mutations. Keep source-of-truth arrays synchronized immediately.

34. `remove(_:)` sorts rows descending and reloads trailing rows after deletion. This helps row-dependent separators, first/last rounding, and index-based styles.

35. Use the public `section.pick { ... }` batching helper when several mutations must become one collection update transaction.

36. Do not call `manager.reload(sections)` inside every tap if a row-level `refresh` or `delete` is sufficient.

37. If an event mutates shared state and the render pipeline also listens to that state, choose one update path. Avoid both local section mutation and an immediate full render unless intentionally replacing local animation.

38. When deleting the selected row, update selection state before or during deletion so toolbar/button state does not reflect a removed model.

39. When a row mutation changes cell size, invalidate any `SKHighPerformanceStore` entry for that model identity before refreshing.

40. For optimistic updates, store enough identity to reconcile or rollback even if row offsets shift before the async response returns.

## Reload And Diff Recipes

41. Use `config(models:)` / `apply(_:)` for full replacement when the screen is rerendering from a canonical state object.

42. Use `reloadKind = .normal` for large reshuffles, sort mode changes, or updates where animations add confusion.

43. Use `reloadKind = .difference(by:)` when inserts/deletes should animate and the predicate describes stable identity.

44. Remember that `.difference(by:)` is an identity predicate, not a content equality predicate. Refresh changed rows separately when identity is the same but display content changed.

45. Use `ReloadKind.difference(by: \.id)` for models with stable IDs. Avoid row indexes or display strings as diff identity.

46. Use `.configAndDelete` only when visible cell reconfiguration is enough and count changes are simple. Prefer `.normal` when cell sizes, supplementary views, or decorations also need recalculation.

47. If old and new arrays can be empty, `.difference(by:)` falls back to a section reload. Keep empty-state transitions explicit.

48. After `difference` inserts/deletes, verify selection sequences and exposure counters still match the new model universe.

49. Use `refresh(_ models, predicate:)` for targeted replacement by identity. Keep the predicate deterministic and identity-based.

50. Prefer stable section instances when using incremental section operations. If sections are recreated every render, a full manager reload is simpler and safer.

## Selection Recipes

51. Put selection state in models via `SKSelectionProtocol` when the cell should react directly to selected/enabled/can-select changes.

52. Use `SKSelectionWrapper` when the domain model should remain immutable or shared outside the UI layer.

53. Use `section.selectionSequence(isUnique:)` when section models conform to `SKSelectionProtocol` and the selection store should follow `modelsPulisher`.

54. Subscribe to `selectionSequence.itemChangedPublisher` before expecting item-change callbacks. Observation is created lazily when the publisher is used.

55. Use `reloadPublisher` when external controls need to respond after the entire selection store is replaced.

56. Use `SKSelectionSequence` for row-offset-driven selection, such as a local menu where row order is stable within the section.

57. Use `SKSelectionIdentifiableSequence` for filtered lists, moved rows, or selections that must survive reordered sections.

58. For identifiable selection, call `update` when new selectable models arrive and `remove(id:)` when models leave the selectable universe.

59. `selectedItemsPublisher` on identifiable selection is better for toolbar enablement than polling selected IDs after each tap.

60. In unique mode, selecting one item deselects the others. Avoid manual deselect loops unless additional domain validation is required.

61. Respect `canSelect` and `isEnabled` separately: `canSelect` blocks selection, while `isEnabled` should usually also affect visual affordance.

62. If a cell subscribes to `selectedPublisher`, cancel the old cancellable in `config(_:)` or `prepareForReuse`.

63. When a selected model is deleted, remove it from identifiable selection or reload the offset sequence before reading selected items.

64. For reusable selectable sections, wrap the sequence inside the section abstraction and expose `firstSelectedItem`, `selectedItems`, or `selectedItemsPublisher`.

## Prefetch And Load More

65. Enable manager-level prefetching before relying on section `prefetchPublisher` or `loadMorePublisher`; SectionUI gates prefetch forwarding behind `manager.prefetching.isEnable`.

66. `prefetchPublisher` emits section-local rows. Convert rows to model identities immediately while `section.models` is still in sync.

67. `cancelPrefetchingPublisher` should cancel by model identity when network/image work can survive row movement.

68. `loadMorePublisher` emits when the largest prefetched row reaches the current last item. Gate requests with `isLoading`, `hasMore`, or request state.

69. Avoid using `loadMorePublisher` on an empty section. Load the first page explicitly, then enable prefetch-driven pagination after the list has a stable count.

70. When replacing all models, cancel outstanding prefetch tasks for old identities before accepting prefetch events for the new list.

71. If a section is nested in a reusable cell, clear or replace prefetch subscriptions when the parent cell is rebound.

72. Do not use prefetch as a visibility guarantee. It is an optimization hint and can be cancelled or skipped by UIKit.

73. For image/media prefetch, keep a small identity-keyed task store so cancellation and reuse are deterministic.

74. If load-more fires repeatedly, check request gating first, then verify that prefetch is not being re-enabled during every render without cancelling old sinks.

## Context Menu And Reorder

75. Use `onContextMenu` when menu actions are row/model-specific and belong beside section event wiring.

76. Use `onContextMenu(where:)` to keep conditional menus composable. The first non-`nil` context menu result wins.

77. Use `clearContextMenuActions()` before changing the menu policy of a reused section.

78. Build context menus from `context.model` and `context.row`. `SKCContextMenuContext` does not provide a cell view.

79. Use `SKUIAction` when menu work is async and should stay on the main actor.

80. Return `nil` from a menu provider when the row should not have a menu. Do not return an empty menu as a disabled state unless that visual affordance is intentional.

81. Enable reorder with `onCellShould(.move, true)` or a predicate. Movement eligibility belongs in the section because UIKit asks by index path.

82. The default same-section move swaps two models. Override or wrap the section if the desired behavior is insertion-style reorder.

83. Cross-section move removes from the source section and asserts if a destination single-type section is asked to accept a model it does not own. Handle cross-section moves explicitly.

84. After user reorder, immediately synchronize the canonical model array. A later render from stale state will undo the visible order.

85. Recompute row-dependent cell styles after reorder. Separators, rounded first/last rows, and rank labels often depend on final position.

86. Do not use reorder callbacks to mutate unrelated sections as a side effect. Update source state and rerender dependent sections from that state.

## Publishers And Cross-Cutting Observers

87. `modelsPulisher` is a current-value stream. It emits the current model array to subscribers and every later replacement.

88. `cellActionPulisher` and `supplementaryActionPulisher` are deferred pass-through streams. They are useful for analytics, debug tooling, and cross-cutting observers.

89. Prefer direct `onCellAction` / `onSupplementaryAction` for feature-local behavior because it is easier to find beside the section declaration.

90. Keep Combine cancellables owned by the section owner, view controller, or reusable section abstraction. Do not let section publishers retain stale screens.

91. If a publisher sink writes back to the same section, guard against feedback loops with identity checks, `removeDuplicates`, or a separate render coordinator.

92. Use `@SKPublished(kind: .passThrough)` for one-shot events and default current-value mode for persistent state.

93. Use `SKPublishedValue` inside cell models when a child view should react without replacing the whole section model.

94. When a reusable section is rebound to a new data source, cancel old subscriptions before calling `subscribe(models:)` again.

95. Do not combine `subscribe(models:)` with manual local mutations unless the publisher remains the source of truth and will emit the reconciled result.

## Debug Checklist

96. Tap handler fires twice: inspect duplicate `onCellAction` registrations and missing `clearCellAction`.

97. Tap handler retains old owner: replace manual captures with `onCellAction(on:owner, ...)` and clear actions when rebinding.

98. Exposure missing: verify `.willDisplay` fires, section is bound, row exists, and `feature.skipDisplayEventWhenFullyRefreshed` is not suppressing expected end-display behavior.

99. Exposure fires for old content: reset `displayedTimes` after replacing the model universe or rebinding a nested section.

100. Selection UI stale: verify cells cancel old selection subscriptions and sequence reload/update follows model replacement.

101. Unique selection not working: verify selection changes go through `select` / `toggle`, not direct unrelated UI state.

102. Diff animates incorrectly: check whether the predicate is stable identity rather than content equality.

103. Row refresh does nothing: verify the row is still in bounds and the model was written before `refresh(at:)`.

104. Load-more repeats: verify `manager.prefetching.isEnable`, request gating, cancellable ownership, and empty-section behavior.

105. Context menu missing: verify at least one provider returns non-`nil` and the row is still valid.

106. Reorder does not persist: verify the canonical source array is updated after the visible move.

107. Old menu/actions appear after state change: call `clearContextMenuActions`, `clearCellAction`, or rebuild the section abstraction before rebinding.

108. Async action updates the wrong row: reconcile by model identity, not by the row captured before `await`.

## Framework Boundary

109. Promote a new interaction API into SectionUI only when it is a reusable collection/list primitive.

110. Keep product analytics names, route names, permission prompts, and business-specific menu actions in the integration layer.

111. Prefer section wrappers for repeated selectable lists, diffable lists, action sheets, and menu rows before adding core framework API.

112. Document interaction recipes as ownership and lifecycle rules. Do not encode one downstream app's navigation or event taxonomy as a SectionUI convention.
