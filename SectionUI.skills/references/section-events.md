# Section Events

Use this reference when a SectionUI task involves `onCellAction`, `onAsyncCellAction`, `onCellShould`, supplementary actions, `clearCellAction(_:)`, event ordering, or registering handlers around cell configuration and reuse.

## Contents

- [Registration Contract](#registration-contract)
- [Cell Configuration And Reuse](#cell-configuration-and-reuse)
- [Rebinding](#rebinding)
- [Ownership](#ownership)
- [Debug Checklist](#debug-checklist)
- [Framework Boundary](#framework-boundary)

## Registration Contract

1. `onCellAction` appends a handler to the section's event group. It does not replace an existing handler.

2. Multiple handlers for one action kind run in registration order. Use multiple handlers only when their concerns are independent; combine them when ordering is part of the behavior.

3. `onAsyncCellAction` wraps and appends an async handler through `onCellAction`, so it has the same registration and ordering rules.

4. `onCellShould` and `setCellStyle` are also registration APIs. Each call adds another callback or style to the section.

5. Register events once when the section is created. A fluent declaration or a stable lazy section initializer makes the registration lifetime visible.

```swift
private lazy var itemSection = ItemCell
    .wrapperToSingleTypeSection()
    .onCellAction(.selected) { [weak self] context in
        self?.onSelect?(context.model)
    }

func config(_ model: Model) {
    itemSection.config(models: model.items)
}
```

## Cell Configuration And Reuse

6. `config(_:)` is a repeated render step. `SKCSingleTypeSection.item(at:)` calls `cell.config(model)` whenever a cell is requested, including normal cell-for-item requests, reuse, and reload paths. A `reloadKind == .configAndDelete` update can also configure visible cells directly.

7. Keep `config(_:)` idempotent: render the current model and reset replaceable state. Do not call `onCellAction`, `onAsyncCellAction`, `onCellShould`, `setCellStyle`, subscribe, or add notification observers from `config(_:)`.

8. Re-registering an action from `config(_:)` makes a single tap run every accumulated handler. If a reusable cell owns a stable nested section, keep the event registration in the lazy initializer and update only its models during `config(_:)`.

## Rebinding

9. `clearCellAction(_:)` removes all handlers for one cell action kind. Use it before intentionally rebinding a reusable section to a different action policy.

10. Clearing and re-registering is a rebinding escape hatch, not a substitute for one-time registration. Prefer a section instance with one stable action policy when the section's owner does not change.

11. When a section is reused for a different model universe, reset related selection, exposure, subscription, and context-menu state at the same rebinding boundary.

## Ownership

12. Keep navigation, analytics, and other business side effects near the section or coordinator that owns the row. Cells should render models and expose small intent closures.

13. Capture long-lived owners weakly, or use `on: owner` helpers where available.

## Debug Checklist

14. If a handler fires twice, inspect every path that calls `onCellAction` and check whether it runs from `config(_:)` or another repeated binding path.

15. If a reused section keeps an old owner or policy, call `clearCellAction(_:)` before rebinding or create a fresh section.

16. If a style or observer runs repeatedly, inspect `setCellStyle`, subscriptions, and notification registration for the same repeated-binding pattern.

## Framework Boundary

The section owns its event groups and executes all registered handlers. UIKit only supplies the delegate event; it does not deduplicate SectionUI registrations.
