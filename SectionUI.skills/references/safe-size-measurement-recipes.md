# Safe Size Measurement Recipes

Use this reference when a SectionUI task involves `safeSize`, `cellSafeSize`, `supplementarySafeSize`, `preferredSize(limit:model:)`, adaptive cells, fraction grids, or size-cache misses.

## Measurement Contract

SectionUI measures a row in this order:

1. The section builds an `SKSafeSizeProvider.Context` with `.cell` and the row index path.
2. `fetchSafeSize` reads a kind-specific provider from `safeSizeProviders[.cell]`, otherwise it falls back to the section-level `safeSizeProvider`.
3. The resulting limit is passed into `Cell.preferredSize(limit:model:)`.
4. If high-performance caching is enabled and `highPerformanceID` returns an ID, the calculated preferred size is cached by ID and limit.

Treat safe size as the measurement envelope. It constrains the cell's own `preferredSize` implementation, but it is not the final item size by itself unless the cell returns it unchanged.

## Default Safe Size

The default provider reads the bound `sectionView` and `sectionInset`.

- For a vertical `UICollectionViewFlowLayout`, width subtracts collection content inset and section left/right inset; height stays at collection bounds height.
- For a horizontal `UICollectionViewFlowLayout`, height subtracts collection content inset and section top/bottom inset; width stays at collection bounds width.
- For non-flow layouts, both axes subtract collection content inset and section inset.
- If the section is not bound to a collection view, the provider returns `.zero`.
- Negative width or height is clamped to zero.

Prefer the default provider for ordinary vertical feeds. Override it only when the measurement envelope is intentionally different from the collection's available content area.

## Cell Safe Size

Use `cellSafeSize` when a cell should receive a different limit from the section's default safe size.

```swift
section.cellSafeSize(.default)

section.cellSafeSize(.fixed(CGSize(width: 120, height: 80)))

section.cellSafeSize(
    .default,
    transforms: .fixed(height: 96)
)
```

Keep expensive Auto Layout work inside `preferredSize(limit:model:)` stable. If the same model can be measured under different limits, make sure the size cache key includes enough identity or let `SKHighPerformanceStore` cache by both ID and limit.

## Fraction Grids

Use `.fraction` when the row width is a fraction of the current safe width.

```swift
section.cellSafeSize(.fraction(0.5))

section.cellSafeSize(.fraction { context in
    context.limitSize.width >= 768 ? 0.25 : 0.5
})
```

Fraction sizing uses `SKCCellFractionLayoutContext`:

- `limitSize` is the current section safe size.
- `minimumInteritemSpacing` is read from the section.
- `size(of:)` returns `.zero` when the fraction is not in `0...1` or the limit is invalid.
- The item width is floored after subtracting inter-item spacing.

Use fractions such as `0.5`, `1.0 / 3.0`, or `0.25`. Avoid hard-coding screen width when `context.limitSize.width` already reflects the current collection and inset state.

## Transforms

Transforms are applied after the base safe size has been computed. Public helpers are:

```swift
section.cellSafeSize(.fraction(0.5), transforms: .fixed(height: 120))
section.cellSafeSize(.default, transforms: .fixed(width: 88))
section.cellSafeSize(.fraction(0.5), transforms: .height(asRatioOfWidth: 1.0))
section.cellSafeSize(.default, transforms: .offset(width: -32))
section.cellSafeSize(.default, transforms: .offset(height: -12))
section.cellSafeSize(.default, transforms: .print(prefix: "cell safe size"))
```

There is no public `.aspectRatio`, `.inset`, or `.subtract` transform. For uncommon math, create an explicit `SKSafeSizeTransform` so the formula is visible:

```swift
let contentInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)

section.cellSafeSize(
    .default,
    transforms: SKSafeSizeTransform { size in
        CGSize(
            width: max(0, size.width - contentInsets.left - contentInsets.right),
            height: max(0, size.height - contentInsets.top - contentInsets.bottom)
        )
    }
)
```

Order matters. For square grid cells, compute the fraction width first, then set height from width:

```swift
section.cellSafeSize(
    .fraction(0.5),
    transforms: .height(asRatioOfWidth: 1.0)
)
```

## Supplementary Safe Size

Supplementary views use the same provider map, keyed by `SKSupplementaryKind`.

```swift
section.supplementarySafeSize(.header, .apple)
section.supplementarySafeSize(.footer, .default)
```

Use `.apple` when a header or footer should measure against the full collection bounds. Use `.default` to remove the kind-specific provider and fall back to the section-level provider.

For custom supplementary kinds, install a provider directly:

```swift
section.safeSize(.custom("badge"), SKSafeSizeProvider {
    CGSize(width: 160, height: 44)
})
```

`SKSupplementaryKind.cell` has the raw value `"UICollectionViewCell"` and is how cell measurement is represented in the provider map.

## Custom Providers

Use a section-level custom provider when the same measurement envelope should apply to cells and default supplementary views:

```swift
section.safeSize(SKSafeSizeProvider { [weak sectionView] in
    guard let sectionView else { return .zero }
    return CGSize(width: sectionView.bounds.width - 32, height: sectionView.bounds.height)
})
```

Use a kind-specific provider when only one supplementary kind or cell measurement needs special treatment:

```swift
section.safeSize(.header, SKSafeSizeProvider {
    CGSize(width: UIScreen.main.bounds.width, height: 56)
})
```

Prefer provider closures that read current view bounds at measurement time. Avoid caching safe size outside the provider unless the layout truly cannot change with rotation, split view, dynamic type, or content inset updates.

## Debug Checklist

- If cells measure as zero, confirm the section is bound to a `sectionView` before measurement and the collection bounds are non-zero.
- If grid widths drift, inspect `minimumInteritemSpacing` and remember that fraction width is floored.
- If headers ignore section inset, check whether `.apple` was set; it uses full collection bounds.
- If a transform has no effect, verify it is passed to `cellSafeSize`, not to `safeSize`.
- If a cached size is stale after width changes, validate the high-performance cache ID and limit used during measurement.
- If code references `.aspectRatio`, `.inset`, or `.subtract`, replace it with a public transform helper or an explicit `SKSafeSizeTransform`.

## Framework Boundary

Keep safe-size guidance generic. Document SectionUI API semantics, measurement order, transform behavior, provider ownership, and cache invalidation. Do not encode app-specific card ratios, page names, business spacing tokens, source paths, or scan results into the skill.
