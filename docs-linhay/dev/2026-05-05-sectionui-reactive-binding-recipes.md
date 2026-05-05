# SectionUI.skills 响应式绑定深挖更新

## 背景

本次继续更新通用 SectionUI 框架 skill，重点从下游重复出现的 `SKPublished`、`SKBinding`、section 订阅、section publishers、`SKBindingKey`、result builder、事件组、异步菜单 action 与反馈环控制中提炼通用 recipes。下游代码只作为取样来源，不在 skill 或项目文档中建立项目索引。

## 验收场景

1. `SectionUI.skills/SKILL.md` 能导航到响应式绑定 recipes。
2. `SectionUI.skills/references/reactive-binding-recipes.md` 能说明 `SKPublished` 语义、transform 数组、`subscribe(models:)`、section publishers、`SKBinding`、`SKBindingKey`、`SectionArrayResultBuilder`、`SKWhen`、`SKEventGroup`、`SKUIAction` 与反馈环排障。
3. 旧 `reactive.md` 中与当前源码不一致的 transform 链式写法和 pass-through 描述已校正。
4. 文档不包含下游项目路径、项目名、业务模块名、源码清单、扫描命中数或页面索引。
5. 本次不修改 Swift 源码，不改变运行时行为。

## 泛化边界

- 可以沉淀：SectionUI API 语义、状态所有权、publisher 生命周期、绑定键动态解析、事件注册与清理、反馈环控制。
- 不应沉淀：具体业务状态机、请求客户端、事件命名、页面结构、项目目录、具体文件来源、统计数字。

## 更新内容

- 新增 `SectionUI.skills/references/reactive-binding-recipes.md`。
- 更新 `SectionUI.skills/SKILL.md`，在生产实践导航和 Reference Documentation 中加入新 reference。
- 校正 `SectionUI.skills/references/reactive.md` 中过期或不准确的响应式示例。
- 更新 2026-05-05 记忆，记录本次响应式绑定层泛化结果。

## 验证策略

本次是 Markdown 技能文档更新，不涉及 Swift 源码行为变更，因此不运行 Xcode 测试。验证重点是：

- `rg` 审计新增 skill/reference/doc/memory 中不存在下游项目索引式内容。
- `qmd update` 与 `qmd embed` 成功。
- `qmd query --collection SectionKit` 能检索到新增 reactive binding recipes。
