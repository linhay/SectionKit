---
name: SectionUI
description: Master skill for SectionUI (SectionKit), a powerful data-driven framework for building complex UICollectionView layouts in Swift. Use when working with UICollectionView, building list interfaces, implementing reactive data binding with Combine, optimizing collection view performance, managing selection state, implementing sticky headers/footers, creating waterfall layouts, integrating SwiftUI views, handling scroll events, implementing page-based navigation, or applying production-tested SectionUI patterns. Covers cells, sections, managers, layout plugins, decorations, performance optimization, reactive programming, selection management, scroll observation, page view controllers, and reusable list architecture patterns.
---

# SectionUI Skill

`SectionUI` (formerly SectionKit) is a powerful, data-driven framework for building complex `UICollectionView` layouts in Swift. It abstracts away the complexity of `UICollectionViewDataSource` and `UICollectionViewDelegate`, allowing you to focus on composable **Sections** and **Cells**.

## Core Components

1.  **SKCManager**: The central coordinator that manages sections and binds them to the `UICollectionView`.
2.  **SKCollectionView**: A subclass of `UICollectionView` optimized for use with `SectionUI`.
3.  **SKCSingleTypeSection**: A generic section type for displaying a list of identical cells (homogenous data).
4.  **SKLoadViewProtocol & SKConfigurableView**: Protocols that Cells must conform to for automatic registration and configuration.

## Production-Tested Defaults

When changing SectionUI or teaching someone how to use it, prefer the patterns that survive in large app surfaces:

- Favor small, composable sections over monolithic collection-view controllers.
- Prefer `wrapperToSingleTypeSection`, `setSectionStyle`, `onCellAction`, supplementary views, decorations, exposure tracking, and nested horizontal sections before custom collection plumbing.
- Treat `@SKPublished`, `SKPublishedValue`, and selection state as first-class UI state tools when they reduce reload scope.
- Put reusable behavior such as selection, diff application, grid/action sheets, settings rows, and common spacer/divider views into integration-level abstractions instead of bloating the core framework.

