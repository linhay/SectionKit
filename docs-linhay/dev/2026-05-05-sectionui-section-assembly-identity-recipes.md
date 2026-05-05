# SectionUI Section Assembly Identity Recipes 深挖

## 背景

本轮继续将下游重复出现的动态 section 组装、过滤、索引绑定和 SwiftUI hosted collection 身份规则泛化为 SectionUI skill。下游仓库只作为匿名取样来源，不在 skill 或项目文档中建立项目索引。

## 结论

1. 新增 `SectionUI.skills/references/section-assembly-identity-recipes.md`，专门沉淀 `SectionArrayResultBuilder`、`SKCSectionCollector`、`SKWhen`、`SKBindingKey` 与 `SKCHostingCollectionView` 的身份规则。
2. `SectionArrayResultBuilder` 是纯 flatten：单个 model、数组、闭包、optional、if/else、loop 与 availability block 最终都归并为 `[Model]`。
3. `SKCSectionCollector` 存储 `[SKCSectionProtocol]`，append `SKCAnySectionProtocol` wrapper 时会解包 `.section`；collector 应每次 render pass 重建。
4. `SKBindingKey.wrappedValue` 每次读取都会执行 closure；`Equatable` 和 `Hashable` 都基于当前 wrapped value，不适合作为长期稳定 key。
5. `SKCHostingCollectionView` 的 update 只比较 `objectIdentifier` 序列；相同 section 实例的内部模型变化不会自动触发 hosted collection reload。

## 文档改动

- 新增 `SectionUI.skills/references/section-assembly-identity-recipes.md`。
- 更新 `SectionUI.skills/SKILL.md`，把 section assembly identity recipes 加入渐进式加载导航。
- 更新 `SectionUI.skills/references/render-builder-recipes.md`，把精确 builder/collector/binding identity 细节导向新 reference。

## 泛化边界

- 只沉淀 SectionUI builder flattening、collector filtering/conversion、predicate composition、dynamic section-index binding 与 identity 规则。
- 不沉淀下游模块顺序、业务状态名、页面结构、路由、埋点、项目路径、源码索引或扫描统计。

