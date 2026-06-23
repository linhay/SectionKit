# Data Driven Best Practices

Use this reference when a SectionUI task needs framework-level guidance for data-driven rendering, state ownership, binding boundaries, or "bind once, then manage data" architecture.

## Contents

- [Doctrine](#doctrine)
- [Binding Phase Vs Runtime Phase](#binding-phase-vs-runtime-phase)
- [Binding Strategy](#binding-strategy)
- [Source Of Truth](#source-of-truth)
- [Update Flow](#update-flow)
- [High Frequency Row State](#high-frequency-row-state)
- [Composition Rules](#composition-rules)
- [Anti Patterns](#anti-patterns)
- [Debug Checklist](#debug-checklist)

## Doctrine

SectionUI 的核心宗旨是：完成 section / manager / view 绑定后，业务层只管理数据和状态；UI 注册、配置、尺寸、刷新、动画、曝光、选择和滚动等变化由 SectionUI 从数据自然派生。

This does not mean every screen must be fully reactive. It means each UI change should have an explicit data or state cause, and the framework should translate that cause into collection-view work.

## Binding Phase Vs Runtime Phase

1. Binding phase decides structure: create sections, attach cell actions, configure supplementary views, choose reload strategy, bind sections through `manager.reload`, `manager.insert`, or `manager.append`.

2. Runtime phase changes state: update upstream state, replace section models, mutate rows through section APIs, change selection state, invalidate affected caches, or rebuild the final section array.

3. After binding, avoid treating visible cells as the source of truth. Visible cells are render results and can disappear because of reuse, reload, scrolling, or layout invalidation.

4. Code that needs `sectionView`, layout attributes, visible cells, or bound section indexes must run after manager binding. Use `isBindSectionView`, `taskIfLoaded`, lifecycle publishers, `manager.sections`, or `manager.publishers.sectionsPublisher` according to timing needs.

## Binding Strategy

Choose the binding owner before choosing the API:

| Owner | Use | Runtime mutation |
| --- | --- | --- |
| View model, reducer, store, or request pipeline | `@SKPublished`, `SKPublishedValue`, upstream Combine publisher, then `section.subscribe(models:)` | Mutate upstream state; the section receives the next model snapshot. |
| Section owner / screen coordinator | `config(models:)`, `apply(_:)`, row mutation APIs | Mutate the section directly with `apply`, `refresh`, `append`, `insert`, `remove`, or `delete`. |
| Derived UI such as counts, empty hints, selection summaries | state publishers, `modelsPulisher`, `manager.publishers.sectionsPublisher` | Subscribe and render derived state; do not make the derived UI the data owner. |

- Do not create a publisher only to mirror a local array that the section owner already controls.
- Do not manually mutate a section that is already subscribed to a complete model publisher. The next emission will overwrite the manual change.
- If both upstream state and local section APIs seem necessary, split ownership by concern: durable models upstream; transient visual state in selection/cache/interaction state.

## Source Of Truth

5. Keep canonical screen data in the view model, reducer state, store, or section owner. Section models are the render snapshot.

6. A cell should render from its model in `config(_:)`; it should not own durable business state.

7. When a publisher owns a section, the publisher is the source of truth. Use `section.subscribe(models:)`, then mutate the upstream state instead of manually editing the section.

```swift
@SKPublished var items: [ItemCell.Model] = []

let section = ItemCell.wrapperToSingleTypeSection()
section.subscribe(models: $items.eraseToAnyPublisher())

manager.reload(section)

items = loadedItems
```

8. When the section owner is imperative, use `config(models:)`, `apply(_:)`, `append`, `insert`, `delete`, `remove`, or `refresh(with:)` directly. Do not add a publisher layer only to mirror the same local array.

```swift
let section = ItemCell.wrapperToSingleTypeSection()
manager.reload(section)

section.apply(loadedItems)
section.refresh(at: row, model: updatedItem)
```

9. Selection is state. Prefer `SKSelectionState`, `SKSelectionWrapper`, `SKSelectionSequence`, `SKSelectionIdentifiableSequence`, or a screen-owned selection model over ad hoc selected flags stored only in cells.

10. Empty, loading, error, and content are render states. Model them explicitly as state or sections instead of relying on hidden cells or a controller-side flag that the section cannot observe.

## Update Flow

11. Initial render: create stable section instances, configure actions/styles/supplementary views, set initial models if available, then bind through the manager.

12. Full data replacement: call `section.apply(newModels)` or `section.config(models: newModels)`. Set `section.reloadKind` before applying if diff behavior is required.

13. Local row replacement: call `section.refresh(at:model:)` or `section.refresh(with:)`. These APIs write the new row model before reloading the row.

14. Visible-only reconfiguration: use `section.refresh(at:)` only when the model object has already changed or the cell can re-render from existing state.

15. Insert/delete/move: use section row mutation APIs for row-local changes. Use manager section operations only when the screen composition itself changes.

16. Screen composition changes: rebuild the final `[SKCBaseSectionProtocol]` or collector output from current state, then call `manager.reload(sections)` when optional sections, ordering, or section identity changed.

17. Derived UI should subscribe to state or section publishers. Examples: count labels, empty-state toggles, sticky affordances, selection summaries, or cross-cutting analytics observers.

18. Size-affecting changes must update data first, invalidate the affected size-cache entries when high-performance cache is used, then refresh or apply.

## High Frequency Row State

For progress text, status badges, icon state, alpha, enabled/disabled visuals, or similar fields that change often but do not change row count, section order, supplementary views, layout plugins, decorations, or cell height, keep stable reference-type cell view models in the section and update `@SKPublished` fields on those same instances.

| Change | Prefer |
| --- | --- |
| Non-height visual state on an existing row | Stable cell view model + cell-owned `@SKPublished` subscriptions |
| Same row identity, new value model content | `section.refresh(at:model:)`, `refresh(with:)`, or predicate refresh |
| Full snapshot, sorting, filtering, insert/delete/reorder | `section.apply(_:)` / `config(models:)` with the chosen `reloadKind` |
| Section list, optional section, header/footer, plugin, decoration, or layout geometry changes | Rebuild sections and `manager.reload(sections)` |

Do not drive high-frequency progress/status updates with repeated `manager.reload`, `section.apply`, or `section.refresh` when the structure and height are unchanged. That creates avoidable collection-view work and can cause visible cell churn.

## Composition Rules

19. Prefer many small sections over one section that switches on every row shape and business state.

20. Keep section instances stable when later row refresh, selection, display tracking, or scroll targeting needs identity.

21. Use `SKCSectionCollector`, result builders, or explicit section arrays to derive the final visible structure from state. Avoid hard-coded section indexes after optional sections enter the screen.

22. Keep business actions near the section that emits them, usually through `onCellAction`, `onSupplementaryAction`, context menu handlers, prefetch handlers, or section publishers owned by the screen/coordinator.

23. Put repeated product patterns into integration-level abstractions: selectable sections, diff sections, settings rows, grid/action sheets, spacer/divider sections, or render-state helpers. Keep the core framework focused on generic mechanisms.

## Anti Patterns

24. Do not change UI by grabbing a visible cell and mutating labels, images, or hidden flags. Change the model/state, then refresh/apply.

25. Do not duplicate the same durable state in a controller property, section models, and cell fields without one clear owner.

26. Do not combine `subscribe(models:)` with manual `append`, `insert`, `remove`, or `delete` unless the next publisher emission intentionally overwrites local mutations.

27. Do not let cell closures become mini reducers. Cells should report intent; the state owner decides the data mutation.

28. Do not store long-lived business state in supplementary views. Treat supplementary views like cells: configured from model/state and replaceable by reuse.

29. Do not call `manager.reload` for every small row event. Prefer row mutation APIs when structure is unchanged, or stable `@SKPublished` cell view models when only non-layout visual state changes.

30. Do not persist `sectionIndex` or `IndexPath` across optional section changes, filtering, sorting, or manager reloads. Re-resolve from identity and current bound sections.

## Debug Checklist

31. UI did not update: verify the data owner changed, the section is bound, and the update path reaches `apply`, `refresh(with:)`, or a publisher subscription.

32. Row refresh did nothing: verify the row is still in bounds and the model was written before `refresh(at:)`, or use `refresh(at:model:)`.

33. Local edits disappear: check whether `subscribe(models:)` is active. If yes, move the edit upstream.

34. Wrong section updated: stop relying on stale offsets. Hold typed section references or derive current indexes from `manager.sections`.

35. Stale size: invalidate `SKHighPerformanceStore` entries keyed by the affected model identity before refreshing.

36. Feedback loop: if section publishers and state publishers write to each other, add identity guards, `removeDuplicates`, or a coordinator that owns the render transaction.
