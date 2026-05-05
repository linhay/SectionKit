# SectionUI.skills 生产模式泛化更新

## 背景

目标是从下游大规模使用中提炼 SectionUI 的通用使用模式，并更新 `SectionUI.skills/`。该 skill 属于通用框架知识，不应成为使用该框架的项目索引。

## 验收场景

1. 能从 `SectionUI.skills/SKILL.md` 直接看到生产验证后的通用实践优先级。
2. 能在 `SectionUI.skills/references/production-usage.md` 看到泛化后的模式、反模式和选型原则。
3. 更新不修改框架源码，不引入运行时行为变化。

## 泛化边界

- 可以沉淀：组合式 section、fluent API、选择状态、响应式状态、嵌套横滑、装饰、曝光事件、集成层抽象边界。
- 不应沉淀：下游项目路径、业务模块索引、单个项目的源码清单、只对某个产品成立的命名或流程。

## 更新内容

- 更新 `SectionUI.skills/SKILL.md` 的 description、生产实践优先级、引用导航、section 形态选择和最佳实践。
- 新增 `SectionUI.skills/references/production-usage.md`，沉淀泛化后的生产使用模式与反模式。
- 新增 `SectionUI.skills/references/production-tips.md`，沉淀下游反复出现但已去项目化的 SectionUI 使用技巧。
- 新增 `SectionUI.skills/references/advanced-production-tips.md`，沉淀低频但高价值 API 的泛化用法：布局属性修正、plugin mode 分层、scroll observer、display tracker、pin、view wrapping、nested/page、prefetch、context menu、reorder。
- 新增 `SectionUI.skills/references/production-lifecycle-state.md`，沉淀生命周期与状态层经验：section collector、manager 绑定、loaded lifecycle、section publishers、reload strategy、empty supplementary、size cache、selection、scroll request、beta API 边界。
- 新增 `SectionUI.skills/references/custom-section-patterns.md`，沉淀 heterogeneous row、自定义 `SKCSectionProtocol`、row enum、snapshot builder、尺寸缓存、事件与更新契约。

## 验证策略

本次是技能文档更新，不涉及 Swift 源码行为变更，因此不运行 Xcode 测试。验证重点是：

- 文件存在且内容可检索。
- `SKILL.md` 能导航到新增 reference。
- 新增 reference 不包含下游项目索引式内容。
- tips 覆盖 section composition、safe size、supplementary、decoration、events/exposure、selection、reactive state、incremental updates、nested sections、styling、framework API 边界。
- advanced tips 只记录通用 API 语义和使用边界，不记录下游仓库名、业务模块名、路径、扫描命中数或文件索引。
- lifecycle/state tips 只沉淀框架生命周期、状态流、刷新策略和缓存失效规则，不把取样项目的具体页面结构写入 skill。
- custom section patterns 只沉淀自定义 section 的实现契约与抽象边界，不写具体业务 row 名、页面名或项目文件来源。
