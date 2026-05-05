# SectionUI Nested Section Cell Recipes 深挖

## 背景

本轮继续把下游重复出现的嵌套 Section 使用方式泛化为 SectionUI skill。下游仓库只作为匿名取样来源，不在 skill 或项目文档中建立项目索引。

## 结论

1. 新增 `SectionUI.skills/references/nested-section-cell-recipes.md`，专门沉淀 `SKCSectionViewCell`、`SKCSingleSectionViewCell`、`wrapperToHorizontalSection`、嵌套尺寸、内部 `SKCollectionView` 生命周期与状态重置规则。
2. 当前推荐 API 是 `wrapperToHorizontalSection(height:insets:style:)`。旧的 ViewCell 后缀包装方法已 deprecated，skill 不再推荐。
3. 当前 `SKCSectionViewCell` 不通过子类 section-setup hook 生成 child section；child sections 通过 `SKCSectionViewCell.Model` 传入，并在 `config(_:)` 中 reload 内部 `sectionView.manager`。
4. 内部 `SKCollectionView` 会随 cell 实例复用，且 inner manager 设置 `supportUnbindSection = false`。因此嵌套曝光、选择、prefetch、scroll observer 和订阅清理必须在父模型 rebinding 时显式处理。
5. 嵌套 row 的高度应来自固定高度、代表性 `heightModel` 或自定义 `size` closure，并显式包含 top/bottom insets；不能依赖当前可见内部 cell frame。

## 文档改动

- 新增 `SectionUI.skills/references/nested-section-cell-recipes.md`。
- 更新 `SectionUI.skills/SKILL.md`，把嵌套 section cell recipes 加入渐进式加载导航。
- 修正 `SectionUI.skills/references/production-usage.md` 中已 deprecated 的旧包装方法推荐。
- 修正 `SectionUI.skills/references/advanced-sections.md` 中不存在的子类 section-setup 示例，改为 model-based 嵌套 section 用法。
- 更新 `SectionUI.skills/references/rendering-performance-recipes.md`，把细节导向新 reference。

## 泛化边界

- 只沉淀 SectionUI API 语义、生命周期、尺寸、状态所有权和排障路径。
- 不沉淀下游项目路径、仓库名、业务模块、页面结构、业务事件、源码索引或扫描统计。
