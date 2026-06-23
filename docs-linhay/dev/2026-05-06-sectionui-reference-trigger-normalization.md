# SectionUI.skills reference 触发表述规范化

## 背景

继续整理 `SectionUI.skills` 的查找体验。入口已经有 `Task Router` 与 `API Keyword Map`，但多篇 reference 的首段仍是 “This reference captures...”，对 agent 的任务匹配、qmd 检索和人工扫读都不如 “Use this reference when...” 直接。

## 验收场景

1. 主要 `*-recipes.md` reference 的首段能直接说明适用场景。
2. 首段覆盖核心 API 关键词、行为关键词和常见排障关键词。
3. 保留通用框架边界，不包含下游项目路径、项目名、业务模块名、源码清单、扫描命中数或页面索引。
4. 本次不修改 Swift 源码，不改变运行时行为。

## 更新内容

- 将多篇 reference 首段从 “captures...” 改为 “Use this reference when...”。
- 覆盖 manager transaction、row/interaction state、reactive binding、composition/styling、layout/decoration、rendering/performance、SwiftUI hosting、nested section cell、raw section wrapper、forwarding/extension、diagnostics utility 等主要方向。
- 补强关键词：source-of-truth、binding lifecycle、section identity、row operation、cache invalidation、feedback loop、nested collection lifecycle、hosting sizing、delegate gates、layout invalidation 等。

## 验证策略

本次是 Markdown 技能文档整理，不涉及 Swift 源码行为变更，因此不运行 Xcode 测试。验证重点是：

- `rg` 审计剩余 “This reference captures” 是否仍有必要。
- `rg` 审计不引入下游项目索引式内容。
- `rg` 审计不引入已知过期 API 表述。
- `qmd update` 与 `qmd embed` 成功。

