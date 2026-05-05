# SectionUI.skills Index Title 深挖更新

## 背景

本次继续更新通用 SectionUI 框架 skill，重点补齐 `indexTitle`、`indexTitleRow`、`sectionIndex`、iOS 14+ collection index titles 与 data-source forwarding 的精确语义。下游代码只作为匿名取样来源，不在 skill 或项目文档中建立项目索引。

## 来源与结论

- 来源：SectionUI 框架源码中的 `SKCDataSourceProtocol`、`SKCDataSource`、`SKCDataSourceForward`、`SKCSingleTypeSection.indexTitle`，以及匿名下游重复使用形态。
- 结论：index title 应沉淀为 section navigation metadata：从最终 bound sections 收集非空标题，按 filtered title position 定位到当前 `sectionInjection.index` 和 `indexTitleRow`；不沉淀下游页面分组、业务分类或源文件清单。

## 验收场景

1. `SectionUI.skills/SKILL.md` 能导航到 index title recipes。
2. `SectionUI.skills/references/index-title-recipes.md` 能说明 contract、single-type section、custom section、lookup semantics、forwarding、reload/identity 与排障路径。
3. 旧 `MISSING_FEATURES.md` 与 `section-advanced-2.md` 中的 index-title 示例不再使用不存在的 `manager.update`。
4. 文档不包含下游项目路径、项目名、业务模块名、源码清单、扫描命中数或页面索引。
5. 本次不修改 Swift 源码，不改变运行时行为。

## 泛化边界

- 可以沉淀：iOS 14+ data-source contract、`indexTitle` 收集规则、`indexTitleRow` 默认值、自定义 section target row、forwarding 覆盖边界、reload timing。
- 不应沉淀：具体字母表/分类表、业务分组、城市/联系人/频道等产品概念、页面顺序、下游路径、文件来源列表或扫描统计。

## 更新内容

- 新增 `SectionUI.skills/references/index-title-recipes.md`。
- 更新 `SectionUI.skills/SKILL.md`，在生产实践导航和 Reference Documentation 中加入新 reference。
- 更新 `SectionUI.skills/references/composition-styling-recipes.md`，把深入 index-title 细节导向新 reference。
- 校正 `SectionUI.skills/references/MISSING_FEATURES.md` 与 `SectionUI.skills/references/section-advanced-2.md` 中的 `manager.update` 示例为 `manager.reload`。
- 更新 2026-05-05 记忆，记录本次 index title 泛化结果。

## 验证策略

本次是 Markdown 技能文档更新，不涉及 Swift 源码行为变更，因此不运行 Xcode 测试。验证重点是：

- `rg` 审计 skill/reference/doc/memory 中不存在下游项目索引式内容。
- `rg` 审计 index-title skill docs 中不再出现旧 manager update 示例。
- `qmd update` 与 `qmd embed` 成功。
- `qmd query --collection SectionKit` 能检索到新增 index title recipes。
