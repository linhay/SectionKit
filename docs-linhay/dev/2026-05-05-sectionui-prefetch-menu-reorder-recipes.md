# SectionUI.skills Prefetch / Menu / Reorder 深挖更新

## 背景

本次继续更新通用 SectionUI 框架 skill，重点补齐 section prefetch、load more、context menu、`SKUIAction`、`SKUIContextMenuResult`、`onCellShould(.move)` 与 reorder 默认行为的精确语义。下游代码只作为匿名取样来源，不在 skill 或项目文档中建立项目索引。

## 验收场景

1. `SectionUI.skills/SKILL.md` 能导航到 prefetch menu reorder recipes。
2. `SectionUI.skills/references/prefetch-menu-reorder-recipes.md` 能说明 section-local row、load-more gating、context menu routing、async action error handling、move gate 与 reorder persistence。
3. 旧 reference 中不再示例 `.canMove`、把 section prefetch rows 误写为 `IndexPath`、或声称 cross-section move 自动完成。
4. 文档不包含下游项目路径、项目名、业务模块名、源码清单、扫描命中数或页面索引。
5. 本次不修改 Swift 源码，不改变运行时行为。

## 泛化边界

- 可以沉淀：prefetch row 语义、pagination gate、model identity cancellation、context menu first non-nil、`SKUIAction` error ownership、same-section swap、cross-section move 边界。
- 不应沉淀：具体网络客户端、图片库、业务菜单标题、权限规则、页面状态名、下游项目路径、文件来源、扫描统计。

## 更新内容

- 新增 `SectionUI.skills/references/prefetch-menu-reorder-recipes.md`。
- 更新 `SectionUI.skills/SKILL.md`，在生产实践导航和 Reference Documentation 中加入新 reference。
- 修正 `section-advanced.md`、`reactive.md`、`performance.md` 中 prefetch/reorder 的过期或不准确示例。
- 更新 2026-05-05 记忆，记录本次 prefetch/menu/reorder 层泛化结果。

## 验证策略

本次是 Markdown 技能文档更新，不涉及 Swift 源码行为变更，因此不运行 Xcode 测试。验证重点是：

- `rg` 审计 skill/reference/doc/memory 中不存在下游项目索引式内容。
- `rg` 审计旧 reference 中不再包含 `.canMove` 或将 section prefetch rows 命名为 `indexPaths` 的示例。
- `qmd update` 与 `qmd embed` 成功。
- `qmd query --collection SectionKit` 能检索到新增 prefetch menu reorder recipes。
