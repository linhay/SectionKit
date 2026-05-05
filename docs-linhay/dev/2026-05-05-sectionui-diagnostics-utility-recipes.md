# SectionUI.skills 诊断与工具层深挖更新

## 背景

本次继续更新通用 SectionUI 框架 skill，重点从框架通用工具层提炼 diagnostics 与 utility recipes，覆盖 DEBUG 输出、性能计时、尺寸缓存、计数器、环境对象、动画值盒、弱引用包装、identity box、inout builder、actor box 与 event group。下游代码只作为取样来源，不在 skill 或项目文档中建立项目索引。

## 来源依据

- 当前框架内通用工具实现：`SKPrint`、`SKPerformance`、`SKHighPerformanceStore`、`SKKVCache`、`SKCountedStore`、`SKEnvironmentConfiguration`、`SKAnimationBox`、`SKWeakBox`、`SKWeakWrapped`、`SKIDBox`、`SKInout`、`SKActorBox`、`SKEventGroup`。
- 已沉淀的 SectionUI 渲染性能、交互状态、生命周期与扩展点 recipes。

## 结论

- 诊断工具需要明确 DEBUG-only 语义，不能被 agents 误写成生产 telemetry 或行为依赖。
- size cache 的 key 由稳定 identity 与测量 limit 共同决定，排障时必须同时看身份、safe-size、动态字体和缓存失效。
- `SKCountedStore`、`SKWeakWrapped`、`SKIDBox` 等工具都和 identity 生命周期相关，必须说明何时重置、何时使用稳定 id、何时不能作为唯一所有权。
- `SKEnvironmentConfiguration` 是 type-keyed local registry，不应被描述成完整依赖注入框架。
- 这类工具不适合散落在各专题 reference 中，单独归档更利于 agents 在调试、性能和集成问题中按需加载。

## 验收场景

1. `SectionUI.skills/SKILL.md` 能导航到诊断与工具层 recipes。
2. `SectionUI.skills/references/diagnostics-utility-recipes.md` 能说明 DEBUG 输出、性能计时、cache、计数器、环境对象、动画值盒、弱引用包装、identity box、inout builder、actor box、event group 与排障路径。
3. 文档不包含下游项目路径、项目名、业务模块名、源码清单、扫描命中数或页面索引。
4. 本次不修改 Swift 源码，不改变运行时行为。

## 泛化边界

- 可以沉淀：SectionUI 工具 API 语义、DEBUG-only 边界、性能计时、缓存 key 与失效、计数触发、弱引用 identity、环境对象 type-keyed 语义、utility 选型。
- 不应沉淀：生产 telemetry 方案、业务事件、具体页面排障记录、项目目录、下游源码位置、扫描统计、业务依赖图。

## 更新内容

- 新增 `SectionUI.skills/references/diagnostics-utility-recipes.md`。
- 更新 `SectionUI.skills/SKILL.md`，在生产实践导航和 Reference Documentation 中加入新 reference。
- 更新 2026-05-05 记忆，记录本次诊断与工具层泛化结果。

## 验证策略

本次是 Markdown 技能文档更新，不涉及 Swift 源码行为变更，因此不运行 Xcode 测试。验证重点是：

- `rg` 审计新增 skill/reference/doc/memory 中不存在下游项目索引式内容。
- `qmd update` 与 `qmd embed` 成功。
- `qmd query --collection SectionKit` 能检索到新增 diagnostics/utility recipes。
