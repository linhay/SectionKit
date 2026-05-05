# SectionUI.skills SwiftUI Hosting 深挖更新

## 背景

本次继续更新通用 SectionUI 框架 skill，重点从 SwiftUI bridge 与 hosting 能力中提炼 SwiftUI hosting recipes，覆盖 `SKUIView`、`SKUIController`、`STCHostingCell`、`SKCHostingSection`、`SKCHostingCollectionView`、`SKPreview`、sizing/performance 与 SwiftUI/SectionUI state ownership。下游代码只作为取样来源，不在 skill 或项目文档中建立项目索引。

## 来源依据

- 当前框架源码：`SKUIView`、`SKUIController`、`SKPreview`、`SKCHostingCollectionView`、`SKCHostingSection`、`STCHostingCell`、`SKExistModelProtocol`。
- 已沉淀的 view/cell/container、rendering/performance、manager transaction 与 reactive binding recipes。

## 结论

- SwiftUI bridge 需要区分 UIKit-in-SwiftUI、SwiftUI-in-SectionUI row、SwiftUI embedding whole SectionUI collection 三条路径。
- `STCHostingCell` 是 iOS 16+ 能力，依赖 `UIHostingConfiguration` 且 margins 为零。
- `SKCHostingSection.section` 是 computed section，适合 full reload 语义；如果需要选择、滚动、增量更新或曝光计数持久性，应自行持有稳定 section。
- `SKCHostingCollectionView` 通过 section wrapper `objectIdentifier` 判断 SwiftUI update 是否 reload，稳定 identity 与 computed section identity 都需要明确设计。
- `SKPreview` 是预览辅助，不应被描述成生产 embedding API。

## 验收场景

1. `SectionUI.skills/SKILL.md` 能导航到 SwiftUI hosting recipes。
2. `SectionUI.skills/references/swiftui-hosting-recipes.md` 能说明 bridge selection、UIView bridge、UIViewController bridge、hosting cell、hosting section、hosting collection view、preview helper、sizing/performance、state ownership 与排障路径。
3. 文档不包含下游项目路径、项目名、业务模块名、源码清单、扫描命中数或页面索引。
4. 本次不修改 Swift 源码，不改变运行时行为。

## 泛化边界

- 可以沉淀：SectionUI SwiftUI bridge API 语义、iOS availability、hosting identity、computed section 风险、safe-size/sizing、state ownership、debug checklist。
- 不应沉淀：具体 SwiftUI 业务组件、页面名称、路由、请求客户端、设计系统命名、项目目录、下游源码位置、扫描统计。

## 更新内容

- 新增 `SectionUI.skills/references/swiftui-hosting-recipes.md`。
- 更新 `SectionUI.skills/SKILL.md`，在生产实践导航和 Reference Documentation 中加入新 reference。
- 更新 2026-05-05 记忆，记录本次 SwiftUI hosting 泛化结果。

## 验证策略

本次是 Markdown 技能文档更新，不涉及 Swift 源码行为变更，因此不运行 Xcode 测试。验证重点是：

- `rg` 审计新增 skill/reference/doc/memory 中不存在下游项目索引式内容。
- `qmd update` 与 `qmd embed` 成功。
- `qmd query --collection SectionKit` 能检索到新增 SwiftUI hosting recipes。
