# Navigation And Scroll Recipes

Use this reference when a SectionUI task involves scroll observation, display tracking, pending scroll requests, scroll-to-section/row, pin state, paging, nested scroll coordination, zoomable content, or scroll synchronization debugging. Keep it generic: no downstream project paths, product names, business module names, source-file indexes, scan statistics, or page names.

## Contents

- [Scroll Observation](#scroll-observation)
- [Delegate Forwarding](#delegate-forwarding)
- [Display Tracking](#display-tracking)
- [Programmatic Scroll](#programmatic-scroll)
- [Pinned Elements](#pinned-elements)
- [Page Manager](#page-manager)
- [Zoomable Content](#zoomable-content)
- [Synchronization Recipes](#synchronization-recipes)
- [Debug Checklist](#debug-checklist)
- [Framework Boundary](#framework-boundary)

## Scroll Observation

1. Use `manager.scrollObserver.add(scroll: "stable-id")` for replaceable scroll observation blocks.

2. Re-adding an observer block with the same id replaces the previous `SKScrollViewDelegateHandler` observer.

3. Use `.onChanged` for every content-offset change. Keep work inside this callback lightweight.

4. Use `.onDrag(began:changed:ended:)` for user-drag lifecycle state such as pausing timers or dismissing transient UI.

5. Use `.onDecelerate(began:changed:ended:)` for work that should follow momentum scrolling.

6. Do not rely on `.onAnimation` as an animation-completion hook in the current implementation. It is registered with ordinary scroll callbacks, while `scrollViewDidEndScrollingAnimation` dispatches a separate internal list.

7. Use `.onZoom` only when the observed scroll view supports zooming.

8. `SKScrollViewDelegateHandler.isEnabled` disables callback dispatch without removing the handler.

9. Prefer one stable observer id per responsibility, for example navigation collapse, load trigger, or toolbar visibility. Do not put unrelated behavior behind one id.

10. If the owner is a reusable cell or nested component, replace the observer during rebinding and clear its cancellables when the component is reused.

11. Throttle or debounce expensive UI updates outside `SKScrollViewDelegateHandler`; the handler itself does not coalesce `onChanged` events.

12. Do not call network requests directly from `onChanged`. Convert scroll position into state, then let request gating own the network work.

## Delegate Forwarding

13. `SKScrollViewDelegateForward` has two lanes: forward handlers that may handle delegate return values, and observers that receive the resolved value.

14. Forward handlers are evaluated in reverse registration order. The first `.handle(value)` wins; `.next` passes control to earlier handlers.

15. Observers run after forward resolution and receive the value returned by the forward lane.

16. Use a forward handler only when you need to provide delegate return values such as `viewForZooming(in:)` or `scrollViewShouldScrollToTop`.

17. Use observer handlers for analytics, visual state, display tracking, and ordinary scroll callbacks.

18. Observer blocks are normally replaced by re-adding the same stable id. Treat `remove(id:)` cautiously; it targets the forward lane and does not remove ordinary observer blocks.

19. If multiple integrations need `scrollViewShouldScrollToTop`, document which forward handler owns the final boolean.

20. Avoid installing a second direct `UIScrollViewDelegate` on the collection view; it bypasses SectionUI forwarding.

21. When adding a raw `UIScrollViewDelegate` with `manager.scrollObserver.add(delegate)`, treat it as observation through `SKScrollViewDelegateObserverBox`, not as the owner of delegate return values.

## Display Tracking

22. Use `SKCDisplayTracker` when visible cells, headers, or footers should drive menu selection, table-of-contents highlighting, exposure aggregation, or deferred work.

23. Register the tracker with `manager.scrollObserver.add(tracker)` before subscribing to its publishers.

24. The tracker updates on `scrollViewDidScroll`, `scrollViewDidEndDecelerating`, and non-decelerating drag end.

25. The tracker only updates when the observed scroll view is a `UICollectionView`.

26. `displayedCellIndexPaths`, `displayedHeaderIndexPaths`, and `displayedFooterIndexPaths` publish raw visible index paths.

27. Build `TopSectionForVisibleAreaItem` from final bound section instances, not from pre-render module inputs.

28. The item stores the section weakly. Keep the section alive elsewhere when display tracking depends on it.

29. `sectionsForVisibleArea` returns matching section tags ordered by visible section index.

30. `topSectionForVisibleArea` returns the first visible section among cells, headers, and footers.

31. `indexPathsForVisibleArea` returns header, cell, and footer results, then sorts them by section index and supplementary order.

32. `topCellIndexPathForVisibleArea` uses item layout attributes to find the top visible cell row among the tracked sections.

33. Rebuild display-tracker item lists after any render that replaces section instances.

34. Use item `tag` and `label` as UI-neutral identifiers. Do not encode route names or analytics event names in framework-level docs.

35. If a section can disappear in empty/error/loading state, make the tracker subscription tolerate missing results.

36. Store tracker cancellables with the screen or component that owns the section list.

## Programmatic Scroll

37. Use `section.scroll(to: row, at: position, offset: offset, animated: animated)` when the caller already owns the bound section instance.

38. Use `manager.scroll(to: section, row: row, at: position, offset: offset, animated: animated)` when the scroll may need to wait until layout has non-zero size.

39. Manager scroll returns an optional `SKRequestID`. A non-nil request means the scroll was queued for a later layout pass.

40. Keep the returned request when user intent may be superseded by another request; cancel or replace older requests at the feature layer.

41. Section scroll requires a bound section, visible window, non-zero collection size, and real layout attributes.

42. Scroll by section instance instead of cached integer section index after full renders.

43. Use `scroll(to: .header/.footer/.cell, at:offset:animated:)` when targeting structural elements.

44. Use `scrollToTop(animated:)` and `scrollToBottom(animated:)` only when the section has at least one item.

45. For `Equatable` models, `scroll(toFirst:)` and `scroll(toLast:)` are useful only while the model array still represents the displayed section state.

46. Offset-based scroll computes a content offset from layout attributes. Prefer this for fixed navigation bars, pinned controls, or custom alignment.

47. When `offset` is nil, row scroll temporarily disables collection paging if needed, calls `scrollToItem`, then restores paging.

48. Default scroll position follows flow-layout direction: vertical uses `.top`, horizontal uses `.left`.

49. Do not issue scroll requests before `manager.reload(sections)` has bound the target section unless you intentionally use manager pending requests.

50. After data reload, defer target lookup until the final section and model arrays are known.

51. For deep links, store semantic target identity first, then resolve to section and row after render.

52. If the target row can be removed during refresh, treat the scroll as optional and clear the pending request.

## Pinned Elements

53. Use `pinHeader`, `pinFooter`, or `pinCell(at:)` on sections that conform to `SKCSectionLayoutPluginProtocol`.

54. Store the returned `AnyCancellable`. Releasing it disables the pin layout plugin.

55. `SKCSectionPinOptions.section` resolves through a binding key, so section index can follow a bound section after manager reload.

56. `padding` is the target distance from the collection content offset, commonly used for safe area or existing fixed chrome.

57. `isEnabled` disables pin behavior while preserving the plugin and its subscriptions.

58. `distance` publishes the distance from the target pin point before it becomes pinned.

59. `isPinned` publishes pinned state with duplicate removal.

60. Use `customAdjust` for layout-attribute changes such as alpha, transform, or size changes tied to distance.

61. Keep `customAdjust` purely visual. Do not mutate section data, selection, or request state from layout calculation.

62. Do not mix SectionUI pin APIs with `UICollectionViewFlowLayout` built-in header/footer pinning in the same collection.

63. For stacked sticky elements, compute later `padding` from earlier sticky element heights.

64. Prefer `pinCell(at:)` for filter bars or segment rows that are real cells. Prefer `pinHeader`/`pinFooter` for structural supplementary views.

65. If a pinned element disappears near viewport edges, verify its layout attributes exist and the section/row/kind are valid.

66. Use `options.$distance` for progressive effects before the element reaches the pin point.

67. Use `options.$isPinned` for discrete state such as shadow, separator, or accessibility announcement changes.

68. When a pinned row can move after insertion/deletion, update the row target or recreate the pin subscription.

## Page Manager

For exact page child identity/cache, `selection`/`current` binding, `SKPageViewController` rebuild lifecycle, `SKZoomableScrollView`, tap actions, and pan-to-dismiss behavior, read `page-zoom-recipes.md`.

69. Use `SKPageManager` and `SKPageViewController` for controller-level paging, not for a simple horizontal row inside a collection.

70. Configure `scrollDirection`, `spacing`, `childs`, and initial `selection` before binding to UI when possible.

71. Use stable child ids. Controller cache keys are child ids, and stale ids make page restoration and cache cleanup ambiguous.

72. Use `Child.withController(id:)` when the child maker must run on the main actor.

73. `Child(id:maker:)` can return either a `UIViewController` or a `UIView`; view children are wrapped in an internal box controller.

74. `selection` is the source for programmatic page switching.

75. `current` publishes `ChildContext` for the current id, index, and cached controller when available.

76. The manager updates `current` from `selection` and `childs` even before a page controller is bound.

77. `makePageController()` caches and returns the existing `UIPageViewController` after the first bind.

78. Use `unbind()` when the page manager leaves its owning UI lifecycle and cached child controllers should be released.

79. `clearCache()` removes cached child wrappers without changing child definitions.

80. Mutating `childs` removes controller cache entries whose ids no longer exist.

81. With `SKPageViewController`, changes to `scrollDirection`, `spacing`, or `childs` are debounced and cause `renderUI()` when children exist.

82. When embedding `SKPageViewController`, create it, call `set(manager:)`, then add it as a child view controller.

83. Do not rely on non-existent paging flags in `SKPageManager`; paging behavior comes from `UIPageViewController`.

84. If selection is out of range, `current` becomes nil. Clamp selection after removing or replacing children.

85. Avoid rebuilding child ids on every render. Stable ids are the boundary between page identity and page content updates.

## Zoomable Content

86. Use `SKZoomableScrollView` for content that needs pinch/double-tap zoom and optional pan-to-dismiss behavior.

87. A zoomable content view can conform to `SKZoomableContentView` and provide a `SKZoomableContext`.

88. `wrapperToZoomableView()` wraps a `UIView` conforming to `SKZoomableContentView`.

89. Set `zoomableContext.size` to the intrinsic content size before relying on layout.

90. `zoomableContext.zoomScale` publishes the current scroll-view zoom scale.

91. `singleTapAction` and `longPressAction` enable their gestures only when a closure exists. Double tap stays available for either a custom action or the default zoom toggle.

92. Without a custom double-tap action, double tap toggles between zoomed-in and reset states.

93. `panToDismiss` only begins for downward, mostly vertical gestures while the internal scroll view is at top.

94. Use `PanToDismiss.alphaPublisher` when surrounding chrome should fade in sync with the drag.

95. Keep zoomable content ownership separate from list section ownership. Do not let a reusable cell retain a stale zoom context for a different model.

## Synchronization Recipes

96. For menu highlight while scrolling, derive final sections, register `SKCDisplayTracker`, then subscribe to `topSectionForVisibleArea`.

97. For tapping a menu item, resolve the target section from the same final section list and call manager scroll with an offset for fixed chrome.

98. For pinned menu plus display tracking, pin the real menu row or header, and use tracker output only for selection state.

99. For refresh followed by restore position, keep a semantic target id, rerender, resolve the target to section/row, then issue a manager scroll request.

100. For load-more triggered by scroll, prefer section prefetch/load-more publishers when the trigger is row proximity; use scroll observers when the trigger is raw viewport position.

101. For nested horizontal sections, keep inner scroll observation local to the nested collection. Outer navigation state should only depend on deliberate child events.

102. For controller paging plus list tracking, let `SKPageManager.selection/current` own page identity and let each page own its own SectionUI tracker.

103. For programmatic scroll plus completion work, prefer explicit feature-level completion state or a custom delegate-forward observer; do not depend on `.onAnimation` until its implementation is verified.

104. For exposure aggregation, use display tracker for currently visible structural state and cell/supplementary actions for exact lifecycle events.

105. For sticky headers that change appearance while scrolling, use pin `distance` and `isPinned` instead of duplicating threshold math in `onChanged`.

## Debug Checklist

106. Scroll observer does not fire: verify `manager` is bound to the collection view and no direct delegate replaced SectionUI forwarding.

107. Observer replacement fails: verify the same stable id is passed to `add(scroll: "id")`.

108. Removal by id does not affect an observer block: observer blocks are replaced by id; `remove(id:)` targets the forward lane.

109. Display tracker stays empty: verify the observed scroll view is a collection view and has visible cells or supplementary views.

110. Top section is nil: rebuild `TopSectionForVisibleAreaItem` with currently bound sections and keep section instances alive.

111. Top cell result is wrong: ensure target sections have layout attributes and the layout has completed.

112. Programmatic scroll returns a pending request forever: check the collection is in a window, has non-zero bounds, and the target attributes exist.

113. Scroll lands under fixed chrome: use the `offset` parameter instead of manually mutating content offset afterward.

114. Pinned element flickers: disable native flow-layout pinning and verify only one pin system owns that element.

115. Pinned row targets the wrong item after mutation: update the row index or recreate the pin subscription after row changes.

116. Page selection does not switch UI: verify the manager is bound through `SKPageViewController` or a page controller created by `makePageController()`.

117. Page current controller is nil: the current page may not have been created yet; rely on id/index unless the controller must already be visible.

118. Child controller cache is stale: use stable ids, mutate child arrays through manager APIs, or call `clearCache()` / `unbind()` at lifecycle boundaries.

119. Zoomable content lays out as zero: set `SKZoomableContext.size` and ensure the wrapper has non-zero bounds.

120. Pan-to-dismiss conflicts with vertical content scroll: the gesture only begins at top; verify `contentOffset.y <= 0` and velocity direction.

## Framework Boundary

121. Promote scroll helpers into SectionUI only when they are independent of app chrome, route names, analytics taxonomy, and visual brand.

122. Keep page ids, menu tags, exposure labels, and scroll target identifiers semantic but product-neutral in framework-level examples.

123. Prefer documenting coordination recipes before adding new APIs for a single screen's navigation behavior.

124. Keep downstream-specific tab structures, fixed-header heights, event names, and page restoration policies outside the generic skill.
