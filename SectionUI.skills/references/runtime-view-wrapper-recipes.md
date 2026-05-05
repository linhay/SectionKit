# Runtime View Wrapper Recipes

This reference captures recipes for `SKCAnyViewCell`, `SKWrapperView`, `SKCWrapperCell`, and `SKCWrapperReusableView`. Keep it generic: no downstream project paths, product names, business module names, source-file indexes, scan statistics, page names, or business event names.

## Contents

- [When To Use](#when-to-use)
- [SKCAnyViewCell](#skcanyviewcell)
- [SKWrapperView](#skwrapperview)
- [SKCWrapperCell](#skcwrappercell)
- [SKCWrapperReusableView](#skcwrapperreusableview)
- [Sizing And Insets](#sizing-and-insets)
- [Reuse And Ownership](#reuse-and-ownership)
- [Debug Checklist](#debug-checklist)
- [Framework Boundary](#framework-boundary)

## When To Use

1. Use `SKCAnyViewCell` when the rendered `UIView` instance already exists at runtime and should be hosted as one collection cell.

2. Use `SKWrapperView<Content, UserInfo>` when a reusable `UIView` should become a SectionUI-configurable view with model, inset, sizing, and style closures.

3. Use `View.wrapperToCollectionCell()` when a reusable `UIView` already conforms to `SKLoadViewProtocol` and `SKConfigurableView` and should be used as a cell.

4. Use `View.wrapperToCollectionReusableView()` when that reusable view should become a header or footer.

5. Prefer a dedicated `UICollectionViewCell` when the row needs selected background, focus, editing, reorder affordance, cell-specific cleanup, or complex reuse lifecycle.

6. Prefer a normal configurable view over `SKCAnyViewCell` when the row type will be reused across screens.

## SKCAnyViewCell

7. `SKCAnyViewCell.Model` stores `view: UIView?`, `size: PreferredSize`, and `layout: Layout`.

8. `preferredSize(limit:model:)` delegates to `model.size.value(limit, model)` and returns `.zero` when the model is nil.

9. `PreferredSize.height(_:)` returns full available width and the fixed height.

10. `Layout.fill()` pins the hosted view to the cell `contentView` edges with required constraints.

11. `config(_:)` removes the previously hosted view from its superview.

12. `config(_:)` also removes the incoming view from its current superview before adding it to this cell.

13. If `model.view` is nil, `config(_:)` leaves the cell empty after clearing the previous view.

14. Use explicit `PreferredSize` and `Layout` for every `SKCAnyViewCell.Model`. A view instance alone is not a sizing or layout contract.

```swift
let model = SKCAnyViewCell.Model(
    view: customView,
    size: .height(88),
    layout: .fill()
)

let section = SKCAnyViewCell.wrapperToSingleTypeSection(model)
```

15. Do not reuse the same live `UIView` instance in multiple visible `SKCAnyViewCell` models. UIKit view ownership allows one superview at a time.

16. If a hosted view owns subscriptions or gesture state, reset that view before reusing it in another model.

## SKWrapperView

17. `UIView.sk.wrapperToConfigurableView()` returns `SKWrapperView<Base, Void>.Type`.

18. `UIView.sk.wrapperToConfigurableView(userInfo:)` returns `SKWrapperView<Base, UserInfo>.Type`.

19. `SKWrapperView.Model` stores `userInfo`, `insets`, a `size` closure, and a `style` closure.

20. For `Content: SKConfigurableView` and `UserInfo == Content.Model`, `Model(userInfo:insets:)` measures the content using the limit minus insets, then adds the insets back.

21. That same initializer calls `content.config(userInfo)` from the style closure.

22. `preferredSize(limit:model:)` returns `model.size(limit)` or `.zero` when the model is nil.

23. `config(_:)` calls `model.style(content)` and updates edge constraints from `model.insets`.

24. `SKWrapperView` creates one `content` view and keeps it across config calls.

25. `init(content:)` for `Content: SKLoadViewProtocol` instantiates `Content.nib` when available; otherwise it creates `Content()`.

26. The normal `init(frame:)` creates `Content()` directly.

27. Keep `style` idempotent. It may run repeatedly on the same content view during reuse.

```swift
typealias BadgeWrapper = SKWrapperView<BadgeView, BadgeView.Model>.Model

let model = BadgeWrapper(
    userInfo: badge,
    insets: .init(top: 4, left: 12, bottom: 4, right: 12)
)
```

## SKCWrapperCell

28. `View.wrapperToCollectionCell()` returns `SKCWrapperCell<View>.Type`.

29. `SKCWrapperCell.preferredSize(limit:model:)` delegates to `View.preferredSize(limit:model:)`.

30. `SKCWrapperCell.config(_:)` delegates to `wrappedView.config(model)`.

31. `SKCWrapperCell.wrappedView` is loaded from `View.nib` when available; otherwise it creates `View()`.

32. The wrapped view is pinned to `contentView` edges.

33. Use this wrapper when the reusable unit is a `UIView`, not a collection cell.

34. Do not put cell-only behavior in a plain wrapped view unless that behavior is also valid outside collection cells.

## SKCWrapperReusableView

35. `View.wrapperToCollectionReusableView()` returns `SKCWrapperReusableView<View>.Type`.

36. `SKCWrapperReusableView.preferredSize(limit:model:)` delegates to `View.preferredSize(limit:model:)`.

37. `SKCWrapperReusableView.config(_:)` delegates to `wrappedView.config(model)`.

38. `SKCWrapperReusableView.wrappedView` currently creates `View()` directly and does not instantiate `View.nib`.

39. Wrapper reusable view constraints use `.defaultHigh` priority.

40. Use a direct supplementary view conforming to `SKLoadViewProtocol` when a nib-backed reusable view is required.

## Sizing And Insets

41. Keep wrapper size closures pure. They should depend on model and limit, not visible view state.

42. For configurable content wrapped by `SKWrapperView`, prefer the built-in `Model(userInfo:insets:)` initializer so measurement and constraints agree.

43. For fixed spacers, dividers, and simple chrome, use explicit fixed size closures rather than Auto Layout measurement.

44. If wrapper content uses dynamic type or async media, pair refresh with cache invalidation when a high-performance store is involved.

45. Do not encode section spacing into wrapper content size. Keep external spacing in section inset, line spacing, or supplementary layout rules.

## Reuse And Ownership

46. `SKCAnyViewCell` transfers a live view instance into the cell. Treat the view instance as owned by the currently configured cell.

47. `SKWrapperView`, `SKCWrapperCell`, and `SKCWrapperReusableView` own their wrapped content view for the lifetime of the wrapper instance.

48. If wrapped content starts async work, define cancellation in the content view's own model binding lifecycle.

49. If wrapper `style` closures capture owners, capture weakly unless the wrapper has a clearly shorter lifecycle.

50. Avoid storing controller references in wrapper models. Route taps through section actions or a reusable coordinator.

## Debug Checklist

51. Hosted runtime view disappears from another cell: the same `UIView` instance was reused in multiple `SKCAnyViewCell` models.

52. Wrapper size is correct but content clips: check insets, internal content constraints, and whether the wrapper size closure subtracts/adds insets consistently.

53. Nib-backed cell wrapper works but supplementary wrapper does not: `SKCWrapperReusableView` creates `View()` directly.

54. Duplicate constraints appear in `SKCAnyViewCell`: a custom layout closure adds new constraints on every reuse without removing or reusing previous constraints.

55. Old state appears in wrapped content: `style` or `config(_:)` did not reset all reusable visual state.

56. Taps fire on stale owner: a wrapper model or style closure captured an old controller strongly.

## Framework Boundary

57. Keep generic wrapper primitives in SectionUI: runtime view hosting, configurable view wrappers, wrapper cell/reusable bridges, sizing, and lifecycle rules.

58. Keep branded rows, product copy, request clients, route names, analytics payloads, and design-system-specific presets in integration layers.
