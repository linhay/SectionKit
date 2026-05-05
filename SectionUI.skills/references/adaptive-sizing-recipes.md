# Adaptive Sizing Recipes

Use this reference when a SectionUI task involves `SKAdaptive`, `SKConfigurableAdaptiveView`, `SKConfigurableAdaptiveMainView`, `SKConfigurableAutoAdaptiveView`, Auto Layout fitting, dynamic cell height, dynamic cell width, or stale adaptive-size debugging.

Keep it generic: no downstream project paths, product names, business module names, source-file indexes, scan statistics, page names, analytics events, or route names.

## Contents

- [Protocol Choice](#protocol-choice)
- [Measurement Pipeline](#measurement-pipeline)
- [Direction And Fitting Priority](#direction-and-fitting-priority)
- [Content View Override](#content-view-override)
- [Insets](#insets)
- [Auto Cache](#auto-cache)
- [High Performance Cache](#high-performance-cache)
- [Examples](#examples)
- [Debug Checklist](#debug-checklist)
- [Framework Boundary](#framework-boundary)

## Protocol Choice

1. Use `SKConfigurableAutoAdaptiveView` for the common case: the cell or view can configure itself from `Model`, then Auto Layout can measure the same instance type.

2. Use `SKConfigurableAdaptiveMainView` when the adaptive measurement view is the conforming type itself and you want the concise `SpecializedAdaptive` type alias.

3. Use `SKConfigurableAdaptiveView` when the measurement view is not the final reusable cell type, or when a feature needs a custom `SKAdaptive<AdaptiveView, Model>` instance.

4. A collection cell still needs `SKLoadViewProtocol` to be registered and dequeued by SectionUI. Adaptive protocols provide sizing, not reuse registration.

5. `SKConfigurableAdaptiveView` requires `static var adaptive: SKAdaptive<AdaptiveView, Model>`. Do not omit the `Model` generic unless using the `SpecializedAdaptive` alias from `SKConfigurableAdaptiveMainView`.

6. Prefer manual `preferredSize(limit:model:)` for fixed rows, simple spacers, fixed-height buttons, and cells whose size is only a constant plus known safe width.

7. Prefer adaptive sizing for text-heavy, Auto Layout-driven rows where manual text measurement would duplicate constraint logic.

## Measurement Pipeline

8. `preferredSize(limit:model:)` returns `.zero` when `model` is nil.

9. `SKAdaptive` calls its `config(view, size, model)` closure before measuring.

10. For `AdaptiveView: SKConfigurableView`, the convenience initializer sets `view.bounds.size` before `view.config(model)`.

11. In vertical mode, the convenience initializer sets the adaptive view bounds to `width = limit.width`, `height = 0`.

12. In horizontal mode, the convenience initializer sets the adaptive view bounds to `width = 0`, `height = limit.height`.

13. Measurement uses `view.systemLayoutSizeFitting(view.bounds.size, withHorizontalFittingPriority:..., verticalFittingPriority:...)`.

14. The result is increased by `insets.left + insets.right` and `insets.top + insets.bottom`.

15. If the measured result has zero width or zero height after insets are applied, `SKAdaptive` returns `.zero`.

16. In DEBUG builds, adaptive measurement is wrapped by `SKPerformance.shared.duration("[SKAdaptive] \(AdaptiveView.self)")`.

17. Keep `config(_:)` reset-safe because the same adaptive view instance can be reused for many models and limits.

18. Keep `preferredSize` and adaptive config side-effect free. They should not start requests, mutate selection state, or depend on visible cell state.

## Direction And Fitting Priority

19. Vertical direction means fixed width and fitting height.

20. Horizontal direction means fixed height and fitting width.

21. Default vertical fitting priority is horizontal `.required`, vertical `.fittingSizeLevel`.

22. Default horizontal fitting priority is horizontal `.fittingSizeLevel`, vertical `.required`.

23. Override `SKAdaptiveFittingPriority` only when the default axis contract does not match the constraint graph.

24. If both axes are `.required`, Auto Layout may preserve the input bounds instead of discovering compressed content size.

25. If both axes are `.fittingSizeLevel`, ambiguous constraints can produce unstable sizes.

26. Match `cellSafeSize` to the adaptive direction. A vertical adaptive cell usually needs a meaningful safe width; a horizontal adaptive cell usually needs a meaningful safe height.

## Content View Override

27. `content` is optional. Without it, `SKAdaptive` uses the size returned by `systemLayoutSizeFitting`.

28. When `content` returns a view, `SKAdaptive` calls `layoutIfNeeded()` and reads `content.frame.size`.

29. If horizontal fitting priority is `.fittingSizeLevel`, `content.frame.width` overrides the measured width.

30. If vertical fitting priority is `.fittingSizeLevel`, `content.frame.height` overrides the measured height.

31. Use `content` for a stable inner label, stack view, or content container whose frame better represents the desired size than the outer reusable cell.

32. Do not point `content` at a view whose frame is not fully constrained after configuration.

33. Do not use `content` to compensate for missing constraints. Fix the constraint graph first.

## Insets

34. `SKAdaptive.insets` are measurement insets around the adaptive view.

35. Insets are added after Auto Layout fitting. They are not applied as constraints automatically.

36. Use adaptive insets for measurement padding when the cell's constraints intentionally measure the inner content only.

37. If the cell constraints already include padding, do not duplicate that padding in adaptive insets.

38. Keep adaptive insets and visual constraints aligned. Mismatches cause cells that look clipped or oversized.

## Auto Cache

39. `SKConfigurableAutoAdaptiveView` stores one `SKAdaptive<Self, Model>` in `SKConfigurableAdaptiveAutoCache.shared` keyed by `SKAdaptive<Self, Model>.self`.

40. The auto cache reuses the adaptive view instance for that view/model specialization.

41. Override `static func adaptive() -> SKAdaptive<Self, Model>` when the default direction, content view, insets, fitting priority, or after-config behavior is not enough.

42. Do not store model-specific state on the adaptive measurement view that survives into the next measurement.

43. If dynamic type, trait collection, or global visual configuration changes the measured size, refresh rows and invalidate any separate size cache.

44. `SKConfigurableAdaptiveAutoCache` is not the same as `SKHighPerformanceStore`. It caches the measuring adapter instance, not per-model sizes.

## High Performance Cache

45. Adaptive sizing can be expensive for long lists because it runs Auto Layout measurement.

46. Combine adaptive cells with `setHighPerformance(.init())` and a stable `highPerformanceID` when row sizes are repeatedly measured under the same limit.

47. `SKHighPerformanceStore` caches by both id and limit size. Make sure the id represents the content that affects size.

48. If text, image ratio, expansion state, dynamic type, or width class changes, invalidate the size cache before refreshing affected rows.

49. Do not use a cache id that ignores collapsed/expanded state for expandable adaptive cells.

50. Do not use row index as cache identity when rows can be inserted, deleted, sorted, or filtered.

## Examples

Use `SKConfigurableAdaptiveMainView` when the cell is the adaptive view:

```swift
final class MessageCell: UICollectionViewCell, SKLoadViewProtocol, SKConfigurableAdaptiveMainView {
    typealias Model = String

    static let adaptive = SpecializedAdaptive(direction: .vertical)

    func config(_ model: String) {
        titleLabel.text = model
    }

    private let titleLabel = UILabel()
}
```

Use `SKConfigurableAutoAdaptiveView` and override `adaptive()` for common cell-owned measurement:

```swift
final class TextCell: UICollectionViewCell, SKLoadViewProtocol, SKConfigurableAutoAdaptiveView {
    struct Model {
        let title: String
        let isExpanded: Bool
    }

    static func adaptive() -> SKAdaptive<TextCell, Model> {
        .init(
            direction: .vertical,
            content: \.contentStack,
            insets: .zero
        )
    }

    func config(_ model: Model) {
        titleLabel.text = model.title
        titleLabel.numberOfLines = model.isExpanded ? 0 : 2
    }

    private let contentStack = UIStackView()
    private let titleLabel = UILabel()
}
```

Use `SKConfigurableAdaptiveView` when measuring with a separate view type:

```swift
final class WrappedTextCell: UICollectionViewCell, SKLoadViewProtocol, SKConfigurableAdaptiveView {
    typealias Model = TextView.Model
    typealias AdaptiveView = TextView

    static let adaptive = SKAdaptive<TextView, Model>(direction: .vertical)

    func config(_ model: Model) {
        textView.config(model)
    }

    private let textView = TextView()
}
```

Add size caching when repeated adaptive measurement is too costly:

```swift
let sizeStore = SKHighPerformanceStore<String>()

let section = TextCell.wrapperToSingleTypeSection()
    .setHighPerformance(sizeStore)
    .highPerformanceID { context in
        "\(context.model.id)-\(context.model.isExpanded)"
    }
```

`adaptiveWidthFittingSize(limit:model:)` is deprecated beta API. Prefer the normal `preferredSize(limit:model:)` path through an adaptive protocol.

## Debug Checklist

51. Size is zero: check nil model, zero safe-size limit, missing constraints, hidden content, and whether the content view has a non-zero frame.

52. Height is clipped: verify vertical direction, required horizontal fitting, complete top/bottom constraints, and no duplicated inset math.

53. Width is clipped: verify horizontal direction, required vertical fitting, complete leading/trailing constraints, and a meaningful safe height.

54. Size ignores inner content: verify the `content` key path points at the actual constrained content container.

55. Size is stale after content changes: invalidate `SKHighPerformanceStore`, update the model, then refresh or reload the row.

56. Size changes every reload: inspect ambiguous constraints, non-idempotent config, and model state that mutates during measurement.

57. Adaptive cell is slow: add a high-performance size cache, reduce constraint complexity, or use manual sizing for fixed subtrees.

58. Generic type does not compile: use `SKAdaptive<View, Model>` or `SpecializedAdaptive`; a one-argument `SKAdaptive` specialization is not complete.

59. Reuse visual state leaks into measurement: reset labels, hidden flags, images, stack arranged subviews, cancellables, and async placeholders before applying the new model.

60. Dynamic type changed but heights did not: reset size cache and reload affected sections after the typography change.

## Framework Boundary

61. Promote adaptive helpers into SectionUI only when they describe reusable measurement mechanics, not product-specific typography, copy, spacing, or expansion rules.

62. Keep design-system component names and brand spacing outside generic adaptive recipes.

63. Document adaptive sizing as a measurement contract: safe-size limit in, model configuration, Auto Layout fitting, optional content override, insets, final size out.
