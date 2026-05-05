# SectionUI.skills 交互事件与状态深挖更新

## 背景

本次继续更新通用 SectionUI 框架 skill，重点从下游重复出现的事件、曝光、选择、增量刷新、prefetch、context menu 与 reorder 组合中提炼通用 recipes。下游代码只作为取样来源，不在 skill 或项目文档中建立项目索引。

## 验收场景

1. `SectionUI.skills/SKILL.md` 能导航到交互与状态 recipes。
2. `SectionUI.skills/references/interaction-state-recipes.md` 能说明 action ownership、action context、exposure、mutation、reload/diff、selection、prefetch/load-more、context menu、reorder、publisher 和排障路径。
3. 文档不包含下游项目路径、项目名、业务模块名、源码清单、扫描命中数或页面索引。
4. 本次不修改 Swift 源码，不改变运行时行为。

## 泛化边界

- 可以沉淀：SectionUI API 语义、事件注册与清理、曝光计数生命周期、row-local 与 identity-based 状态选择、prefetch gating、context menu/reorder 机制、通用排障步骤。
- 不应沉淀：具体页面跳转、业务日志名、产品菜单项、项目目录、具体文件来源、统计数字。

## 更新内容

- 新增 `SectionUI.skills/references/interaction-state-recipes.md`。
- 更新 `SectionUI.skills/SKILL.md`，在生产实践导航和 Reference Documentation 中加入新 reference。
- 更新 2026-05-05 记忆，记录本次交互与状态层泛化结果。

## 验证策略

本次是 Markdown 技能文档更新，不涉及 Swift 源码行为变更，因此不运行 Xcode 测试。验证重点是：

- `rg` 审计新增 skill/reference/doc/memory 中不存在下游项目索引式内容。
- `qmd update` 与 `qmd embed` 成功。
- `qmd query --collection SectionKit` 能检索到新增 interaction/state recipes。
