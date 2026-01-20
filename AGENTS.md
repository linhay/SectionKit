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

## RELEASE WORKFLOW
发布脚本位于 `shells/xctemplate/`，详细文档见该目录的 `README.md`。

### 正式发布新版本
```bash
# 完整发布流程（版本号更新 → Git 标签 → GitHub Release → CocoaPods）
./shells/xctemplate/release.sh <version>

# 示例：发布 2.5.4 版本
./shells/xctemplate/release.sh 2.5.4

# 演练模式（不执行实际操作）
./shells/xctemplate/release.sh 2.5.4 --dry-run
```

### 异常恢复流程
```bash
# 场景 1：CocoaPods 发布步骤失败（Git 和 GitHub 已完成）
./shells/xctemplate/resume_release.sh

# 场景 2：SectionKit2 已发布，只需发布 SectionUI（刚发布，需等待）
./shells/xctemplate/publish_sectionui_only.sh

# 场景 3：SectionKit2 已发布 20 分钟以上，直接发布 SectionUI
./shells/xctemplate/publish_sectionui_only.sh --skip-wait
```

### 发布流程说明
1. **SectionKit2** 先发布（基础框架）
2. **等待 20 分钟**（CocoaPods CDN 同步）
3. **SectionUI** 后发布（依赖 SectionKit2）

**依赖要求**：`git`, `gh` (GitHub CLI), `bundle`, `pod`, `zip`

## NOTES
- **Shadow Module**: `Sources/SectionFoundation` is currently empty/unused.
- **Versioning**: Check `versions/` dir for changelogs (non-standard).