For the distilled rules, read [Production Usage Patterns](references/production-usage.md).
For concrete field-tested tricks, read [Production Tips](references/production-tips.md).
For lower-frequency production APIs and edge cases, read [Advanced Production Tips](references/advanced-production-tips.md).
For lifecycle, state, reload, and binding guidance, read [Production Lifecycle And State Tips](references/production-lifecycle-state.md).
For heterogeneous rows and custom section contracts, read [Custom Section Patterns](references/custom-section-patterns.md).
For layout plugin, supplementary sizing/inset, and decoration recipes, read [Layout And Decoration Recipes](references/layout-decoration-recipes.md).
For layout plugin execution order, collection-vs-section scope, `setAttributes`, `layoutAttributesForElements`, invalidation, and cancellation semantics, read [Layout Plugin Execution Recipes](references/layout-plugin-execution-recipes.md).
For cell events, selection, exposure, prefetch, context menus, and reorder recipes, read [Interaction And State Recipes](references/interaction-state-recipes.md).
For `refresh(at:)`, `refresh(with:)`, predicate refresh, `append`, `insert`, `remove`, `apply`, and `reloadKind` semantics, read [Row Mutation Recipes](references/row-mutation-recipes.md).
For exact prefetch row semantics, load-more gating, context menu result routing, `SKUIAction`, and reorder defaults, read [Prefetch Menu Reorder Recipes](references/prefetch-menu-reorder-recipes.md).
For selection state ownership, wrapper identity, cell reuse binding, sequence observation, ID-based selection, and single/multi-select rules, read [Selection Ownership Recipes](references/selection-ownership-recipes.md).
For sizing, performance cache, wrapper views, hosting, nested sections, and waterfall guidance, read [Rendering And Performance Recipes](references/rendering-performance-recipes.md).
For exact safe-size measurement semantics, `cellSafeSize`, fraction grids, transforms, supplementary providers, and cache-limit debugging, read [Safe Size Measurement Recipes](references/safe-size-measurement-recipes.md).
For `SKAdaptive`, Auto Layout fitting priorities, adaptive protocol choice, content key paths, auto-cache behavior, and dynamic-size debugging, read [Adaptive Sizing Recipes](references/adaptive-sizing-recipes.md).
For size cache identity, `SKHighPerformanceStore`, `SKKVCache`, display count tracking, and exposure reset timing, read [Cache Exposure Recipes](references/cache-exposure-recipes.md).
For `SKCAnyViewCell`, `SKWrapperView`, `SKCWrapperCell`, runtime view ownership, wrapper sizing, nib behavior, and reusable wrapper debugging, read [Runtime View Wrapper Recipes](references/runtime-view-wrapper-recipes.md).
For `SKCSectionViewCell`, `SKCSingleSectionViewCell`, `wrapperToHorizontalSection`, nested sizing, inner collection lifecycle, and nested state reset rules, read [Nested Section Cell Recipes](references/nested-section-cell-recipes.md).
For section assembly, manager binding, render states, supplementary views, and styling recipes, read [Composition And Styling Recipes](references/composition-styling-recipes.md).
For exact header/footer setup, dynamic supplementary models, hiding rules, removal semantics, lifecycle actions, and custom kind boundaries, read [Supplementary Recipes](references/supplementary-recipes.md).
For `indexTitle`, `indexTitleRow`, section index lookup, iOS 14+ collection index titles, and data-source forwarding boundaries, read [Index Title Recipes](references/index-title-recipes.md).
For scroll observation, display tracking, pending scroll requests, pinning, paging, and zoomable content, read [Navigation And Scroll Recipes](references/navigation-scroll-recipes.md).
For exact `SKPageManager`, `SKPageViewController`, child identity/cache, selection/current binding, `SKZoomableScrollView`, tap actions, and pan-to-dismiss behavior, read [Page And Zoom Recipes](references/page-zoom-recipes.md).
For `SKPublished`, `SKBinding`, section publishers, binding keys, result builders, and feedback-loop control, read [Reactive Binding Recipes](references/reactive-binding-recipes.md).
For load protocols, configurable views, adaptive sizing, wrappers, collection containers, and SwiftUI bridges, read [View Cell And Container Recipes](references/view-cell-container-recipes.md).
For exact `SKCollectionView` / `SKCollectionViewController` lifecycle, queued reloads, safe-area behavior, refreshable, layout invalidation, scroll direction, and plugin modes, read [Container Lifecycle Recipes](references/container-lifecycle-recipes.md).
For manager forwarding chains, `SKHandleResult`, delegate/data-source/flow-layout/prefetch extension points, and section injection hooks, read [Forwarding And Extension Recipes](references/forwarding-extension-recipes.md).
For `SKCRawSectionProtocol`, `SKCAnySectionProtocol`, `SKCAnySingleTypeSectionProtocol`, raw-section wrapper identity, forwarded style/plugins, and wrapper lifecycle rules, read [Raw Section Wrapper Recipes](references/raw-section-wrapper-recipes.md).
For beta drag selection, rectangular multi-select, auto-scroll, overlay styling, gesture conflicts, and selection-state ownership, read [Drag Selection Recipes](references/drag-selection-recipes.md).
For debug output, performance timing, caches, counted stores, weak wrappers, identity boxes, environment objects, and utility boundaries, read [Diagnostics And Utility Recipes](references/diagnostics-utility-recipes.md).
For manager binding, section identity, transaction boundaries, row mutations, injection actions, pending requests, and reload configuration, read [Manager Transaction Recipes](references/manager-transaction-recipes.md).
For UIKit delegate interactions such as highlight, selection gates, primary action, focus, editing, spring-load, multiple selection, context menus, and reorder gates, read [Delegate Interaction Recipes](references/delegate-interaction-recipes.md).
For SwiftUI bridges, hosting cells, hosting sections, `SKCHostingCollectionView`, previews, sizing, and SwiftUI/SectionUI state ownership, read [SwiftUI Hosting Recipes](references/swiftui-hosting-recipes.md).
For conditional section assembly, `SectionArrayResultBuilder`, `SKCSectionCollector`, `SKWhen`, `SKBindingKey`, and SwiftUI builder identity, read [Render Builder Recipes](references/render-builder-recipes.md).
For exact builder flattening, collector append/unwrapping semantics, `SKWhen`, dynamic `SKBindingKey` equality/hash, and SwiftUI hosted collection reload identity, read [Section Assembly Identity Recipes](references/section-assembly-identity-recipes.md).

## Reference Documentation

### Core Components
- **[Cell Creation & Configuration](references/cell.md)** - SKLoadViewProtocol, SKConfigurableView, Auto Layout integration, adaptive cells
- **[Section Management](references/section.md)** - SKCSingleTypeSection basics, event handling, headers/footers, styling
- **[Manager & CollectionView](references/manager.md)** - SKCManager, SKCollectionView, SKCollectionViewController

