# Delegate Interaction Recipes

This reference captures production recipes for SectionUI UIKit delegate interactions: highlight, select, primary action, display lifecycle, focus, edit, spring-load, multiple selection, context menus, and reorder gates. Keep it generic: no downstream project paths, product names, business module names, source-file indexes, scan statistics, or page names.

## Contents

- [Routing Model](#routing-model)
- [Selection And Highlight](#selection-and-highlight)
- [Primary Action](#primary-action)
- [Display Lifecycle](#display-lifecycle)
- [Focus And Editing](#focus-and-editing)
- [Spring Load](#spring-load)
- [Multiple Selection](#multiple-selection)
- [Context Menus](#context-menus)
- [Reorder Gates](#reorder-gates)
- [Subclassing Boundary](#subclassing-boundary)
- [Debug Checklist](#debug-checklist)
- [Framework Boundary](#framework-boundary)

## Routing Model

1. `SKCManager` routes collection-view delegate calls through `SKCDelegate` to the currently bound section.

2. Delegate routing uses the current `IndexPath.section` to find a section from `manager.publishers.sections`.

3. Section-level delegate methods are the framework extension point for UIKit interaction behavior.

4. `SKCSingleTypeSection` provides useful defaults for many delegate gates.

5. Fluent helpers are not available for every UIKit delegate method. Use section overrides when a gate has no chainable API.

6. `onCellAction` covers `selected`, `deselected`, `willDisplay`, `didEndDisplay`, and `config`.

7. `onCellShould` currently covers `SKCCellShouldType.move`.

8. Use delegate forwarding only for collection-wide integration policy. Prefer section APIs or section overrides for row/model-specific behavior.

9. Do not install a second direct `UICollectionViewDelegate` to handle these interactions. It bypasses SectionUI routing.

## Selection And Highlight

10. UIKit touch selection normally flows through should-highlight, did-highlight, should-select or should-deselect, did-select or did-deselect, then did-unhighlight.

11. `SKCSingleTypeSection` defaults `shouldHighlight`, `shouldSelect`, and `shouldDeselect` to true.

12. Use `onCellAction(.selected)` and `onCellAction(.deselected)` for ordinary tap selection side effects.

13. For selection eligibility that depends on model state, prefer model-level `canSelect` with SectionUI selection wrappers when using `SKSelectionProtocol`.

14. If UIKit should completely reject selection for a row, override `item(shouldSelect:)` in a custom section.

15. If UIKit should reject deselection for a row in multiple-selection mode, override `item(shouldDeselect:)`.

16. Use highlight overrides only for interaction gating. Use `setCellStyle` or cell configuration for persistent highlighted/pressed visuals.

17. `didSelect` and `didDeselect` callbacks do not guarantee a live cell view. Use row and model as the source of truth.

18. Avoid using `didSelect` as both "update selection state" and "navigate" when iOS 16 primary action is enabled. Split those responsibilities.

## Primary Action

19. iOS 16 primary action is routed through `item(canPerformPrimaryAction:)` and `item(performPrimaryAction:)`.

20. Default `canPerformPrimaryAction` is true.

21. Use primary action for navigation or opening detail when selection state and activation should be separate.

22. Use `didSelect` for selection state, toolbar state, or current-item state.

23. When primary action is used, make duplicate navigation impossible if `didSelect` also fires.

24. Override primary-action methods in a custom section when row activation must be section-local and model-driven.

25. Keep async primary actions gated by model identity because selection can change before the async task completes.

## Display Lifecycle

26. `willDisplay` routes to section `item(willDisplay:row:)`, then single-type sections send `.willDisplay` actions and increment `displayedTimes` by row.

27. `didEndDisplaying` routes to section `item(didEndDisplaying:row:)`, then single-type sections send `.didEndDisplay` actions using `deletedModels` when the row was removed.

28. Use `.willDisplay` for lightweight visible-row work and exposure starts.

29. Use `.didEndDisplay` for exposure ends, cancellation, and cleanup that needs the old model after deletion.

30. `displayedTimes` is row-based for single-type sections. Reset it when replacing the model universe.

31. For exact display-end behavior on full reloads, inspect manager and section skip-display-event flags.

32. Supplementary display lifecycle routes through `SKCSupplementaryActionType.willDisplay` and `.didEndDisplay`.

33. Use supplementary actions for header/footer exposure and visual lifecycle, not cell actions.

34. Keep heavy work out of display lifecycle callbacks; fast scrolling can call them frequently.

## Focus And Editing

35. `item(canFocus:)` defaults to true.

36. `selectionFollowsFocus` is available on iOS 15+ and defaults to true when the collection view asks the section.

37. Override focus methods in a custom section for tvOS, keyboard, or hardware-focus behavior that depends on row model state.

38. `item(canEdit:)` is available on iOS 14+ and defaults to false.

39. Do not assume edit support exists just because a cell visually looks editable. Route edit eligibility through the section method when using UIKit edit interactions.

40. Keep focus and edit policy independent from business authorization. The section should reflect already-decided UI eligibility.

## Spring Load

41. `item(shouldSpringLoad:with:)` defaults to true.

42. Use spring-load overrides when a row or subview should opt out of spring-loaded interaction.

43. If a custom target view is needed, adjust the `UISpringLoadedInteractionContext` in the section override.

44. Keep spring-load behavior row-local. Cross-screen spring-load policy belongs in delegate forwarding only when it is truly collection-wide.

## Multiple Selection

45. `item(shouldBeginMultipleSelectionInteraction:)` defaults to false.

46. Override it to support UIKit's multiple-selection interaction for rows that can enter multi-select mode.

47. `item(didBeginMultipleSelectionInteraction:)` is called after UIKit enables multiple selection from the gesture.

48. `section(didEndMultipleSelectionInteraction:)` is broadcast to all delegate sections when the collection view reports the interaction ended.

49. The end callback means the multi-select gesture or keyboard interaction ended; it does not imply selected rows were cleared.

50. Keep selected state in models or a selection store. Do not infer final selected state from the multiple-selection interaction lifecycle.

51. For rectangular drag selection, use `SKCDragSelector` recipes instead of UIKit's multiple-selection delegate hooks.

52. For batch toolbars, drive UI from selection store changes rather than from begin/end callbacks alone.

## Context Menus

53. Use `onContextMenu` for row/model-specific menus.

54. `onContextMenu(where:)` keeps conditional menus composable.

55. The first non-nil context menu result wins.

56. `clearContextMenuActions()` is required when rebinding a reused section to a different menu policy.

57. `SKCContextMenuContext` intentionally does not support `view()`. Build menus from `context.model` and `context.row`.

58. `SKUIContextMenuResult` can be created from `UIMenu`, `[UIAction]`, `[SKUIAction]`, or array literals.

59. Use `SKUIAction` when a menu action needs an async main-actor handler.

60. On iOS 13-15, SectionUI stores context menu configuration by object identity to route highlight and dismissal preview callbacks.

61. On iOS 16+, SectionUI handles the multi-item context-menu API only when exactly one index path is supplied; multi-item or background menus pass through.

62. For menus on multiple selected items or collection background, use integration-level delegate forwarding.

63. Return nil when no menu should appear. Do not return an empty menu unless the cancellation affordance is intentional.

64. Custom highlight and dismissal previews belong in `SKUIContextMenuResult` when they are row/model-specific.

## Reorder Gates

65. `onCellShould(.move, true)` enables movement for all rows in that section.

66. `onCellShould(.move) { context in ... }` enables row/model-specific movement policy.

67. `item(canMove:)` checks registered move predicates in order and returns the first non-nil result.

68. If no move predicate handles the row, movement defaults to false.

69. Same-section move swaps source and destination models by default.

70. Moving out of a single-type source section removes the source model.

71. Moving into a different single-type destination section asserts by default. Handle cross-section moves explicitly when needed.

72. After reorder, synchronize the canonical source array immediately. A later render from stale state will undo the visible order.

73. Recompute row-position styles after reorder.

## Subclassing Boundary

74. Subclass `SKCSingleTypeSection` when a row/model-specific UIKit delegate gate has no fluent helper.

75. Good subclass targets include `shouldSelect`, `shouldDeselect`, focus, edit, primary action, spring-load, and UIKit multiple-selection gates.

76. Keep subclass overrides thin. Delegate durable decisions to model state or a feature policy object.

77. Prefer fluent helpers for actions, styles, context menus, and move eligibility.

78. Prefer delegate forwarding only when the policy is collection-wide or cannot be expressed by a section.

79. If a subclass adds owner callbacks, provide a reset/rebind method so reused sections do not retain stale owners.

80. Document availability when using iOS 14/15/16 delegate gates.

## Debug Checklist

81. Tap does nothing: inspect `shouldSelect`, selection wrappers, cell controls swallowing touches, and duplicate gesture recognizers.

82. Navigation fires twice: split `didSelect` and primary action responsibilities and gate duplicate activation.

83. Highlight appears but selection does not: check `shouldSelect` or `shouldDeselect` return values.

84. Focus moves unexpectedly: inspect `canFocus` and `selectionFollowsFocus` overrides.

85. Edit interaction unavailable: verify `canEdit` and collection view edit-mode requirements.

86. Multiple-selection gesture never starts: verify the collection scroll direction is constrained and `shouldBeginMultipleSelectionInteraction` returns true.

87. Batch toolbar remains after gesture ends: remember that end interaction does not clear selection.

88. Context menu missing: verify a provider returns non-nil for the current model and row.

89. Context menu preview wrong on iOS 13-15: verify the stored configuration identity still maps to the original index path.

90. Multi-item menu not handled: SectionUI's section-level menu path handles single-row menus; add integration-level forwarding for multi-item menus.

91. Reorder not allowed: verify `onCellShould(.move, ...)` is registered and not stale from an old section owner.

92. Reorder persists visually but later reverts: update the canonical source array after movement.

## Framework Boundary

93. SectionUI can route delegate calls to sections and provide section-level helpers for common list interactions.

94. The app layer owns product navigation, authorization, menu contents, multi-item command semantics, edit-mode orchestration, and accessibility alternatives.

95. Keep interaction examples anonymous and framework-level. Do not encode business routes, event names, module names, product permissions, downstream source locations, or scan statistics into this skill.
