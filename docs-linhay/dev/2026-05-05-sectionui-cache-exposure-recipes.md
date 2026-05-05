# SectionUI.skills Cache / Exposure 深挖更新

## 背景

本次继续更新通用 SectionUI 框架 skill，重点补齐 `SKHighPerformanceStore`、`SKKVCache`、`SKCountedStore`、`displayedTimes` 与 `model(displayedAt:)` 的缓存身份、失效所有权和曝光计数语义。下游代码只作为匿名取样来源，不在 skill 或项目文档中建立项目索引。

## 验收场景

1. `SectionUI.skills/SKILL.md` 能导航到 cache exposure recipes。
2. `SectionUI.skills/references/cache-exposure-recipes.md` 能说明 size cache key、manual invalidation、`SKKVCache` 边界、row-based display count、reset strategy 与排障路径。
3. 旧 reference 中不再示例 `highPerformanceStore?.removeValue`、`highPerformance?.clear()`、`displayedAt: .at(...)`、`context.displayedTimes`、`context.displayCount` 或 `displayedTimes.reset(row:)`。
4. 文档不包含下游项目路径、项目名、业务模块名、源码清单、扫描命中数或页面索引。
5. 本次不修改 Swift 源码，不改变运行时行为。

## 泛化边界

- 可以沉淀：cache ID 选型、limit size 作为 key、外部持有 store 以失效缓存、`SKKVCache` count/eviction/expiration 边界、row-based exposure reset timing。
- 不应沉淀：具体埋点事件名、业务 ID、页面曝光规则、下游项目路径、文件来源、扫描统计。

## 更新内容

- 新增 `SectionUI.skills/references/cache-exposure-recipes.md`。
- 更新 `SectionUI.skills/SKILL.md`，在生产实践导航和 Reference Documentation 中加入新 reference。
- 修正 `performance.md`、`section-advanced-2.md`、`MISSING_FEATURES.md`、`layout-plugins.md`、`advanced-sections.md` 与 `production-tips.md` 中过期或不准确的高性能缓存/曝光示例。
- 更新 2026-05-05 记忆，记录本次 cache/exposure 层泛化结果。

## 验证策略

本次是 Markdown 技能文档更新，不涉及 Swift 源码行为变更，因此不运行 Xcode 测试。验证重点是：

- `rg` 审计 skill/reference/doc/memory 中不存在下游项目索引式内容。
- `rg` 审计旧 reference 中不再包含过期 cache/exposure API 示例。
- `qmd update` 与 `qmd embed` 成功。
- `qmd query --collection SectionKit` 能检索到新增 cache exposure recipes。