### Advanced Features
- **[Advanced Sections](references/advanced-sections.md)** - SKCHostingSection (SwiftUI), SKCAnyViewCell, SKCSectionViewCell (nested sections)
- **[Reactive Programming](references/reactive.md)** - SKPublished, data subscription, prefetch publishers, selection publishers
- **[Performance Optimization](references/performance.md)** - SKHighPerformanceStore (size caching), prefetching, display times tracking, safe size providers
- **[Selection Management](references/selection.md)** - SKSelectionProtocol, SKSelectionWrapper, SKCDragSelector (multi-select)
- **[Pin Functionality](references/pin.md)** - Sticky headers/footers/cells, distance tracking, custom animations
- **[Scroll Management](references/scroll.md)** - SKScrollViewDelegateHandler, SKCDisplayTracker, scroll control
- **[Layout Plugins](references/layout-plugins.md)** - Vertical/horizontal alignment, SKWaterfallLayout, custom attribute plugins
- **[Decorations](references/decorations.md)** - Background decorations, custom decoration views
- **[Page View Controller](references/page.md)** - SKPageManager, SKPageViewController, nested scrolling
- **[Production Usage Patterns](references/production-usage.md)** - Distilled rules from large SectionUI app surfaces.
- **[Production Tips](references/production-tips.md)** - Practical tips distilled from repeated real-world SectionUI usage.
- **[Advanced Production Tips](references/advanced-production-tips.md)** - Lower-frequency APIs, layout attribute fixes, pinning, scroll tracking, prefetch, context menus, and reorder guidance.
- **[Production Lifecycle And State Tips](references/production-lifecycle-state.md)** - Binding lifecycle, section collectors, reload strategy, section publishers, selection state, high-performance cache, and scroll requests.
- **[Custom Section Patterns](references/custom-section-patterns.md)** - Heterogeneous row enums, direct `SKCSectionProtocol` implementation, custom sizing, events, and snapshot-style sections.
- **[Layout And Decoration Recipes](references/layout-decoration-recipes.md)** - Plugin ordering, alignment, supplementary size/inset fixes, background decoration frames, cross-section decoration, z-index, and debug checklists.
- **[Layout Plugin Execution Recipes](references/layout-plugin-execution-recipes.md)** - `SKCollectionFlowLayout` mode priority, collection-level modes, section-level plugins, `setAttributes`, full-attribute forwards, invalidation, and cancellation.
- **[Interaction And State Recipes](references/interaction-state-recipes.md)** - Cell action ownership, exposure counting, reload/diff transactions, selection sequences, prefetch/load-more, context menus, reorder, and interaction debug checklists.
- **[Row Mutation Recipes](references/row-mutation-recipes.md)** - `refresh(at:)`, `refresh(with:)`, predicate refresh, `append`, `insert`, `remove`, `delete`, `apply`, `config(models:)`, action-context row edits, and `reloadKind`.
- **[Prefetch Menu Reorder Recipes](references/prefetch-menu-reorder-recipes.md)** - Section-local prefetch rows, pagination gates, context menus, `SKUIContextMenuResult`, async `SKUIAction`, reorder move gates, and persistence boundaries.
- **[Selection Ownership Recipes](references/selection-ownership-recipes.md)** - `SKSelectionState`, `SKSelectionWrapper`, `SKSelectionSequence`, `SKSelectionIdentifiableSequence`, publisher lifecycle, reuse binding, and identity rules.
- **[Rendering And Performance Recipes](references/rendering-performance-recipes.md)** - Safe-size providers, high-performance size cache, wrapper views, `SKCAnyViewCell`, SwiftUI hosting, nested `SKCSectionViewCell`, waterfall layout, and rendering debug checklists.
- **[Safe Size Measurement Recipes](references/safe-size-measurement-recipes.md)** - `safeSize`, `cellSafeSize`, default provider rules, fraction grid math, public transforms, supplementary providers, custom providers, and measurement debug checklists.
- **[Adaptive Sizing Recipes](references/adaptive-sizing-recipes.md)** - `SKAdaptive`, adaptive protocol choice, Auto Layout fitting priorities, content key paths, insets, auto-cache behavior, size-cache pairing, and stale-size debugging.
- **[Cache Exposure Recipes](references/cache-exposure-recipes.md)** - `SKHighPerformanceStore`, `SKKVCache`, cache invalidation ownership, `displayedTimes`, `SKCountedStore`, and row-based exposure reset strategy.
- **[Runtime View Wrapper Recipes](references/runtime-view-wrapper-recipes.md)** - `SKCAnyViewCell`, `SKWrapperView`, `SKCWrapperCell`, runtime view ownership, wrapper sizing, nib behavior, and reusable wrapper debugging.
- **[Nested Section Cell Recipes](references/nested-section-cell-recipes.md)** - `SKCSectionViewCell`, `SKCSingleSectionViewCell`, `wrapperToHorizontalSection`, nested sizing, inner collection lifecycle, and state reset rules.
- **[Composition And Styling Recipes](references/composition-styling-recipes.md)** - Section assembly, `SKCSectionCollector`, manager reload/insert/remove semantics, render states, supplementary views, section styles, cell styles, and composition debug checklists.
- **[Supplementary Recipes](references/supplementary-recipes.md)** - `setHeader`, `setFooter`, dynamic supplementary models, visibility flags, removal by kind, lifecycle actions, supplementary sizing, and custom-kind limits.
- **[Index Title Recipes](references/index-title-recipes.md)** - `indexTitle`, `indexTitleRow`, section index lookup, iOS 14+ collection index titles, reload timing, and data-source forwarding boundaries.
- **[Navigation And Scroll Recipes](references/navigation-scroll-recipes.md)** - Scroll observers, delegate forwarding, display tracker, manager scroll requests, pin options, page manager, zoomable content, and synchronization debug checklists.
- **[Page And Zoom Recipes](references/page-zoom-recipes.md)** - `SKPageManager`, `SKPageViewController`, child identity/cache, selection/current binding, `SKZoomableScrollView`, tap actions, and pan-to-dismiss behavior.
- **[Reactive Binding Recipes](references/reactive-binding-recipes.md)** - `SKPublished`, transforms, section model subscriptions, section publishers, `SKBinding`, `SKBindingKey`, result builders, async actions, and feedback-loop control.
- **[View Cell And Container Recipes](references/view-cell-container-recipes.md)** - Load protocols, nib identifiers, configurable view contracts, adaptive sizing, wrapper cells/views, supplementary wrappers, `SKCollectionView`, `SKCollectionViewController`, and SwiftUI bridges.
- **[Container Lifecycle Recipes](references/container-lifecycle-recipes.md)** - `SKCollectionView`, `SKCollectionViewController`, queued `reloadSections`, style hooks, safe-area constraints, refreshable, layout invalidation, scroll direction, and plugin modes.
- **[Forwarding And Extension Recipes](references/forwarding-extension-recipes.md)** - Manager forwarding chains, `SKHandleResult`, data source, delegate, flow layout, prefetch, section injection, raw section wrappers, and integration boundaries.
- **[Raw Section Wrapper Recipes](references/raw-section-wrapper-recipes.md)** - `SKCRawSectionProtocol`, `SKCAnySectionProtocol`, `SKCAnySingleTypeSectionProtocol`, wrapper identity, forwarded style/plugins, and lifecycle rules.
- **[Drag Selection Recipes](references/drag-selection-recipes.md)** - Beta drag selector setup/reset, rectangular multi-select, selection-state ownership, auto-scroll, overlay styling, gesture conflicts, haptics, and debug checklists.
- **[Diagnostics And Utility Recipes](references/diagnostics-utility-recipes.md)** - `SKPrint`, `SKPerformance`, `SKHighPerformanceStore`, `SKKVCache`, `SKCountedStore`, `SKEnvironmentConfiguration`, `SKAnimationBox`, weak wrappers, identity boxes, inout builders, actor boxes, and event groups.
- **[Manager Transaction Recipes](references/manager-transaction-recipes.md)** - Manager binding, section identity, reload/insert/remove semantics, row refresh/insert/delete, section injection, pending requests, bound-section access, and transaction debug checklists.
- **[Delegate Interaction Recipes](references/delegate-interaction-recipes.md)** - UIKit delegate routing, highlight/select gates, primary action, display lifecycle, focus, editing, spring-load, multiple selection, context menus, reorder gates, and subclassing boundaries.
- **[SwiftUI Hosting Recipes](references/swiftui-hosting-recipes.md)** - `SKUIView`, `SKUIController`, `STCHostingCell`, `SKCHostingSection`, `SKCHostingCollectionView`, `SKPreview`, hosting sizing, identity, and state ownership.
- **[Render Builder Recipes](references/render-builder-recipes.md)** - Conditional section assembly, `SectionArrayResultBuilder`, `SKCSectionCollector`, `SKWhen`, `SKBindingKey`, dynamic section indexes, and SwiftUI builder identity.
- **[Section Assembly Identity Recipes](references/section-assembly-identity-recipes.md)** - Builder flattening, collector append/unwrapping semantics, `SKWhen`, dynamic `SKBindingKey` equality/hash, and SwiftUI hosted collection reload identity.

