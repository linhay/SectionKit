# Reactive Binding Recipes

Use this reference when a SectionUI task involves `@SKPublished`, `SKPublishedValue`, transforms, `subscribe(models:)`, section publishers, `SKBinding`, `SKBindingKey`, result builders, event groups, async UI actions, or feedback-loop control. Keep it generic: no downstream project paths, product names, business module names, source-file indexes, scan statistics, or page names.

## Contents

- [SKPublished Semantics](#skpublished-semantics)
- [Stable Cell View Models](#stable-cell-view-models)
- [Stable Supplementary View Models](#stable-supplementary-view-models)
- [Identity-Only Structural Updates](#identity-only-structural-updates)
- [Idempotent Image Binding](#idempotent-image-binding)
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

## Stable Supplementary View Models

Register one reference model once for a header or footer. For fixed-size title/count/status changes, bind the model fields directly to reusable-view controls. Repeated `setHeader` / `setFooter` calls replace the supplementary definition and reload the **entire section**, including unchanged cells; matching size or identity does not suppress that reload.

```swift
import Combine
import SectionKit
import UIKit

final class SummaryViewModel {
    @SKPublished var title = "Items"
    @SKPublished var count = 0
    @SKPublished var status = "Ready"
    var height: CGFloat = 44
}

final class SummaryHeader: UICollectionReusableView, SKLoadViewProtocol, SKConfigurableView {
    typealias Model = SummaryViewModel
    private var subscriptions = Set<AnyCancellable>()
    private let titleLabel = UILabel()
    private let countLabel = UILabel()
    private let statusLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        let stack = UIStackView(arrangedSubviews: [titleLabel, countLabel, statusLabel])
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            stack.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func config(_ model: Model) {
        subscriptions.removeAll()
        model.$title.prepend(model.title).removeDuplicates()
            .sink { [weak self] in self?.titleLabel.text = $0 }.store(in: &subscriptions)
        model.$count.prepend(model.count).removeDuplicates()
            .sink { [weak self] in self?.countLabel.text = String($0) }.store(in: &subscriptions)
        model.$status.prepend(model.status).removeDuplicates()
            .sink { [weak self] in self?.statusLabel.text = $0 }.store(in: &subscriptions)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        subscriptions.removeAll()
    }

    static func preferredSize(limit size: CGSize, model: Model?) -> CGSize {
        CGSize(width: size.width, height: model?.height ?? 44)
    }
}

// Configure and mutate UI-facing state on the main thread.
let summary = SummaryViewModel()
section.setHeader(SummaryHeader.self, model: summary)
manager.reload(section)
summary.count = 12
summary.status = "Complete"
```

`prepend` gives an immediate initial value; `removeDuplicates` filters both repeated values and the deferred current-value replay. `bind` is also valid for cheap assignments, but its immediate callback is separate from publisher transforms, so it can deliver the initial value again. Clear subscriptions in both `config` and `prepareForReuse`: reconfiguration need not be preceded by reuse. The same recipe works with `setFooter` and a direct `UICollectionReusableView` subclass.

For **layout-changing state**, a content subscription is not sufficient. Change the sizing model first, then invalidate the bound collection layout on the main thread:

```swift
summary.height = 80
if section.isBindSectionView {
    section.sectionView.collectionViewLayout.invalidateLayout()
}
```

This recomputes geometry for an existing, self-binding supplementary without an intentional cell reload. Use `section.reload()` for definition/type/visibility changes that need dequeue or reconfiguration, including adding/removing supplementary views. Fixed `highestHeaderSize` / `highestFooterSize` overrides still win. If row sizes also change, invalidate the affected entries in the app-owned `SKHighPerformanceStore` (for example `sizeStore.remove(by: row.id)`) before invalidating layout; content binding and `apply` do not clear size caches. When coalescing layout work, clear stale caches immediately and throttle only the subsequent layout invalidation. Custom layouts/plugins must support their own invalidation contracts.

## Identity-Only Structural Updates

For stable reference models whose visible fields bind themselves:

```swift
section.reloadKind = .difference(by: \.id)
section.differenceReloadPolicy = .structuralOnly
section.apply(rows)
```

- `.reloadVisible` is the default and preserves existing behavior: visible items reload for an identity no-op and after insertion/deletion; empty transitions reload the section.
- `.structuralOnly` suppresses those extra reloads. An identity no-op, including empty-to-empty, makes no collection-view update calls. The model array is still assigned and `modelsPulisher` still emits; subscriber side effects remain the caller's responsibility.
- Insertions/deletions use one UIKit batch, including transitions to/from empty. Retained visible cells keep their bindings where UIKit can preserve them. Newly visible cells still configure normally. Reorders use the collection difference's remove/insert operations and may recreate moved cells.
- Keep IDs unique and immutable, and keep the **same model object** for each retained ID. Replacing an object with another object of the same ID leaves an existing cell bound to the old object under this policy. Use the default policy or an explicit row refresh for replacement payloads.
- Position-dependent separators, first/last styles, row-number labels, and `.config` handlers do not rerun for retained cells. Keep `.reloadVisible` if they need to rerun, or explicitly refresh affected rows.
- This policy affects only `apply` / `config(models:)` / `subscribe(models:)` with `.difference`. `setHeader`, `setFooter`, `reload`, `refresh`, and `remove` / `delete` retain their existing side effects. In particular, `remove` reloads trailing rows after deletion or reloads the section when none remain; use `apply(finalRows)` for structural-only deletion.
- Apply on the main thread and serialize structural batches; do not start another `apply` while an earlier batch is in progress. This policy does not provide a transaction queue.

Display-end events use the payload configured on the actual cell, tracked with weak cell keys. Row-index snapshots alone become stale after insertion/deletion; do not infer the displayed model from the current array at a callback row. This applies to both difference policies, including cells configured before becoming visible.

Regression coverage is in `Tests/SectionKitTests/ReactiveBindingTests.swift`: no-op UIKit operations, count updates, preserved visible bindings through insert/delete, empty transitions, reorder, default payload refresh, subscription cancellation, supplementary layout invalidation, image request counts, and display-end model identity through structural changes and scrolling.

## Idempotent Image Binding

`removeDuplicates()` on the URL publisher helps within one subscription. It resets on reconfiguration, so also keep a URL guard in the reusable view. Even `bind`'s immediate call and current-value replay must not restart the same request:

```swift
// Cell-owned state, alongside its subscriptions and image view:
private var requestedURL: URL?
private var imageTask: Task<Void, Never>?

// Called by the imageURL subscription on the main thread.
private func configureImage(_ url: URL?) {
    guard requestedURL != url else { return }
    requestedURL = url
    imageTask?.cancel()
    imageTask = nil
    imageView.image = nil
    guard let url else { return }
    // imageLoader is the app's injected asynchronous image pipeline.
    imageTask = Task { @MainActor [weak self, imageLoader] in
        let image = await imageLoader.image(for: url)
        guard !Task.isCancelled, self?.requestedURL == url else { return }
        self?.imageView.image = image
    }
}
```

In `prepareForReuse`, cancel subscriptions and the image task, set `requestedURL = nil`, and clear the image. In `config`, replace subscriptions but retain the URL guard and in-flight task until the URL actually changes. Include any rendition/size/authentication variant in the request key when URL alone does not identify the image. Retry failures through an explicit retry path that clears the guard. SectionKit does not implement image networking or caching; the regression uses a request spy to verify request initiation counts, not a network benchmark.

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

98. For prefetch-driven load-more, use `statefulLoadMorePublisher` when duplicate request gating belongs to the section; call `finishLoadMore(hasMore:)` or `failLoadMore()` from the request completion. For correctness-critical pagination, use `statefulLoadMoreOnDisplayPublisher` with the same completion methods.

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
