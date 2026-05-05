# Diagnostics And Utility Recipes

This reference captures production recipes for SectionUI diagnostics, lightweight utility types, environment objects, cache helpers, weak wrappers, animation boxes, and identity wrappers. Keep it generic: no downstream project paths, product names, business module names, source-file indexes, scan statistics, or page names.

## Contents

- [Debug Output](#debug-output)
- [Performance Timing](#performance-timing)
- [High Performance Cache](#high-performance-cache)
- [Counted Stores](#counted-stores)
- [Environment Objects](#environment-objects)
- [Animation Boxes](#animation-boxes)
- [Weak Wrappers](#weak-wrappers)
- [Identity Boxes](#identity-boxes)
- [Inout Builders](#inout-builders)
- [Actor Boxes](#actor-boxes)
- [Event Groups](#event-groups)
- [Debug Checklist](#debug-checklist)
- [Framework Boundary](#framework-boundary)

## Debug Output

1. `SKPrint` is a small debug-print facade for framework diagnostics.

2. `SKPrint.highPerformance` prints only in DEBUG builds and only when `SKPrint.kinds` contains `.highPerformance`.

3. Enable high-performance logging locally when investigating size-cache hits and misses.

```swift
#if DEBUG
SKPrint.kinds.insert(.highPerformance)
#endif
```

4. Do not leave noisy diagnostic kinds enabled from reusable sample code. Keep opt-in logging close to the debug session or test harness.

5. `SKPrint.function` prints in DEBUG builds and includes the calling function name by default.

6. Do not build production behavior from `SKPrint` output. It is diagnostic output, not a telemetry API.

7. Prefer feature-owned logging for business events. Keep SectionUI utility logging focused on framework behavior such as sizing, cache, and lifecycle.

## Performance Timing

8. Use `SKPerformance.shared.duration` to measure hot closures during local diagnosis.

9. The default `duration(file:function:line:_:)` wrapper records by source location in DEBUG builds.

10. In non-DEBUG builds, `duration` simply executes the closure.

11. Use a custom prefix when comparing multiple implementations of the same sizing or render path.

```swift
let size = SKPerformance.shared.duration("cell-size.measure") {
    Cell.preferredSize(limit: limit, model: model)
}
```

12. Async duration exists for async closures and records into actor-backed async records.

13. Call `await SKPerformance.shared.printRecords()` when you need an aggregated table of counts, totals, and averages.

14. Treat `printRecords` as a debugging summary. Do not parse its text output in tests or tooling.

15. Because records are process-local, reset the app or isolate the scenario before comparing numbers.

16. Time the smallest meaningful unit. Measuring a full screen render may hide the specific expensive cell or supplementary view.

17. When investigating list jank, pair `SKPerformance` timing with row identity and safe-size limits so cache misses are explainable.

18. Avoid shipping custom code paths that depend on DEBUG-only timing side effects.

## High Performance Cache

19. `SKHighPerformanceStore` uses `SKKVCache` under the hood for size caching.

20. The size-cache key combines stable model identity and the measuring `CGSize` limit.

21. Use stable identity for `highPerformanceID`; volatile display text or row offsets make cache reuse unreliable.

22. Remove a cached size by identity when content changes but the row remains in the section.

23. Remove a cached size by identity and limit when only one measured envelope is invalid.

24. Call `removeAll()` when dynamic type, global layout mode, or container width changes invalidate the entire store.

25. Enable `SKPrint.highPerformance` while verifying whether a slow cell is hitting cache.

26. `SKKVCache.countLimit` can limit cache pressure when many identity and size combinations are possible.

27. `SKKVCache.insert(_:forKey:lifeTime:)` supports time-based expiration only when a `dateProvider` is supplied.

28. `SKKVCache` tracks keys separately because `NSCache` does not expose key enumeration.

29. Do not rely on `SKKVCache.count` as a durable metric. `NSCache` can evict entries under memory pressure.

30. When encoding `SKKVCache`, expired entries are omitted through the entry lookup path.

31. Prefer SectionUI's high-performance section helpers before using `SKKVCache` directly in list code.

## Counted Stores

32. `SKCountedStore` is useful for count-triggered behavior such as display counts.

33. `update(by:count:)` increments until `maxCount`; after that, the cached count no longer increases.

34. Global triggers run on every update after the count is computed.

35. Per-id triggers run when their predicate matches the current count.

36. `trigger(of:when:)` with an integer matches exact counts.

37. Predicate triggers are useful for repeated thresholds, but keep predicates cheap.

38. Reset an id when the counted identity leaves the current model universe.

39. Use `resetAll()` when replacing the full list or reusing a section for a new parent model.

40. The model convenience methods use `hashValue`. Prefer explicit integer or stable identity mapping when cross-process or long-lived identity matters.

41. Keep trigger callbacks lightweight. Count updates can happen from display events during fast scrolling.

## Environment Objects

42. `SKEnvironmentConfiguration` stores objects by `ObjectIdentifier` of their type.

43. Use `environment(of:)` for optional retrieval of a type-scoped object.

44. Use `environment(_:)` to assign the object for its concrete static type.

45. This is a type-keyed local registry, not a dependency injection framework.

46. Avoid storing multiple objects of the same type unless the latest assignment intentionally replaces the previous one.

47. Prefer explicit initializer dependencies for feature logic. Use environment objects for cross-cutting framework or integration context.

48. Clear or replace environment values when reusing long-lived owners across screens.

49. Do not use environment objects to hide business state mutations. Keep render state and section models explicit.

## Animation Boxes

50. `SKAnimationBox<Value>` carries a value together with animation metadata.

51. Use it when a state stream needs to say both "what changed" and "whether this change should animate".

52. `isEnabled` can carry whether the receiving behavior should apply the boxed value.

53. Literal conformances exist for `Int`, `Double`, `Bool`, and optional-any nil convenience.

54. Do not use `SKAnimationBox` as a general model wrapper when animation state is irrelevant.

55. Keep animation flags close to UI transition state. Persisting them in domain models usually leaks presentation concerns.

56. When a publisher emits `SKAnimationBox`, downstream sinks should read both `value` and animation metadata before mutating UI.

## Weak Wrappers

57. `SKWeakBox` is a reference type that stores a weak object.

58. `SKWeakBox` equality and hashing use the box object identity, not the wrapped value identity.

59. Use `SKWeakBox` when the box itself is the stored token and should remain distinguishable even if the wrapped object is the same.

60. `SKWeakWrapped` is a value type with a stable `ObjectIdentifier` captured from the wrapped object at initialization.

61. Use `SKWeakWrapped` when a weak object needs to participate in `Identifiable`, `Equatable`, or `Hashable` collections by wrapped-object identity.

62. If `SKWeakWrapped` is initialized with nil, it receives a placeholder identity. Do not treat nil wrappers as interchangeable.

63. Dynamic member lookup forwards optional writable properties to the wrapped object when it is still alive.

64. Always tolerate `value == nil`. Weak wrappers are for avoiding retention, not for guaranteeing availability.

65. Do not store weak wrappers as the only ownership of objects needed by active UI.

## Identity Boxes

66. `SKIDBox<ID, Value>` attaches an explicit id to a value.

67. Use it when a value needs stable identity for diffing, selection, or cache keys without changing the original model type.

68. The `UUID` convenience initializer creates a new id each time. Avoid it when identity must survive rerenders.

69. Prefer domain ids over generated ids when reconciling selection, scroll targets, or async results.

70. Do not use `SKIDBox` to hide unstable identity. If the id changes every render, diffing and cache reuse will still break.

## Inout Builders

71. `SKInout<Object>` composes mutations as value-returning builders.

72. Use key-path setters for concise configuration of value or reference objects.

```swift
let style = SKInout<UILabel>.set(\.numberOfLines, 2)
    .set(\.textAlignment, .center)
```

73. For value types, key-path setters copy and return the changed object.

74. For reference types, key-path setters mutate the object and return it.

75. Optional block helpers return nil when no block is supplied. This is useful for optional style hooks.

76. Do not use `SKInout` when direct configuration is clearer. It is most useful for composable configuration APIs.

## Actor Boxes

77. `SKActorBox<Value>` serializes access to a wrapped value through an actor.

78. Use `update(_:)` to replace the value.

79. Read `value` with `await`.

80. `SKActorBox` is a lightweight state holder, not a full synchronization design. Keep invariants near the actor owner.

81. Prefer purpose-built actors when operations need validation, batching, cancellation, or multi-step transactions.

## Event Groups

82. `SKEventGroup<Event, Element>` stores arrays of handlers or values by hashable event key.

83. Appending preserves registration order inside the event bucket.

84. `removeAll(of:)` clears only one event key.

85. Use event groups for local extension points where multiple handlers may belong to one event.

86. Clear old event groups before rebinding a reusable section or integration object to a different owner.

87. Avoid putting order-dependent business policy into multiple separate handlers. Combine handlers when order changes behavior.

## Debug Checklist

88. Size cache misses repeatedly: verify model identity, safe-size limit, dynamic type, and whether the cache was invalidated.

89. High-performance logs do not print: confirm DEBUG build and `SKPrint.kinds` opt-in.

90. Timing output is missing in release: `SKPerformance.duration` is DEBUG-only for measurement side effects.

91. Counted exposure repeats too often: inspect `maxCount`, row identity, and whether the counted store was reset during full render.

92. Environment lookup returns nil: check the concrete type used at assignment and retrieval.

93. Weak wrapper value disappears: something else must own the object strongly.

94. `SKIDBox` diffing looks unstable: verify ids are stable across renders.

95. `SKInout` mutation appears ignored: distinguish value-type copy behavior from reference-type mutation behavior.

96. Actor-box state reads stale from UI: ensure the UI awaits the read after the relevant update, or render from a publisher instead.

## Framework Boundary

97. SectionUI utilities can help diagnose list behavior and express small framework integration patterns.

98. The app layer owns product telemetry, durable persistence, feature dependency graphs, cross-screen state management, and business event semantics.

99. Keep utility examples anonymous and framework-level. Do not encode business routes, event names, module names, project-specific thresholds, or downstream source locations into this skill.
