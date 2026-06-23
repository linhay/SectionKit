# Forwarding And Extension Recipes

Use this reference when a SectionUI task involves manager forwarding chains, `SKHandleResult`, data source/delegate/flow-layout/prefetch extension points, `SKCSectionInjection`, raw section wrappers, or advanced integration hooks. Keep it generic: no downstream project paths, product names, business module names, source-file indexes, scan statistics, or page names.

## Contents

- [Forwarding Model](#forwarding-model)
- [SKHandleResult](#skhandleresult)
- [Manager Wiring](#manager-wiring)
- [Data Source Forwarding](#data-source-forwarding)
- [Delegate Forwarding](#delegate-forwarding)
- [Flow Layout Forwarding](#flow-layout-forwarding)
- [Prefetch Forwarding](#prefetch-forwarding)
- [Section Injection](#section-injection)
- [Section Wrapper Protocols](#section-wrapper-protocols)
- [Integration Boundaries](#integration-boundaries)
- [Debug Checklist](#debug-checklist)
- [Framework Boundary](#framework-boundary)

## Forwarding Model

1. SectionUI forwarding separates handlers that can provide UIKit return values from observers that only see the final value.

2. Forward handlers are evaluated in reverse registration order. The last added handler gets the first chance to handle.

3. A forward handler returns `.handle(value)` to stop the chain and provide the final value.

4. A forward handler returns `.next` to let earlier handlers or the default implementation decide.

5. Observers run after the final value is resolved.

6. Observers should not be used to change the UIKit answer. They are for analytics, debug, metrics, and lifecycle observation.

7. Put behavior that must affect UIKit return values in the forward lane.

8. Put behavior that should watch SectionUI's decision in the observer lane.

9. Keep forwarding ownership explicit. A screen should know which integration owns selection gating, focus gating, sizing, or prefetch routing.

10. Avoid replacing `collectionView.delegate`, `dataSource`, or `prefetchDataSource` directly after SectionUI manager setup. That bypasses forwarding.

11. Prefer adding a forward/observer object to the manager's existing forwarding chain.

12. If several forward handlers can handle the same callback, document registration order or consolidate the decision.

## SKHandleResult

13. Use `.handle(value)` when the integration fully answers a UIKit callback.

14. Use `.next` when the integration has no opinion.

15. Use `.handleable(optional)` to return `.handle(value)` for a non-nil optional and `.next` for nil.

16. For `Void`, `.handle` is shorthand for `.handle(())`.

17. For `Bool`, `.handle` is shorthand for `.handle(true)`.

18. Do not return `.handle(false)` accidentally when the desired behavior is "no opinion"; use `.next` for no opinion.

19. When a nil value is a meaningful UIKit answer, do not use `handleable`; return `.handle(nil)` from a result type that allows nil.

20. Use `get()` only for local extraction when dropping the chain semantics is intentional.

21. Keep forward handlers pure and fast. UIKit callbacks are synchronous.

22. Avoid network requests, heavy logging, or state-machine transitions inside callbacks that return `SKHandleResult`.

## Manager Wiring

23. `SKCManager(sectionView:)` installs SectionUI forwarding objects as the collection view's delegate, data source, and prefetch data source.

24. `flowLayoutForward` is the collection view delegate and also inherits scroll-view delegate forwarding.

25. `dataSourceForward` is the collection view data source.

26. `prefetchForward` is the collection view prefetch data source.

27. Manager setup adds default SectionUI implementations into the forward chains: `delegate`, `flowlayoutDelegate`, `dataSource`, and `prefetching`.

28. `manager.scrollObserver` is an alias for `flowLayoutForward`.

29. Use `manager.dataSourceForward.add(...)` for advanced data-source integration.

30. Use `manager.flowLayoutForward.add(...)` for delegate, scroll, and flow-layout integration.

31. Use `manager.prefetchForward.add(...)` for prefetch integration.

32. Do not add app-specific forwarding globally unless every collection screen shares the same behavior.

33. Prefer screen-local forwarding objects owned by a controller, coordinator, or reusable component.

34. Store forwarding objects strongly for as long as their callbacks should participate.

35. If forwarding behavior changes during a screen lifecycle, add a small owner object with mutable state rather than repeatedly stacking anonymous handlers.

## Data Source Forwarding

36. The default `SKCDataSource` answers section count, item count, cell creation, supplementary creation, move eligibility, move handling, and index titles from the bound section list.

37. Custom data-source forwards should be rare. Most custom UI belongs in sections.

38. Use data-source forwarding for cross-cutting collection data-source behavior that cannot be expressed by a section.

39. If a custom data-source forward handles `cellForItemAt`, it must dequeue from the collection view using the provided index path.

40. If no data-source forward handles a cell callback, SectionUI returns a debug red fallback cell.

41. A debug fallback cell means the section failed to provide a cell or registration/dequeue failed upstream.

42. Supplementary fallback also returns a debug reusable view when no handler provides a view.

43. Index titles are built from bound sections whose `indexTitle` is non-nil.

44. Index-title lookup returns the section's `indexTitleRow` inside the matching bound section.

45. Reorder callbacks route through source and destination sections. Cross-section behavior must be explicitly supported by the involved sections.

46. Keep data-source observers side-effect-light; UIKit may ask for counts and cells frequently.

## Delegate Forwarding

47. `SKCDelegateForward` handles collection delegate callbacks and inherits scroll forwarding.

48. It supports optional override properties such as `shouldHighlight`, `shouldSelect`, `shouldDeselect`, `canFocus`, and related focus/selection gates.

49. Override properties win before forward handlers are consulted.

50. Use override properties for simple screen-wide boolean policies.

51. Use forward handlers for index-path-specific policy.

52. Default selection, highlight, primary action, display, focus, context menu, editing, and movement behavior is routed from the bound section through `SKCDelegate`.

53. Use section APIs such as `onCellAction`, `onCellShould`, and `onContextMenu` before adding a custom delegate forward.

54. Add delegate observers for metrics, debug tracing, or external instrumentation that should see SectionUI's final decision.

55. Do not perform navigation from a delegate observer if `shouldSelect` or related gating returned false.

56. For primary actions, decide whether navigation belongs in `.selected` or primary-action handling and keep one owner.

57. For focus-driven interfaces, avoid global `canFocus` overrides unless every row follows the same rule.

58. For context menus, prefer section-level menu providers. Delegate forwarding is for integration-level policy.

## Flow Layout Forwarding

59. `SKCDelegateFlowLayoutForward` adds a separate flow-layout forwarding lane and observer lane.

60. The default `SKCDelegateFlowLayout` asks the bound section for item size, section inset, line spacing, interitem spacing, header size, and footer size.

61. Negative item sizes assert and are clamped to non-negative values.

62. Zero item sizes are logged and replaced with a tiny non-zero size for flow layout.

63. Use section safe-size and `preferredSize` contracts before overriding flow-layout forwarding.

64. Use flow-layout forward handlers for collection-wide layout policy that cannot live in a section.

65. Use flow-layout observers to audit measured sizes or spacing without changing layout decisions.

66. Keep flow-layout forwarding compatible with `SKCollectionFlowLayout` plugins. A handler that bypasses section sizing can make plugins look wrong.

67. If a custom flow-layout forward handles sizes, ensure supplementary sizes and decoration spans still match the section contract.

68. Avoid returning `.zero` from custom size handlers unless the item should effectively disappear and the layout can tolerate it.

## Prefetch Forwarding

69. `SKCDataSourcePrefetchingForward` forwards prefetch and cancel-prefetch callbacks.

70. The default `SKCDataSourcePrefetching` routes collection index paths to section-local row arrays.

71. Default prefetch routing is gated by `manager.prefetching.isEnable`.

72. If prefetching is disabled, the default forward handles the callback but does not emit section prefetch work.

73. Enable prefetching before relying on `section.prefetch.prefetchPublisher`, `cancelPrefetchingPublisher`, or `loadMorePublisher`.

74. The manager-level prefetch publishers emit collection index paths; section-level publishers emit section-local rows.

75. Use prefetch observers for diagnostics. Use section-level publishers for feature work.

76. If a custom prefetch forward handles callbacks before the default forward, make sure section prefetch still receives events when needed.

77. Cancel prefetch work by stable model identity, not just row offset, when rows can move or be replaced.

78. Do not treat prefetch as guaranteed visibility. UIKit can skip or cancel it.

## Section Injection

79. `SKCSectionInjection` binds a section to a collection view, manager, and section index.

80. Sections should not mutate `sectionInjection` directly from feature code.

81. `manager.reload` rebuilds the section view provider and binds all sections from index zero.

82. `manager.insert`, `append`, `remove`, and `delete` update injection indexes for the resulting bound section list.

83. `SKCSectionInjection.task(_:)` maps section actions through injection configuration before dispatching to the collection view.

84. `SKCSectionInjection.configuration.converts` can remap actions such as reload, insert items, delete items, and reload data.

85. Use injection converts only at integration boundaries where a whole screen needs a custom update policy.

86. `SKCSectionViewProvider` owns the action handlers for reload, delete, reloadData, insertItems, deleteItems, and reloadItems.

87. `pick` wraps changes in `performBatchUpdates`.

88. `indexPath(from:)` derives item index paths from the current injection index.

89. If a section is unbound, index-path helpers fall back with assertions. Guard with `isBindSectionView` for optional access.

90. Do not cache `sectionInjection.index` across full renders. Resolve after binding or use `SKBindingKey(section)`.

## Section Wrapper Protocols

For exact raw-section wrapper patterns, `SKCAnySingleTypeSectionProtocol` forwarding, identity rules, and lifecycle checklists, read `raw-section-wrapper-recipes.md`.

91. `SKCBaseSectionProtocol` is the minimal collection section surface: action, data source, and delegate protocols.

92. `SKCSectionProtocol` adds flow-layout behavior and type-erased section identity support.

93. `SKCAnySectionProtocol` delegates `itemCount`, injection, and config to an underlying `section`.

94. Use `SKCAnySectionProtocol` for wrapper objects that expose a section without being the raw section itself.

95. `objectIdentifier` defaults to the underlying section identity.

96. `SKCRawSectionProtocol` exposes `rawSection` for wrappers that want fluent style setters on a wrapped raw section.

97. `setSectionStyle` on raw-section wrappers mutates the raw section directly.

98. Use raw-section wrappers to add a focused public surface around a lower-level section without hiding the underlying section lifecycle.

99. If a wrapper recreates its `section` every time, object identity is not stable. Prefer full manager reloads or stable section storage.

100. Keep wrapper `section` access cheap and deterministic.

## Integration Boundaries

101. Reach for section-level APIs first: section actions, cell shoulds, context menus, safe-size providers, supplementary views, and layout plugins.

102. Reach for manager forwarding only when behavior crosses section boundaries or must participate in UIKit's global callback answer.

103. Keep forwarding objects small and named by responsibility.

104. Avoid anonymous forwarding objects with many unrelated callback implementations.

105. Use observer lanes for logging and measurement so default SectionUI behavior remains intact.

106. Use forward lanes for policy.

107. Do not let forwarding objects own business requests. Emit intent to a coordinator or state owner.

108. If a forwarding object owns cancellables, define a clear lifecycle for cancellation.

109. When adding framework APIs, ask whether the behavior can be expressed as a section wrapper, raw-section wrapper, layout plugin, or forwarding object first.

## Debug Checklist

110. Delegate method never fires: verify `collectionView.delegate` still points to SectionUI's `flowLayoutForward`.

111. Data source method never fires: verify `collectionView.dataSource` still points to `dataSourceForward`.

112. Prefetch never fires: verify `prefetchDataSource` is intact, collection prefetching is enabled, and `manager.prefetching.isEnable` is true for default routing.

113. Custom forward does not win: it may have been registered before another handler. Forward evaluation is reverse registration order.

114. Observer changed nothing: observers receive the final value but cannot change it.

115. Unexpected boolean result: check delegate override properties before inspecting forward handlers.

116. Red debug cell appears: inspect section count, item count, cell registration, and whether `item(at:)` returned a cell.

117. Flow layout size is tiny: a section returned `.zero`; inspect `preferredSize`, safe-size limit, and model nil handling.

118. Section action reload becomes reloadData: inspect `SKCSectionInjection.configuration.converts` and manager configuration flags.

119. Incremental section operation misses target: manager insert/remove is based on section object identity.

120. Raw-section wrapper style did not apply: verify `rawSection` is the same instance ultimately bound to the manager.

121. Cached section index is wrong: resolve after `manager.reload` or use a binding key.

122. Cross-section reorder corrupts data: implement explicit source and destination section handling.

## Framework Boundary

123. Promote forwarding helpers into SectionUI only when they are independent of product state, route names, analytics taxonomy, and request clients.

124. Keep screen-specific focus, selection, context menu, and prefetch policies outside generic framework recipes.

125. Document extension recipes as callback ownership and forwarding semantics. Do not encode one downstream app's integration stack.

126. Prefer small forward/observer objects and section wrappers before adding broad manager-level APIs.
