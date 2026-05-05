# SectionUI.skills Forwarding 与扩展点深挖更新

## 背景

本次继续更新通用 SectionUI 框架 skill，重点从下游重复出现的 manager forwarding、`SKHandleResult`、dataSource/delegate/flowLayout/prefetch 转发链、section injection、raw section wrapper 与集成边界用法中提炼通用 recipes。下游代码只作为取样来源，不在 skill 或项目文档中建立项目索引。

## 验收场景

1. `SectionUI.skills/SKILL.md` 能导航到 forwarding 与扩展点 recipes。
2. `SectionUI.skills/references/forwarding-extension-recipes.md` 能说明 forwarding 模型、`SKHandleResult`、manager wiring、data source/delegate/flow layout/prefetch forwarding、section injection、section wrapper protocols、集成边界与排障路径。
3. 旧 `production-lifecycle-state.md` 中读取 section 的非公开 helper 表述已校正为持有 typed section 引用或从 `manager.sections` / `sectionsPublisher` 派生。
4. 文档不包含下游项目路径、项目名、业务模块名、源码清单、扫描命中数或页面索引。
5. 本次不修改 Swift 源码，不改变运行时行为。

## 泛化边界

- 可以沉淀：SectionUI API 语义、UIKit forwarding 顺序、observer/forward 职责、section injection 生命周期、wrapper identity、集成扩展边界。
- 不应沉淀：具体业务 callback、埋点分类、页面策略、请求客户端、项目目录、具体文件来源、统计数字。

## 更新内容

- 新增 `SectionUI.skills/references/forwarding-extension-recipes.md`。
- 更新 `SectionUI.skills/SKILL.md`，在生产实践导航和 Reference Documentation 中加入新 reference。
- 校正 `SectionUI.skills/references/production-lifecycle-state.md` 中读取 section 的非公开 helper 表述。
- 更新 2026-05-05 记忆，记录本次 forwarding 与扩展点泛化结果。

## 验证策略

本次是 Markdown 技能文档更新，不涉及 Swift 源码行为变更，因此不运行 Xcode 测试。验证重点是：

- `rg` 审计新增 skill/reference/doc/memory 中不存在下游项目索引式内容。
- `qmd update` 与 `qmd embed` 成功。
- `qmd query --collection SectionKit` 能检索到新增 forwarding/extension recipes。
