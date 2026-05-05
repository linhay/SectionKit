# SectionUI.skills 布局插件与 Decoration 深挖更新

## 背景

本次继续更新通用 SectionUI 框架 skill，目标是把下游大量重复出现的布局插件、Supplementary 修正、Decoration 背景与 z-index 排障经验提炼成框架级 recipes。下游仓库只作为取样来源，不在 skill 或项目文档中建立索引。

## 验收场景

1. `SectionUI.skills/SKILL.md` 能导航到布局与 Decoration recipes。
2. `SectionUI.skills/references/layout-decoration-recipes.md` 能说明插件作用域、执行顺序、冲突规则、对齐、Supplementary size/inset、Decoration frame、z-index 和排障路径。
3. 文档不包含下游项目路径、项目名、业务模块名、源码清单、扫描命中数或页面索引。
4. 本次不修改 Swift 源码，不改变运行时行为。

## 泛化边界

- 可以沉淀：SectionUI API 语义、插件优先级、section-level 与 collection-level 的选型、`SKBindingKey` 绑定规则、Decoration frame 计算、z-index 策略、常见排障步骤。
- 不应沉淀：取样项目页面结构、业务模块命名、品牌视觉参数、项目目录、具体文件来源、统计数字。

## 更新内容

- 新增 `SectionUI.skills/references/layout-decoration-recipes.md`。
- 更新 `SectionUI.skills/SKILL.md`，在生产实践导航和 Reference Documentation 中加入新 reference。
- 新增 2026-05-05 记忆，记录本次泛化边界与验证要求。

## 验证策略

本次是 Markdown 技能文档更新，不涉及 Swift 源码行为变更，因此不运行 Xcode 测试。验证重点是：

- `rg` 审计新增 skill/reference/doc/memory 中不存在下游项目索引式内容。
- `qmd update` 与 `qmd embed` 成功。
- `qmd query --collection SectionKit` 能检索到新增 recipes。