### Examples
- [Basic List](examples/BasicListViewController.swift)
- [Decorations](examples/DecorationExampleViewController.swift)

### Templates
- [Adaptive Cell](examples/AdaptiveCellTemplate.swift) - Template for a cell with self-sizing capabilities.
- [Mixed Cells Section](examples/MixedCellsSectionTemplate.swift) - Template for a section managing multiple cell types.
- [Section Cell](examples/SectionCellTemplate.swift) - Template for a standard configurable cell.

## Quick Start Guide

### 1. Basic Setup
Use `SKCollectionViewController` or `SKCollectionView` to get started quickly.

```swift
class MyViewController: SKCollectionViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // Setup sections here
        manager.reload(mySection)
    }
}
```

### 2. Creating a Cell
Cells must conform to `SKLoadViewProtocol` and `SKConfigurableView`:

```swift
class MyCell: UICollectionViewCell, SKLoadViewProtocol, SKConfigurableView {
    struct Model {
        let title: String
    }

    static func preferredSize(limit size: CGSize, model: Model?) -> CGSize {
        return CGSize(width: size.width, height: 50)
    }

    func config(_ model: Model) {
        label.text = model.title
    }
    
    private lazy var label = UILabel()
}
```

### 3. Creating a Section
The most common pattern is using `wrapperToSingleTypeSection` on your Cell type.

