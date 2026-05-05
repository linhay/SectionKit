# SectionUI.skills Container Lifecycle 深挖更新

## 背景

本次继续更新通用 SectionUI 框架 skill，重点补齐 `SKCollectionView`、`SKCollectionViewController`、`reloadSections`、`controllerStyle`、`sectionViewStyle`、`ignoresSafeArea`、`refreshable`、layout invalidation、`scrollDirection` 与 collection-level plugin modes 的精确生命周期语义。下游代码只作为匿名取样来源，不在 skill 或项目文档中建立项目索引。

## 来源与结论

- 来源：SectionUI 框架源码中的 `SKCollectionViewController`、`SKCollectionView`、manager pending request、layout plugin fetch 逻辑，以及匿名下游重复使用形态。
- 结论：container 应沉淀为生命周期与所有权契约：controller API 可在 load 前排队，manual collection integration 需要自己处理时机；`ignoresSafeArea` 只切 top；`refreshable` action 必须返回才会 endRefreshing；collection-level plugin modes 与 section-level plugins 在 flow layout fetch 阶段合并。

## 验收场景

1. `SectionUI.skills/SKILL.md` 能导航到 container lifecycle recipes。
2. `SectionUI.skills/references/container-lifecycle-recipes.md` 能说明 SKCollectionView defaults、manager ownership、plugin modes、scroll direction、request publishers、controller loading、safe area、refreshable、layout invalidation、transition events 与排障路径。
3. `view-cell-container-recipes.md` 能把深入容器生命周期细节导向新 reference。
4. 文档不包含下游项目路径、项目名、业务模块名、源码清单、扫描命中数或页面索引。
5. 本次不修改 Swift 源码，不改变运行时行为。

## 泛化边界

- 可以沉淀：容器加载前/后时序、queued style/reload、manager ownership、pending scroll request、safe-area 约束行为、refreshable 结束时机、plugin mode 合并与 layout invalidation。
- 不应沉淀：具体页面加载策略、路由、请求客户端、埋点、产品状态流、下游路径、文件来源列表或扫描统计。

## 更新内容

- 新增 `SectionUI.skills/references/container-lifecycle-recipes.md`。
- 更新 `SectionUI.skills/SKILL.md`，在生产实践导航和 Reference Documentation 中加入新 reference。
- 更新 `SectionUI.skills/references/view-cell-container-recipes.md`，把深入 container lifecycle 细节导向新 reference。
- 更新 2026-05-05 记忆，记录本次 container lifecycle 泛化结果。

## 验证策略

本次是 Markdown 技能文档更新，不涉及 Swift 源码行为变更，因此不运行 Xcode 测试。验证重点是：

- `rg` 审计 skill/reference/doc/memory 中不存在下游项目索引式内容。
- `qmd update` 与 `qmd embed` 成功。
- `qmd query --collection SectionKit` 能检索到新增 container lifecycle recipes。
