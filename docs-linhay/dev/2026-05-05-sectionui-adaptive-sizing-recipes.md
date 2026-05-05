# SectionUI.skills Adaptive Sizing 深挖更新

## 背景

本次继续更新通用 SectionUI 框架 skill，重点补齐 `SKAdaptive`、`SKConfigurableAdaptiveView`、`SKConfigurableAdaptiveMainView`、`SKConfigurableAutoAdaptiveView` 与 Auto Layout fitting 的精确测量语义。下游代码只作为匿名取样来源，不在 skill 或项目文档中建立项目索引。

## 来源与结论

- 来源：SectionUI 框架源码中的 `SKAdaptive`、adaptive protocol、safe-size 与 single-type section 测量链路，以及匿名下游重复使用形态。
- 结论：Adaptive sizing 应沉淀为通用测量契约：safe-size limit 进入，model 配置测量视图，按方向选择 fitting priority，可选 content frame 覆盖，可选 insets 叠加，最终返回 item size；不沉淀下游页面、组件名、业务尺寸或扫描统计。

## 验收场景

1. `SectionUI.skills/SKILL.md` 能导航到 adaptive sizing recipes。
2. `SectionUI.skills/references/adaptive-sizing-recipes.md` 能说明 protocol 选型、measurement pipeline、direction/fitting priority、content key path、insets、auto cache、high-performance cache pairing 与排障路径。
3. skill 示例不再使用不完整的单参数 `SKAdaptive` 泛型示例。
4. performance 示例中的 adaptive cell 明确包含 `SKLoadViewProtocol`。
5. 文档不包含下游项目路径、项目名、业务模块名、源码清单、扫描命中数或页面索引。
6. 本次不修改 Swift 源码，不改变运行时行为。

## 泛化边界

- 可以沉淀：Adaptive protocol 选型、Auto Layout fitting priority、content view override、adaptive insets、auto cache 与 size cache 的区别、stale size invalidation。
- 不应沉淀：具体页面排版、品牌 spacing、业务展开规则、设计系统组件名、下游路径、文件来源列表或扫描统计。

## 更新内容

- 新增 `SectionUI.skills/references/adaptive-sizing-recipes.md`。
- 更新 `SectionUI.skills/SKILL.md`，在生产实践导航和 Reference Documentation 中加入新 reference。
- 更新 `SectionUI.skills/references/view-cell-container-recipes.md`，把深入 Adaptive 细节导向新 reference。
- 修正 `SectionUI.skills/examples/AdaptiveCellTemplate.swift` 的 adaptive protocol 和 `SKAdaptive<AdaptiveCellTemplate, Model>` 泛型示例。
- 修正 `SectionUI.skills/references/performance.md` 中 adaptive cell 示例，明确 SectionUI cell 仍需 `SKLoadViewProtocol`。
- 更新 2026-05-05 记忆，记录本次 adaptive sizing 泛化结果。

## 验证策略

本次是 Markdown 与 skill 示例更新，不涉及 Swift 源码行为变更，因此不运行 Xcode 测试。验证重点是：

- `rg` 审计 skill/reference/doc/memory 中不存在下游项目索引式内容。
- `rg` 审计 skill docs 中不再出现不完整的单参数 `SKAdaptive` 泛型示例。
- `qmd update` 与 `qmd embed` 成功。
- `qmd query --collection SectionKit` 能检索到新增 adaptive sizing recipes。
