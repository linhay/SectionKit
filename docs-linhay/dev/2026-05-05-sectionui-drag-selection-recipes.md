# SectionUI.skills 拖拽框选深挖更新

## 背景

本次继续更新通用 SectionUI 框架 skill，重点从重复出现的拖拽多选、矩形框选、边缘自动滚动、选择框样式、手势冲突与选择状态同步问题中提炼通用 recipes。下游代码只作为取样来源，不在 skill 或项目文档中建立项目索引。

## 来源依据

- 当前框架内 beta drag selector 实现：`SKCDragSelector`、`SKCRectSelectionManager`、`SKAutoScrollManager`、`SKSelectionOverlayView` 与调试日志工具。
- 现有 skill 旧 reference：`SectionUI.skills/references/selection-drag-selector.md`。
- 已沉淀的 SectionUI 选择、事件、滚动与生命周期 recipes。

## 结论

- `SKCDragSelector` 是 iOS 13+ 的 deprecated beta API，应作为可选能力记录，不能当作稳定默认推荐。
- 拖拽框选必须明确 `setup` / `reset` 生命周期；重复 setup 前必须 reset，组件销毁时也要 reset。
- 选择状态归属业务层或集成层，框架只通过 delegate 查询与回写 row 状态。
- 自动滚动、overlay 样式、手势冲突和触觉反馈都属于同一交互闭环，需要在同一 reference 中说明，否则 agents 容易只接入一部分。
- 旧文档中的控制器 collection 属性命名、过期行刷新 helper 与直接改 overlay view/layer 的示例已不适合作为当前推荐写法。

## 验收场景

1. `SectionUI.skills/SKILL.md` 能导航到拖拽框选 recipes。
2. `SectionUI.skills/references/drag-selection-recipes.md` 能说明 beta 状态、setup/reset、状态所有权、意图分析、矩形选择、自动滚动、overlay 样式、手势冲突、haptics 与排障路径。
3. `SectionUI.skills/references/selection-drag-selector.md` 的旧示例改为 `sectionView`、`section.refresh(at:)` 与 `overlayView.style`。
4. 文档不包含下游项目路径、项目名、业务模块名、源码清单、扫描命中数或页面索引。
5. 本次不修改 Swift 源码，不改变运行时行为。

## 泛化边界

- 可以沉淀：SectionUI API 语义、beta 风险、主线程约束、selector 生命周期、selection delegate 契约、阈值语义、auto-scroll 配置、overlay 样式、手势冲突、排障清单。
- 不应沉淀：具体业务列表、页面名称、业务事件、项目目录、下游源码位置、扫描统计、业务选中规则。

## 更新内容

- 新增 `SectionUI.skills/references/drag-selection-recipes.md`。
- 更新 `SectionUI.skills/SKILL.md`，在生产实践导航和 Reference Documentation 中加入新 reference。
- 修正 `SectionUI.skills/references/selection-drag-selector.md` 中过期示例。
- 更新 2026-05-05 记忆，记录本次拖拽框选层泛化结果。

## 验证策略

本次是 Markdown 技能文档更新，不涉及 Swift 源码行为变更，因此不运行 Xcode 测试。验证重点是：

- `rg` 审计新增 skill/reference/doc/memory 中不存在下游项目索引式内容。
- `rg` 审计旧 drag selector reference 中不再出现过期示例片段。
- `qmd update` 与 `qmd embed` 成功。
- `qmd query --collection SectionKit` 能检索到新增 drag selection recipes。
