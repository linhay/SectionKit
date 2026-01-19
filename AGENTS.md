# PROJECT KNOWLEDGE BASE

**Generated:** 2026-01-19
**Framework:** SectionKit (Swift)

## OVERVIEW
Data-driven `UICollectionView` framework for building flexible, reusable lists.
- **Core**: Protocol-oriented architecture separating Data, Logic (Section), and View.
- **UI**: Declarative API, plugin-based layouts, and SwiftUI compatibility.

## STRUCTURE
```
.
├── Sources/
│   ├── SectionKit/       # Core Logic: Manager, Protocols, Base Sections
│   └── SectionUI/        # UI Layer: CollectionView, Layouts, Plugins, Wrappers
├── Example/              # Usage Patterns & Demos
└── .agent/skills/        # AI Assistant Context (Best Practices)
```

## WHERE TO LOOK
| Task | Location | Notes |
|------|----------|-------|
| **Core Logic** | `Sources/SectionKit` | `SKCManager`, `SKCSectionProtocol` |
| **UI Components** | `Sources/SectionUI` | `SKCollectionView`, `SKWrapperCell` |
| **Layouts** | `Sources/SectionUI/.../FlowLayout` | `SKCollectionFlowLayout`, Plugins |
| **Usage Demos** | `Example/` | Copy-pasteable patterns |

## KEY CONCEPTS
| Concept | Role |
|---------|------|
| **SKCManager** | Orchestrator. Acts as DataSource/Delegate. |
| **Section** | Unit of logic. Manages models & cell config. (`SKCSingleTypeSection`) |
| **Wrapper** | `SKCWrapperCell` wraps any `UIView` into a Collection Cell. |
| **Plugin** | Extends layout (Pinning, Decoration, Alignment). |

## CONVENTIONS
- **Testing**: Uses modern **Swift Testing** framework (`import Testing`).
- **AI Context**: Check `.agent/skills` for detailed implementation guides.
- **Naming**: `.sk` namespace for extensions.

## ANTI-PATTERNS (THIS PROJECT)
- **Memory**: NEVER capture `self` strongly in section closures (`.onCellAction`).
- **Layout**: NEVER mix `SKCSectionPinOptions` with FlowLayout's own pinning.
- **Performance**: NEVER instantiate formatters in `config(_:)`. Use `static`.
- **Logic**: NEVER subclass `SKCSingleTypeSection` just for config; use the fluent API.

## COMMANDS
```bash
# Build
swift build

# Test (Manual)
swift test

# Lint (Manual)
pod lib lint SectionUI.podspec
```

## NOTES
- **Shadow Module**: `Sources/SectionFoundation` is currently empty/unused.
- **Versioning**: Check `versions/` dir for changelogs (non-standard).
