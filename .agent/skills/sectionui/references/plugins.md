# Layout Plugins

SectionUI provides a powerful plugin system to modify `UICollectionViewFlowLayout` behavior without subclassing. This allows you to easily implement complex layouts like left-aligned tags, sticky headers, or decorations.

## Usage

You can apply plugins globally to the `SKCollectionView` or locally to a specific Section.

### Global Plugins
Apply plugins to the collection view to affect all sections or specific ones globally.

```swift
sectionView.set(pluginModes: .left, .fixSupplementaryViewInset(.all))
```

### Section Plugins (Recommended)

When working with `SKCSingleTypeSection` (or any section conforming to `SKCSectionLayoutPluginProtocol`), it is **highly recommended** to configure plugins directly on the section instance.

This API is more declarative and keeps the configuration close to the section definition.

```swift
// 1. Alignment
section.addLayoutPlugins(.left)

// 2. Decoration (Simplified API)
section.set(decoration: MyBackgroundView.self, model: myModel)

// 3. Custom / Multiple
section.addLayoutPlugins(.verticalAlignment(.center), .attributes([...]))
```

> **Note**: `SKCSingleTypeSection` fully supports this protocol.

## Available Plugins

### 1. Alignment
Control the horizontal alignment of cells. Useful for "Tag" or "Chip" layouts that should align to the left instead of justified.

- **`.left`**: Align cells to the left.
- **`.right`**: Align cells to the right.
- **`.centerX`**: Center cells horizontally.

```swift
sectionView.set(pluginModes: .left)
```

### 2. Supplementary View Fixes
Fix common `UICollectionViewFlowLayout` issues with headers and footers.

- **`.fixSupplementaryViewInset(direction)`**: Fixes the issue where headers/footers respect `sectionInset`.
- **`.fixSupplementaryViewSize`**: Ensures headers/footers respect their calculated size.

### 3. Decorations

Decorations allow you to add visual elements (like backgrounds) behind your sections or cells.

For detailed usage, see **[Decorations](decorations.md)**.

## Advanced: Custom Plugins

Plugins work by intercepting `layoutAttributesForElements(in:)` and other layout methods. 
To create a custom plugin, check `SKCLayoutPlugin` protocol in `Sources`.
