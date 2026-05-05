# Prefetch Menu Reorder Recipes

Use this reference when a SectionUI task involves `section.prefetch`, pagination, media preloading, `onContextMenu`, `SKUIAction`, `SKUIContextMenuResult`, `onCellShould(.move)`, or drag reorder persistence.

## Prefetch Contract

Section-level prefetch publishers emit section-local row indexes, not collection index paths.

```swift
section.prefetch.prefetchPublisher
    .sink { rows in
        let models = rows.compactMap { row in
            section.models.indices.contains(row) ? section.models[row] : nil
        }
        preload(models)
    }
    .store(in: &cancellables)
```

`cancelPrefetchingPublisher` also emits section-local rows. Cancel by stable model identity when the work can outlive row movement or a full model replacement.

Manager-level prefetch forwarding must remain installed and enabled before section prefetch publishers receive events. Use section-level publishers for feature work; use manager-level prefetch observers for diagnostics or cross-cutting infrastructure.

## Load More

`loadMorePublisher` emits when the largest prefetched row reaches the current last model index.

```swift
section.prefetch.loadMorePublisher
    .sink { [weak self] in
        guard let self, !isLoading, hasMore else { return }
        loadNextPage()
    }
    .store(in: &cancellables)
```

Load the first page explicitly. Avoid relying on `loadMorePublisher` for empty sections because it needs a meaningful current model count.

When replacing the entire model list, cancel work for old identities before accepting new prefetch events.

## Context Menus

Use `onContextMenu` for row-specific menus and `onContextMenu(where:)` for composable predicates.

```swift
section.onContextMenu(where: { $0.model.canShowMenu }) { context in
    SKUIContextMenuResult([
        UIAction(title: "Open") { _ in
            open(context.model)
        }
    ])
}
```

The first non-nil context menu result wins. Call `clearContextMenuActions()` before rebinding a reused section to a different menu policy.

`SKCContextMenuContext` contains `section`, `model`, and `row`. It intentionally does not support `view()`, so menu construction should come from model state rather than visible cell state.

`SKUIContextMenuResult` can be built from a `UIMenu`, `[UIAction]`, `[SKUIAction]`, or an array literal. Use it for row-specific highlight and dismissal previews:

```swift
section.onContextMenu { context in
    SKUIContextMenuResult(
        configuration: UIContextMenuConfiguration(
            identifier: nil,
            previewProvider: nil,
            actionProvider: { _ in
                UIMenu(children: [
                    UIAction(title: "Delete", attributes: .destructive) { _ in
                        context.remove()
                    }
                ])
            }
        ),
        highlightPreview: nil,
        dismissalPreview: nil
    )
}
```

`SKUIAction` runs an async throwing handler in a main-actor `Task`. Handle errors inside the action when user feedback or retry state matters.

```swift
SKUIAction(title: "Refresh") {
    do {
        try await refresh()
    } catch {
        showError(error)
    }
}
```

Section-level menus are single-row oriented. For multi-item menus or background menus, use integration-level delegate forwarding.

## Reorder

Enable movement with `onCellShould(.move, true)` or a row/model predicate.

```swift
section.onCellShould(.move) { context in
    context.model.canMove
}
```

If no `.move` predicate handles the row, movement defaults to false.

Default move behavior for `SKCSingleTypeSection`:

- same source and destination section: swaps the two models,
- source section to another section: removes the source model,
- destination single-type section receiving a foreign source: asserts by default.

Use a custom section or integration-level data-source forwarding when the desired behavior is insertion-style reorder, cross-section transfer, or domain-specific move validation.

After user reorder, update the canonical source array immediately. A later render from stale state will undo the visible collection order.

## Debug Checklist

- Prefetch never fires: verify the collection prefetch data source is still SectionUI's forwarder and manager prefetch routing is enabled.
- Prefetch rows map to wrong models: convert rows to model identities immediately and guard row bounds.
- Load more repeats: add request gating and ensure old subscriptions are cancelled on rerender.
- Menu missing: confirm at least one provider returns non-nil for the current model and row.
- Menu action error disappears: catch errors inside `SKUIAction`.
- Reorder not allowed: verify `.move`, not an older `.canMove` name, is registered.
- Reorder appears then resets: synchronize canonical state after move before the next render.
- Cross-section move crashes or loses data: implement explicit cross-section handling instead of relying on the single-type default.

## Framework Boundary

Keep prefetch, menu, and reorder guidance generic. Document row-index semantics, pagination gates, menu result routing, async action ownership, move defaults, and persistence boundaries. Do not encode downstream network clients, business menu titles, permission rules, page names, source paths, scan counts, or project indexes into the skill.
