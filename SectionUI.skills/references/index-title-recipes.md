# Index Title Recipes

Use this reference when a SectionUI task involves `indexTitle`, `indexTitleRow`, `sectionIndex`, collection index titles, alphabet navigation, or data-source forwarding for index-title lookup.

Keep it generic: no downstream project paths, product names, business module names, source-file indexes, scan statistics, page names, route names, or business taxonomy.

## Contents

- [Contract](#contract)
- [Single Type Sections](#single-type-sections)
- [Custom Sections](#custom-sections)
- [Lookup Semantics](#lookup-semantics)
- [Forwarding](#forwarding)
- [Reload And Identity](#reload-and-identity)
- [Examples](#examples)
- [Debug Checklist](#debug-checklist)
- [Framework Boundary](#framework-boundary)

## Contract

1. Index titles are exposed through the iOS 14+ `UICollectionViewDataSource` methods `indexTitles(for:)` and `collectionView(_:indexPathForIndexTitle:at:)`.

2. SectionUI's default data source builds the title list from currently bound sections whose `indexTitle` is non-nil.

3. If no bound section has an index title, SectionUI returns nil for index titles.

4. `SKCSingleTypeSection` exposes `indexTitle` as a mutable section property.

5. `SKCDataSourceProtocol.indexTitleRow` defaults to `0`.

6. `SKCDataSourceProtocol.sectionIndex` defaults to the section's current `sectionInjection.index` for sections that conform to `SKCSectionActionProtocol`.

7. Index-title lookup returns `IndexPath(item: section.indexTitleRow, section: section.sectionIndex)`.

8. Because section index comes from injection, index-title behavior depends on the final manager-bound section order.

9. Do not cache an integer section index for index-title lookup across `manager.reload`.

10. Treat index titles as navigation affordances. They do not replace headers, grouping models, or search.

## Single Type Sections

11. Set index titles through `setSectionStyle` near the section declaration.

```swift
let section = ContactCell.wrapperToSingleTypeSection(models)
    .setSectionStyle(\.indexTitle, "A")
```

12. For single-type sections, the index title jumps to row `0` unless a custom section overrides `indexTitleRow`.

13. Set index titles after filtering optional sections and before `manager.reload(sections)` so the final title list matches the final section order.

14. Do not set `indexTitle` on spacer, divider, loading, error, or hidden utility sections unless users should navigate to them.

15. If several adjacent logical groups share one title, assign the title only to the first navigable section for that group.

16. If a titled section can become empty, decide whether the title should remain navigable or be removed from the rendered section list.

## Custom Sections

17. A direct `SKCSectionProtocol` implementation can expose an index title by implementing `indexTitle`.

18. Override `indexTitleRow` when the title should jump to a row other than `0`.

19. Return an index row that is inside `0..<itemCount`.

20. If the target row can disappear, recompute `indexTitleRow` from the current row snapshot.

21. For heterogeneous row sections, expose an index title only when there is a stable row that represents the group start.

22. Use a typed row lookup such as `rowForGroupStart` rather than hard-coded offsets when row composition is conditional.

23. Keep index-title grouping in the render/snapshot layer. Do not compute grouping inside data-source callbacks.

## Lookup Semantics

24. SectionUI filters sections by non-nil `indexTitle`, then matches UIKit's supplied title index against that filtered title list.

25. The `title` string passed by UIKit is not the primary lookup key in SectionUI's default implementation; the filtered title position is.

26. Duplicate index titles are allowed by the type system, but tapping the second duplicate depends on its position in the filtered title list.

27. Prefer unique title entries for predictable navigation.

28. If duplicate titles are intentional, document that each title position maps to a distinct section.

29. A section without `sectionInjection` cannot provide a valid `sectionIndex`, so index-title lookup returns `.next` from the default SectionUI data source.

30. When the manager has not loaded or the section list is stale, index-title lookup can fall through to the data-source forward default.

31. The data-source forward default for index-title lookup is an empty `IndexPath`. Avoid relying on it.

## Forwarding

32. Prefer section `indexTitle` before adding data-source forwarding.

33. Use `manager.dataSourceForward` only when the screen needs collection-wide custom title behavior that cannot be represented by sections.

34. A custom data-source forward that handles `indexTitles(for:)` should also handle `indexPathForIndexTitle` consistently.

35. Returning `.next` from a custom forward lets SectionUI's default section-based implementation handle the callback.

36. Returning `.handle(nil)` intentionally disables the index title list.

37. Observers can log the final title list and target index path, but cannot change the UIKit answer.

38. Keep index-title forwarding synchronous and cheap. UIKit asks for it as part of collection navigation.

## Reload And Identity

39. Call `manager.reload(sections)` after changing the set of titled sections.

40. If only row content changes and titles stay stable, normal section refreshes are enough.

41. If a section's `indexTitle` changes while the section remains bound, prefer a manager reload so the data source's title list is refreshed consistently.

42. Build titled sections from the final sorted/grouped data, not from an earlier unfiltered source list.

43. Recompute titles after locale, collation, search filter, or grouping mode changes.

44. When using `SKCSectionCollector` or result builders, assign titles after optional sections are collected and ordered.

45. Do not use `manager.insert` or `manager.remove` with newly created section instances to simulate title diffing. Use stable section instances or a full reload.

## Examples

Alphabet sections:

```swift
let sections = groups.map { group in
    ContactCell.wrapperToSingleTypeSection(group.items)
        .setSectionStyle(\.indexTitle, group.title)
        .setHeader(TitleHeaderView.self, model: group.title)
}

manager.reload(sections)
```

Skip empty groups:

```swift
let sections = groups.compactMap { group -> SKCBaseSectionProtocol? in
    guard !group.items.isEmpty else { return nil }
    return ContactCell.wrapperToSingleTypeSection(group.items)
        .setSectionStyle(\.indexTitle, group.title)
}

manager.reload(sections)
```

Custom section row target:

```swift
final class GroupedSection: SKCSectionProtocol {
    var sectionInjection: SKCSectionInjection?
    var rows: [Row] = []
    var indexTitle: String?

    @available(iOS 14.0, *)
    var indexTitleRow: Int {
        rows.firstIndex(where: \.isGroupStart) ?? 0
    }

    var itemCount: Int { rows.count }
}
```

Custom forwarding only when section titles are not enough:

```swift
final class IndexTitleForward: SKCDataSourceForwardableProtocol {
    var titles: [String] = []
    var targets: [IndexPath] = []

    @available(iOS 14.0, *)
    func indexTitles(for collectionView: UICollectionView) -> SKHandleResult<[String]?> {
        .handle(titles.isEmpty ? nil : titles)
    }

    @available(iOS 14.0, *)
    func collectionView(
        _ collectionView: UICollectionView,
        indexPathForIndexTitle title: String,
        at index: Int
    ) -> SKHandleResult<IndexPath> {
        guard targets.indices.contains(index) else { return .next }
        return .handle(targets[index])
    }
}
```

## Debug Checklist

46. Index titles do not appear: verify iOS 14+, non-empty bound sections, non-nil `indexTitle`, and `collectionView.dataSource` still pointing to SectionUI's `dataSourceForward`.

47. Title jumps to the wrong section: check final manager-bound section order and avoid cached integer section indexes.

48. Title jumps to the wrong row: inspect `indexTitleRow` and ensure it is valid for the current row snapshot.

49. Title list includes empty groups: filter empty groups before assigning index titles or remove titles from empty sections.

50. Duplicate titles feel unpredictable: ensure the title positions in the filtered titled-section list match the intended targets.

51. Custom forward hides section titles: check whether it returns `.handle(nil)` instead of `.next`.

52. Index title appears stale after sorting or filtering: rebuild titled sections and call `manager.reload(sections)`.

53. Background utility section receives navigation: remove `indexTitle` from spacer/loading/error sections.

54. Index title lookup returns an empty index path: the default data-source forward fallback was reached; verify a forward or default SectionUI data source handled the callback.

55. Header and index title disagree: derive both from the same group snapshot.

## Framework Boundary

56. Promote index-title helpers into SectionUI only when they describe generic grouping, collation, or forwarding mechanics.

57. Keep app-specific alphabets, locale policy, product categories, and business grouping outside the generic skill.

58. Document index titles as section navigation metadata, not as a downstream screen index.
