# Container Lifecycle Recipes

Use this reference when a SectionUI task involves `SKCollectionView`, `SKCollectionViewController`, `reloadSections`, `controllerStyle`, `sectionViewStyle`, `ignoresSafeArea`, `refreshable`, layout invalidation, `scrollDirection`, collection-level `pluginModes`, or pending scroll/layout requests.

Keep it generic: no downstream project paths, product names, business module names, source-file indexes, scan statistics, page names, route names, request-client names, or analytics events.

## Contents

- [SKCollectionView Defaults](#skcollectionview-defaults)
- [Manager Ownership](#manager-ownership)
- [Plugin Modes](#plugin-modes)
- [Scroll Direction](#scroll-direction)
- [Request Publishers](#request-publishers)
- [Controller Loading](#controller-loading)
- [Safe Area](#safe-area)
- [Refreshable](#refreshable)
- [Layout Invalidation](#layout-invalidation)
- [Transition Events](#transition-events)
- [Examples](#examples)
- [Debug Checklist](#debug-checklist)
- [Framework Boundary](#framework-boundary)

## SKCollectionView Defaults

1. `SKCollectionView()` creates an `SKCollectionFlowLayout`, initializes the collection, and attaches an `SKCManager`.

2. `SKCollectionView.manager` is lazy and is created with the collection view as its section view.

3. `SKCollectionView` conforms to `SKCRequestViewProtocol`.

4. `layoutSubviews()` sends `requestPublishers.layoutSubviews`.

5. The default initializer disables both vertical and horizontal scroll indicators.

6. If the background color is black during initialization, SectionUI changes it to white.

7. `translatesAutoresizingMaskIntoConstraints` is set to false.

8. A coder-based `SKCollectionView` replaces its layout with `SKCollectionFlowLayout` during initialization.

## Manager Ownership

9. Let `SKCollectionView` own its `SKCManager` for the collection surface.

10. Do not replace the collection view's `delegate`, `dataSource`, or `prefetchDataSource` after manager setup unless intentionally bypassing SectionUI.

11. Use `sectionView.manager.reload(...)` for manual collection view integration.

12. Use `SKCollectionViewController.reloadSections(...)` when the controller may not have loaded yet.

13. Do not share one manager across multiple collection views.

14. Keep section references only when later code must refresh, scroll, observe, select, or mutate that same section instance.

## Plugin Modes

15. `sectionView.set(pluginModes:)` stores collection-level `SKCLayoutPlugins.Mode` values.

16. Collection-level modes are combined with section-level layout plugins during `SKCollectionFlowLayout.fetchPlugins`.

17. Collection-level modes are placed before collected section-level modes.

18. Section-level plugins are collected only from bound sections conforming to both `SKCSectionLayoutPluginProtocol` and `SKCSectionActionProtocol`.

19. Use collection-level modes for screen-wide layout contracts.

20. Use section-level plugins or `setAttributes` for behavior owned by one section.

21. Changing plugin modes affects later layout passes. Invalidate layout or reload when the change must apply immediately.

22. If the active layout is not `SKCollectionFlowLayout`, SectionUI's layout plugin system may not run.

## Scroll Direction

23. `sectionView.scrollDirection` writes to `UICollectionViewFlowLayout.scrollDirection` when the layout is a flow layout.

24. `sectionView.scrollDirection` writes to `UICollectionViewCompositionalLayout.configuration.scrollDirection` when the layout is compositional.

25. Unknown layout types assert and return `.vertical` on read.

26. Set scroll direction before measuring sections when safe-size, alignment, pinning, or layout plugins depend on direction.

27. After changing scroll direction, invalidate layout and consider refreshing sections whose safe-size math depends on direction.

## Request Publishers

28. `SKCManager(sectionView: UICollectionView & SKCRequestViewProtocol)` subscribes to layout-subviews events.

29. Manager pending requests, such as delayed scroll, retry only after a non-zero frame layout-subviews signal.

30. Layout-subviews request retries are throttled on the main run loop.

31. Store returned `SKRequestID` values when user intent may need cancellation.

32. A plain `UICollectionView` initializer for manager does not provide layout-subviews retry support.

33. Use `SKCollectionView` when pending scroll after load/layout matters.

## Controller Loading

34. `SKCollectionViewController` owns a lazy `sectionView = SKCollectionView()`.

35. `manager` is a computed shortcut to `sectionView.manager`.

36. `viewDidLoad` runs registered `viewDidLoad.before` endpoints before `super.viewDidLoad()`.

37. `viewDidLoad` sets the controller view background to white when it is nil.

38. `viewDidLoad` adds `sectionView` and creates top, bottom, left, right constraints.

39. `viewDidLoad` runs registered `viewDidLoad.after` endpoints after constraints are installed.

40. `controllerStyle` runs immediately when `isViewLoaded` is true.

41. `controllerStyle` queues its block as a `viewDidLoad.after` endpoint when the view is not loaded.

42. `sectionViewStyle` is a controller style wrapper that passes the loaded `sectionView`.

43. `reloadSections(section)` delegates to `reloadSections([section])`.

44. `reloadSections(sections)` queues through `controllerStyle`, so it is safe before the view loads.

45. When called after load, `reloadSections` runs immediately.

46. Keep expensive section construction outside queued style blocks. Queue only the binding/reload step when possible.

## Safe Area

47. By default, the collection top is constrained to `view.safeAreaLayoutGuide.topAnchor`.

48. Left and right are constrained to the safe area.

49. Bottom is constrained to the controller view bottom.

50. Top constraints use default-low priority.

51. `ignoresSafeArea()` sets `isIgnoresSafeArea = true`, activates the direct top-to-view constraint, and deactivates the safe-area top constraint when available.

52. `ignoresSafeArea()` is safe before or after view load.

53. Because left/right remain safe-area constrained, `ignoresSafeArea()` only changes the top edge behavior.

54. If a screen needs full-bleed left/right behavior, provide explicit controller/container layout rather than assuming `ignoresSafeArea()` changes every edge.

## Refreshable

55. `refreshable(action:)` creates a `UIRefreshControl`, sets it on `sectionView.refreshControl`, and stores the async action.

56. Pull-to-refresh calls `refreshAction`.

57. `refreshAction` launches a main-actor `Task`, awaits the stored action, then calls `endRefreshing()`.

58. If the async action never returns, the refresh control never ends.

59. Handle errors inside the refresh action. The stored action is `async -> Void`, not throwing.

60. If the refresh action updates section models, call section mutation APIs or `reloadSections` inside the action before it returns.

61. Avoid starting multiple independent refresh tasks from the same refresh action unless they are coordinated.

## Layout Invalidation

62. `viewDidLayoutSubviews` invalidates the collection layout on every layout pass.

63. Avoid adding expensive work to controller layout callbacks; SectionUI already invalidates layout there.

64. `viewWillTransition` runs `viewTransition.before` endpoints before calling `super`.

65. During non-Catalyst transitions after view load, SectionUI invalidates layout inside the transition animation block.

66. `viewTransition.animate` endpoints run inside the transition animation block.

67. `viewTransition.after` endpoints run in the transition completion block.

68. On macCatalyst, transition handling invalidates layout and returns without animation/after endpoint execution.

69. If a transition changes section models, coordinate it with layout invalidation and avoid nested reloads from every layout pass.

## Transition Events

70. `onAppear` appends a `viewDidAppear.after` endpoint.

71. `viewDidAppear` runs before endpoints before `super.viewDidAppear`, then after endpoints.

72. Use `onAppear` for lightweight appearance work.

73. Keep durable data loading ownership in the feature layer or refresh flow, not hidden in repeated appearance callbacks.

74. Transition endpoints are controller-level lifecycle hooks. Use section actions for row/supplementary lifecycle.

## Examples

Queue sections before the controller is loaded:

```swift
let controller = SKCollectionViewController()
controller
    .sectionViewStyle { view in
        view.scrollDirection = .horizontal
    }
    .reloadSections(sections)
```

Configure collection-wide plugins:

```swift
controller.sectionViewStyle { sectionView in
    sectionView.set(pluginModes: [
        .decorations(decorationModes)
    ])
}
```

Pull-to-refresh with explicit section update:

```swift
controller.refreshable {
    let models = await store.fetchLatest()
    section.apply(models)
}
```

Manual collection view integration:

```swift
let sectionView = SKCollectionView()
sectionView.scrollDirection = .vertical
sectionView.manager.reload(sections)
```

## Debug Checklist

75. Reload before load does nothing: use `reloadSections` on `SKCollectionViewController`, or ensure `sectionView.manager.reload` runs after the view exists.

76. Scroll request never executes: use `SKCollectionView` so layout-subviews request publishing is available, and verify non-zero frame.

77. Pull-to-refresh spinner never stops: ensure the async action returns.

78. Pull-to-refresh updates data but UI is stale: call `section.apply`, row mutation APIs, or `reloadSections` inside the refresh action.

79. Plugin does not run: verify the collection uses `SKCollectionFlowLayout` and plugin modes are set before layout invalidation.

80. Plugin affects every section unexpectedly: move behavior from collection-level `set(pluginModes:)` to section-level plugins.

81. Safe-area top is wrong: inspect `ignoresSafeArea()` timing and active top constraints.

82. Full-bleed horizontal layout still has side inset: `ignoresSafeArea()` does not change left/right constraints.

83. Layout work repeats too often: remember `viewDidLayoutSubviews` invalidates layout on every pass.

84. Transition callback missing on Catalyst: macCatalyst path invalidates layout and returns early.

85. Scroll direction change produces wrong cell sizes: refresh/reload sections whose safe-size math depends on flow direction.

## Framework Boundary

86. Promote container helpers into SectionUI only when they describe generic lifecycle, layout, or manager-binding mechanics.

87. Keep screen-specific loading, routing, analytics, and product-state transitions outside generic container recipes.

88. Document containers as lifecycle and ownership contracts, not as downstream page structure.
