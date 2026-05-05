# Render Builder Recipes

Use this reference when a SectionUI task involves conditional section assembly, optional modules, `SectionArrayResultBuilder`, `SKCSectionCollector`, `SKWhen`, `SKBindingKey`, or SwiftUI-hosted SectionUI collections.

For exact builder flattening, collector append/unwrapping semantics, `SKBindingKey` equality/hash, and hosted collection reload identity, read `section-assembly-identity-recipes.md`.

## Core Contract

SectionUI offers two complementary ways to assemble section arrays:

- `SectionArrayResultBuilder<Model>` is a result builder that flattens expressions, arrays, `if` / `else`, optionals, loops, and availability blocks into `[Model]`.
- `SKCSectionCollector` is an imperative collector for optional objects that may or may not produce an `SKCSectionProtocol`.

Use the builder when the render tree is already readable as a declarative block. Use the collector when each optional object needs a predicate, conversion result, or boolean append result.

## SectionArrayResultBuilder

`SectionArrayResultBuilder` supports single expressions, arrays, empty expressions, conditionals, optionals, loops, and limited availability.

```swift
func makeSections(state: ViewState) -> [SKCAnySectionProtocol] {
    buildSections {
        headerSection

        if state.isLoading {
            loadingSection
        }

        state.rows.map { row in
            makeRowSection(row)
        }

        if let footerSection = makeFooterSection(state) {
            footerSection
        }
    }
}

func buildSections(
    @SectionArrayResultBuilder<SKCAnySectionProtocol> _ builder: () -> [SKCAnySectionProtocol]
) -> [SKCAnySectionProtocol] {
    builder()
}
```

Prefer helper functions with a builder parameter when multiple screens share the same render shape. Keep the builder focused on section assembly; move networking, mutation, and analytics decisions outside the builder.

## Wrapper Model Builders

Cell wrappers also use `SectionArrayResultBuilder` for model arrays.

```swift
let section = ExampleCell.wrapperToSingleTypeSection {
    firstModel

    if shouldShowSecondModel {
        secondModel
    }

    extraModels
}
```

This is useful for small static groups, settings-like rows, and preview data. For remote lists or paginated feeds, prefer explicit `section.config(models:)`, `section.apply(models)`, or row mutation APIs so state transitions are visible.

## SKCSectionCollector

`SKCSectionCollector` stores `[SKCSectionProtocol]` and has append overloads for optional sections, arrays of optional sections, `SKCAnySectionProtocol` wrappers, and arbitrary objects that can be converted into sections.

```swift
let collector = SKCSectionCollector()

collector.append(headerSection)
collector.append(optionalSection)
collector.append(optionalWrappers)

let didAppend = collector.append(viewModel, section: { model in
    model.makeSection()
}, when: { model in
    model.shouldRender
})

manager.reload(collector.sections)
```

Use the returned `Bool` when a later section depends on whether a previous object actually rendered. Do not keep one collector as long-lived screen state; rebuild it for each render pass so stale sections do not accumulate.

## SKWhen

`SKWhen<Object>` wraps reusable predicates and supports `and` / `or` composition.

```swift
let hasRows = SKWhen<ViewState> { !$0.rows.isEmpty }
let isLoaded = SKWhen.equal(\ViewState.isLoaded, true)
let canRenderList = hasRows.and(isLoaded)

if canRenderList.isIncluded(state) {
    collector.append(listSection)
}
```

Use `SKWhen.equal` for simple equality and `SKWhen.compare` for comparable values. Keep predicates product-neutral in framework examples; name the condition by UI responsibility rather than business status.

## SKBindingKey

Use `SKBindingKey` when a layout plugin, pin target, decoration endpoint, or scroll target must resolve its section index after optional sections have been filtered.

```swift
let current = SKBindingKey(section)
let next = SKBindingKey(section, offset: 1)
let last = SKBindingKey.relative(from: sectionView, \.last)
let all = SKBindingKey<Int>.all
```

`SKBindingKey(section, offset:)` returns nil while the section is unbound. Equality and hashing read the current wrapped value, so avoid long-lived sets or dictionaries whose keys can change after reload.

## SwiftUI Hosted Collections

`SKCHostingCollectionView` accepts a builder of `SKCAnySectionProtocol` values.

```swift
SKCHostingCollectionView {
    headerWrapper

    if showBody {
        bodyWrapper
    }
}
```

The hosting view reloads when the `objectIdentifier` sequence changes. Keep section identity stable when SwiftUI state updates should preserve selection, display counts, or cached sizes; recreate wrappers when a full reset is intended.

## Decision Rules

1. Use a plain array when the section list is small and unconditional.
2. Use `SectionArrayResultBuilder` when the render tree reads naturally as a declarative block.
3. Use `SKCSectionCollector` when optional domain objects must be filtered and converted.
4. Use `SKWhen` for predicates shared across render paths.
5. Use `SKBindingKey` for any layout behavior that targets a section after dynamic filtering.
6. Call `manager.reload(finalSections)` once per render pass.

## Debug Checklist

- Missing optional section: verify the optional object is non-nil, the `when` predicate returned true, and the conversion closure returned a section.
- Duplicate sections: confirm a collector is rebuilt each render pass and not stored across renders.
- Layout plugin targets wrong section: replace hard-coded section indexes with `SKBindingKey(section)` or a relative key.
- SwiftUI hosted collection does not reload: compare the wrapper `objectIdentifier` sequence.
- Section identity operation does nothing: confirm the referenced section is the exact bound instance in `manager.sections`.

## Framework Boundary

Keep render builder guidance generic. Document section assembly semantics, predicate composition, identity, and dynamic-index binding. Do not encode downstream page order, module names, business statuses, source paths, scan counts, or project indexes into the skill.
