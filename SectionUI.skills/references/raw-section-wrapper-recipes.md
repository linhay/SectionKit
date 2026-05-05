# Raw Section Wrapper Recipes

This reference captures recipes for `SKCRawSectionProtocol`, `SKCAnySectionProtocol`, and `SKCAnySingleTypeSectionProtocol`. Keep it generic: no downstream project paths, product names, business module names, source-file indexes, scan statistics, page names, or business event names.

## Contents

- [When To Use](#when-to-use)
- [Protocol Contracts](#protocol-contracts)
- [Single-Type Wrapper Pattern](#single-type-wrapper-pattern)
- [Identity And Binding](#identity-and-binding)
- [Styling And Plugins](#styling-and-plugins)
- [Events And Actions](#events-and-actions)
- [Debug Checklist](#debug-checklist)
- [Framework Boundary](#framework-boundary)

## When To Use

1. Use a raw-section wrapper when a reusable component should expose a small public render API while internally using `SKCSingleTypeSection<Cell>`.

2. Use a wrapper when the component owns persistent behavior such as one-model rendering, selection state, cache invalidation, events, or a domain-independent render contract.

3. Use plain helper functions returning `[SKCBaseSectionProtocol]` when no persistent state or fluent configuration is needed.

4. Implement `SKCSectionProtocol` directly when the component owns heterogeneous row dispatch, custom item sizing, custom supplementary behavior, or one logical mixed-row snapshot.

5. Do not use a wrapper only to rename `Cell.wrapperToSingleTypeSection(...)`. That adds identity and lifecycle surface without value.

## Protocol Contracts

6. `SKCAnySectionProtocol` exposes `section: SKCSectionProtocol` and defaults `objectIdentifier` to the underlying section identity.

7. `SKCAnySectionProtocol` delegates `itemCount`, `sectionInjection`, and `config(sectionView:)` to `section`.

8. A type that is already an `SKCSectionProtocol` automatically satisfies `section` as `self`.

9. `SKCRawSectionProtocol` adds `rawSection`, which is the concrete section instance that style helpers mutate.

10. `SKCRawSectionProtocol.setSectionStyle(...)` mutates `rawSection` directly and returns `Self` for fluent wrapper configuration.

11. `SKCAnySingleTypeSectionProtocol` is for wrappers whose `RawSection` is exactly `SKCSingleTypeSection<Cell>`.

12. `SKCAnySingleTypeSectionProtocol.Cell` must be a `UICollectionViewCell` that conforms to `SKLoadViewProtocol` and `SKConfigurableView`.

13. `SKCAnySingleTypeSectionProtocol` forwards `sectionInset`, `sectionInjection`, `plugins`, `pin(options:)`, and `onCellAction(...)` to `rawSection`.

## Single-Type Wrapper Pattern

14. Store one `rawSection` instance. Do not compute a fresh raw section from a getter if the wrapper can be rebound, styled, pinned, or observed.

```swift
final class SingleModelSection<Cell>: SKCAnySingleTypeSectionProtocol
where Cell: UICollectionViewCell & SKLoadViewProtocol & SKConfigurableView {
    let rawSection = Cell.wrapperToSingleTypeSection()

    var section: SKCSectionProtocol { rawSection }

    func render(_ model: Cell.Model?) -> Self? {
        guard let model else { return nil }
        rawSection.config(models: [model])
        return self
    }
}
```

15. Return the wrapper itself when downstream code uses `SKCSectionCollector`, result builders, or wrapper-level fluent APIs that can unwrap `SKCAnySectionProtocol.section`.

16. Return `rawSection` directly when the wrapper is only a temporary render helper and no one should observe wrapper identity.

17. Keep render methods small: transform input model to cell models, configure `rawSection`, then return the wrapper or raw section.

18. If the wrapper can render no content, return `nil` or omit it from a section builder. Do not render an empty section unless an empty UI is intentional.

19. If a wrapper owns multiple visual sections, prefer returning `[SKCBaseSectionProtocol]` rather than pretending it is one section.

20. If the wrapper needs multiple cell types in one logical order, move to a direct `SKCSectionProtocol` implementation.

21. `SKCManager.reload(...)`, `insert(...)`, `append(...)`, and `remove(...)` operate on `SKCBaseSectionProtocol`; pass `wrapper.section` or collect wrappers through `SKCSectionCollector` before binding to the manager.

## Identity And Binding

22. Section identity comes from the section instance ultimately bound to the manager.

23. If `section` returns a new section instance every access, `objectIdentifier`, manager insert/remove, pinning, binding keys, and scroll targets can become unstable.

24. Prefer `let rawSection = ...` or `lazy var rawSection = ...` for wrappers with lifecycle.

25. Do not cache `sectionInjection.index` inside a wrapper across full manager reloads. Resolve it from the current raw section when needed.

26. If a wrapper returns `self` from render, ensure `section` still returns the same raw section instance that manager binds.

27. If multiple wrappers share one raw section instance accidentally, selection, displayed counts, plugins, and injection will collide.

28. Keep one wrapper instance per logical section lifetime unless the component is intentionally stateless.

## Styling And Plugins

29. Use `setSectionStyle` on wrappers when you want wrapper callers to configure the underlying `SKCSingleTypeSection` without exposing it.

```swift
section
    .setSectionStyle(\.sectionInset, .init(top: 8, left: 16, bottom: 8, right: 16))
    .onCellAction(.selected) { context in
        handleSelection(context.model)
    }
```

30. `sectionInset` on `SKCAnySingleTypeSectionProtocol` reads and writes `rawSection.sectionInset`.

31. `plugins` on `SKCAnySingleTypeSectionProtocol` reads and writes `rawSection.plugins`.

32. `pin(options:)` pins the raw section. Store the returned cancellable for the same lifetime as the wrapper's pin behavior.

33. Configure section-level layout plugins on the wrapper only when the plugin belongs to that reusable component.

34. Configure collection-level plugin modes on `SKCollectionView` when the behavior applies across sections.

35. If wrapper styling appears ignored, verify the wrapper's `rawSection` is the same section instance returned through `section`.

## Events And Actions

36. `onCellAction(...)` on `SKCAnySingleTypeSectionProtocol` forwards to `rawSection.onCellAction(...)` and returns the wrapper.

37. Keep navigation, analytics, and row callbacks at the wrapper boundary when the wrapper owns the reusable interaction contract.

38. If a wrapper exposes callbacks, keep callback names generic and UI-focused. Do not bake product-specific events into framework-level wrappers.

39. Capture owners weakly in wrapper action closures unless the wrapper has an explicit shorter lifecycle.

40. If the wrapper owns Combine subscriptions, reset them when the rendered model universe changes.

41. If the wrapper reuses raw section models across renders, reset row-based state such as selection, prefetch work, and display counters deliberately.

## Debug Checklist

42. Wrapper style did not apply: `rawSection` was not the same instance returned by `section`.

43. Manager remove misses the section: wrapper or raw section identity changed after binding, or manager was given a different underlying section instance.

44. Pin stops working: the returned cancellable was released or the wrapper was replaced.

45. Cell action fires twice: render added another action closure without clearing or owning the previous registration lifecycle.

46. Selection leaks between screens: the same wrapper or raw section instance is shared across independent render lifetimes.

47. Display count is stale after new content: row-based counters were not reset when the wrapper changed model universe.

48. Section builder cannot omit the wrapper: render returns an empty raw section instead of `nil` for absent content.

49. Layout plugin affects the wrong rows: plugin was configured on a shared raw section or at collection scope instead of wrapper scope.

## Framework Boundary

50. Keep generic raw-section wrapper contracts in SectionUI: identity, raw section forwarding, style/plugin forwarding, and lifecycle rules.

51. Keep branded rows, request clients, route names, analytics payloads, and feature-specific empty states in integration layers.
