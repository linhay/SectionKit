# Composition And Styling Recipes

Use this reference when a SectionUI task involves section assembly, `SKCSectionCollector`, manager binding, render states, empty/loading/error/content sections, supplementary views, section style, cell style, or composition debugging. Keep it generic: no downstream project paths, product names, business module names, source-file indexes, scan statistics, or page names.

## Contents

- [Render Pipeline](#render-pipeline)
- [Section Collector](#section-collector)
- [Manager Binding](#manager-binding)
- [Render States](#render-states)
- [Supplementary Views](#supplementary-views)
- [Section Style](#section-style)
- [Cell Style](#cell-style)
- [Composition Boundaries](#composition-boundaries)
- [Debug Checklist](#debug-checklist)
- [Framework Boundary](#framework-boundary)

## Render Pipeline

1. Build screen state first, derive sections second, then call `manager.reload(sections)` once for that render pass.

2. Derive decorations, display trackers, scroll targets, and collection-level plugins from the final section array, not from pre-filtered module inputs.

3. Treat `manager.reload(sections)` as the clean render boundary when section instances are recreated.

4. Use incremental manager operations only when section object identity is stable and the operation is a real section-level insert/delete.

5. Use row-level `append`, `insert`, `refresh`, `delete`, or `remove` when the structure of the section list does not change.

6. Keep render builders pure: converting state to sections should not trigger navigation, network requests, analytics, or mutation of unrelated state.

7. Keep long-lived sections as properties when later code needs selection, refresh, scroll, layout attributes, or display tracking.

8. Use local helper methods or small render objects for optional modules. Avoid a controller method with dozens of interleaved `if` blocks and side effects.

9. Make placeholder, loading, empty, error, and content sections explicit. Do not make one empty model array mean several UI states.

10. After a full render, assume section indexes have changed. Prefer section instances, `SKBindingKey(section)`, or final-section lookup over cached integer indexes.

## Section Collector

11. Use `SKCSectionCollector` when a screen has many optional modules or wrapper objects that may or may not render.

12. `collector.append(section?)` skips `nil` sections and preserves order for non-nil sections.

13. `collector.append(object, section:when:)` keeps the render condition attached to the object that owns the section.

14. The `Bool` returned by `append(object, section:when:)` is render-time information only. Use it for adjacent spacer/decoration decisions, not durable business state.

15. Use `collector.append(list, section:when:)` for repeated modules with the same render rule.

16. Do not store `SKCSectionCollector` as screen state. Rebuild it for each render pass.

17. Store section instances separately when they must survive across collector rebuilds.

18. When using `SKCAnySectionProtocol` wrappers, ensure `.section` does not create a fresh section every time if downstream code expects stable identity.

19. If a wrapper's `.section` is intentionally ephemeral, prefer full `manager.reload(collector.sections)` over incremental manager insert/delete.

20. Keep `collector.sections` as the single output from a render builder. Avoid appending extra sections after downstream plugins have already been derived.

## Manager Binding

21. `manager.reload(sections)` binds each section with a new `sectionInjection`, sends `sectionsPublisher`, runs section `config(sectionView:)`, then reloads the collection view.

22. Code that needs `sectionView`, `sectionIndex`, layout attributes, visible cells, or scroll APIs must run after binding.

23. `manager.insert`, `append`, `remove`, and `delete` operate by section object identity. They are not semantic diff operations.

24. `manager.remove` unbinds removed sections when `supportUnbindSection` is true. Do not use unbound sections for layout attributes or visible-cell access.

25. `replaceInsertWithReloadData` defaults to true, so manager inserts usually become a full reload unless configured otherwise.

26. `replaceDeleteWithReloadData` defaults to false, so manager deletes can use section deletion when the resulting list is non-empty.

27. Keep manager configuration screen-local unless the whole application shares the same tradeoff.

28. Use `manager.publishers.sectionsPublisher` for observers that need the bound section list after renders.

29. Prefer holding typed section references from the render builder. If you must inspect manager state, derive from the bound section list instead of hard-coded indexes.

30. Use `manager.converts.sectionInjection` only at integration boundaries. Feature code should not mutate `sectionInjection` directly.

31. Use `manager.pick { ... }` when several manager/section mutations should be one collection batch update.

32. Use pending scroll requests returned by manager scroll APIs when a scroll may need to wait until layout has non-zero size.

## Render States

33. Model render state explicitly, for example as loading, empty, error, and content states.

34. Loading skeletons should be real sections. They can have their own sizing, shimmer, and decoration behavior.

35. Empty states should be real sections when the UI needs copy, actions, or spacing. Do not hide every content section and hope the collection's background explains the state.

36. Error states should be real sections when retry is part of the list UI.

37. For first load, prefer a loading section over rendering an empty content section with hidden headers.

38. For filtered empty results, keep filters/menu sections visible and swap only the results section group.

39. Keep state transition rules near the render builder. A maintainer should see which states can render together.

40. When state changes from loading to content, rebuild the final section array before deriving decoration spans or scroll targets.

41. When removing a section due to state, also remove or rebuild trackers, selections, prefetch subscriptions, and scroll targets tied to that section.

42. Do not reuse a content section instance for a semantically different state unless all actions, styles, displayed counters, and subscriptions are reset.

## Supplementary Views

43. Use `setHeader` and `setFooter` for constant supplementary models. For exact dynamic model, removal, hiding, lifecycle, and custom-kind rules, read `supplementary-recipes.md`.

44. Use `set(supplementary:type:model:)` with a closure when the model should be evaluated at layout/config time.

45. The closure-based supplementary model returning `nil` produces zero size and skips configuration. Use this for lightweight optional supplementary content.

46. Use `remove(supplementary:)` when a supplementary view truly leaves the section contract.

47. `remove(supplementary:)` reloads the section. Account for that when changing several supplementary views together.

48. Supplementary registration is queued through `taskIfLoaded`, so it is safe to set header/footer before binding.

49. Use `onSupplementaryAction(.willDisplay)` for header/footer exposure or visual lifecycle. Use cell actions for row exposure.

50. Use `onAsyncSupplementaryAction` only when the async work belongs to the supplementary lifecycle and is properly gated.

51. `hiddenHeaderWhenNoItem` and `hiddenFooterWhenNoItem` default to true. Set them to false for static section chrome that should remain visible in empty sections.

52. Reload the section after toggling header/footer hidden behavior so supplementary size is recalculated.

53. If a header participates in a decoration background, align supplementary safe-size and inset fixes before tuning decoration insets.

54. Keep supplementary views structural. Do not hide entire feature state inside a header if it is really an empty, error, or content section.

## Section Style

55. Use `setSectionStyle` for section-owned layout properties such as `sectionInset`, `minimumLineSpacing`, `minimumInteritemSpacing`, `reloadKind`, and `indexTitle`.

56. Use the key-path overload for simple property assignments. It keeps section declarations concise and scan-friendly.

57. Use the multiple-key-path overload when line spacing and interitem spacing share one value.

58. Use closure-based `setSectionStyle` when several properties must be configured together or when configuration depends on environment.

59. Use `setSectionStyle(on:owner, ...)` when style depends on a controller/coordinator and needs weak capture.

60. Keep section-level spacing in section style, not in every cell's content insets.

61. Use `indexTitle` only when the collection view index feature is part of the screen contract. For exact `indexTitleRow`, lookup, reload, and forwarding rules, read `index-title-recipes.md`.

62. Set `reloadKind` near the section declaration. It changes how later model replacement behaves and should be easy to find.

63. Avoid mutating section layout properties from `setCellStyle`; cell style runs during cell creation and is not the right place to change section-wide layout.

64. If multiple helpers style the same section, keep their order explicit because later property assignments win.

## Cell Style

65. Use `setCellStyle` for row-dependent visual rules that do not belong inside reusable cell configuration.

66. Good `setCellStyle` use cases: separators, first/last rounding, selected backgrounds, hidden trailing lines, accessibility traits, and row-position visuals.

67. Keep data rendering in `cell.config(model)`. Keep list-context visuals in `setCellStyle`.

68. `setCellStyle` runs after `cell.config(model)` and before `.config` cell action is sent.

69. Multiple cell styles run in registration order. Use stable style IDs when a reusable `SKCCellStyle` should be replaceable by convention.

70. Use `setCellStyle(on:owner, ...)` for theme or environment values that live on a controller.

71. Do not use `setCellStyle` for navigation, analytics, network calls, or mutation. Use actions and publishers for side effects.

72. Do not use `setCellStyle` to fix missing model state. If a cell needs selected/disabled/error state, put that state in the model or selection wrapper.

73. For grouped rows, derive first/last state from `context.isFirstRow` and `context.isLastRow` rather than duplicating row-count logic.

74. After deleting rows, SectionUI reloads trailing rows for row-dependent styles in common remove paths. Still verify custom mutations refresh affected rows.

75. Keep cell style closures light. They run on the main thread during cell creation.

76. If a style needs expensive calculation, precompute it into model or section state before reload.

## Composition Boundaries

77. Use multiple small sections when modules can appear/disappear independently.

78. Use one custom section when rows share a strong ordering, one cache, one event contract, or one heterogeneous layout surface.

79. Use `SKCSectionViewCell` for nested child sections only when the child collection has a clear independent scrolling/composition contract.

80. Use wrapper views for simple visual rows. Do not promote labels, spacers, dividers, or single buttons into custom sections.

81. Use integration-level section factories for design-system rows, selectable groups, settings groups, and action grids.

82. Keep business route names, analytics names, permission prompts, and copywriting out of framework-level SectionUI recipes.

83. When repeated integration wrappers appear in several apps, first document the pattern as a recipe; promote to SectionUI only if it is a framework-level primitive.

84. Keep a clear owner for every section: screen, reusable component, nested cell, or coordinator. Ambiguous ownership causes stale actions and subscriptions.

85. If a section is shared across owners, define a reset/rebind method that clears actions, styles, displayed counters, selection state, and cancellables.

86. Avoid section factories that return both sections and unrelated side effects. Return sections, then let the caller wire side effects explicitly.

## Debug Checklist

87. Section appears in wrong order: inspect the final collector output, not the input module list.

88. Decoration spans wrong section: derive decoration bindings after final section list is built.

89. Incremental insert/remove does nothing: verify the target section object identity is the same instance currently bound by manager.

90. Section index is stale: rerun index-dependent work after `manager.reload(sections)` binds the new list.

91. Header missing in empty section: check `hiddenHeaderWhenNoItem`, model closure nil, and header size.

92. Header persists after state change: call `remove(supplementary:)` or rebuild the section state instead of only returning an empty model.

93. Cell style stale after delete/reorder: refresh rows whose first/last/separator state changed.

94. Unexpected global reload: check manager configuration flags that replace insert/delete/reload operations with `reloadData`.

95. Old actions fire after render state changes: clear actions or create a fresh section instance for the new state.

96. Supplementary action does not fire: verify the supplementary view is present, non-zero size, registered, and visible.

97. Section view access asserts: the section is not bound. Check `isBindSectionView` or defer work with `taskIfLoaded`.

98. `sectionsPublisher` observer sees unexpected sections: verify render builder did not append sections after plugins/trackers were derived.

99. Empty/loading/content states overlap: make render-state enum mutually exclusive, then map it to explicit section groups.

100. Spacing inconsistent across modules: move shared spacing to section factories or section style helpers.

## Framework Boundary

101. Promote a composition helper into SectionUI only if it is independent of product state, copy, visual brand, and route names.

102. Keep app-specific module ordering, empty-state copy, design tokens, and analytics taxonomy outside the framework skill.

103. Prefer `SKCSectionCollector`, section factories, wrapper views, and reusable `SKCCellStyle` before adding new manager or section APIs.

104. Document composition recipes as ownership, render-state, and lifecycle rules. Do not encode one downstream app's screen assembly as a SectionUI convention.
