# Layout And Decoration Recipes

Use this reference when a SectionUI task involves layout plugins, alignment, supplementary view correction, decoration backgrounds, cross-section decoration, decoration frames, z-index, or layout/decoration debugging. Keep it generic: no downstream project paths, product names, business module names, source-file indexes, scan statistics, or page names.

## Plugin Scope And Ordering

1. Use section-level `addLayoutPlugins(...)` when the behavior belongs to one section. Use `sectionView.set(pluginModes: ...)` when the behavior is a collection-wide layout rule.

2. Section-level plugins are converted through the section's current binding index, so they survive section insertion/removal better than hard-coded integer section indexes.

3. Collection-level plugin modes and section-level plugin modes are collected together by `SKCollectionView` before layout execution. Keep collection-level modes close to the render path so future maintainers can see the screen-wide contract.

4. Plugin modes are sorted by priority, not by call order:
   `attributes` runs first, then `fixSupplementaryViewSize`, `fixSupplementaryViewInset`, `adjustSupplementaryViewSize`, alignment, decorations, and finally `layoutAttributesForElements`.

5. Multiple `.attributes`, alignment, decoration, and `layoutAttributesForElements` modes are merged. `fixSupplementaryViewSize`, `fixSupplementaryViewInset`, and `adjustSupplementaryViewSize` are singleton modes by priority and should not be duplicated in the same resolved plugin list.

6. If a layout fix appears to do nothing, inspect the resolved scope first: collection-level `.all`, section-bound `SKBindingKey(section)`, and hard-coded indexes behave differently after optional sections are filtered.

7. Prefer `SKBindingKey(section, offset:)` for a section-relative neighbor, such as a decoration that spans from a section to the next section.

8. Prefer `SKBindingKey.relative(from: sectionView, \.first)` or `\.last` for dynamic first/last section references after reload.

9. Avoid deriving plugin indexes from a pre-filtered module array. Build plugins after the final section list exists, or bind them to section instances.

10. Keep brand spacing, colors, and named visual presets in the integration layer. The SectionUI skill should describe plugin mechanics and reusable layout contracts.

## Alignment Recipes

11. Use `.left`, `.right`, or `.centerX` when rows in a vertical flow layout need horizontal alignment. Despite the internal type name, these align cells horizontally within each row.

12. Alignment plugins only support vertical scroll direction. Do not rely on them for horizontally scrolling collections.

13. Use `.left` for tag clouds, chips, filters, and non-full-width cells that should pack from the leading edge.

14. Use `.centerX` for compact rows whose cells should remain visually centered when a row is not full.

15. Use `.right` rarely, mainly for trailing-aligned rows in right-heavy layouts or special localized flows.

16. Alignment groups cells by section and row `minY`. Keep row heights stable enough that cells intended for one row share the same layout row.

17. Do not encode row alignment by inflating cell width unless the cell genuinely owns the full-width interaction area.

18. Use `section.addLayoutPlugins(.left)` when only one section needs packing. Use `sectionView.set(pluginModes: .left)` only when every section in the collection follows the same row-packing rule.

19. Use `.horizontalAlignment(.equalSpacing)` when every row should distribute leftover horizontal space between items.

20. Avoid `.equalSpacing` for rows that can contain a single item, because the spacing calculation divides by `items.count - 1`.

21. Prefer `minimumInteritemSpacing` plus `.left` for predictable chip wrapping. Prefer `.equalSpacing` when the design explicitly wants full-row distribution.

22. If alignment looks wrong after self-sizing changes, first verify `preferredSize(limit:model:)`, section insets, and interitem spacing before adding another plugin.

## Supplementary Size And Inset Recipes

23. Use `.fixSupplementaryViewSize` when a header/footer layout attribute has drifted from the size declared by the section's supplementary size provider.

24. Use `.fixSupplementaryViewInset(.vertical)` when headers or footers should move inside section top/bottom inset: headers move down by top inset, footers move up by bottom inset.

25. Use `.fixSupplementaryViewInset(.horizontal)` when headers/footers should match the cell content width inside left/right section insets.

26. Use `.fixSupplementaryViewInset(.all)` when both vertical position and horizontal width should be corrected to the section's inset box.

27. Use `.adjustSupplementaryViewSize(.including([...]))` when only specific section/kind pairs need size reset plus inset application.

28. Use `.adjustSupplementaryViewSize(.excluding([...]))` when the default should apply broadly except for a few section/kind pairs.

29. Do not stack multiple size/inset singleton modes with the same priority. Decide the one correction mode that describes the layout contract.

30. Pair supplementary size fixes with decoration backgrounds when the background must hug headers, cells, and footers consistently.

31. If a header visually overlaps a card background, verify whether the header was moved by section inset correction before changing decoration insets.

32. If a footer appears outside the intended group, verify bottom inset handling and the footer's fixed size before adding spacer sections.

33. Keep supplementary correction at the narrowest scope that solves the problem. A collection-wide fix can unexpectedly affect unrelated headers and footers.

34. Use section-level `setAttributes(...)` for one-off attribute adjustments such as z-index, transforms, alpha, or section-specific supplementary correction.

35. Keep attribute adjustment closures pure with respect to layout state. Mutate layout attributes, not business state.

36. When a supplementary fix depends on final section order, bind it by section instance rather than a literal index.

## Decoration Frame Recipes

37. Use `section.set(decoration: MyDecorationView.self)` for a background owned by one section.

38. Use `section.set(decoration:model:)` when the decoration view conforms to `SKConfigurableModelProtocol` and can be configured during `.willDisplay`.

39. Use `decoration.from.layout` to choose which parts contribute to the frame: `.header`, `.cells`, `.footer`.

