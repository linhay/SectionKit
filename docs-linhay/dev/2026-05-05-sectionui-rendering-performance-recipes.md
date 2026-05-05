# SectionUI.skills 渲染尺寸与性能深挖更新

## 背景

本次继续更新通用 SectionUI 框架 skill，重点从下游重复出现的尺寸计算、性能缓存、wrapper view、SwiftUI hosting、嵌套 section 与 waterfall 用法中提炼通用 recipes。下游代码只作为取样来源，不在 skill 或项目文档中建立项目索引。

## 验收场景

1. `SectionUI.skills/SKILL.md` 能导航到渲染尺寸与性能 recipes。
2. `SectionUI.skills/references/rendering-performance-recipes.md` 能说明 safe-size、cellSafeSize、supplementarySafeSize、high-performance cache、fixed-size fast path、wrapper view、any view cell、SwiftUI hosting、nested section、waterfall layout 与排障路径。
3. 文档不包含下游项目路径、项目名、业务模块名、源码清单、扫描命中数或页面索引。
4. 本次不修改 Swift 源码，不改变运行时行为。

## 泛化边界

- 可以沉淀：SectionUI API 语义、尺寸计算链路、缓存键与失效策略、wrapper/hosting/nested 的选型、渲染性能排障步骤。
- 不应沉淀：具体页面布局、品牌 spacing、业务 card 比例、项目目录、具体文件来源、统计数字。

## 更新内容

- 新增 `SectionUI.skills/references/rendering-performance-recipes.md`。
- 更新 `SectionUI.skills/SKILL.md`，在生产实践导航和 Reference Documentation 中加入新 reference。
- 更新 2026-05-05 记忆，记录本次渲染尺寸与性能层泛化结果。

## 验证策略

本次是 Markdown 技能文档更新，不涉及 Swift 源码行为变更，因此不运行 Xcode 测试。验证重点是：

- `rg` 审计新增 skill/reference/doc/memory 中不存在下游项目索引式内容。
- `qmd update` 与 `qmd embed` 成功。
- `qmd query --collection SectionKit` 能检索到新增 rendering/performance recipes。
