# SectionUI API Map

Use this file for concrete API names. If the user names a symbol, search here first, then open the mapped reference.

| API / keyword | Reference |
| --- | --- |
| `SKCManager`, `manager.reload`, `manager.insert`, `manager.append`, `manager.remove`, `sectionInjection`, `pick`, pending requests | `manager-transaction-recipes.md` |
| `SKCollectionView`, `SKCollectionViewController`, `reloadSections`, `controllerStyle`, `sectionViewStyle`, `refreshable`, `scrollDirection` | `container-lifecycle-recipes.md` |
| `SKCSingleTypeSection`, `wrapperToSingleTypeSection`, homogeneous section | `section.md`, `composition-styling-recipes.md` |
| `refresh(at:)`, `refresh(with:)`, `RefreshPayload`, `apply`, `config(models:)`, `reloadKind`, `append`, `insert`, `remove`, `delete` | `row-mutation-recipes.md` |
| `@SKPublished`, `SKPublishedValue`, `modelsPulisher`, `subscribe(models:)`, `SKBinding`, `SKBindingKey` | `reactive-binding-recipes.md` |
| `SectionArrayResultBuilder`, `SKCSectionCollector`, `SKWhen`, dynamic section indexes | `render-builder-recipes.md`, `section-assembly-identity-recipes.md` |
| `SKLoadViewProtocol`, `SKLoadNibProtocol`, `SKConfigurableView`, `preferredSize(limit:model:)`, `config(_:)` | `view-cell-container-recipes.md` |
| `SKAdaptive`, `SKConfigurableAdaptiveView`, `SKConfigurableAdaptiveMainView`, auto adaptive sizing | `adaptive-sizing-recipes.md` |
| `safeSize`, `cellSafeSize`, `supplementarySafeSize`, `SKSafeSizeProvider`, `SKSafeSizeTransform` | `safe-size-measurement-recipes.md` |
| `SKHighPerformanceStore`, `SKKVCache`, `SKCountedStore`, `displayedTimes`, `model(displayedAt:)`, cache invalidation | `cache-exposure-recipes.md` |
| `SKSelectionState`, `SKSelectionProtocol`, `SKSelectionWrapper`, `SKSelectionSequence`, `SKSelectionIdentifiableSequence` | `selection-ownership-recipes.md` |
| `SKCDragSelector`, `SKCRectSelectionManager`, `SKSelectionOverlayView`, `SKAutoScrollManager` | `drag-selection-recipes.md` |
| `onCellAction`, `onCellShould`, `SKCCellActionType`, `SKCCellShouldType`, `SKCSupplementaryActionType` | `interaction-state-recipes.md`, `delegate-interaction-recipes.md` |
| `SKCPrefetch`, `loadMorePublisher`, `onContextMenu`, `SKUIContextMenuResult`, `SKUIAction`, `move(from:to:)` | `prefetch-menu-reorder-recipes.md` |
| `setHeader`, `setFooter`, `set(supplementary:)`, `SKCSupplementary`, `SKSupplementaryKind`, `hiddenHeaderWhenNoItem` | `supplementary-recipes.md` |
| `indexTitle`, `indexTitleRow`, `sectionIndex`, collection index titles | `index-title-recipes.md` |
| `SKCollectionFlowLayout`, `SKCLayoutPlugins.Mode`, `SKCLayoutPlugin`, `setAttributes`, `SKCPluginAdjustAttributes`, `SKCPluginLayoutAttributesForElementsForward` | `layout-plugin-execution-recipes.md` |
| `SKCLayoutDecoration`, `SKCLayoutDecorationPlugin`, `SKCDecorationView`, decoration z-index | `layout-decoration-recipes.md` |
| `pinHeader`, `pinFooter`, pin distance, sticky supplementary | `navigation-scroll-recipes.md` |
| `SKScrollViewDelegateHandler`, `SKCDisplayTracker`, scroll observers, delegate forwarding | `navigation-scroll-recipes.md` |
| `SKPageViewController`, `SKPageManager`, `SKZoomableScrollView`, `SKZoomableContext` | `page-zoom-recipes.md` |
| `SKUIView`, `SKUIController`, `SKPreview`, `STCHostingCell`, `SKCHostingSection`, `SKCHostingCollectionView` | `swiftui-hosting-recipes.md` |
| `SKCSectionViewCell`, `SKCSingleSectionViewCell`, `wrapperToHorizontalSection` | `nested-section-cell-recipes.md` |
| `SKCAnyViewCell`, `SKWrapperView`, `SKCWrapperCell`, `SKCWrapperReusableView` | `runtime-view-wrapper-recipes.md` |
| `SKCRawSectionProtocol`, `SKCAnySectionProtocol`, `SKCAnySingleTypeSectionProtocol` | `raw-section-wrapper-recipes.md` |
| `SKCDelegate`, `SKCDelegateForward`, `SKCDataSource`, `SKCDataSourcePrefetching`, `SKCDelegateFlowLayout`, `SKHandleResult` | `forwarding-extension-recipes.md` |
| `SKPrint`, `SKPerformance`, `SKEnvironmentConfiguration`, `SKAnimationBox`, `SKWeakBox`, `SKIDBox`, `SKInout`, `SKActorBox`, `SKEventGroup` | `diagnostics-utility-recipes.md` |

When the mapped reference does not include the exact signature, inspect the source under `Sources/SectionUI` or `Sources/SectionKit`.
