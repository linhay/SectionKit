# Reactive Binding Recipes

This reference captures production recipes for SectionUI reactive state, `SKPublished`, `SKBinding`, publisher-driven sections, binding keys, event groups, result builders, and async UI actions. Keep it generic: no downstream project paths, product names, business module names, source-file indexes, scan statistics, or page names.

## Contents

- [SKPublished Semantics](#skpublished-semantics)
- [SKPublished Transforms](#skpublished-transforms)
- [Section Model Subscription](#section-model-subscription)
- [Section Publishers](#section-publishers)
- [SKBinding](#skbinding)
- [SKBindingKey](#skbindingkey)
- [Result Builders And Conditions](#result-builders-and-conditions)
- [Event Groups And Async Actions](#event-groups-and-async-actions)
- [Feedback Loop Control](#feedback-loop-control)
- [Debug Checklist](#debug-checklist)
- [Framework Boundary](#framework-boundary)

## SKPublished Semantics

1. Use `@SKPublished` for UI-facing state that benefits from immediate read access plus Combine observation.

2. `SKPublishedValue.value` is the source of truth. Setting it updates backing storage before publishing.

3. Subscriber delivery is deferred to the main queue to avoid Swift exclusivity traps when a sink reads the same wrapped value during mutation.

4. Default `kind: .currentValue` uses a `CurrentValueSubject`, so new subscribers receive the current value through the publisher pipeline.

5. `kind: .passThrough` uses a `PassthroughSubject`, so the publisher only emits future sets. The wrapped value still stores the latest value.

6. `bind` immediately invokes the closure with the current `value`, then subscribes for later values.

7. `sink` subscribes to the transformed publisher only. For pass-through state, it does not replay the current value.

8. Use `bind` when initial UI render should happen from current state.

9. Use `sink` when the callback represents a future event or when the initial value would be noise.

10. Use `send(_:)` when the projected value is passed around as a signal object.

11. Use `send()` for `Output == Void` event streams.

12. Keep `@SKPublished(kind: .passThrough)` for one-shot UI events, refresh intents, or actions where replay would be wrong.

13. Keep `@SKPublished` default current-value mode for durable screen state such as items, selected tab, render state, filters, and loading flags.

14. Store cancellables with the state owner, not with reusable cells unless the cell explicitly owns that subscription lifecycle.

15. `assign(onWeak:to:)` is useful for simple view-model-to-view assignments without strongly retaining the target object.

## SKPublished Transforms

16. Pass multiple transforms as an array. `SKPublishedTransform` is not a chainable builder.

```swift
@SKPublished(transform: [
    .dropFirst(),
    .removeDuplicates()
])
var items: [Item] = []
```

17. Transform publishers run in the order stored in the transform array.

18. Use `.removeDuplicates()` for `Equatable` output when repeated UI updates are wasteful.

19. Use `.removeDuplicates(by: \.id)` when only a stable identity should gate repeated emissions.

20. Use `.filter` for state streams where invalid values should not reach the UI.

21. Use `.dropFirst(count:)` when the initial subject value is only a placeholder.

22. Use `.receiveOnMainQueue()` only when a custom upstream can publish off-main. Base `SKPublishedValue` delivery is already deferred to the main queue.

23. Use `.onChanged` for lightweight side effects tied to old/new values. It is delivered asynchronously on the main queue.

24. For `Equatable` output, `.onChanged` skips equal old/new values.

25. Use `.print(prefix:)` only during local debugging. Do not leave noisy framework examples as production guidance.

26. Use `.mapPublisher` for custom Combine operators when the built-in transforms are insufficient.

27. Avoid transforms with hidden mutation of the same state. Prefer downstream sinks with explicit guards for feedback control.

28. Do not treat transforms as validation that changes the wrapped value. They shape the publisher output, not the stored `value`.

## Section Model Subscription

29. Use `section.subscribe(models:)` when a publisher is the complete source of truth for a section's models.

30. The `[Model]` overload receives on `RunLoop.main` and calls `apply(models)`.

31. The `Model` overload wraps each emitted value into a single-row array.

32. The `Model?` overload maps `nil` to an empty section and non-nil to one row.

33. The deprecated conversion overloads should be replaced by upstream `map` / `compactMap` before calling `subscribe(models:)`.

34. Do not mix `subscribe(models:)` with manual `append`, `insert`, `remove`, or `delete` unless the next publisher emission intentionally overwrites local mutations.

35. If local row edits are needed, mutate the upstream state and let the subscribed section apply the new array.

36. `subscribe(models:)` stores its cancellable in `publishers.modelsCancellable`, so a later subscription replaces the previous model subscription.

37. Use `config(models:)` or `apply(_:)` directly when the section owner already controls rendering imperatively.

38. For optional single-row sections, pair the empty-array behavior with explicit empty or placeholder sections when the UI still needs explanation or action.

39. If the publisher emits quickly during initial load, apply request gating or `removeDuplicates` upstream before reaching the section.

## Section Publishers

40. `modelsPulisher` is backed by a `CurrentValueSubject` and emits the current model array to new subscribers.

41. `cellActionPulisher`, `supplementaryActionPulisher`, and `lifeCyclePulisher` are deferred pass-through streams. The subject is created lazily when observed.

42. `lifeCyclePulisher` is delayed on `RunLoop.main` by about 0.3 seconds. Do not use it for same-render synchronous layout work.

43. Use `modelsPulisher` for derived UI such as count labels, empty-state toggles, and selection stores that follow model replacement.

44. Use `cellActionPulisher` and `supplementaryActionPulisher` for analytics, debug tools, and cross-cutting observers.

45. Prefer `onCellAction` and `onSupplementaryAction` for local screen behavior because the callback is declared beside the section.

46. When a publisher sink writes back to the same section, add an identity guard, `removeDuplicates`, or a render coordinator.

47. Keep event publisher sinks owned by the screen, reusable section abstraction, or coordinator that knows when to cancel them.

48. Do not let a section publisher retain a stale controller through a long-lived cancellable.

49. Use `manager.publishers.sectionsPublisher` for observers that need the bound section list after reloads.

50. Use synchronous `manager.sections` only for immediate inspection, not as a durable index cache.

## SKBinding

51. Use `SKBinding` when a helper needs read/write access to state without owning the state.

52. `wrappedValue` reads through the getter closure every time.

53. Setting `wrappedValue` calls every setter closure in registration order.

54. `changedPublisher` emits only after setting when the binding has at least one setter.

55. `isSetable` is false when the binding was created with only a getter.

56. `SKBinding.constant(_:)` supplies a setter that ignores writes, so `isSetable` is true but writes do not mutate external state.

57. Use `SKBinding(on:keyPath:)` for object-owned state when the object lifetime is at least as long as the binding.

58. Use the `Root: AnyObject` initializer with a default value when weak ownership is required.

59. Use the `CurrentValueSubject` initializer when a binding should read and write a subject's current value.

60. Avoid using `changedPublisher` as a source of truth for external changes; it only publishes writes performed through that binding instance.

61. Do not store bindings globally. They close over object or subject lifetimes and should stay near the component that uses them.

## SKBindingKey

62. Use `SKBindingKey` for lazily resolving section indexes, decoration endpoints, pin targets, and scroll targets.

63. `wrappedValue` calls the closure every time. It is not a cached value.

64. Use `.constant` for fixed section indexes only when the section order is static.

65. Use `SKBindingKey(section, offset:)` when a target should follow a bound section after manager reload or insert/delete.

66. `SKBindingKey(section, offset:)` returns nil when the section is unbound.

67. Use `.relative(from:view, task)` for dynamic first/last section boundaries of a collection view.

68. `.all` is a sentinel key for APIs that interpret all sections. Do not use the raw sentinel integer directly.

69. Equality and hashing compare current wrapped values. Avoid putting a mutable `SKBindingKey` into long-lived sets or dictionaries if the underlying closure result can change.

70. Prefer binding keys over cached integer indexes for decorations, pinning, and scroll targets derived from a final section list.

## Result Builders And Conditions

71. Use `SectionArrayResultBuilder` when a helper needs to build a section array from optional and conditional blocks.

72. The builder accepts single models, arrays, closures returning models, empty expressions, optionals, conditionals, and loops.

73. Keep result-builder blocks pure. They should assemble sections, not start requests or navigate.

74. Use `SKWhen` to name reusable render predicates when a condition appears in several section builders.

75. Combine predicates with `.and` and `.or` instead of duplicating long boolean expressions.

76. Use `SKWhen.equal` and `SKWhen.compare` for simple key-path based rules.

77. Keep `SKWhen` conditions product-neutral in framework examples. Do not encode business status names into the skill.

78. Prefer `SKCSectionCollector` when render-time append decisions need a returned boolean or object-to-section mapping.

## Event Groups And Async Actions

79. `SKEventGroup` stores multiple handlers per hashable event key.

80. `append(of:_:)` preserves registration order for handlers under the same key.

81. `removeAll(of:)` clears every handler for that event key.

82. Use event groups for framework-level action registries where multiple independent handlers are expected.

83. Clear event groups when a reusable section or component changes owner.

84. `SKUIAction` wraps async menu work in a `Task` on the main actor.

85. `SKUIAction` does not surface thrown errors to the caller. Handle errors inside the async handler when user feedback matters.

86. Use `SKUIAction` for context menus and menu-like actions that must remain on the main actor.

87. Gate duplicate async actions at the feature layer. The action wrapper starts a task each time the UIAction fires.

## Feedback Loop Control

88. If `@SKPublished` state drives `section.subscribe(models:)`, do not also mutate the same section directly from row events. Mutate the state and let the publisher render.

89. If a section publisher drives `@SKPublished` state, guard writes so the same emission does not bounce back into the section.

90. Prefer identity-based `removeDuplicates` for large model arrays when only insert/delete identity matters.

91. Prefer content-aware guards when row content can change without identity changing.

92. For request state, separate durable state from transient events: current-value for `isLoading`, pass-through for `retryTapped`.

93. For UI controls, bind initial state with `bind`, then use event publishers for user intents.

94. For nested sections, keep parent model state and child section state in separate subscriptions. Rebind child subscriptions when the parent cell is reused.

95. For selection sequences derived from models, let `modelsPulisher` be the update trigger rather than polling section models from unrelated sinks.

96. For load-more, gate publisher emissions with `isLoading` and `hasMore`; do not rely on `loadMorePublisher` alone as request state.

## Debug Checklist

97. Initial UI does not render: use `bind` instead of `sink`, or verify current-value publisher semantics.

98. Pass-through event replays unexpectedly: check whether the code used `bind`, which always calls with current `value`.

99. Transform does not compile: pass transforms as an array; do not chain `SKPublishedTransform` values.

100. Duplicate UI updates: add `removeDuplicates` or move expensive derived work behind identity guards.

101. Section subscription overwrote local edits: the publisher is the source of truth; move the edit upstream or stop using `subscribe(models:)`.

102. `changedPublisher` does not fire: verify the binding has a setter and the write happened through that binding.

103. Binding writes do not mutate state: check for `SKBinding.constant` or a weak object that has already been released.

104. Binding key returns nil: the section is not bound or the collection view is gone.

105. Binding key dictionary lookup is unstable: the key's wrapped value changed after hashing.

106. Lifecycle publisher is late: it intentionally delays. Use `taskIfLoaded` or direct post-bind work for synchronous setup.

107. Event handlers from an old screen still fire: clear actions/event groups and cancel publisher sinks when reusing a section.

108. Async menu action fails silently: catch and handle errors inside the `SKUIAction` handler.

109. Result-builder output misses a section: inspect optional branches and empty expressions before checking manager reload.

110. Feedback loop spikes CPU: find sinks that write to the same publisher or section they observe and add guards.

## Framework Boundary

111. Promote reactive helpers into SectionUI only when they are independent of app state machines, route names, request clients, and analytics taxonomy.

112. Keep business-specific event streams, render-state enums, and retry policies outside framework-level examples.

113. Document binding recipes as state ownership and publisher semantics, not as a downstream app's architecture.

114. Prefer small reference recipes over adding new APIs for one repeated screen pattern until the behavior is proven framework-level.
