# SectionUI.skills Layout Plugin 执行语义深挖更新

## 背景

本次继续更新通用 SectionUI 框架 skill，重点补齐 `SKCollectionFlowLayout`、`SKCLayoutPlugins.Mode`、section-level layout plugins、`setAttributes`、full-attribute forward、layout store 与 invalidation 的执行语义。下游代码只作为匿名取样来源，不在 skill 或项目文档中建立项目索引。

## 验收场景

1. `SectionUI.skills/SKILL.md` 能导航到 layout plugin execution recipes。
2. `SectionUI.skills/references/layout-plugin-execution-recipes.md` 能说明 mode priority、collection-level vs section-level scope、attribute adjustment、layoutAttributes forward、invalidation 与 cancellation。
3. `SectionUI.skills/references/layout-plugins.md` 中旧的 section-level supplementary fix、closure-style adjust size、protocol-style attribute plugin 示例已修正为当前 API。
4. 文档不包含下游项目路径、项目名、业务模块名、源码清单、扫描命中数或页面索引。
5. 本次不修改 Swift 源码，不改变运行时行为。

## 泛化边界

- 可以沉淀：layout mode 排序、插件合并/冲突、collection/section scope、attribute mutation、layout cache、invalidation、pin forward 取消与调试步骤。
- 不应沉淀：具体页面视觉 preset、业务模块顺序、品牌颜色/圆角/阴影、下游项目路径、文件来源、扫描统计。

## 更新内容

- 新增 `SectionUI.skills/references/layout-plugin-execution-recipes.md`。
- 更新 `SectionUI.skills/SKILL.md`，在生产实践导航和 Reference Documentation 中加入新 reference。
- 修正 `SectionUI.skills/references/layout-plugins.md` 与 `advanced-production-tips.md` 中过期或不准确的 layout plugin 示例。
- 更新 2026-05-05 记忆，记录本次 layout plugin 执行层泛化结果。

## 验证策略

本次是 Markdown 技能文档更新，不涉及 Swift 源码行为变更，因此不运行 Xcode 测试。验证重点是：

- `rg` 审计 skill/reference/doc/memory 中不存在下游项目索引式内容。
- `rg` 审计旧 layout plugin reference 中不再包含过期协议式 attribute plugin 或 section-level supplementary singleton 示例。
- `qmd update` 与 `qmd embed` 成功。
- `qmd query --collection SectionKit` 能检索到新增 layout plugin execution recipes。