```swift
let section = MyCell.wrapperToSingleTypeSection()
    .onCellAction(.selected) { context in
        print("Selected: \(context.model)")
    }

section.config(models: [Model1, Model2, ...])
manager.reload(section)
```

### 4. Reactive Updates
`SectionUI` works seamlessly with Combine:

```swift
@SKPublished var items: [Model] = []

$items.bind { [weak self] newItems in
    self?.section.config(models: newItems)
}.store(in: &cancellables)

// Or subscribe directly
section.subscribe(models: $items.eraseToAnyPublisher())
```

## Common Usage Patterns

### Choose the Right Section Shape
- Simple homogeneous list: `Cell.wrapperToSingleTypeSection(models)`.
- One-off label/image/spacer/action: `SKWrapperView<UIView, Model>.wrapperToCollectionCell().wrapperToSingleTypeSection(...)` instead of creating a throwaway cell.
- Mixed vertical feed: compose `[SKCBaseSectionProtocol]` and reload through `manager.reload(sections)`.
- Embedded horizontal row: wrap a child section with `wrapperToHorizontalSection(height:insets:style:)` or use `SKCSectionViewCell.Model` when the row owns multiple nested sections or custom sizing.
- Reusable selected list: model conforms to `SKSelectionProtocol`; use `SKSelectionSequence` / `SKSelectionIdentifiableSequence`, or a local selectable-section wrapper.

### Performance Optimization
```swift
section
    .setHighPerformance(.init())
    .highPerformanceID { $0.model.id }
```

### Sticky Headers
```swift
section.pinHeader { options in
    options.padding = 16
}
```

### Selection Management
```swift
let selectableItems = items.map { SKSelectionWrapper(value: $0) }
section.config(models: selectableItems)
```

### Waterfall Layout
```swift
let layout = SKWaterfallLayout()
    .columnWidth(equalParts: 2)
    .heightCalculationMode(.aspectRatio)
```

### SwiftUI Integration
```swift
@available(iOS 16.0, *)
let section = SKCHostingSection(
    cell: MySwiftUIView.self,
    models: viewModels
)
```

## Best Practices
- **Prefer `SKCManager`**: Always use `SKCManager` to manipulate sections (reload, insert, delete).
- **Fluent Configuration**: Use the chainable generic methods on `SKCSingleTypeSection` (`onCellAction`, `setSectionSeparators`, etc.) instead of subclassing whenever possible.
- **Decomposition**: Break complex lists into multiple small Sections.
- **Use Reactive Binding**: Leverage Combine and `SKPublished` for automatic UI updates.
- **Prefer Integration Abstractions**: Before adding a new framework API, check whether the behavior belongs in a project-level wrapper such as selectable sections, diff sections, grid views, or settings rows.
- **Keep Business Events Near Sections**: Production code commonly attaches navigation, logging, exposure, and separator styling through `onCellAction`, `model(displayedAt:)`, `willDisplay`, and `setCellStyle`.
- **Cache Sizes**: Use `SKHighPerformanceStore` for complex Auto Layout calculations.
- **Weak References**: Always use `[weak self]` in closures to avoid retain cycles.
- **Naming Convention**: When declaring a `UICollectionView` variable, use `sectionView` as the variable name instead of `collectionView`.
