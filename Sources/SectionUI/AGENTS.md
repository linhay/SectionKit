# PROJECT KNOWLEDGE BASE (SectionUI)

**Generated:** 2026-01-19
**Domain:** UI Layer & Layout Engine

## OVERVIEW
`SectionUI` is the rendering layer of `SectionKit`. It transforms abstract `Section` logic into visual lists using a specialized `UICollectionView` subclass and a plugin-driven layout engine.

## LAYOUT ENGINE
The core of `SectionUI` is `SKCollectionFlowLayout`, which extends `UICollectionViewFlowLayout` with a modular plugin architecture.

- **SKCollectionFlowLayout**: Manages layout attributes by delegating to active plugins. Supports advanced features like custom decoration views and attribute filtering.
- **Plugins (`SKCLayoutPlugin`)**: 
  - **Decoration**: `SKCLayoutDecorationPlugin` for section backgrounds, borders, and shadows.
  - **Pinning**: `SectionHeadersPinToVisibleBounds` logic for sticky headers.
  - **Alignment**: `HorizontalAlignmentPlugin` and `VerticalAlignmentPlugin` for precise cell positioning (e.g., left-aligned tags).
  - **Fixes**: `FixSupplementaryViewSize` and `FixSupplementaryViewInset` to solve common UIKit layout glitches.

## COMPONENT PATTERNS
`SectionUI` promotes "View-first" development through wrappers, ensuring UI components remain decoupled from `UICollectionViewCell` specifics.

### Wrappers
- **SKCWrapperCell<View>**: Wraps any `UIView` (conforming to `SKConfigurableView`) into a `UICollectionViewCell`.
  - *Pattern*: Define logic in a plain `UIView`, then use `.sk.wrapperToCollectionCell()` to use it in a section.
- **SKCWrapperReusableView**: Similar wrapper for supplementary views (Headers/Footers).

### SwiftUI Integration
- **SKCHostingSection**: Allows using SwiftUI `View`s as cells within an `SKCollectionView`.
- **SKUIView**: A robust `UIViewRepresentable` utility for embedding UIKit-based list views into SwiftUI hierarchies.
- **SKBindingKey**: Reactive key system for synchronizing state between models and views.

## KEY CLASSES
| Class | Role |
|-------|------|
| `SKCollectionView` | Root view. Automatically manages an `SKCManager` and `SKCollectionFlowLayout`. |
| `SKCollectionFlowLayout` | Plugin-aware layout engine. |
| `SKCWrapperCell` | Generic cell wrapper for `UIView`. |
| `SKCHostingCell` | Generic cell wrapper for SwiftUI `View`. |

## USAGE TIPS
- **Plugins**: Enable plugins via `collectionView.set(pluginModes: ...)` or per-section via `SKCSectionLayoutPluginProtocol`.
- **Sizing**: Use `SKLoadViewProtocol.preferredSize(limit:model:)` for accurate self-sizing calculations.
- **Decoration**: Prefer `SKCLayoutDecoration` over manual background views for performance and flexibility.
