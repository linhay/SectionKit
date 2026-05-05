# SectionUI.skills Delegate 交互层深挖更新

## 背景

本次继续更新通用 SectionUI 框架 skill，重点从 UIKit delegate 交互面提炼 delegate interaction recipes，覆盖 highlight/select gates、primary action、display lifecycle、focus、editing、spring-load、multiple selection、context menu、reorder gate 与 section subclassing 边界。下游代码只作为取样来源，不在 skill 或项目文档中建立项目索引。

## 来源依据

- 当前框架源码：`SKCDelegate`、`SKCDelegateProtocol`、`SKCCellActionType`、`SKCCellShouldType`、`SKCSupplementaryActionType`、`SKCContextMenuContext`、`SKUIContextMenuResult`、`SKUIAction`、`SKCSingleTypeSection` delegate override。
- 已沉淀的交互状态、forwarding、manager transaction 与拖拽框选 recipes。

## 结论

- SectionUI 的 UIKit delegate 行为由 manager forwarding 路由到当前 bound section。
- `onCellAction` 只覆盖常用 action；`onCellShould` 目前只覆盖 `.move`。
- `shouldSelect`、`shouldDeselect`、primary action、focus、editing、spring-load、UIKit multiple-selection gate 等需要通过自定义/子类化 section override 表达。
- context menu 是 row/model 级能力，`SKCContextMenuContext` 不支持 `view()`，iOS 16 多 item/background menu 需要 integration-level forwarding。
- 这类细节如果不单独沉淀，agents 容易误用 controller delegate 或假设存在不存在的 fluent helper。

## 验收场景

1. `SectionUI.skills/SKILL.md` 能导航到 delegate interaction recipes。
2. `SectionUI.skills/references/delegate-interaction-recipes.md` 能说明 delegate routing、selection/highlight、primary action、display lifecycle、focus/editing、spring-load、multiple selection、context menu、reorder gate、subclassing boundary 与排障路径。
3. 文档不包含下游项目路径、项目名、业务模块名、源码清单、扫描命中数或页面索引。
4. 本次不修改 Swift 源码，不改变运行时行为。

## 泛化边界

- 可以沉淀：SectionUI delegate routing 语义、UIKit gate 默认值、section override 边界、context menu 单 item 语义、reorder move gate、debug checklist。
- 不应沉淀：具体业务导航、菜单内容、权限规则、页面状态、项目目录、下游源码位置、扫描统计、业务交互文案。

## 更新内容

- 新增 `SectionUI.skills/references/delegate-interaction-recipes.md`。
- 更新 `SectionUI.skills/SKILL.md`，在生产实践导航和 Reference Documentation 中加入新 reference。
- 更新 2026-05-05 记忆，记录本次 delegate 交互层泛化结果。

## 验证策略

本次是 Markdown 技能文档更新，不涉及 Swift 源码行为变更，因此不运行 Xcode 测试。验证重点是：

- `rg` 审计新增 skill/reference/doc/memory 中不存在下游项目索引式内容。
- `qmd update` 与 `qmd embed` 成功。
- `qmd query --collection SectionKit` 能检索到新增 delegate interaction recipes。
