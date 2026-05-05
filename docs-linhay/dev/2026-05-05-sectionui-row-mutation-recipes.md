# SectionUI.skills Row Mutation 深挖更新

## 背景

本次继续更新通用 SectionUI 框架 skill，重点补齐 `SKCSingleTypeSection` row mutation、`refresh(at:)`、`refresh(with:)`、predicate refresh、`append`、`insert`、`remove`、`delete`、`apply` 与 `reloadKind` 的精确语义。下游代码只作为匿名取样来源，不在 skill 或项目文档中建立项目索引。

## 来源与结论

- 来源：SectionUI 框架源码中的 `SKCSingleTypeSection+refresh`、`SKCSingleTypeSection` row mutation 实现、manager transaction 语义，以及匿名下游重复使用形态。
- 结论：row mutation 应沉淀为“先维护 section source-of-truth，再匹配 UIKit item operation”的通用契约；`refresh(at:)` 不写模型，`refresh(with:)` 写模型后刷新，predicate refresh 只替换已匹配行，不负责插入/删除。

## 验收场景

1. `SectionUI.skills/SKILL.md` 能导航到 row mutation recipes。
2. `SectionUI.skills/references/row-mutation-recipes.md` 能说明 refresh APIs、predicate refresh、append/insert、remove/delete、full replacement、reloadKind、action context mutation 与排障路径。
3. 旧 `performance.md` 不再使用不存在的“向 section reload 传入 ReloadKind”示例。
4. 旧 `section-best-practices.md` 不再建议在 bound row mutation 后追加无条件 `manager.reload()`。
5. 文档不包含下游项目路径、项目名、业务模块名、源码清单、扫描命中数或页面索引。
6. 本次不修改 Swift 源码，不改变运行时行为。

## 泛化边界

- 可以沉淀：row mutation API 顺序、刷新/替换差异、predicate identity、insert/remove 边界、reloadKind 选型、async context row 重解析。
- 不应沉淀：业务回滚策略、网络请求客户端、埋点事件、权限判断、具体页面流程、下游路径、文件来源列表或扫描统计。

## 更新内容

- 新增 `SectionUI.skills/references/row-mutation-recipes.md`。
- 更新 `SectionUI.skills/SKILL.md`，在生产实践导航和 Reference Documentation 中加入新 reference。
- 更新 `SectionUI.skills/references/section-data-operations.md`，把深入 row mutation 细节导向新 reference，并收窄 `configAndDelete` / `difference` 描述。
- 修正 `SectionUI.skills/references/performance.md` 中不存在的“向 section reload 传入 ReloadKind”示例，改为设置 `reloadKind` 后 `apply(newModels)`。
- 修正 `SectionUI.skills/references/section-best-practices.md` 中 row mutation 后无条件追加 `manager.reload()` 的误导。
- 更新 2026-05-05 记忆，记录本次 row mutation 泛化结果。

## 验证策略

本次是 Markdown 技能文档更新，不涉及 Swift 源码行为变更，因此不运行 Xcode 测试。验证重点是：

- `rg` 审计 skill/reference/doc/memory 中不存在下游项目索引式内容。
- `rg` 审计 skill docs 中不再出现旧的 section reload 传参示例。
- `qmd update` 与 `qmd embed` 成功。
- `qmd query --collection SectionKit` 能检索到新增 row mutation recipes。
