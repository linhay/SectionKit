# SwiftUI Hosting Recipes

This reference captures production recipes for SectionUI SwiftUI bridges, hosting cells, hosting sections, SwiftUI-backed collection previews, and ownership boundaries. Keep it generic: no downstream project paths, product names, business module names, source-file indexes, scan statistics, or page names.

## Contents

- [Bridge Selection](#bridge-selection)
- [UIView Bridge](#uiview-bridge)
- [UIViewController Bridge](#uiviewcontroller-bridge)
- [Hosting Cells](#hosting-cells)
- [Hosting Sections](#hosting-sections)
- [Hosting Collection View](#hosting-collection-view)
- [Preview Helpers](#preview-helpers)
- [Sizing And Performance](#sizing-and-performance)
- [State Ownership](#state-ownership)
- [Debug Checklist](#debug-checklist)
- [Framework Boundary](#framework-boundary)

## Bridge Selection

1. Use `SKUIView` when SwiftUI should host a UIKit `UIView`.

2. Use `SKUIController` when SwiftUI should host a UIKit `UIViewController`.

3. Use `STCHostingCell` / `SKCHostingSection` when SectionUI should render SwiftUI rows inside a collection view.

4. Use `SKCHostingCollectionView` when a SwiftUI surface should embed an entire SectionUI collection view.

5. Keep the direction explicit: UIKit-in-SwiftUI bridges have different ownership and update semantics than SwiftUI-in-SectionUI hosting cells.

6. Gate hosting-cell and hosting-section code with iOS 16+ availability. They rely on `UIHostingConfiguration`.

7. Prefer UIKit cells when the row already has a mature UIKit implementation with reuse, focus, edit, reorder, or performance tuning.

8. Prefer SwiftUI hosting when the row is maintained as SwiftUI, is value-model driven, and has deterministic sizing.

## UIView Bridge

9. `UIView.sk.toSwiftUI(make:update:)` builds an `SKUIView`.

10. `SKUIView.makeUIView(context:)` calls the supplied `make` closure once for the representable's UIKit view instance.

11. `SKUIView.updateUIView(_:context:)` calls the supplied `update` closure whenever SwiftUI updates the representable.

12. Keep expensive UIKit setup in `make`.

13. Keep SwiftUI-driven state synchronization in `update`.

14. Make `update` idempotent. SwiftUI may call it frequently and for reasons unrelated to model changes.

15. Do not create SectionUI managers repeatedly in `update`. Create the view/manager in `make`, then update sections or models deliberately.

## UIViewController Bridge

16. `UIViewController.sk.toSwiftUI(make:update:)` builds an `SKUIController`.

17. `SKUIController.makeUIViewController(context:)` calls `make` without passing SwiftUI context.

18. Use `updateUIViewController(_:context:)` for SwiftUI state changes after creation.

19. Keep controller ownership clear. SwiftUI owns the representable lifecycle, but the controller still owns its SectionUI manager and sections.

20. Avoid starting network requests from `updateUIViewController` without identity guards.

21. When embedding `SKCollectionViewController`, prefer using controller APIs that queue work until `viewDidLoad`, such as `reloadSections`.

## Hosting Cells

22. A SwiftUI row view must conform to `SKExistModelProtocol` and `View`.

23. The row view must provide `init(model:)`.

24. `Content.wrapperToCollectionCell()` returns `STCHostingCell<Content>.self`.

25. `STCHostingCell` conforms to `SKLoadViewProtocol` and `SKConfigurableAutoAdaptiveView`.

26. `STCHostingCell.config(_:)` writes the model into an observable store.

27. The SwiftUI content renders only when the store has a non-nil model; otherwise it renders `EmptyView`.

28. The cell uses `UIHostingConfiguration` with `.margins(.all, 0)`.

29. Put padding in the SwiftUI view or SectionUI section insets intentionally. Do not expect hosting configuration margins.

30. Keep hosted row models small and value-oriented.

31. Do not put UIKit owners, request clients, or navigation closures directly into hosted row models unless ownership is explicit.

32. If hosted content owns async work, make it cancellation-safe under cell reuse and model replacement.

## Hosting Sections

33. `SKCHostingSection` is an iOS 16+ `SKCAnySectionProtocol` wrapper over a SwiftUI row type and model array.

34. `SKCHostingSection.section` creates a new `SKCSingleTypeSection<STCHostingCell<Content>>` from the current models.

35. Because `section` is computed, do not expect the generated section instance to preserve selection, actions, displayed counters, or cancellables across accesses.

36. Use `SKCHostingSection` for simple SwiftUI-backed sections where full reload semantics are acceptable.

37. If incremental row updates, scroll targets, selection sequences, or display counters matter, create and hold the generated single-type section yourself.

38. Apply `style` in `SKCHostingSection` for section-level layout and SectionUI configuration.

39. Do not store side-effectful logic inside the `style` closure. It may run when a new section is produced.

40. If the SwiftUI row needs SectionUI actions, wire them on the generated section and keep that section stable.

## Hosting Collection View

41. `SKCHostingCollectionView` embeds an `SKCollectionViewController` in SwiftUI.

42. Its coordinator stores a manager reference and the last section wrappers.

43. `makeUIViewController` creates the controller, clears backgrounds, stores the manager, and reloads the coordinator's sections.

44. `updateUIViewController` reloads only when the incoming section wrappers' `objectIdentifier` list differs from the coordinator's previous list.

45. For stable section wrappers, changing internal model state without changing object identity may not trigger `SKCHostingCollectionView` reload.

46. For wrappers whose `objectIdentifier` is computed from a fresh `.section`, SwiftUI updates may reload more often than expected.

47. Choose section wrapper identity deliberately before embedding in SwiftUI.

48. When SwiftUI state changes models, either provide new section wrapper identity intentionally or update stable SectionUI section models through a clear owner.

49. Avoid doing both SwiftUI-driven full reloads and SectionUI local mutations for the same data.

50. Clear collection/controller backgrounds only when the SwiftUI parent is responsible for background rendering.

51. `@SectionArrayResultBuilder` initializer is useful for small embedded collections, but keep complex render logic in a named builder.

## Preview Helpers

52. `SKPreview.sections { ... }` wraps `SKCollectionViewController` in `SKUIController`.

53. The preview helper calls `reloadSections` on the created controller.

54. Use preview helpers for visual inspection and small examples.

55. Do not treat `SKPreview` as a production embedding API. Use `SKCHostingCollectionView` or explicit bridges for real SwiftUI screens.

56. Keep preview sections deterministic and self-contained.

57. Avoid using preview helpers to hide production dependencies such as request clients, route handlers, or app-wide environment state.

## Sizing And Performance

58. Hosted SwiftUI rows are measured through adaptive sizing and `UIHostingConfiguration` behavior.

59. Validate multiline text, dynamic type, async image placeholders, and conditional SwiftUI branches under the SectionUI safe-size limit.

60. If hosted row size is expensive, use SectionUI high-performance caching with stable identities.

61. Include size-affecting SwiftUI state in cache identity or invalidate cache when that state changes.

62. Avoid hosting for extremely dense or highly animated rows until profiling proves it is acceptable.

63. If a hosted row clips, inspect SwiftUI layout first, then SectionUI safe size, then cache state.

64. Do not mix hosted SwiftUI rows and UIKit rows in one section unless their sizing policy is clear and tested.

## State Ownership

65. Pick one source of truth: SwiftUI state, SectionUI section models, or a shared view model.

66. Avoid feedback loops where SwiftUI state updates SectionUI and SectionUI publishers immediately write back to the same SwiftUI state.

67. Use identity guards when bridging `@SKPublished`, Combine, and SwiftUI state.

68. Keep SectionUI action handlers near the section owner, even when the visible row is SwiftUI.

69. Navigation and product commands should stay in the app layer, not inside hosted row models.

70. If SwiftUI owns the screen, keep the SectionUI manager behind a small bridge object rather than scattering manager calls across SwiftUI views.

## Debug Checklist

71. SwiftUI row never appears: verify `SKExistModelProtocol.init(model:)`, non-nil model, iOS 16+ availability, and section binding.

72. Hosted row has unexpected padding: remember `UIHostingConfiguration` margins are set to zero; inspect SwiftUI padding and section inset.

73. Hosted row size is zero: inspect SwiftUI layout under the given safe-size limit and verify adaptive measurement has a model.

74. Embedded collection does not update: check whether `SKCHostingCollectionView` saw changed `objectIdentifier` values.

75. Embedded collection reloads too often: inspect wrappers whose `objectIdentifier` is computed from newly created sections.

76. Selection state resets: `SKCHostingSection.section` creates new section instances; hold a stable section if state must survive.

77. SwiftUI update loop: add identity guards between SwiftUI state, `@SKPublished`, and section subscriptions.

78. Preview differs from production: `SKPreview` is a convenience wrapper, not the same ownership path as a production SwiftUI screen.

## Framework Boundary

79. SectionUI can provide bridge primitives, hosting cells, hosting sections, and preview helpers.

80. The app layer owns SwiftUI state architecture, routing, request lifecycles, dependency injection, and design-system-specific SwiftUI components.

81. Keep SwiftUI hosting examples anonymous and framework-level. Do not encode business routes, event names, module names, product state names, downstream source locations, or scan statistics into this skill.
