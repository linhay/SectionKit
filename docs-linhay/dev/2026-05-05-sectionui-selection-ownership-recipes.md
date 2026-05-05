# SectionUI.skills Selection 状态所有权深挖更新

## 背景

本次继续更新通用 SectionUI 框架 skill，重点补齐 `SKSelectionState`、`SKSelectionProtocol`、`SKSelectionWrapper`、`SKSelectionSequence`、`SKSelectionIdentifiableSequence` 的状态所有权、publisher 生命周期、cell reuse 绑定和单选/多选语义。下游代码只作为匿名取样来源，不在 skill 或项目文档中建立项目索引。

## 验收场景

1. `SectionUI.skills/SKILL.md` 能导航到 selection ownership recipes。
2. `SectionUI.skills/references/selection-ownership-recipes.md` 能说明 wrapper identity、cell binding、sequence observation、ID-based selection、single/multi-select 与排障路径。
3. 旧 selection reference 中不再示例只读 `isSelected` 赋值、过期 wrapper `.value` 访问、协议式手动单选或不准确的 identifiable sequence 初始化。
4. 文档不包含下游项目路径、项目名、业务模块名、源码清单、扫描命中数或页面索引。
5. 本次不修改 Swift 源码，不改变运行时行为。

## 泛化边界

- 可以沉淀：selection state ownership、wrapper identity、publisher lazy observation、cell reuse subscription、offset vs ID 选型、unique/select-all 语义、reload/append 观察边界。
- 不应沉淀：具体业务权限、状态名、页面选择规则、下游项目路径、文件来源、扫描统计。

## 更新内容

- 新增 `SectionUI.skills/references/selection-ownership-recipes.md`。
- 更新 `SectionUI.skills/SKILL.md`，在生产实践导航和 Reference Documentation 中加入新 reference。
- 修正 `selection.md`、`selection-protocol.md`、`selection-sequence.md`、`selection-identifiable-sequence.md` 中过期或不准确的示例。
- 更新 2026-05-05 记忆，记录本次 selection 状态所有权层泛化结果。

## 验证策略

本次是 Markdown 技能文档更新，不涉及 Swift 源码行为变更，因此不运行 Xcode 测试。验证重点是：

- `rg` 审计 skill/reference/doc/memory 中不存在下游项目索引式内容。
- `rg` 审计旧 selection reference 中不再包含过期访问与赋值示例。
- `qmd update` 与 `qmd embed` 成功。
- `qmd query --collection SectionKit` 能检索到新增 selection ownership recipes。
