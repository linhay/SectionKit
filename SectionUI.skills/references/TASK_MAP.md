# SectionUI Task Map

Use this file to route user intent to the smallest reference set. Open the primary reference first; open adjacent references only when the task crosses domains.

| Intent / keywords | Primary reference | Adjacent references |
| --- | --- | --- |
| architecture, source of truth, bind once, data-driven rendering, UI update flow, visible cell mutation, anti-pattern | `data-driven-best-practices.md` | `production-usage.md`, `composition-styling-recipes.md` |
| production conventions, app-scale list patterns, reusable wrappers | `production-usage.md` | `production-tips.md`, `advanced-production-tips.md` |
| lifecycle state, loaded lifecycle, empty state, section publishers | `production-lifecycle-state.md` | `manager-transaction-recipes.md`, `reactive-binding-recipes.md` |
| section composition, optional sections, render state, section styles, cell styles | `composition-styling-recipes.md` | `supplementary-recipes.md`, `render-builder-recipes.md` |
| result builders, `SKCSectionCollector`, `SKWhen`, builder identity | `render-builder-recipes.md` | `section-assembly-identity-recipes.md` |
| manager binding, `reload`, `insert`, `remove`, section identity, pending requests | `manager-transaction-recipes.md` | `container-lifecycle-recipes.md`, `forwarding-extension-recipes.md` |
| row update, `refresh`, `apply`, append, insert, remove, delete, `reloadKind` | `row-mutation-recipes.md` | `reactive-binding-recipes.md`, `cache-exposure-recipes.md` |
| data binding strategy, publisher-owned section, section-owned models, state-to-section mapping, high-frequency progress/status, non-layout row state | `data-driven-best-practices.md` | `reactive-binding-recipes.md`, `row-mutation-recipes.md` |
| `@SKPublished`, stable cell view model, model publishers, `subscribe(models:)`, `SKBinding`, feedback loop | `reactive-binding-recipes.md` | `data-driven-best-practices.md`, `production-lifecycle-state.md` |
| cell setup, configurable views, nib loading, wrapper cell/view, container setup | `view-cell-container-recipes.md` | `runtime-view-wrapper-recipes.md`, `container-lifecycle-recipes.md` |
| `SKCollectionView`, `SKCollectionViewController`, refreshable, safe area, layout invalidation | `container-lifecycle-recipes.md` | `manager-transaction-recipes.md`, `view-cell-container-recipes.md` |
| dynamic height/width, Auto Layout fitting, stale size, stale cached size, `safeSize` | `safe-size-measurement-recipes.md` | `adaptive-sizing-recipes.md`, `rendering-performance-recipes.md` |
| adaptive cell sizing, `SKAdaptive`, fitting priorities, content key paths | `adaptive-sizing-recipes.md` | `safe-size-measurement-recipes.md`, `cache-exposure-recipes.md` |
| rendering performance, fixed-size fast path, waterfall, nested rendering | `rendering-performance-recipes.md` | `cache-exposure-recipes.md`, `safe-size-measurement-recipes.md` |
| cache keys, high-performance cache, exposure counts, displayed times | `cache-exposure-recipes.md` | `rendering-performance-recipes.md`, `interaction-state-recipes.md` |
| selection ownership, single select, multi select, ID-based selection | `selection-ownership-recipes.md` | `interaction-state-recipes.md`, `drag-selection-recipes.md` |
| drag selection, rectangular selection, auto-scroll overlay | `drag-selection-recipes.md` | `selection-ownership-recipes.md` |
| cell events, exposure, context menu, reorder, load more | `interaction-state-recipes.md` | `delegate-interaction-recipes.md`, `prefetch-menu-reorder-recipes.md` |
| prefetch, load more, context menu, async menu action, reorder persistence | `prefetch-menu-reorder-recipes.md` | `interaction-state-recipes.md`, `delegate-interaction-recipes.md` |
| UIKit delegate routing, highlight/select gates, display lifecycle, focus/editing | `delegate-interaction-recipes.md` | `forwarding-extension-recipes.md`, `interaction-state-recipes.md` |
| layout plugin system, plugin scope, plugin priority, section-level plugins, collection-level modes, attribute adjustment, invalidation, custom forward | `layout-plugin-execution-recipes.md` | `layout-decoration-recipes.md`, `container-lifecycle-recipes.md` |
| decorations, background frames, z-index, supplementary fixes, alignment, plugin conflict | `layout-decoration-recipes.md` | `layout-plugin-execution-recipes.md`, `supplementary-recipes.md` |
| supplementary views, headers, footers, custom kind, hidden when empty | `supplementary-recipes.md` | `composition-styling-recipes.md`, `safe-size-measurement-recipes.md` |
| index titles, section index lookup, iOS 14 collection index titles | `index-title-recipes.md` | `composition-styling-recipes.md`, `forwarding-extension-recipes.md` |
| scroll observer, delegate forwarding, display tracker, pending scroll, pin | `navigation-scroll-recipes.md` | `page-zoom-recipes.md`, `index-title-recipes.md` |
| page controller, zoomable scroll view, child identity/cache | `page-zoom-recipes.md` | `navigation-scroll-recipes.md` |
| SwiftUI bridge, hosting cell, hosting section, hosting collection view | `swiftui-hosting-recipes.md` | `view-cell-container-recipes.md`, `rendering-performance-recipes.md` |
| nested horizontal section, collection in cell, section-in-cell lifecycle | `nested-section-cell-recipes.md` | `container-lifecycle-recipes.md`, `rendering-performance-recipes.md` |
| runtime view wrappers, `SKCAnyViewCell`, `SKWrapperView`, wrapper reuse | `runtime-view-wrapper-recipes.md` | `view-cell-container-recipes.md`, `safe-size-measurement-recipes.md` |
| raw section wrapper protocols, reusable wrappers, direct raw sections | `raw-section-wrapper-recipes.md` | `custom-section-patterns.md`, `forwarding-extension-recipes.md` |
| custom heterogeneous section, row enum, direct `SKCSectionProtocol` | `custom-section-patterns.md` | `raw-section-wrapper-recipes.md`, `manager-transaction-recipes.md` |
| forwarding chain, `SKHandleResult`, data source/delegate/prefetch forwarding | `forwarding-extension-recipes.md` | `delegate-interaction-recipes.md`, `raw-section-wrapper-recipes.md` |
| diagnostics, utility wrappers, stores, environment configuration, timing | `diagnostics-utility-recipes.md` | `advanced-production-tips.md`, `rendering-performance-recipes.md` |

If no row matches, search `INDEX.md` and then use `rg -n "<keyword>" SectionUI.skills/references`.
