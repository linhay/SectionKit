# SectionUI.skills 条件渲染与 Builder 深挖更新

## 背景

本次继续更新通用 SectionUI 框架 skill，重点补齐 `SectionArrayResultBuilder`、`SKCSectionCollector`、`SKWhen`、`SKBindingKey` 与 SwiftUI hosted collection builder 的通用渲染组装语义。下游代码只作为匿名取样来源，不在 skill 或项目文档中建立项目索引。

## 验收场景

1. `SectionUI.skills/SKILL.md` 能导航到 render builder recipes。
2. `SectionUI.skills/references/render-builder-recipes.md` 能说明 result builder、collector、predicate、动态 section index binding、SwiftUI builder identity 与排障路径。
3. 文档不包含下游项目路径、项目名、业务模块名、源码清单、扫描命中数或页面索引。
4. 本次不修改 Swift 源码，不改变运行时行为。

## 泛化边界

- 可以沉淀：SectionUI 条件组装语义、builder/collector 选型、optional section 过滤、predicate 组合、`SKBindingKey` 动态解析、SwiftUI hosted collection reload identity。
- 不应沉淀：具体页面模块顺序、业务状态名、路由、业务埋点、下游项目路径、文件来源、扫描统计。

## 更新内容

- 新增 `SectionUI.skills/references/render-builder-recipes.md`。
- 更新 `SectionUI.skills/SKILL.md`，在生产实践导航和 Reference Documentation 中加入新 reference。
- 更新 2026-05-05 记忆，记录本次条件渲染与 builder 层泛化结果。

## 验证策略

本次是 Markdown 技能文档更新，不涉及 Swift 源码行为变更，因此不运行 Xcode 测试。验证重点是：

- `rg` 审计 skill/reference/doc/memory 中不存在下游项目索引式内容。
- `qmd update` 与 `qmd embed` 成功。
- `qmd query --collection SectionKit` 能检索到新增 render builder recipes。
