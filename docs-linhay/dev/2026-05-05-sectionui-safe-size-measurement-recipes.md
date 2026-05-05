# SectionUI.skills Safe Size 测量语义深挖更新

## 背景

本次继续更新通用 SectionUI 框架 skill，重点补齐 `safeSize`、`cellSafeSize`、`supplementarySafeSize`、fraction grid、`SKSafeSizeTransform` 与 size cache limit 的精确语义。下游代码只作为匿名取样来源，不在 skill 或项目文档中建立项目索引。

## 验收场景

1. `SectionUI.skills/SKILL.md` 能导航到 safe size measurement recipes。
2. `SectionUI.skills/references/safe-size-measurement-recipes.md` 能说明默认 safe size、cell safe size、fraction grid、公开 transform、supplementary provider、自定义 provider 与排障路径。
3. 旧 reference 中不再示例不存在的 `.aspectRatio`、`.inset`、`.subtract` transform。
4. 文档不包含下游项目路径、项目名、业务模块名、源码清单、扫描命中数或页面索引。
5. 本次不修改 Swift 源码，不改变运行时行为。

## 泛化边界

- 可以沉淀：SectionUI 测量链路、provider fallback、滚动方向下的默认 safe size、fraction 宽度计算、transform 顺序、supplementary kind 语义、cache limit 排障。
- 不应沉淀：具体页面卡片比例、业务 spacing token、下游项目路径、文件来源、业务模块、扫描统计。

## 更新内容

- 新增 `SectionUI.skills/references/safe-size-measurement-recipes.md`。
- 更新 `SectionUI.skills/SKILL.md`，在生产实践导航和 Reference Documentation 中加入新 reference。
- 修正 `SectionUI.skills/references/performance.md` 与 `SectionUI.skills/references/section-advanced-2.md` 中过期的 transform 示例。
- 更新 2026-05-05 记忆，记录本次 safe size 测量层泛化结果。

## 验证策略

本次是 Markdown 技能文档更新，不涉及 Swift 源码行为变更，因此不运行 Xcode 测试。验证重点是：

- `rg` 审计 skill/reference/doc/memory 中不存在下游项目索引式内容。
- `rg` 审计旧 safe-size reference 不再包含不存在的 `.aspectRatio`、`.inset`、`.subtract` transform 示例。
- `qmd update` 与 `qmd embed` 成功。
- `qmd query --collection SectionKit` 能检索到新增 safe size measurement recipes。
