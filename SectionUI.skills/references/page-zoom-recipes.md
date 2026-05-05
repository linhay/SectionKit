# Page And Zoom Recipes

This reference captures recipes for `SKPageManager`, `SKPageViewController`, `SKPageChildController`, `SKZoomableScrollView`, and `SKZoomableContext`. Keep it generic: no downstream project paths, product names, business module names, source-file indexes, scan statistics, page names, or business event names.

## Contents

- [When To Use](#when-to-use)
- [SKPageManager Contracts](#skpagemanager-contracts)
- [Child Identity And Cache](#child-identity-and-cache)
- [Selection And Current](#selection-and-current)
- [SKPageViewController Lifecycle](#skpageviewcontroller-lifecycle)
- [Zoomable Content](#zoomable-content)
- [Pan To Dismiss](#pan-to-dismiss)
- [Debug Checklist](#debug-checklist)
- [Framework Boundary](#framework-boundary)

## When To Use

1. Use `SKPageManager` / `SKPageViewController` when a screen owns controller-level paging.

2. Use nested horizontal sections when the UI is only a horizontal row inside a collection screen.

3. Use `SKZoomableScrollView` when one content view needs pinch/double-tap zoom, tap/long-press actions, and optional pan-to-dismiss behavior.

4. Do not use page controllers to model simple carousel cells. Page children are view controllers or boxed views with controller lifecycle.

## SKPageManager Contracts

5. `SKPageManager.Child` is identified by a string `id` and creates a child from `ChildContext`.

6. `Child.withController(id:_:)` accepts a `@MainActor` controller maker.

7. `Child(id:maker UIView)` wraps the returned view in an internal box controller.

8. `scrollDirection` maps to `UIPageViewController.NavigationOrientation` when `makePageController()` builds the container.

9. `spacing` is passed as `.interPageSpacing` when the page controller is created.

10. `configure(_:)` is a convenience for batching manager property setup before binding UI.

11. `setChilds`, `addChild`, `addChilds`, `removeChild`, `removeAllChilds`, `replaceChild`, and `insertChild` mutate the child list and return `Self`.

12. `clearCache()` removes cached child controllers without changing child definitions.

13. `unbind()` removes UI subscriptions, clears the weak container reference, marks the manager unbound, and clears cached controllers.

## Child Identity And Cache

14. Child controllers are cached by child `id`, not by index.

15. Keep child ids stable across insert, delete, and reorder when child controller state should survive.

16. Change a child id when the old controller state must not be reused for new content.

17. When `childs` changes after binding, cache entries whose ids are no longer present are filtered out.

18. `ChildContext.controller` is weak and may be nil before a child controller is created.

19. Do not rely on `ChildContext.index` as stable identity after insertions or removals. Use `id` for state, restoration, and analytics.

## Selection And Current

20. `selection` is an `@SKPublished` integer index.

21. `current` is a Combine `@Published` `ChildContext?`.

22. `current` is updated from `selection` and `childs` even before UI binding; in that phase its `controller` can be nil.

23. If `selection` is outside the child list, `current` becomes nil.

24. When UI is bound, changing `selection` sets the visible controller without animation and chooses forward/reverse direction from index comparison.

25. User-completed page gestures update `selection` from the displayed `SKPageChildController` model.

26. `isUpdatingSelection` prevents manager-driven selection updates and gesture-driven updates from feeding back into each other.

27. Clamp or validate external selection writes before assigning if the source can outlive the child list.

## SKPageViewController Lifecycle

28. `SKPageViewController` owns a manager and a lazily created `pageController`.

29. `set(manager:)` before `viewDidLoad` stores the manager and defers UI wiring.

30. `set(manager:)` after load rebuilds built-in subscriptions.

31. Changes to manager `scrollDirection`, `spacing`, or `childs` are debounced and send a reload request.

32. Reload requests are throttled and render only when `manager.childs` is not empty.

33. `renderUI()` removes the old page controller from parent and view hierarchy, recreates it via `manager.makePageController()`, and pins its view to the container edges.

34. Changing `scrollDirection` or `spacing` after binding rebuilds the page controller. Preserve child ids if controller state should survive that rebuild.

35. `SKPageChildController.config(_:)` removes the previous child controller before adding the new one.

36. `SKPageChildController.viewDidLoad` calls `config(model)` if the model was assigned before view loading.

## Zoomable Content

37. A zoomable content view conforms to `SKZoomableContentView` and exposes a `SKZoomableContext`.

38. `wrapperToZoomableView()` creates `SKZoomableScrollView` and configures it with the content view and its context.

39. `SKZoomableContext.size` drives content layout. Set it to the content's intrinsic media size or intended aspect-ratio size.

40. `SKZoomableContext.zoomScale` is updated from the underlying scroll view after layout and zooming.

41. `config(_:,context:)` clears old subscriptions, removes the old content view, removes the incoming content from any existing superview, and adds it to the internal scroll view.

42. `minimumZoomScale` and `maximumZoomScale` write through to the internal `UIScrollView`.

43. Layout resets zoom scale to `1.0`, computes fitted content size, centers the content, then writes the context zoom scale.

44. The default double-tap behavior zooms into the tap point when zoom scale is near 1, and resets to 1 otherwise.

45. If `doubleTapAction` is set, it replaces the default double-tap zoom behavior.

46. `singleTapGesture` is enabled only when `context.singleTapAction` is non-nil.

47. `longPressGesture` is enabled only when `context.longPressAction` is non-nil.

48. The single-tap gesture requires the double-tap gesture to fail.

49. Override `computeImageLayoutSize`, `computeImageLayoutOrigin`, or `computeImageLayoutCenter` only when the fitting and centering policy must change.

## Pan To Dismiss

50. `panToDismiss(_:)` installs a pan gesture on the provided container or the zoomable view itself.

51. Pan-to-dismiss starts only for downward vertical gestures when the scroll view is already at top offset.

52. Upward gestures, mostly horizontal gestures, and downward gestures while scrolled down do not begin.

53. During pan, the content frame scales from `1.0` down to `0.3` based on vertical translation.

54. `PanToDismiss.alphaPublisher` emits the squared scale while dragging.

55. On downward end velocity, `dismiss()` is called.

56. Otherwise alpha resets to 1 and the content animates back to the fitted center.

## Debug Checklist

57. Current page has nil controller: the manager has not created or cached that child controller yet.

58. Page state appears on the wrong item: child ids were reused for different content.

59. Selection write does nothing: the selection index is outside the current child list or matches the visible index.

60. Page controller does not reflect spacing or direction changes: verify the manager is bound through `SKPageViewController` or recreate via `makePageController()`.

61. Zoom content is zero-sized: `SKZoomableContext.size` is zero.

62. Double tap does not use default zoom: `context.doubleTapAction` is set and overrides the default.

63. Single tap does not fire: `singleTapAction` is nil or the double-tap recognizer has not failed yet.

64. Pan-to-dismiss does not start: gesture is upward, mostly horizontal, or the scroll view content offset is not at top.

65. Content jumps after resize: layout resets zoom to `1.0`; preserve custom zoom state outside the default layout path if needed.

## Framework Boundary

66. Keep generic page and zoom primitives in SectionUI: child identity, selection/current binding, controller lifecycle, zoom sizing, tap actions, and pan-to-dismiss mechanics.

67. Keep product page names, route handling, analytics payloads, image loading, and feature-specific chrome in integration layers.

