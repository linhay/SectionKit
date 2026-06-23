# Drag Selection Recipes

Use this reference when a SectionUI task involves `SKCDragSelector`, rectangular multi-select, drag selection setup/reset, auto-scroll, selection overlays, haptics, or gesture conflict handling. Keep it generic: no downstream project paths, product names, business module names, source-file indexes, scan statistics, or page names.

## Contents

- [Status And Scope](#status-and-scope)
- [Setup And Lifecycle](#setup-and-lifecycle)
- [Selection State Ownership](#selection-state-ownership)
- [Intent Analysis](#intent-analysis)
- [Rect Selection](#rect-selection)
- [Auto Scroll](#auto-scroll)
- [Overlay Styling](#overlay-styling)
- [Gesture Conflicts](#gesture-conflicts)
- [Haptics And Logging](#haptics-and-logging)
- [Integration Recipes](#integration-recipes)
- [Debug Checklist](#debug-checklist)
- [Framework Boundary](#framework-boundary)

## Status And Scope

1. Treat `SKCDragSelector`, `SKCRectSelectionManager`, `SKAutoScrollManager`, and `SKSelectionOverlayView` as beta APIs. They are available on iOS 13+ and marked deprecated with a beta warning.

2. Use drag selection only when rectangular multi-select is a real interaction requirement. For ordinary tap selection, prefer `SKSelectionProtocol`, `SKSelectionWrapper`, `SKSelectionSequence`, or `SKSelectionIdentifiableSequence`.

3. Keep the feature behind an integration-level abstraction when possible. The screen should own setup, reset, selection store, and refresh policy.

4. Keep drag selection on the main actor. `SKCDragSelector` and `SKCRectSelectionManager` are `@MainActor`.

5. Do not present these APIs as stable framework defaults. Document local adoption risks and regression-test the target list before shipping.

6. Prefer framework-provided selector coordination over manually combining a pan gesture, overlay view, edge scrolling, and row mutation.

## Setup And Lifecycle

7. Create one `SKCDragSelector` per collection surface. Avoid sharing one selector across multiple collection views.

8. Call `setup(collectionView:rectSelectionDelegate:)` after the collection view has been added to a view hierarchy. Setup validates that the target view has a `window` or `superview`.

9. In `SKCollectionViewController`, pass `sectionView` to setup.

```swift
private let dragSelector = SKCDragSelector()

override func viewDidLoad() {
    super.viewDidLoad()

    do {
        try dragSelector.setup(
            collectionView: sectionView,
            rectSelectionDelegate: self
        )
    } catch {
        assertionFailure("Drag selection setup failed: \(error)")
    }
}
```

10. `setup` throws `alreadySetup` when called twice. Call `reset()` before rebinding the selector to another collection view.

11. Call `reset()` when the owning screen or reusable component is torn down. This removes the pan gesture, stops auto-scroll, ends any active selection, and clears weak collection references.

12. If a setup attempt can fail in production, surface a degraded selection path instead of leaving a half-configured selector.

13. Do not install a second raw pan gesture for the same drag-selection responsibility. Let `SKCDragSelector` coordinate gesture state, auto-scroll, and rect selection.

14. When reusing a nested collection component, reset the old selector before assigning a new delegate or model universe.

15. `reset()` is safe as cleanup even when selection is idle.

16. Orientation changes interrupt active selection. Make selection state durable enough that interruption does not corrupt the selected model set.

## Selection State Ownership

17. The delegate is the source of truth for row selection. `SKCRectSelectionManager` asks `isSelectedAt` and emits `didUpdateSelection`; it does not own the canonical selected set.

18. Keep selected state in row models, a selection sequence, or an identity-keyed store. Do not infer selection from visible cell appearance.

19. In `didUpdateSelection`, update the model or selection store first, then refresh the affected row.

```swift
func rectSelectionManager(
    _ manager: SKCRectSelectionManager,
    didUpdateSelection isSelected: Bool,
    for indexPath: IndexPath
) {
    guard models.indices.contains(indexPath.item) else { return }
    guard models[indexPath.item].isSelected != isSelected else { return }

    models[indexPath.item].isSelected = isSelected
    section.refresh(at: indexPath.item)
}
```

20. If the row model is immutable, replace the model and call `section.refresh(at:model:)` or `section.refresh(with:)`.

21. If the list can be filtered, sorted, or paged during selection, drive the selected set by stable identity instead of row offset.

22. Guard every delegate callback against out-of-bounds rows. Selection calculation can race with a render or deletion on the main run loop.

23. Do not perform network work directly from `didUpdateSelection`. Update UI state immediately and let a debounced command layer persist or sync.

24. When a row leaves the selection rectangle, the rect manager restores its original selected state. Keep `isSelectedAt` deterministic during a single drag.

25. If selection rules include disabled rows, return the current state from `isSelectedAt` and ignore `didUpdateSelection` for rows that cannot change.

26. If ignored rows need visible feedback, model that separately from selected state.

27. When selection count drives toolbars or batch actions, subscribe to the selection store rather than counting visible selected cells.

28. Clear selection state explicitly when replacing the selectable model universe.

## Intent Analysis

29. Drag selection starts in `.analyzing` and waits until movement exceeds `configuration.minimumDistance`.

30. High-speed movement with a strong vertical component is treated as scroll intent.

31. Fast vertical-dominant movement is treated as scroll intent.

32. Horizontal-dominant movement below the high-speed threshold is treated as selection intent.

33. Slow vertical-dominant movement can still start selection. This supports precise vertical drag selection.

34. Large horizontal translation can start selection even if velocity is ambiguous.

35. Very slow movement defaults to selection.

36. Ambiguous movement defaults to not starting selection.

37. Increase `minimumDistance` when normal scrolling is frequently misclassified as selection.

38. Increase `fastScrollSpeedThreshold` cautiously. A high value makes quick vertical gestures more likely to enter selection mode.

39. Lower `horizontalDistanceThreshold` only when horizontal drag selection feels unresponsive.

40. Keep `directionDominanceRatio >= 1.0`; invalid values are rejected and the old configuration is restored.

41. Keep `horizontalToVerticalRatio` between `0` and `1`. Invalid values are rejected.

42. Treat the default thresholds as a starting point, not as universal constants. Validate against the list's cell density, scroll direction, and common user gestures.

## Rect Selection

43. `SKCRectSelectionManager` creates the overlay when selection begins and removes it when selection ends.

44. Selection mode is determined once at the starting point. Starting on a selected cell enters deselecting mode; starting on an unselected cell or blank area enters selecting mode.

45. During one drag, all rows inside the rectangle receive the same target state based on the initial mode.

46. The manager records original states for rows as they enter the rectangle.

47. Rows that leave the rectangle are restored to their original states.

48. Visual rectangle updates are throttled separately from row selection calculation.

49. The default visual update interval is about 60fps.

50. The default row-selection update interval is about 20fps.

51. Lower the row-selection throttle only when row counts are small and responsiveness is visibly inadequate.

52. Raise the row-selection throttle when large sections perform expensive model mutation or refresh work.

53. The selection query expands the layout-attributes search rect to the full collection width, then filters attributes that intersect the actual rectangle.

54. Custom layouts must return correct `layoutAttributesForElements(in:)` results for cells inside the expanded query rect.

55. If selection skips visible rows, inspect layout attributes first before changing gesture thresholds.

56. If section decorations or supplementary views appear selected, verify that only item attributes are being treated as selectable by the integration.

57. Keep row refresh narrow. Full section or manager reloads during a drag are more likely to invalidate row offsets and overlay state.

## Auto Scroll

58. `SKAutoScrollManager` starts when selection starts and stops when selection ends.

59. The selector disables `collectionView.isScrollEnabled` during active selection, then restores it when selection ends.

60. Auto-scroll uses a `CADisplayLink` and a target frame rate, defaulting to 60fps.

61. On iOS 15+, the display link uses a frame-rate range and can adapt up to the configured maximum behavior.

62. `edgeInset` controls the distance from the scroll view edge where auto-scroll begins. Default is `40`.

63. `maxSpeed` controls maximum points per frame. Default is `12`.

64. Keep `targetFPS` between `1` and `120`; invalid values are rejected.

65. Auto-scroll clamps offsets using content size, bounds, and content inset.

66. Auto-scroll does nothing when content is not larger than the visible bounds.

67. The velocity curve is eased near edges. This avoids abrupt acceleration when the finger enters the edge zone.

68. The auto-scroll delegate callback causes the selector to update the selection rectangle at the saved touch location, keeping the rectangle anchored to the finger while content moves.

69. If auto-scroll feels too aggressive, lower `maxSpeed` before increasing `edgeInset`.

70. If auto-scroll is hard to trigger, increase `edgeInset` before increasing `maxSpeed`.

71. Validate auto-scroll with non-zero content insets, safe areas, and any fixed chrome that changes visible bounds.

## Overlay Styling

72. Customize the rectangle through `SKSelectionOverlayView.Style`, not by setting view background or border layer properties.

```swift
func rectSelectionManager(
    _ manager: SKCRectSelectionManager,
    willDisplay overlayView: SKSelectionOverlayView
) {
    overlayView.style = .init(
        fillColor: UIColor.systemBlue.withAlphaComponent(0.16),
        strokeColor: UIColor.systemBlue.withAlphaComponent(0.7),
        lineWidth: 1.5,
        cornerRadius: 4,
        dashPattern: nil
    )
}
```

73. The overlay is non-interactive. It should not block touches.

74. `updateSelectionRect(_:)` disables implicit Core Animation actions so rectangle updates remain responsive.

75. Keep overlay styling light. Heavy shadows, masks, or blur effects can add cost during continuous drag.

76. Use dashed strokes only when the visual language needs it; dash rendering is extra work during path updates.

77. Prefer semantic colors in app code, but keep skill examples framework-generic.

## Gesture Conflicts

78. The selector installs a one-finger `UIPanGestureRecognizer`.

79. The pan gesture sets `cancelsTouchesInView = false`, `delaysTouchesBegan = false`, and `delaysTouchesEnded = false`.

80. While state is `.selecting`, simultaneous recognition with other gestures is rejected.

81. During analysis, simultaneous recognition with other pan gestures is allowed so ordinary scrolling can still win.

82. Touches outside an expanded collection bounds area are ignored.

83. If a cell has its own horizontal pan, verify whether it should win before drag selection starts. Avoid making both interactions active on the same touch path.

84. If a list uses swipe actions, reorder gestures, or nested horizontal sections, define which gesture owns the first drag movement and test slow, fast, horizontal, and vertical gestures.

85. Do not change `collectionView.panGestureRecognizer.delegate` to solve conflicts. That bypasses SectionUI's forwarding and can break scroll observation.

86. For nested collections, enable drag selection only on the collection surface that should own rectangular selection.

## Haptics And Logging

87. `enableHapticFeedback` defaults to `true`.

88. Entering `.selecting` triggers impact feedback.

89. Returning to `.idle` triggers selection feedback.

90. Disable haptics in automated UI tests or when the surrounding interaction already owns tactile feedback.

91. `SKLog` prints only in debug builds.

92. Use debug logs to inspect state transitions, intent decisions, and setup/reset lifecycle.

93. Do not build production behavior from `SKLog` output.

94. When debugging misclassification, log velocity, translation, distance, and final state together.

## Integration Recipes

95. For a selectable model type, make selection updates idempotent: skip refresh when the row already has the target state.

96. For identity-based stores, map the delegate `indexPath` to the current model id immediately and ignore stale rows.

97. For large batch selection, coalesce external side effects. The delegate can be called many times during one drag.

98. For diff-driven rendering, avoid replacing section instances during active selection.

99. If a full render is unavoidable, call `dragSelector.reset()` before render and let the user start a new drag.

100. For nested sections, keep parent cell reuse from carrying a selector configured with the previous child model set.

101. For accessibility, provide non-drag batch selection alternatives. Rectangular drag is pointer-like and may not be reachable for every user.

102. For edit mode, gate `setup` or gesture acceptance through the screen state so normal browsing gestures remain predictable outside selection mode.

103. If a toolbar appears only during selection, drive it from the selected store rather than from selector state. The selector state returns to `.idle` when the drag ends while selected rows remain selected.

104. Keep selection UI and data updates on the main actor.

## Debug Checklist

105. Setup throws `alreadySetup`: verify the previous owner called `reset()` before reusing the selector.

106. Setup throws collection-view validation: call setup after the collection view is in the hierarchy.

107. Drag never starts selection: inspect `minimumDistance`, velocity thresholds, and whether the gesture is mostly vertical and fast.

108. Scrolling is disabled after a cancelled gesture: confirm `endMultiSelection()` ran through selector cleanup and that no external code also changed `isScrollEnabled`.

109. Overlay appears but rows do not change: verify delegate methods are wired, `isSelectedAt` returns current state, and row indexes are valid.

110. Rows flicker during drag: avoid full reloads, reduce visual work in cells, and make `didUpdateSelection` idempotent.

111. Rows outside the rectangle stay changed: verify the delegate does not ignore restore callbacks for previously changed rows.

112. Auto-scroll does not run: check content size, edge zone, content inset, and whether `updateAutoScroll(for:)` receives points near the scroll view frame edges.

113. Auto-scroll moves in the wrong direction: inspect coordinate conversion between the scroll view and its superview.

114. Selection skips rows in custom layouts: verify `layoutAttributesForElements(in:)` returns item attributes for the expanded query rect.

115. Haptics fire unexpectedly: disable `enableHapticFeedback` or gate selector setup by edit mode.

116. Gesture conflicts with cell controls: reduce overlap between drag-selection activation and control-specific gestures; prefer explicit edit mode for dense interactive cells.

## Framework Boundary

117. SectionUI can coordinate drag intent, overlay display, auto-scroll, and row-level selection callbacks.

118. The app layer owns selectable identity, persistence, authorization, disabled-state rules, toolbar state, undo/redo, and accessibility alternatives.

119. Keep examples anonymous and framework-level. Do not encode business routes, event names, module names, project-specific spacing, or downstream source locations into this skill.
