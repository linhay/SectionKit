# SectionUI.skills 导航滚动与分页深挖更新

## 背景

本次继续更新通用 SectionUI 框架 skill，重点从下游重复出现的滚动监听、曝光追踪、程序化滚动、吸顶、分页容器、缩放查看与同步策略中提炼通用 recipes。下游代码只作为取样来源，不在 skill 或项目文档中建立项目索引。

## 验收场景

1. `SectionUI.skills/SKILL.md` 能导航到导航滚动与分页 recipes。
2. `SectionUI.skills/references/navigation-scroll-recipes.md` 能说明 scroll observer、delegate forwarding、`SKCDisplayTracker`、pending scroll request、pin options、`SKPageManager`、`SKZoomableScrollView`、同步策略与排障路径。
3. 文档不包含下游项目路径、项目名、业务模块名、源码清单、扫描命中数或页面索引。
4. 本次不修改 Swift 源码，不改变运行时行为。

## 泛化边界

- 可以沉淀：SectionUI API 语义、滚动生命周期、曝光追踪、section/row 目标解析、pin 状态、分页身份、缩放查看、请求与滚动同步策略。
- 不应沉淀：具体页面结构、业务 tab 名、曝光事件名、固定头高度、品牌样式、项目目录、具体文件来源、统计数字。

## 更新内容

- 新增 `SectionUI.skills/references/navigation-scroll-recipes.md`。
- 更新 `SectionUI.skills/SKILL.md`，在生产实践导航和 Reference Documentation 中加入新 reference。
- 顺手校正旧 `scroll.md` / `page.md` 中与当前源码不一致的滚动监听替换、`SKCDisplayTracker` 参数、`SKPageManager` 子页操作和 `SKPageViewController.set(manager:)` 示例。
- 更新 2026-05-05 记忆，记录本次导航滚动与分页层泛化结果。

## 验证策略

本次是 Markdown 技能文档更新，不涉及 Swift 源码行为变更，因此不运行 Xcode 测试。验证重点是：

- `rg` 审计新增 skill/reference/doc/memory 中不存在下游项目索引式内容。
- `qmd update` 与 `qmd embed` 成功。
- `qmd query --collection SectionKit` 能检索到新增 navigation/scroll recipes。
