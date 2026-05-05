# SectionUI Raw Section Wrapper Recipes 深挖

## 背景

本轮继续将下游重复出现的 SectionUI wrapper 使用方式泛化为通用 skill。下游仓库只作为匿名取样来源，不在 skill 或项目文档中建立项目索引。

## 结论

1. 新增 `SectionUI.skills/references/raw-section-wrapper-recipes.md`，专门沉淀 `SKCRawSectionProtocol`、`SKCAnySectionProtocol`、`SKCAnySingleTypeSectionProtocol`、raw-section wrapper identity、style/plugin forwarding 与生命周期规则。
2. `SKCAnySectionProtocol` 的默认 `objectIdentifier` 来自 underlying `section`，所以 wrapper 必须保证 `section` 返回稳定实例。
3. `SKCRawSectionProtocol.setSectionStyle(...)` 直接 mutate `rawSection`，因此 `rawSection` 必须和最终绑定到 manager 的 section 是同一实例。
4. `SKCAnySingleTypeSectionProtocol` 适用于 wrapping 一个 `SKCSingleTypeSection<Cell>`，并把 `sectionInset`、`sectionInjection`、`plugins`、`pin(options:)` 和 `onCellAction(...)` 转发到 raw section。
5. `SKCManager` 的 reload/insert/append/remove 仍以 `SKCBaseSectionProtocol` 为绑定对象；wrapper 需要通过 `wrapper.section` 或 `SKCSectionCollector` 解包后进入 manager。
6. wrapper 适合单模型渲染、持久选择状态、cache invalidation、可复用事件契约等场景；多 cell 类型或复杂 row snapshot 仍应实现直接 custom section。

## 文档改动

- 新增 `SectionUI.skills/references/raw-section-wrapper-recipes.md`。
- 更新 `SectionUI.skills/SKILL.md`，把 raw section wrapper recipes 加入渐进式加载导航。
- 更新 `SectionUI.skills/references/forwarding-extension-recipes.md`，把 section wrapper 协议细节导向新 reference。
- 更新 `SectionUI.skills/references/custom-section-patterns.md`，在升级到 direct custom section 前提示优先评估 raw-section wrapper。

## 泛化边界

- 只沉淀 SectionUI wrapper protocol、identity、style/plugin forwarding、event forwarding 与生命周期语义。
- 不沉淀下游项目路径、仓库名、业务模块、页面结构、业务事件、源码索引或扫描统计。
