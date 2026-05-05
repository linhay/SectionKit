# SectionUI.skills Manager 事务层深挖更新

## 背景

本次继续更新通用 SectionUI 框架 skill，重点从 `SKCManager`、`SKCSectionInjection`、`SKCSectionActionProtocol` 与 `SKCSingleTypeSection` 的操作语义中提炼 manager transaction recipes，覆盖 manager 绑定、section 对象身份、section/row 操作、reload 策略、pending request、绑定后访问与配置开关。下游代码只作为取样来源，不在 skill 或项目文档中建立项目索引。

## 来源依据

- 当前框架源码：`SKCManager`、`SKCSectionInjection`、`SKCSectionActionProtocol`、`SKCSingleTypeSection`、`SKCSingleTypeSection+refresh`、`SKCSingleTypeSectionRowContext`。
- 已沉淀的组合渲染、导航滚动、forwarding、生命周期与状态 recipes。

## 结论

- manager 的 section insert/remove/delete 基于 section 对象身份，不是语义 diff。
- `manager.reload(sections)` 是清晰的 render 边界，会重新绑定 `sectionInjection`、发送 bound section 列表并触发 `reloadData`。
- 行级操作必须保持模型数组 mutation 与 UIKit item operation 同步，异步场景要重新通过 identity 解析 row。
- `sectionInjection` 是绑定桥，feature code 不应直接写入；action convert 属于集成层能力。
- pending scroll request 只表示首次滚动失败后等待 layout 重试，不是持久任务队列。
- 这些语义散落在多个 reference 中，单独沉淀为 transaction recipes 可以减少 agents 在增量更新和 full render 之间误选。

## 验收场景

1. `SectionUI.skills/SKILL.md` 能导航到 manager transaction recipes。
2. `SectionUI.skills/references/manager-transaction-recipes.md` 能说明 manager ownership、binding、section identity、manager operations、row operations、reload strategy、section injection、pending requests、bound-section access、configuration flags 与排障路径。
3. 文档不包含下游项目路径、项目名、业务模块名、源码清单、扫描命中数或页面索引。
4. 本次不修改 Swift 源码，不改变运行时行为。

## 泛化边界

- 可以沉淀：SectionUI manager API 语义、绑定顺序、对象身份、UICollectionView batch transaction、row mutation、reload 策略、pending request、section injection、配置开关。
- 不应沉淀：具体业务模块顺序、页面状态名、业务 diff 策略、项目目录、下游源码位置、扫描统计、产品动画策略。

## 更新内容

- 新增 `SectionUI.skills/references/manager-transaction-recipes.md`。
- 更新 `SectionUI.skills/SKILL.md`，在生产实践导航和 Reference Documentation 中加入新 reference。
- 更新 2026-05-05 记忆，记录本次 manager 事务层泛化结果。

## 验证策略

本次是 Markdown 技能文档更新，不涉及 Swift 源码行为变更，因此不运行 Xcode 测试。验证重点是：

- `rg` 审计新增 skill/reference/doc/memory 中不存在下游项目索引式内容。
- `qmd update` 与 `qmd embed` 成功。
- `qmd query --collection SectionKit` 能检索到新增 manager transaction recipes。
