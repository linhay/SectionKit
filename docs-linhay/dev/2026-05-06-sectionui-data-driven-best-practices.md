# SectionUI.skills 数据驱动最佳实践更新

## 背景

本次整理 SectionUI 通用框架最佳实践，明确框架宗旨：绑定完成后，业务只管理数据和状态，UI 变化由 SectionUI 从模型、选择状态、publisher 与 section mutation 自然派生。

## 验收场景

1. `SectionUI.skills/SKILL.md` 能导航到数据驱动最佳实践 reference。
2. `SectionUI.skills/references/data-driven-best-practices.md` 能说明绑定期与运行期职责、source of truth、推荐更新流、组合规则、反模式和排障清单。
3. `README.md` 的最佳实践能直接表达“绑定后只管理数据”的框架宗旨。
4. 文档不包含下游项目路径、项目名、业务模块名、源码清单、扫描命中数或页面索引。
5. 本次不修改 Swift 源码，不改变运行时行为。

## 泛化边界

- 可以沉淀：SectionUI 框架宗旨、状态所有权、manager/section 绑定边界、publisher 驱动、row mutation、selection state、缓存失效和排障路径。
- 不应沉淀：具体业务页面、下游项目目录、产品模块名、业务状态机、埋点事件、扫描来源统计或代码索引。

## 更新内容

- 新增 `SectionUI.skills/references/data-driven-best-practices.md`。
- 更新 `SectionUI.skills/SKILL.md`，在生产实践导航、Reference Documentation 和 Best Practices 中加入数据驱动宗旨。
- 更新 `README.md` 的最佳实践，加入“绑定后只管理数据”的用户侧表述。
- 更新 2026-05-06 记忆，记录本次框架宗旨与沉淀边界。

## 验证策略

本次是 Markdown 技能文档更新，不涉及 Swift 源码行为变更，因此不运行 Xcode 测试。验证重点是：

- `rg` 审计新增 skill/reference/doc/memory 中不存在下游项目索引式内容。
- `rg` 审计不引入已知过期 API 表述。
- `qmd update` 与 `qmd embed` 成功。
- `qmd query --collection SectionKit` 能检索到数据驱动最佳实践。

