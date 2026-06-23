# View Cell And Container Recipes

Use this reference when a SectionUI task involves load protocols, `SKLoadViewProtocol`, `SKConfigurableView`, nib identifiers, configurable view contracts, adaptive sizing, wrapper cells/views, supplementary wrappers, `SKCollectionView`, `SKCollectionViewController`, or UIKit/SwiftUI bridges. Keep it generic: no downstream project paths, product names, business module names, source-file indexes, scan statistics, or page names.

## Contents

- [Load Protocols](#load-protocols)
- [Configurable View Contracts](#configurable-view-contracts)
- [Adaptive Sizing](#adaptive-sizing)
- [Wrapper Cells And Views](#wrapper-cells-and-views)
- [Supplementary Wrappers](#supplementary-wrappers)
- [Collection Containers](#collection-containers)
- [SwiftUI Bridges](#swiftui-bridges)
- [Reuse And Ownership](#reuse-and-ownership)
- [Debug Checklist](#debug-checklist)
- [Framework Boundary](#framework-boundary)

## Load Protocols

1. A SectionUI collection cell must conform to `SKLoadViewProtocol` so the section can register and dequeue it by identifier.

2. `SKLoadViewProtocol` supplies `identifier` and optional `nib`. It does not define sizing; sizing comes from `SKConfigurableLayoutProtocol`.

3. The default `SKLoadViewProtocol.identifier` is `String(reflecting: Self.self)`, which includes the module-qualified name.

4. `SKLoadNibProtocol.identifier` is `String(describing: Self.self)`, matching common xib reuse identifiers.

5. `SKLoadNibProtocol.nib` loads a nib whose name matches `String(describing: Self.self)`.

6. For Swift Package resources, `SKLoadNibProtocol.bundle(of:)` searches likely generated resource bundles before falling back to `Bundle(for:)`.

7. Use `SKLoadNibProtocol.loadFromNib` only when you need to instantiate a view directly. Section registration uses `nib` automatically.

8. If a nib-backed cell fails to dequeue, check nib name, reuse identifier, target class, module, and bundle first.

9. Override `identifier` only when integrating an existing nib or storyboard with a fixed reuse id.

10. Keep cell and supplementary identifiers stable across app versions. Changing them without updating nib reuse identifiers breaks runtime dequeue.

11. Use code-backed cells for simple and highly reused rows; use nib-backed views when the view already exists in xib form and the team maintains it there.

12. Avoid mixing nib and code setup paths for one view type unless both paths are tested.

## Configurable View Contracts

13. `SKConfigurableView` combines `SKConfigurableModelProtocol` and `SKConfigurableLayoutProtocol`.

14. `config(_:)` renders model state into the view. It should be idempotent and safe to call repeatedly during reuse.

15. `preferredSize(limit:model:)` returns the final rendered size for the given measuring limit.

16. Always handle `model == nil` defensively in `preferredSize`; returning `.zero` is usually the safest default.

17. Keep model rendering in `config(_:)`. Keep list-position visuals in `setCellStyle`.

18. `Model == Void` gets a default no-op `config`, useful for spacers, dividers, and static chrome.

19. `SKConfigurableView` supports configuring with a `RawRepresentable` when the view model is the raw value type.

20. Use small value models for cells. Avoid models that retain controllers, views, request clients, or navigation closures.

21. If a cell needs callbacks, expose them through section actions or a coordinator, not through model-owned view closures unless ownership is explicit.

22. If a cell owns Combine subscriptions, reset cancellables before binding a new model.

23. Keep `preferredSize` side-effect free. It may be called often, off the visible path, and before a cell instance is displayed.

24. Do not rely on visible cell state inside `preferredSize`. Measure from model and limit only.

25. Prefer one sizing strategy per cell: manual constants, adaptive Auto Layout, or cached high-performance sizing.

## Adaptive Sizing

26. Use `SKConfigurableAutoAdaptiveView` when a UIKit view/cell can be measured from Auto Layout after `config(_:)`. For exact fitting-priority, content-key-path, auto-cache, and stale-size rules, read `adaptive-sizing-recipes.md`.

27. `SKConfigurableAutoAdaptiveView` caches one `SKAdaptive<Self, Model>` per view type in `SKConfigurableAdaptiveAutoCache`.

28. Use `SKConfigurableAdaptiveView` when the adaptive measurement should use a separate adaptive view or custom `SKAdaptive` configuration.

29. Use `SKConfigurableAdaptiveMainView` when the view itself is the adaptive view and you want to declare a static `adaptive`.

30. `SKAdaptive` configures the adaptive view, calls Auto Layout fitting, optionally reads a content view's frame, then adds configured insets.

31. Default vertical adaptive mode uses required horizontal fitting and fitting-size vertical priority.

32. Default horizontal adaptive mode uses fitting-size horizontal priority and required vertical fitting.

33. Set `content` when a subview's laid-out frame should override fitting-size output for one axis.

34. Use `insets` in `SKAdaptive` for measurement padding, not extra invisible constraints inside the cell.

35. `adaptiveWidthFittingSize` is deprecated beta. Prefer the normal `preferredSize(limit:model:)` path.

36. If adaptive size returns zero, verify the model is non-nil, the limit is non-zero, constraints are complete, and the content view has a measurable frame.

37. Adaptive measurement reuses an adaptive view instance. Keep its `config(_:)` reset-safe and independent of visible cell state.

38. For expensive adaptive cells, combine adaptive sizing with `SKHighPerformanceStore` and stable cache IDs.

39. Avoid adaptive sizing for truly fixed rows. Fixed-size fast paths are clearer and cheaper.

40. When dynamic type or content expansion changes adaptive size, invalidate size cache before refreshing rows.

## Wrapper Cells And Views

For exact runtime view ownership, `SKCAnyViewCell`, `SKWrapperView`, wrapper cell/reusable sizing, nib behavior, and reuse debugging, read `runtime-view-wrapper-recipes.md`.

41. Use `View.wrapperToCollectionCell()` when a reusable `UIView` already conforms to `SKLoadViewProtocol` and `SKConfigurableView`.

42. `SKCWrapperCell<View>` delegates `preferredSize` and `config` to the wrapped view.

43. `SKCWrapperCell` loads the wrapped view from `View.nib` when available; otherwise it uses `View()`.

44. The wrapped view is pinned to the cell content view edges.

45. Use wrapper cells for reusable UI units that should not know about collection-cell lifecycle.

46. Prefer a real `UICollectionViewCell` when the row needs selected background, focus, editing, reorder affordance, complex reuse cleanup, or cell-specific lifecycle.

47. Use `SKWrapperView<Content, UserInfo>` when a plain `UIView` needs SectionUI sizing, insets, and configuration without creating a dedicated cell.

48. `SKWrapperView.Model` owns `userInfo`, `insets`, a `size` closure, and a `style` closure.

49. For `Content: SKConfigurableView`, `SKWrapperView.Model(userInfo:insets:)` delegates size and config to the content view and adds insets consistently.

50. `SKWrapperView.config(_:)` applies style and updates edge constraints from model insets.

51. Use wrapper views for labels, spacers, dividers, buttons, banners, and lightweight embedded components.

52. Keep wrapper `style` closures idempotent. They can run many times as cells are reused.

53. Do not put navigation, request work, or analytics inside wrapper `style`; route those through section actions.

54. If a wrapper model carries closures, ensure they do not retain stale screen owners.

55. If a simple wrapper grows selection, reuse, accessibility, or state-management special cases, promote it to a typed view or cell.

## Supplementary Wrappers

56. Use `View.wrapperToCollectionReusableView()` when a reusable view should be used as a header/footer.

57. `SKCWrapperReusableView<View>` delegates `preferredSize` and `config` to `View`.

58. `SKCWrapperReusableView` currently initializes `wrappedView` with `View()` and does not instantiate `View.nib`.

59. Use a direct reusable view conforming to `SKLoadViewProtocol` when a nib-backed supplementary view is required.

60. Supplementary wrapper constraints use default-high priority, which helps avoid hard conflicts with external sizing.

61. Keep header/footer configuration structural. Do not hide full screen states inside supplementary views.

62. For supplementary size changes, reload the section or supplementary path so flow layout recalculates.

63. Pair supplementary wrappers with `supplementarySafeSize` when their measurement envelope differs from cell measurement.

## Collection Containers

64. Use `SKCollectionView()` for a prewired collection view with `SKCollectionFlowLayout` and an attached `SKCManager`. For exact controller loading, queued reload, safe-area, refreshable, layout invalidation, and plugin-mode rules, read `container-lifecycle-recipes.md`.

65. `SKCollectionView.manager` is created with the collection view as its section view.

66. `SKCollectionView` sends `requestPublishers.layoutSubviews` from `layoutSubviews`, enabling pending manager requests such as delayed scroll.

67. `scrollDirection` sets flow layout direction or compositional layout configuration direction depending on the active layout type.

68. `set(pluginModes:)` configures collection-level layout plugins. Section-level plugins are collected from bound sections and appended after collection-level modes.

69. `collectSectionLayoutPlugins()` only includes sections that conform to both `SKCSectionLayoutPluginProtocol` and `SKCSectionActionProtocol`.

70. `SKCollectionView` defaults to no scroll indicators and clears black background to white during initialization.

71. Use a custom collection view layout only when SectionUI's flow-layout plugin model cannot express the required behavior.

72. If a custom layout is used, verify which SectionUI plugins and delegate forwarding paths still apply.

73. Use `SKCollectionViewController` when the screen is primarily a SectionUI collection screen and the default full-screen collection layout is acceptable.

74. `SKCollectionViewController.viewDidLoad` installs `sectionView` constrained to safe area by default.

75. `ignoresSafeArea()` switches the top constraint from safe-area top to view top. Call it before or after load; the constraints are toggled when available.

76. `sectionViewStyle` and `controllerStyle` queue work until `viewDidLoad` when needed.

77. `reloadSections` queues manager reload until the controller view is loaded.

78. `refreshable` attaches a `UIRefreshControl` and ends refreshing after the async action completes.

79. `viewDidLayoutSubviews` invalidates the collection layout. Avoid adding expensive work there from controller events.

80. `viewWillTransition` invalidates layout during transition and runs registered transition endpoints.

81. Use `onAppear` for simple view-appearance hooks, but keep data loading ownership explicit in the feature layer.

## SwiftUI Bridges

82. Use `UIView.sk.toSwiftUI(make:update:)` to wrap a UIKit view in SwiftUI through `SKUIView`.

83. The view bridge's `make` receives a SwiftUI `Context`; `update` receives the existing view and context.

84. Use `UIViewController.sk.toSwiftUI(make:update:)` to wrap a UIKit view controller through `SKUIController`.

85. The controller bridge's `make` does not receive context; use `update` for SwiftUI state changes.

86. Keep UIKit view/controller ownership clear. SwiftUI can call `update` frequently.

87. Do not rebuild expensive SectionUI managers from every SwiftUI update. Update existing state or section models instead.

88. For a SectionUI collection embedded in SwiftUI, decide whether SwiftUI state or SectionUI section state is the source of truth.

89. Avoid two-way binding loops between SwiftUI state and `@SKPublished` without identity guards.

## Reuse And Ownership

90. Reusable views should reset visual state, subscriptions, async tasks, and gesture state when configured with a new model.

91. A SectionUI cell model should describe render state, not own UIKit view instances unless using explicit any-view migration patterns.

92. Long-lived section instances must clear old actions and cancellables before being rebound to a different owner.

93. Nib-backed views should keep IBOutlet assumptions local to the view. Section declarations should not depend on nib internals.

94. Wrapper views should not become dumping grounds for business logic. Promote repeated behavior into typed components.

95. Container helpers should own layout and binding; feature coordinators should own navigation, requests, and analytics.

## Debug Checklist

96. Dequeue fails: verify registration happened after binding, identifier matches, nib reuse id matches, and the dequeued class conforms to the expected type.

97. Nib-backed cell not loading: check `SKLoadNibProtocol`, nib name, module, target membership, and Swift Package resource bundle.

98. Wrapper reusable view ignores nib: `SKCWrapperReusableView` uses `View()`. Use a direct nib-backed supplementary view if needed.

99. `preferredSize` crashes: handle nil models and zero limits defensively.

100. Adaptive size is zero: inspect constraints, fitting priorities, model nil, limit size, and `content` key path.

101. Adaptive size is stale: invalidate `SKHighPerformanceStore` entries or reset cached adaptive state.

102. Wrapper view padding is wrong: verify `SKWrapperView.Model.insets` and that size closure adds the same insets used by constraints.

103. Collection plugins do not run: verify the collection uses `SKCollectionFlowLayout` and `layout.fetchPlugins` is configured.

104. Section-level plugin missing: verify the section conforms to `SKCSectionLayoutPluginProtocol` and is currently bound.

105. Safe-area layout wrong: inspect `SKCollectionViewController.ignoresSafeArea()` and top constraint activation.

106. Pull-to-refresh never ends: ensure the async `refreshable` action returns.

107. SwiftUI wrapper recreates state: keep manager/section state outside frequently rebuilt SwiftUI value views.

108. SwiftUI update loops: add identity guards between SwiftUI state, `@SKPublished`, and section subscription updates.

## Framework Boundary

109. Promote view/container helpers into SectionUI only when they are independent of product copy, visual brand, route names, and request ownership.

110. Keep design-system-specific cells, spacing tokens, and component naming outside the generic framework skill.

111. Document view recipes as loading, sizing, reuse, and ownership contracts. Do not encode one downstream screen's component hierarchy.

112. Prefer wrappers and typed views before adding new section or manager APIs for a single UI pattern.
