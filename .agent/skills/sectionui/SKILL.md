---
name: sectionui
description: Master skill for SectionUI, a powerful and flexible framework for building complex collection views in Swift.
---

# SectionUI Master Skill

SectionUI is a highly modularized framework designed to simplify the creation of complex, high-performance UICollectionView layouts and interactions. This skill consolidates several specialized sub-skills for easier access.

## Architecture & Components

SectionUI is organized into several key modules, each focusing on a specific aspect of collection view management:

- **[Cell Configuration](file:///Users/linhey/Desktop/丁香园/SectionKit/.agent/skills/sectionui/references/cell.md)**: Master protocols and utilities for UICollectionViewCells (`SKLoadViewProtocol`, `SKConfigurableView`, `SKLoadNibProtocol`, `SKAdaptive`).
- **[Common Utilities](file:///Users/linhey/Desktop/丁香园/SectionKit/.agent/skills/sectionui/references/common.md)**: Universal helpers for View Wrapping, Reactive Bindings, and Conditional Logic.
- **[Page Management](file:///Users/linhey/Desktop/丁香园/SectionKit/.agent/skills/sectionui/references/page.md)**: Memory-efficient paginated view management using `SKPageViewController` and `SKPageManager`.
- **[SwiftUI Previews](file:///Users/linhey/Desktop/丁香园/SectionKit/.agent/skills/sectionui/references/preview.md)**: Tools for generating SwiftUI Previews for SectionUI components.
- **[SKCSingleTypeSection](file:///Users/linhey/Desktop/丁香园/SectionKit/.agent/skills/sectionui/references/single-type-section.md)**: Detailed documentation for the most frequently used section type (Diff, Pagination, Actions, etc.).
- **[Section Orchestration](file:///Users/linhey/Desktop/丁香园/SectionKit/.agent/skills/sectionui/references/section.md)**: Advanced features for `SKCManager`, `SKCollectionViewController`, and Layout Plugins.
- **[Selection Management](file:///Users/linhey/Desktop/丁香园/SectionKit/.agent/skills/sectionui/references/selection.md)**: Comprehensive selection logic (single/multiple, drag-to-select, reactive state).

## Usage

When working with SectionUI, you can refer to the specific documentation above based on your current task.

### Quick Start Example

You can find numerous examples of these components in the [examples/](file:///Users/linhey/Desktop/丁香园/SectionKit/.agent/skills/sectionui/examples) directory.

### Key Protocols

| Protocol | Description |
| :--- | :--- |
| `SKConfigurableView` | Standardizes how views are populated with data models. |
| `SKLoadViewProtocol` | Simplifies programmed UI setup. |
| `SKLoadNibProtocol` | Simplifies XIB/Nib setup. |
| `SKAdaptive` | Handles dynamic layout adjustments. |
| `SKCSectionProtocol` | Core protocol for all section types. |

## References

For detailed instructions on each component, please see the documents in the `references/` directory.
