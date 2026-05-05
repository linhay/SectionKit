# SectionUI.skills Supplementary 深挖更新

## 背景

本次继续更新通用 SectionUI 框架 skill，重点补齐 header/footer、`setHeader`、`setFooter`、`set(supplementary:type:model:)`、动态 supplementary model、隐藏规则、移除语义、生命周期 action 与 custom kind 边界。下游代码只作为匿名取样来源，不在 skill 或项目文档中建立项目索引。

## 来源与结论

- 来源：SectionUI 框架源码中的 `SKCSingleTypeSection+supplementary`、`SKCSupplementary`、`SKCSupplementaryProtocol`、`SKSupplementaryKind`、single-type section header/footer 实现，以及匿名下游重复使用形态。
- 结论：supplementary 应沉淀为 section chrome 契约：set 时注册并 reload，动态 model nil 时 size 为 zero 且跳过 config，header/footer 空列表默认隐藏，remove by type 不等价于移除普通 header/footer，自定义 kind 需要自定义数据源路径支持。

## 验收场景

1. `SectionUI.skills/SKILL.md` 能导航到 supplementary recipes。
2. `SectionUI.skills/references/supplementary-recipes.md` 能说明 registration/storage、constant/dynamic model、sizing、visibility、removal、lifecycle action、custom kind 与排障路径。
3. 旧 `section-styling.md` 中 supplementary `preferredSize` 示例签名已校正。
4. 旧 `section-styling.md` 不再暗示按 view type 移除可以移除普通 `.header`。
5. 文档不包含下游项目路径、项目名、业务模块名、源码清单、扫描命中数或页面索引。
6. 本次不修改 Swift 源码，不改变运行时行为。

## 泛化边界

- 可以沉淀：header/footer 注册时序、dynamic model nil 语义、safe-size 测量、隐藏开关、remove by kind、async lifecycle error ownership、custom kind 限制。
- 不应沉淀：具体 header 文案、业务分组、设计系统组件名、埋点事件、页面结构、下游路径、文件来源列表或扫描统计。

## 更新内容

- 新增 `SectionUI.skills/references/supplementary-recipes.md`。
- 更新 `SectionUI.skills/SKILL.md`，在生产实践导航和 Reference Documentation 中加入新 reference。
- 更新 `SectionUI.skills/references/composition-styling-recipes.md`，把深入 supplementary 细节导向新 reference。
- 校正 `SectionUI.skills/references/section-styling.md` 中 supplementary/header/footer `preferredSize` 示例签名。
- 校正 `SectionUI.skills/references/section-styling.md` 中移除 header/footer 示例，改为按 `.header` / `.footer` kind 移除。
- 更新 2026-05-05 记忆，记录本次 supplementary 泛化结果。

## 验证策略

本次是 Markdown 技能文档更新，不涉及 Swift 源码行为变更，因此不运行 Xcode 测试。验证重点是：

- `rg` 审计 skill/reference/doc/memory 中不存在下游项目索引式内容。
- `rg` 审计旧 section-styling 中不再出现误导性的按 view type 移除普通 header 示例。
- `qmd update` 与 `qmd embed` 成功。
- `qmd query --collection SectionKit` 能检索到新增 supplementary recipes。
