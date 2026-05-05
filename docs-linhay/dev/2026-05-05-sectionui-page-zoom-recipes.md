# SectionUI Page And Zoom Recipes 深挖

## 背景

本轮继续将下游重复出现的分页与缩放使用方式泛化为 SectionUI skill。下游仓库只作为匿名取样来源，不在 skill 或项目文档中建立项目索引。

## 结论

1. 新增 `SectionUI.skills/references/page-zoom-recipes.md`，专门沉淀 `SKPageManager`、`SKPageViewController`、`SKPageChildController`、`SKZoomableScrollView` 与 `SKZoomableContext` 的生命周期和交互契约。
2. `SKPageManager` 的 child controller cache 以 child `id` 为 key；`current` 会随 `selection/childs` 更新，即使 UI 未绑定，此时 controller 可以为 nil。
3. `SKPageViewController` 会 debounce manager 的 `scrollDirection`、`spacing`、`childs` 变化，并在有 children 时重新 render page controller。
4. `SKZoomableScrollView` 由 `SKZoomableContext.size` 驱动 layout，layout 会 reset zoom 到 `1.0` 并更新 `zoomScale`。
5. double tap 默认执行 zoom toggle，只有设置 `doubleTapAction` 时才替换默认行为；single tap 和 long press 根据 action 是否存在启用。

## 文档改动

- 新增 `SectionUI.skills/references/page-zoom-recipes.md`。
- 更新 `SectionUI.skills/SKILL.md`，把 page and zoom recipes 加入渐进式加载导航。
- 更新 `SectionUI.skills/references/navigation-scroll-recipes.md`，把分页/缩放深入细节导向新 reference，并校正 double tap gesture 的启用语义。
- 更新 `SectionUI.skills/references/page.md`，移除直接写 `contentView` / `zoomScale` / `zoom(to:)` 的旧示例，改为 `SKZoomableContentView` + `wrapperToZoomableView()`。

## 泛化边界

- 只沉淀 SectionUI page identity/cache、selection/current binding、controller lifecycle、zoom sizing、tap actions 与 pan-to-dismiss 机制。
- 不沉淀下游页面名、路由、业务事件、图片加载器、项目路径、源码索引或扫描统计。
