# Row Mutation Recipes

Use this reference when a SectionUI task involves `SKCSingleTypeSection` row mutation, `refresh(at:)`, `refresh(with:)`, `RefreshPayload`, predicate refresh, `append`, `insert`, `remove`, `delete`, `apply`, `config(models:)`, or `reloadKind`.

Keep it generic: no downstream project paths, product names, business module names, source-file indexes, scan statistics, page names, route names, analytics events, or request-client names.

## Contents

- [Mutation Boundary](#mutation-boundary)
- [Refresh APIs](#refresh-apis)
- [Predicate Refresh](#predicate-refresh)
- [Append And Insert](#append-and-insert)
- [Remove And Delete](#remove-and-delete)
- [Full Replacement](#full-replacement)
- [ReloadKind](#reloadkind)
- [Action Context Mutations](#action-context-mutations)
- [Examples](#examples)
- [Debug Checklist](#debug-checklist)
- [Framework Boundary](#framework-boundary)

## Mutation Boundary

1. `SKCSingleTypeSection.models` is the section's source of truth.

2. Prefer SectionUI mutation APIs over direct `models` mutation so collection updates, reloads, deleted-model bookkeeping, and publishers stay coherent.

3. Use `config(models:)` or `apply(_:)` for full replacement from canonical screen state.

4. Use `append`, `insert`, `remove`, `delete`, and `refresh(with:)` for local row changes.

5. Use `refresh(at:)` only when the model is already updated or when visible reconfiguration is enough.

6. Do not call `manager.reload()` after every row mutation. Bound row mutation APIs already perform their UIKit item operation or section reload.

7. When a section is unbound, row mutation APIs mutate only section state and cannot perform UIKit item updates.

8. Resolve row indexes as late as possible when async work, filtering, sorting, or pagination can move rows.

## Refresh APIs

9. `refresh(at row)` calls `refresh(at: [row])`.

10. `refresh(at rows)` calls `sectionInjection?.reload(cell: rows)`.

11. `refresh(at:)` does not validate row bounds itself and does not mutate `models`.

12. `SKCSectionInjection.reload(cell:)` returns early for an empty row list.

13. `refresh(at:model:)` builds a `RefreshPayload` and delegates to `refresh(with:)`.

14. `refresh(with payload)` delegates to `refresh(with: [payload])`.

15. `refresh(with payloads)` validates payload rows in DEBUG, filters invalid rows, writes `models[payload.row] = payload.model`, then reloads those rows.

16. Use `refresh(with:)` when replacing row models in place.

17. Use `refresh(at:)` after mutating reference-type model state that the cell reads from the same object.

18. When a size-affecting model field changes, invalidate size cache before calling `refresh(with:)` or `refresh(at:)`.

19. If a row-position style can change after refresh, also refresh adjacent or trailing rows explicitly.

## Predicate Refresh

20. `refresh(_ models, predicate:)` scans current rows and tries to match each old model with a new model.

21. The predicate receives `(old, new)`.

22. The first matching new model for a row becomes that row's replacement payload.

23. Predicate refresh does not insert missing models or delete old models. It only replaces matched existing rows.

24. Make the predicate identity-based and deterministic.

25. Do not use full content equality as the predicate when changed content should replace the old row.

26. For `Model: Equatable`, `refresh(_ model)` and `refresh(_ models)` use `==`.

27. For `Model: AnyObject`, `refresh(_ model)` and `refresh(_ models)` use reference identity (`===`).

28. For value models with stable IDs, prefer `refresh([updated]) { old, new in old.id == new.id }`.

29. If the incoming data may include new rows or removed rows, use `apply(_:)` with an appropriate `reloadKind` instead of predicate refresh.

## Append And Insert

30. `append(item)` delegates to `append([item])`.

31. `append(items)` inserts at `models.count`.

32. `insert(at:row, items)` returns early for an empty item list.

33. When bound, `insert` performs batch updates, mutates `models`, and calls `insertItems(at:)` for the inserted row range.

34. When unbound, `insert` mutates `models` only.

35. `insert` does not clamp the target row. Validate external indexes before calling it.

36. Prefer append for pagination and load-more because it avoids index math.

37. Use insert when the row position is part of the feature contract and the index was derived from the current section state.

38. If insertion changes separator, corner, or first/last-row styling, refresh affected neighboring rows after the insert.

## Remove And Delete

39. `delete` is an alias-style API over `remove`.

40. `remove(row)` delegates to `remove([row])`.

41. `remove(rows)` delegates to `remove(rows, applySectionView: true)`.

42. `remove(rows, applySectionView:)` deduplicates rows, filters invalid rows, and sorts descending before deleting.

43. When bound, `remove` stores deleted models by old row, mutates `models`, calls `deleteItems(at:)`, then reloads trailing rows after the batch completes.

44. The trailing reload helps row-position-dependent styles recover after deletion.

45. When unbound, `remove` mutates `models` directly.

46. `remove(rows, applySectionView: false)` currently returns without mutating. Do not use it as a model-only removal helper.

47. `remove(where:)` collects matching row indexes and delegates to row removal.

48. Equatable remove finds rows whose models compare equal.

49. AnyObject remove finds rows whose models have the same object identity.

50. For optimistic deletion, store the original row and model before removing so a failed request can reinsert at a valid position.

## Full Replacement

51. `config(models:)` calls `apply(models)` and returns the section for chaining.

52. `apply(_:)` records old models for display-end bookkeeping unless `feature.skipDisplayEventWhenFullyRefreshed` is true.

53. `apply(_:)` delegates to the internal reload path selected by `reloadKind`.

54. Use full replacement when the list is rendered from canonical state, after sorting/filtering, or when inserts/deletes/reorders are easier to reason about as a new snapshot.

55. Do not repeatedly call `config(models:)` with single-item arrays in a loop. Build the final array and apply once.

56. If the replacement changes headers, footers, decorations, layout plugins, or size-cache identity, prefer full section reload behavior over targeted row refresh.

## ReloadKind

57. `.normal` replaces models and reloads the whole section.

58. `.configAndDelete` is a narrow optimization. Use it only when visible cell reconfiguration is enough and layout/supplementary/decorations do not need full recalculation.

59. `.difference(by:)` computes a `CollectionDifference` from old models to new models using the supplied equivalence predicate.

60. The `.difference(by:)` predicate is identity equivalence, not content equality.

61. If the same identity has changed display content, refresh changed rows separately or use a replacement path that reconfigures visible cells.

62. `.difference()` is available when `Model: Equatable` and uses `==` as the equivalence predicate.

63. `ReloadKind.difference(by: \.id)` is useful when the key path is stable identity.

64. Avoid row index, title text, or transient display strings as difference identity.

65. When either old or new models are empty, difference reload falls back to section reload.

66. Avoid switching `reloadKind` repeatedly from different feature paths. Set it near section creation unless a specific transition requires a documented change.

67. There is no section API that accepts a `ReloadKind` argument directly. Set `section.reloadKind`, then call `apply(_:)` or `config(models:)`.

## Action Context Mutations

68. `context.reload()` reloads the current row from the action context.

69. `context.refresh(with:)` replaces the current row model and reloads it.

70. `context.remove()` and `context.delete()` remove the current row.

71. `context.insert(before:)` inserts at the current row.

72. `context.insert(after:)` inserts after the current row.

73. Action context row values are snapshots from the callback moment. Re-resolve by model identity before mutating after `await`, delayed callbacks, filtering, sorting, or pagination.

74. Prefer context helpers for immediate synchronous row-local edits.

75. Prefer section-level identity lookup for async edits.

## Examples

Replace one value-model row by stable ID:

```swift
section.refresh([updatedModel]) { old, new in
    old.id == new.id
}
```

Replace a known row and invalidate its size cache:

```swift
sizeStore.remove(by: updated.id)
section.refresh(at: row, model: updated)
```

Apply a new canonical snapshot:

```swift
section.reloadKind = .difference(by: \.id)
section.apply(newModels)
```

Perform an async row action safely:

```swift
section.onCellAction(.selected) { [weak section] context in
    let id = context.model.id

    Task { @MainActor in
        let updated = try await loadUpdatedModel(id: id)
        guard let row = section?.models.firstIndex(where: { $0.id == id }) else {
            return
        }
        section?.refresh(at: row, model: updated)
    }
}
```

Optimistic delete with rollback:

```swift
func delete(_ model: Item) {
    guard let row = section.models.firstIndex(where: { $0.id == model.id }) else {
        return
    }

    section.remove(row)

    Task { @MainActor in
        let success = await deleteRemote(id: model.id)
        if !success {
            let insertionRow = min(row, section.models.count)
            section.insert(at: insertionRow, model)
        }
    }
}
```

## Debug Checklist

76. Row refresh does nothing: verify the section is bound, rows are non-empty, the row is valid, and the model was written before `refresh(at:)`.

77. Row reload crashes: validate external row indexes before calling `refresh(at:)` or `insert(at:)`.

78. Updated content does not appear: use `refresh(with:)`, predicate refresh, or direct model mutation before `refresh(at:)`.

79. New rows are missing after predicate refresh: predicate refresh does not insert. Use `apply(_:)`, `append`, or `insert`.

80. Deleted row's end-display model is wrong: ensure deletion uses SectionUI remove/delete APIs so `deletedModels` is populated.

81. Separators or rounded corners are wrong after deletion: rely on trailing reload or explicitly refresh affected neighbors.

82. Difference animation misses content changes: the identity predicate matched old and new rows, so unchanged identities were not reconfigured.

83. Size is stale after row update: invalidate `SKHighPerformanceStore` by stable model ID before refreshing.

84. Optimistic rollback inserts in the wrong place: clamp the saved row against the current model count.

85. Async context edit affects the wrong row: store model identity and re-resolve row before mutating.

86. Full reload fires too often: replace repeated `manager.reload` calls with row mutation APIs or a single `apply(_:)`.

87. Direct model mutation has no UI effect: use SectionUI row APIs or call a targeted refresh after changing the model.

## Framework Boundary

88. Promote row-mutation helpers into SectionUI only when they are generic state-to-row operations.

89. Keep business rollback policy, request retries, analytics, and authorization outside generic row mutation recipes.

90. Document row mutation as source-of-truth update plus matching UIKit operation, not as downstream screen workflow.