40. Use default `.visibleView` mode for backgrounds that should follow currently visible supplementary attributes, including sticky-style movement.

41. Use `.section` mode when the frame must come from the full logical section attributes rather than the visible cache.

42. Use `.useSectionInsetWhenNotExist([.header, .footer])` when a decoration should still include section top/bottom inset even when the header/footer is absent.

43. Always combine `.useSectionInsetWhenNotExist(...)` with either `.visibleView` or `.section`; debug builds assert if neither frame mode is present.

44. Use negative `decoration.insets` to expand a background across padding that is visually part of the group.

45. Use positive `decoration.insets` to shrink a background inside the union of header/cell/footer frames.

46. Decoration frame is computed as the union of `from` and optional `to` frames, then `decoration.insets` is applied.

47. Decoration attributes are added only when the relevant section range intersects currently requested layout attributes. If a decoration never appears, check whether its bound section has layout attributes.

48. A decoration frame can be `nil` when all selected layout parts are absent or have zero size. Ensure at least one included header, cell, or footer contributes a non-empty frame, or enable section-inset fallback for the intended missing parts.

49. For a section background with no header/footer, use `from.layout = [.cells]` plus inset fallback only when top/bottom padding must remain visible.

50. For a group background that includes header and cells but excludes footer spacing, use `from.layout = [.header, .cells]`.

51. For a background that visually wraps a whole module, prefer one decoration spanning the relevant section instances over several adjacent backgrounds with matching colors.

52. For cross-section backgrounds, set `decoration.to` with a section-bound key or a relative key. Avoid hard-coded indexes unless the section order is fixed by framework contract.

53. When spanning from one section to another, keep the owning decoration on the first logical section. That makes z-index and lifecycle easier to reason about.

54. If a cross-section decoration behaves unexpectedly after optional sections change, rebuild the decoration after producing the final section array.

55. Use `SKBindingKey.relative(from: sectionView, \.last)` for a decoration that should extend to the final rendered section.

56. Use `SKBindingKey(section, offset: 1)` only when the neighbor relationship is structural and remains valid after filtering.

57. Do not use a decoration to create real vertical spacing. Use section insets, header/footer size, or spacer sections for layout space; use decoration for visual grouping.

58. Decoration views must be reusable `UICollectionReusableView` types conforming to `SKCDecorationView`. Keep them visual; route events through section/cell actions unless the decoration itself owns a real lifecycle concern.

## Z-Index And Lifecycle

59. If `zIndex` is omitted, SectionUI assigns decreasing negative values per section so decorations sit behind cells and supplementary views by default.

60. Set explicit negative `zIndex` values when multiple backgrounds, borders, or shadows overlap.

61. Keep z-index values sparse and local. Avoid using one global z-index ladder for every screen.

62. If a decoration covers interactive cells, first check whether an explicit z-index accidentally placed it above content.

63. Use `decoration.onAction(.willDisplay)` for visual configuration, metrics, or lightweight lifecycle hooks tied to the decoration view.

64. Use `decoration.onAction(.didEndDisplaying)` for cleanup that belongs to the decoration view lifecycle.

65. `onAction` dispatches to the decoration whose identifier and section/item match the displayed reusable view. If the callback does not fire, verify the decoration identifier, resolved section, and decoration item index.

66. Prefer model-based decoration configuration over capturing controller state inside layout plugins.

67. Keep decoration action closures weakly capturing owners, just like cell and supplementary actions.

68. Register decoration kinds through SectionUI's decoration flow. Do not manually register a conflicting decoration identifier on the same layout.

## Debug Checklist

69. Decoration missing: verify the section is bound to a manager and has a current `sectionInjection.index`.

70. Decoration missing: verify final section order, especially after feature flags, empty states, or optional sections are filtered.

71. Decoration missing: verify selected `from.layout` / `to.layout` parts produce non-zero attributes.

72. Decoration missing: verify `.useSectionInsetWhenNotExist` is paired with `.visibleView` or `.section`.

73. Decoration missing: verify the decoration view type conforms to `SKCDecorationView` and has a unique identifier.

74. Decoration misplaced: compare section inset, decoration inset, supplementary fixed size, and supplementary inset correction in that order.

75. Decoration clipped: inspect collection view bounds, content inset, section inset, and the decoration's negative/positive insets.

76. Decoration behind another background: set explicit negative `zIndex` values for both decorations.

77. Header/footer width wrong: add horizontal supplementary inset correction or fixed supplementary sizing at section scope.

78. Header/footer y-position wrong: use vertical supplementary inset correction before adding spacer views.

79. Alignment wrong: confirm the collection uses vertical scroll direction and that rows are actually grouped as expected by flow layout.

80. Equal spacing crash or bad math: remove it from rows that can contain one item, or ensure the section always has at least two items per row.

81. Plugin conflict: look for multiple singleton modes of the same priority in collection-level plus section-level plugin lists.

82. Stale decoration after reload: rebuild plugins that depend on `first`, `last`, offsets, or optional sections after producing the new section array.

83. Unexpected global effect: move the plugin from `sectionView.set(pluginModes:)` to section-level `addLayoutPlugins(...)`.

84. Hard-to-debug visual issue: temporarily remove custom attribute plugins first, then reintroduce supplementary fixes, alignment, and decorations one group at a time.

## Framework Boundary

85. Add a new SectionUI API only when the need is a reusable collection/list primitive.

86. Do not promote brand-specific card radii, colors, shadows, analytics names, or business grouping vocabulary into the framework skill.

87. Prefer section factories, wrapper views, `SKCCellStyle`, `SKPublishedValue`, and layout plugins before adding another core abstraction.

88. Document recipes as mechanics and decision rules. Avoid encoding one downstream app's page structure as a SectionUI pattern.
