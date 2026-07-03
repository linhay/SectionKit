# Reactive Binding Recipes

Use this reference when a SectionUI task involves `@SKPublished`, `SKPublishedValue`, transforms, `subscribe(models:)`, section publishers, `SKBinding`, `SKBindingKey`, result builders, event groups, async UI actions, or feedback-loop control. Keep it generic: no downstream project paths, product names, business module names, source-file indexes, scan statistics, or page names.

## Contents

- [SKPublished Semantics](#skpublished-semantics)
- [Stable Cell View Models](#stable-cell-view-models)
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

3. `send(_:)` and wrapped-value writes may happen off the main thread. Stored `value` and `transforms` are protected internally.

4. Subscriber delivery is deferred to the main queue to avoid Swift exclusivity traps when a sink reads the same wrapped value during mutation.

5. Default `kind: .currentValue` uses a `CurrentValueSubject`, so new subscribers receive the current value through the publisher pipeline.

6. `kind: .passThrough` uses a `PassthroughSubject`, so the publisher only emits future sets. The wrapped value still stores the latest value.

7. `publisher` and `anyPublisher` expose a standard Combine publisher, so normal operators, demand, cancellation, and type erasure remain Combine-owned.

8. `bind` immediately invokes the closure with the current `value`, then subscribes for later values. The immediate call is made on the main thread.

9. `sink` subscribes to the transformed publisher only. For pass-through state, it does not replay the current value.

10. Use `bind` when initial UI render should happen from current state.

11. Use `sink` when the callback represents a future event or when the initial value would be noise.

12. Use `send(_:)` when the projected value is passed around as a signal object.

13. Use `send()` for `Output == Void` event streams.

14. Keep `@SKPublished(kind: .passThrough)` for one-shot UI events, refresh intents, or actions where replay would be wrong.

15. Keep `@SKPublished` default current-value mode for durable screen state such as items, selected tab, render state, filters, and loading flags.

16. Store cancellables with the state owner, not with reusable cells unless the cell explicitly owns that subscription lifecycle.

17. `assign(onWeak:to:)` is useful for simple view-model-to-view assignments without strongly retaining the target object.

## Stable Cell View Models

Use a stable reference-type cell model when frequent row updates only affect visible state and do not affect height or section structure:

```swift
final class RowViewModel {
    let id: String
    let title: String

    @SKPublished var detail = ""
    @SKPublished var status: String?
    @SKPublished var isEnabled = true

    init(id: String, title: String) {
        self.id = id
        self.title = title
    }
}
```

Pass the same model instances to the section once, then mutate their published fields:

```swift
let section = RowCell.wrapperToSingleTypeSection()
section.config(models: rows)
manager.reload(section)

row.detail = progressText
row.status = statusText
row.isEnabled = isEnabled
```

Let the reusable cell own and reset subscriptions:

```swift
import Combine

final class RowCell: UICollectionViewCell, SKLoadViewProtocol, SKConfigurableView {
    typealias Model = RowViewModel

    private var cancellables = Set<AnyCancellable>()

    override func prepareForReuse() {
        super.prepareForReuse()
        cancellables.removeAll()
    }

    func config(_ model: RowViewModel) {
        cancellables.removeAll()

        model.$detail.bind { [weak self] value in
            self?.detailLabel.text = value
        }.store(in: &cancellables)

        model.$status.bind { [weak self] value in
            self?.statusLabel.text = value
            self?.statusLabel.isHidden = value == nil
        }.store(in: &cancellables)

        model.$isEnabled.bind { [weak self] value in
            self?.contentView.alpha = value ? 1 : 0.45
        }.store(in: &cancellables)
    }
}
```

Reserve `manager.reload`, `section.apply`, and row refresh APIs for structural changes, full model replacement, row replacement, or intended collection-view reconfiguration.

## SKPublished Transforms

18. Pass multiple transforms as an array. `SKPublishedTransform` is not a chainable builder.

```swift
@SKPublished(transform: [
    .dropFirst(),
    .removeDuplicates()
])
var items: [Item] = []
```

19. Transform publishers run in the order stored in the transform array.

20. Use `.removeDuplicates()` for `Equatable` output when repeated UI updates are wasteful.

21. Use `.removeDuplicates(by: \.id)` when only a stable identity should gate repeated emissions.

22. Use `.filter` for state streams where invalid values should not reach the UI.

23. Use `.dropFirst(count:)` when the initial subject value is only a placeholder.

24. Use `.receiveOnMainQueue()` only around custom upstreams that bypass base `SKPublishedValue` delivery. Base delivery is already deferred to the main queue.

25. Use `.onChanged` for lightweight side effects tied to old/new values. It is delivered asynchronously on the main queue.

26. For `Equatable` output, `.onChanged` skips equal old/new values.

27. Use `.print(prefix:)` only during local debugging. Do not leave noisy framework examples as production guidance.

28. Use `.mapPublisher` for custom Combine operators when the built-in transforms are insufficient.

29. Avoid transforms with hidden mutation of the same state. Prefer downstream sinks with explicit guards for feedback control.

30. Do not treat transforms as validation that changes the wrapped value. They shape the publisher output, not the stored `value`.

## Section Model Subscription

31. Use `section.subscribe(models:)` when a publisher is the complete source of truth for a section's models.

32. The `[Model]` overload receives on `RunLoop.main` and calls `apply(models)`.

33. The `Model` overload wraps each emitted value into a single-row array.

34. The `Model?` overload maps `nil` to an empty section and non-nil to one row.

35. The deprecated conversion overloads should be replaced by upstream `map` / `compactMap` before calling `subscribe(models:)`.

36. Do not mix `subscribe(models:)` with manual `append`, `insert`, `remove`, or `delete` unless the next publisher emission intentionally overwrites local mutations.

37. If local row edits are needed, mutate the upstream state and let the subscribed section apply the new array.

38. `subscribe(models:)` stores its cancellable in `publishers.modelsCancellable`, so a later subscription replaces the previous model subscription.

39. Use `config(models:)` or `apply(_:)` directly when the section owner already controls rendering imperatively.

40. For optional single-row sections, pair the empty-array behavior with explicit empty or placeholder sections when the UI still needs explanation or action.

41. If the publisher emits quickly during initial load, apply request gating or `removeDuplicates` upstream before reaching the section.

## Section Publishers

42. `modelsPulisher` is backed by a `CurrentValueSubject` and emits the current model array to new subscribers.

43. `cellActionPulisher`, `supplementaryActionPulisher`, and `lifeCyclePulisher` are deferred pass-through streams. The subject is created lazily when observed.

44. `lifeCyclePulisher` is delayed on `RunLoop.main` by about 0.3 seconds. Do not use it for same-render synchronous layout work.

45. Use `modelsPulisher` for derived UI such as count labels, empty-state toggles, and selection stores that follow model replacement.

46. Use `cellActionPulisher` and `supplementaryActionPulisher` for analytics, debug tools, and cross-cutting observers.

47. Prefer `onCellAction` and `onSupplementaryAction` for local screen behavior because the callback is declared beside the section.

48. When a publisher sink writes back to the same section, add an identity guard, `removeDuplicates`, or a render coordinator.

49. Keep event publisher sinks owned by the screen, reusable section abstraction, or coordinator that knows when to cancel them.

50. Do not let a section publisher retain a stale controller through a long-lived cancellable.

51. Use `manager.publishers.sectionsPublisher` for observers that need the bound section list after reloads.

52. Use synchronous `manager.sections` only for immediate inspection, not as a durable index cache.

## SKBinding

53. Use `SKBinding` when a helper needs read/write access to state without owning the state.

54. `wrappedValue` reads through the getter closure every time.

55. Setting `wrappedValue` calls every setter closure in registration order.

56. `changedPublisher` emits only after setting when the binding has at least one setter.

57. `isSetable` is false when the binding was created with only a getter.

58. `SKBinding.constant(_:)` supplies a setter that ignores writes, so `isSetable` is true but writes do not mutate external state.

59. Use `SKBinding(on:keyPath:)` for object-owned state when the object lifetime is at least as long as the binding.

60. Use the `Root: AnyObject` initializer with a default value when weak ownership is required.

61. Use the `CurrentValueSubject` initializer when a binding should read and write a subject's current value.

62. Avoid using `changedPublisher` as a source of truth for external changes; it only publishes writes performed through that binding instance.

63. Do not store bindings globally. They close over object or subject lifetimes and should stay near the component that uses them.

## SKBindingKey

64. Use `SKBindingKey` for lazily resolving section indexes, decoration endpoints, pin targets, and scroll targets.

65. `wrappedValue` calls the closure every time. It is not a cached value.

66. Use `.constant` for fixed section indexes only when the section order is static.

67. Use `SKBindingKey(section, offset:)` when a target should follow a bound section after manager reload or insert/delete.

68. `SKBindingKey(section, offset:)` returns nil when the section is unbound.

69. Use `.relative(from:view, task)` for dynamic first/last section boundaries of a collection view.

70. `.all` is a sentinel key for APIs that interpret all sections. Do not use the raw sentinel integer directly.

71. Equality and hashing compare current wrapped values. Avoid putting a mutable `SKBindingKey` into long-lived sets or dictionaries if the underlying closure result can change.

72. Prefer binding keys over cached integer indexes for decorations, pinning, and scroll targets derived from a final section list.

## Result Builders And Conditions

73. Use `SectionArrayResultBuilder` when a helper needs to build a section array from optional and conditional blocks.

74. The builder accepts single models, arrays, closures returning models, empty expressions, optionals, conditionals, and loops.

75. Keep result-builder blocks pure. They should assemble sections, not start requests or navigate.

76. Use `SKWhen` to name reusable render predicates when a condition appears in several section builders.

77. Combine predicates with `.and` and `.or` instead of duplicating long boolean expressions.

78. Use `SKWhen.equal` and `SKWhen.compare` for simple key-path based rules.

79. Keep `SKWhen` conditions product-neutral in framework examples. Do not encode business status names into the skill.

80. Prefer `SKCSectionCollector` when render-time append decisions need a returned boolean or object-to-section mapping.

## Event Groups And Async Actions

81. `SKEventGroup` stores multiple handlers per hashable event key.

82. `append(of:_:)` preserves registration order for handlers under the same key.

83. `removeAll(of:)` clears every handler for that event key.

84. Use event groups for framework-level action registries where multiple independent handlers are expected.

85. Clear event groups when a reusable section or component changes owner.

86. `SKUIAction` wraps async menu work in a `Task` on the main actor.

87. `SKUIAction` does not surface thrown errors to the caller. Handle errors inside the async handler when user feedback matters.

88. Use `SKUIAction` for context menus and menu-like actions that must remain on the main actor.

89. Gate duplicate async actions at the feature layer. The action wrapper starts a task each time the UIAction fires.

## Feedback Loop Control

90. If `@SKPublished` state drives `section.subscribe(models:)`, do not also mutate the same section directly from row events. Mutate the state and let the publisher render.

91. If a section publisher drives `@SKPublished` state, guard writes so the same emission does not bounce back into the section.

92. Prefer identity-based `removeDuplicates` for large model arrays when only insert/delete identity matters.

93. Prefer content-aware guards when row content can change without identity changing.

94. For request state, separate durable state from transient events: current-value for `isLoading`, pass-through for `retryTapped`.

95. For UI controls, bind initial state with `bind`, then use event publishers for user intents.

96. For nested sections, keep parent model state and child section state in separate subscriptions. Rebind child subscriptions when the parent cell is reused.

97. For selection sequences derived from models, let `modelsPulisher` be the update trigger rather than polling section models from unrelated sinks.

98. For load-more, use `statefulLoadMorePublisher` when duplicate request gating belongs to the section; call `finishLoadMore(hasMore:)` or `failLoadMore()` from the request completion.

## Debug Checklist

99. Initial UI does not render: use `bind` instead of `sink`, or verify current-value publisher semantics.

100. Pass-through event replays unexpectedly: check whether the code used `bind`, which always calls with current `value`.

101. Transform does not compile: pass transforms as an array; do not chain `SKPublishedTransform` values.

102. Duplicate UI updates: add `removeDuplicates` or move expensive derived work behind identity guards.

103. Section subscription overwrote local edits: the publisher is the source of truth; move the edit upstream or stop using `subscribe(models:)`.

104. Progress/status updates flicker: if height and structure are unchanged, keep row model identity stable and bind `@SKPublished` fields inside the cell instead of repeatedly reloading/applying/refreshing.

105. `changedPublisher` does not fire: verify the binding has a setter and the write happened through that binding.

106. Binding writes do not mutate state: check for `SKBinding.constant` or a weak object that has already been released.

107. Binding key returns nil: the section is not bound or the collection view is gone.

108. Binding key dictionary lookup is unstable: the key's wrapped value changed after hashing.

109. Lifecycle publisher is late: it intentionally delays. Use `taskIfLoaded` or direct post-bind work for synchronous setup.

110. Event handlers from an old screen still fire: clear actions/event groups and cancel publisher sinks when reusing a section.

111. Async menu action fails silently: catch and handle errors inside the `SKUIAction` handler.

112. Result-builder output misses a section: inspect optional branches and empty expressions before checking manager reload.

113. Feedback loop spikes CPU: find sinks that write to the same publisher or section they observe and add guards.

## Framework Boundary

114. Promote reactive helpers into SectionUI only when they are independent of app state machines, route names, request clients, and analytics taxonomy.

115. Keep business-specific event streams, render-state enums, and retry policies outside framework-level examples.

116. Document binding recipes as state ownership and publisher semantics, not as a downstream app's architecture.

117. Prefer small reference recipes over adding new APIs for one repeated screen pattern until the behavior is proven framework-level.
