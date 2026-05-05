# SectionUI Runtime View Wrapper Recipes 深挖

## 背景

本轮继续将下游重复出现的 SectionUI view wrapper 使用方式泛化为通用 skill。下游仓库只作为匿名取样来源，不在 skill 或项目文档中建立项目索引。

## 结论

1. 新增 `SectionUI.skills/references/runtime-view-wrapper-recipes.md`，专门沉淀 `SKCAnyViewCell`、`SKWrapperView`、`SKCWrapperCell` 与 `SKCWrapperReusableView` 的 sizing、layout、nib、reuse 和 ownership 规则。
2. `SKCAnyViewCell` 承载 live `UIView` 实例；`config(_:)` 会移除旧 view，也会把 incoming view 从原 superview 移除后再挂到 cell。
3. `SKWrapperView` 持有一个 content view，`Model(userInfo:insets:)` 会用扣除 insets 后的 limit 测量内容，再把 insets 加回最终尺寸。
4. `SKCWrapperCell` 会在 `View.nib` 存在时加载 nib；`SKCWrapperReusableView` 当前直接创建 `View()`，不走 nib。
5. wrapper style/config 必须 reset-safe；runtime view 不能同时被多个可见 cell 共享。

## 文档改动

- 新增 `SectionUI.skills/references/runtime-view-wrapper-recipes.md`。
- 更新 `SectionUI.skills/SKILL.md`，把 runtime view wrapper recipes 加入渐进式加载导航。
- 更新 `SectionUI.skills/references/view-cell-container-recipes.md`，把深入 wrapper 细节导向新 reference。

## 泛化边界

- 只沉淀 SectionUI runtime view hosting、wrapper sizing、nib 行为、reuse ownership 与排障路径。
- 不沉淀下游项目路径、仓库名、业务模块、页面结构、业务事件、源码索引或扫描统计。

