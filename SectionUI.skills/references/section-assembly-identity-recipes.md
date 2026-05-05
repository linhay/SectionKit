# Section Assembly Identity Recipes

This reference captures exact contracts for `SectionArrayResultBuilder`, `SKCSectionCollector`, `SKWhen`, `SKBindingKey`, and `SKCHostingCollectionView` identity. Keep it generic: no downstream project paths, product names, business module names, source-file indexes, scan statistics, page names, or business event names.

## Contents

- [When To Use](#when-to-use)
- [SectionArrayResultBuilder](#sectionarrayresultbuilder)
- [SKCSectionCollector](#skcsectioncollector)
- [SKWhen](#skwhen)
- [SKBindingKey](#skbindingkey)
- [SwiftUI Hosted Collection Identity](#swiftui-hosted-collection-identity)
- [Debug Checklist](#debug-checklist)
- [Framework Boundary](#framework-boundary)

## When To Use

1. Use `SectionArrayResultBuilder` when the section or model list reads naturally as a declarative block.

2. Use `SKCSectionCollector` when optional objects must be filtered, converted, and conditionally appended with a returned success flag.

3. Use `SKWhen` for reusable predicates that should be composed outside the render loop.

4. Use `SKBindingKey` when layout plugins, pin targets, decorations, or scroll helpers must resolve section indexes after dynamic filtering.

5. Use stable `SKCAnySectionProtocol.objectIdentifier` sequences when SwiftUI-hosted SectionUI collections should preserve state across updates.

## SectionArrayResultBuilder

6. The builder flattens expressions into `[Model]`.

7. A plain `Model` expression becomes a one-item array.

8. A `[Model]` expression is inserted as-is.

9. A `() -> Model` expression is executed and becomes a one-item array.

10. A `Void` expression becomes an empty array.

11. `if`, `if/else`, optional blocks, loops, and limited availability blocks are flattened by the builder.

12. `buildBlock` joins all components through `buildArray`.

13. Keep builder expressions side-effect-light. A builder can execute during SwiftUI updates, previews, or repeated render passes.

14. For remote lists, pagination, and user-driven mutation, prefer explicit `config(models:)`, `apply`, or row mutation APIs over hiding state transitions in a builder.

## SKCSectionCollector

15. `SKCSectionCollector.sections` stores `[SKCSectionProtocol]`.

16. `append(_ item: SKCSectionProtocol?)` ignores nil.

17. `append(_ list: [SKCSectionProtocol?])` appends each non-nil section.

18. `append<Object: SKCAnySectionProtocol>(_ item:)` unwraps `item.section` before storing.

19. `append<Object: SKCAnySectionProtocol>(_ list:)` unwraps each wrapper's `.section`.

20. `append<Object>(_ item:section:when:)` returns true only when the object is non-nil, `when` is true or absent, and the conversion closure returns a section.

21. Rebuild collectors for each render pass. A long-lived collector accumulates stale sections.

22. Use the boolean return when later sections depend on whether an earlier optional object actually rendered.

```swift
let collector = SKCSectionCollector()

let renderedBody = collector.append(bodyModel, section: { model in
    bodySection.render(model)
}, when: { model in
    model.isRenderable
})

if renderedBody {
    collector.append(footerSection)
}

manager.reload(collector.sections)
```

23. When collecting raw-section wrappers, make sure `.section` returns the same stable raw section instance intended for manager binding.

## SKWhen

24. `SKWhen<Object>` wraps `isIncluded: (Object) -> Bool`.

25. `and(_:)` evaluates both predicates with logical AND.

26. `or(_:)` evaluates predicates with logical OR.

27. `equal(_:_:)` compares an equatable key path to a value.

28. `compare(_:_:_:)` applies a custom comparison to a comparable key path and value.

29. Keep predicates named by render responsibility, not business vocabulary, when documenting framework examples.

30. Do not put mutation, logging, network requests, or analytics in `SKWhen` predicates.

## SKBindingKey

31. `SKBindingKey<Value>` stores a closure returning `Value?`.

32. `wrappedValue` evaluates the closure every time it is read.

33. `constant(_:)` returns a key whose closure always returns that value.

34. `SKBindingKey<Int>.all` is a sentinel constant value for layout plugin APIs that support targeting all sections.

35. `relative(from:_:)` captures the collection view weakly and computes from `0..<view.numberOfSections`.

36. `SKBindingKey(section, offset:)` captures the section weakly and returns `sectionInjection.index + offset` only while the section is bound.

37. Equality compares current `wrappedValue`.

38. Hashing hashes current `wrappedValue`.

39. Avoid using dynamic binding keys as long-lived dictionary keys or set members when their wrapped value can change after reload.

40. Prefer binding keys over hard-coded section indexes when optional sections can be inserted, removed, or reordered.

## SwiftUI Hosted Collection Identity

41. `SKCHostingCollectionView` accepts `[SKCAnySectionProtocol]`, a closure returning that array, or a `SectionArrayResultBuilder<SKCAnySectionProtocol>`.

42. `makeUIViewController` reloads `context.coordinator.sections.map(\.section)`.

43. `updateUIViewController` compares `sections.map(\.objectIdentifier)` with the coordinator's previous sequence.

44. The hosted collection reloads only when the object-identifier sequence changes.

45. If the same section instances remain but their internal models change, update those sections directly or trigger their own reload path.

46. Recreate wrapper/section identity only when a full hosted collection reload is intended.

47. Keep section identity stable when selection, display counters, scroll targets, or size caches should survive SwiftUI state changes.

## Debug Checklist

48. Optional section missing: object is nil, predicate returned false, or conversion returned nil.

49. Duplicate sections appear: collector was reused across render passes.

50. Wrapper style disappears after collection: `.section` created a new raw section instance or returned a different instance from the styled one.

51. Layout plugin targets wrong section: a hard-coded index survived optional filtering; use `SKBindingKey(section)` or `relative(from:)`.

52. Binding key in a set stops matching: its hash changed because `wrappedValue` changed.

53. SwiftUI hosted collection does not reload: object-identifier sequence did not change.

54. SwiftUI hosted collection reloads too often: wrappers or sections are recreated on every update.

55. Builder side effects run unexpectedly: the builder is being evaluated during a render/update pass; move side effects out.

## Framework Boundary

56. Keep generic assembly guidance in SectionUI: builder flattening, collector filtering/conversion, predicate composition, dynamic section-index binding, and identity rules.

57. Keep product module order, business conditions, route handling, analytics, and feature-specific render states in integration layers.

