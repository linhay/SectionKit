# Cache Exposure Recipes

Use this reference when a SectionUI task involves `SKHighPerformanceStore`, size cache invalidation, `SKKVCache`, `SKCountedStore`, `displayedTimes`, or `model(displayedAt:)`.

## Size Cache Contract

`SKHighPerformanceStore` caches cell `preferredSize(limit:model:)` results by `(id, limitSize)`.

```swift
let sizeStore = SKHighPerformanceStore<String>()

section
    .setHighPerformance(sizeStore)
    .highPerformanceID(by: { context in
        context.model.id
    })
```

Use a stable render identity for `highPerformanceID`. Avoid row indexes when rows can be inserted, removed, filtered, or reordered.

Limit size is part of the cache key. Width changes, split view changes, and different `cellSafeSize` values naturally create separate entries.

## Cache Invalidation

Keep the store if callers need manual invalidation.

```swift
sizeStore.remove(by: model.id)
section.refresh(at: row)
```

Use `remove(by:limit:)` only when you know the exact limit that produced the stale entry. Use `remove(by:)` when all cached limits for that model identity should be cleared.

```swift
let limit = section.safeSizeProvider.size(context: .cell(at: row, in: section))
sizeStore.remove(by: model.id, limit: limit)
```

Use `removeAll()` when the cache identity scheme or the entire model universe changes.

```swift
sizeStore.removeAll()
section.apply(newModels)
```

Do not call non-public section cache properties from app code. Own the `SKHighPerformanceStore` instance when external invalidation is needed.

## SKKVCache

`SKKVCache` wraps `NSCache` and tracks keys separately because `NSCache` does not expose key enumeration.

- `countLimit` forwards to `NSCache.countLimit`.
- `count` is tracked-key count, not a durable memory metric.
- Entries can be evicted by `NSCache` under memory pressure.
- `insert(_:forKey:lifeTime:)` uses expiration only when `dateProvider` is available.
- Codable encoding includes currently readable entries and omits expired ones through the lookup path.

Use `SKKVCache` directly for small utility caches. For SectionUI cell size caching, prefer `SKHighPerformanceStore`.

## Display Counts

`displayedTimes` is an `SKCountedStore` keyed by row index for `SKCSingleTypeSection`.

```swift
section.model(displayedAt: .first) { context in
    trackFirstExposure(context.model, row: context.row)
}

section.model(displayedAt: 2) { context in
    showSecondDisplayHint(context.model)
}

section.model(displayedAt: [1, 3, 5]) { context in
    trackRepeatedExposure(context.model, row: context.row)
}
```

`ModelDisplayedContext` provides `section`, `model`, and `row`. It does not provide a display count or a cell view. If the count matters inside the callback, capture it in the `SKModelDisplayedAt` predicate or use `displayedTimes.trigger` directly.

## Reset Strategy

Reset display counters when row identity changes.

```swift
section.displayedTimes.resetAll()
section.apply(newModels)
```

Reset one row by row id:

```swift
section.displayedTimes.reset(by: row)
```

For nested sections inside reusable cells, reset `displayedTimes` when the parent cell is rebound to a different parent model. Otherwise exposure counters from old content can suppress new exposure callbacks.

Use `displayedTimes.maxCount` when repeated display updates past a threshold should stop increasing counts.

## Debug Checklist

- Size cache stale after content change: remove cache entries by stable model ID before `refresh(at:)`.
- Size cache misses after rotation: expected when limit width changes; limit size is part of the key.
- Cache grows too much: set `SKKVCache.countLimit` on the store's underlying cache.
- Exposure fires for old content: reset row-based `displayedTimes` after replacing the model universe.
- Exposure callback needs count: use a predicate or direct `displayedTimes.trigger`; `ModelDisplayedContext` does not expose count.
- First exposure repeats unexpectedly: verify the section instance is not being recreated or counters are not being reset every render.

## Framework Boundary

Keep cache and exposure guidance generic. Document cache identity, limit-size keys, invalidation ownership, counted-store reset timing, and row-based exposure semantics. Do not encode downstream analytics names, business IDs, page names, source paths, scan counts, or project indexes into the skill.
