# Layout Plugin Execution Recipes

Use this reference when a SectionUI task involves `SKCollectionFlowLayout`, `SKCLayoutPlugins.Mode`, section-level layout plugins, attribute adjustments, pinning, layout invalidation, or stale layout attributes.

## Execution Contract

`SKCollectionView` combines collection-level modes from `sectionView.set(pluginModes:)` with section-level plugins collected from bound sections. `SKCollectionFlowLayout` then sorts and executes the resolved mode list during layout.

Mode execution is priority-based, not call-order based:

1. `.attributes`
2. `.fixSupplementaryViewSize`
3. `.fixSupplementaryViewInset`
4. `.adjustSupplementaryViewSize`
5. `.verticalAlignment` / `.horizontalAlignment`
6. `.decorations`
7. `.layoutAttributesForElements`

Multiple `.attributes`, alignment, decoration, and `layoutAttributesForElements` modes are merged. The supplementary size/inset adjustment modes are singleton-by-priority; do not install duplicates in the same resolved mode list.

## Collection-Level Modes

Use collection-level modes for rules that apply to the whole collection view.

```swift
sectionView.set(pluginModes: [
    .fixSupplementaryViewSize,
    .fixSupplementaryViewInset(.horizontal)
])
```

Use `.adjustSupplementaryViewSize(.including([...]))` when only named section/kind pairs should receive size reset plus inset math:

```swift
sectionView.set(pluginModes: [
    .adjustSupplementaryViewSize(.including([
        .init(section: SKBindingKey(headerSection), kind: .header, insets: .zero)
    ]))
])
```

Use `.adjustSupplementaryViewSize(.excluding([...]))` when the rule should apply broadly except for explicit exclusions.

## Section-Level Plugins

Use section-level plugins when the behavior belongs to one section instance and should follow that section after manager reloads.

```swift
section.addLayoutPlugins(.left)
section.addLayoutPlugins(.horizontalAlignment(.equalSpacing))
section.addLayoutPlugins(.verticalAlignment(.center))
```

Section-level alignment plugins convert the section instance into `SKBindingKey(section)`, so they do not depend on a hard-coded integer section index.

Section-level plugins do not currently expose the collection-level singleton modes such as `.fixSupplementaryViewSize` or `.fixSupplementaryViewInset`. For one section's supplementary correction, prefer `setAttributes(...)`:

```swift
section.setAttributes(.fixSupplementaryViewSize)
section.setAttributes(.reverseHeaderAndSectionInset)
section.setAttributes(.reverseFooterAndSectionInset)
```

## Attribute Adjustments

`SKCPluginAdjustAttributes` stores a section binding and a `SKInout<SKCPluginAdjustAttributes.Context>` style. The adjustment agent groups adjustments by resolved section index and applies them only to matching attributes.

```swift
section.setAttributes(.set { context in
    guard context.attributes.representedElementCategory == .cell else {
        return context
    }
    context.attributes.alpha = 0.92
    return context
})
```

Use `setAttributes(when:style:)` when the condition should be named and reusable:

```swift
let isHeader = SKWhen<SKCPluginAdjustAttributes.Context> { context in
    context.attributes.representedElementKind == UICollectionView.elementKindSectionHeader
}

section.setAttributes(when: isHeader, style: .fixHeaderViewSize)
```

Avoid protocol-style attribute-adjustment examples. The current path is `SKCPluginAdjustAttributes` plus `SKInout` or the section helper `setAttributes`.

## Layout Attributes Forward

Use `SKCPluginLayoutAttributesForElementsForward` for framework or integration-level logic that must see or mutate the full attribute array. In ordinary app code, prefer existing helpers such as `pinHeader`, `pinFooter`, `pinCell`, `setAttributes`, and decoration APIs before creating a custom forward.

```swift
let forward = SKCPluginLayoutAttributesForElementsForward { context in
    context.alwaysInvalidate = true
    context.attributes = context.attributes.map { attribute in
        attribute
    }
}

section.addLayoutPlugins(.layoutAttributesForElements(forward))
```

The forward is cancellable. Store the returned `AnyCancellable` from APIs such as `pinHeader` or keep the forward owner alive when the behavior should persist.

Set `context.alwaysInvalidate = true` only for scroll-dependent effects such as pinning. It makes `shouldInvalidateLayout(forBoundsChange:)` return true even when the bounds size is unchanged.

## Layout Cache And Invalidation

`SKCollectionFlowLayout` keeps a temporary layout store during `layoutAttributesForElements(in:)` and a persistent store for decoration and supplementary lookup. It clears those stores on layout invalidation paths.

Invalidate the layout when:

- the plugin mode list changes,
- section order changes and a plugin depends on first/last/offset indexes,
- supplementary sizes or insets change,
- a decoration frame depends on newly available header/footer/cell attributes,
- a custom forward depends on scroll state but did not set `alwaysInvalidate`.

Do not hold layout attributes across layout passes. Store semantic state and rederive attributes from the layout when needed.

## Debug Checklist

- Plugin appears to ignore call order: inspect sorted priorities, not builder order.
- Supplementary fix does not compile on `section.addLayoutPlugins`: use collection-level `sectionView.set(pluginModes:)` or section-level `setAttributes`.
- Attribute adjustment does nothing: verify the `SKBindingKey` resolves to the attribute's section index.
- Global plugin affects unrelated sections: move it from `sectionView.set(pluginModes:)` to a section-level plugin or `setAttributes`.
- Pinning jitters or stops updating while scrolling: confirm the forward sets `alwaysInvalidate` and UIKit flow-layout native pinning is disabled.
- Decorations or supplementary attributes are stale: invalidate the layout after changing plugins, supplementary sizes, or section order.
- Forward still runs after a feature is gone: cancel the forward or release the cancellable owner.

## Framework Boundary

Keep layout plugin guidance generic. Document execution order, mode scope, invalidation, attribute mutation, and cancellation semantics. Do not encode downstream visual presets, business module order, page names, source paths, scan counts, or project indexes into the skill.
