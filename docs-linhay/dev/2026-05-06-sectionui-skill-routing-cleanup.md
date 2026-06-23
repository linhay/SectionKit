# SectionUI.skills 查找路径与入口表述整理

## 背景

本次对 `SectionUI.skills/SKILL.md` 做信息架构整理。此前入口文件同时承担教程、目录、生产经验索引和最佳实践说明，reference 数量增加后，agent 需要阅读较长的连续句子才能判断应打开哪份文档。

## 验收场景

1. `SectionUI.skills/SKILL.md` 能优先说明 SectionUI 的数据驱动宗旨。
2. agent 能按用户意图从 `Task Router` 快速定位主 reference。
3. agent 能按 API 关键词从 `API Keyword Map` 快速定位 reference。
4. 入口表述保持通用框架视角，不包含下游项目路径、项目名、业务模块名、源码清单、扫描命中数或页面索引。
5. 本次不修改 Swift 源码，不改变运行时行为。

## 更新内容

- 优化 frontmatter description，加入 source-of-truth、row mutation、section builders、SwiftUI hosting 等检索关键词。
- 将原本连续的生产 reference 导航改为 `Reference Lookup Workflow`、`Task Router` 和 `API Keyword Map`。
- 保留完整 `Reference Documentation` 列表，确保所有 reference 仍从 `SKILL.md` 一层可达。
- 继续保留 Quick Start、Common Usage Patterns 与 Best Practices，避免只剩索引而缺少基础落点。

## 验证策略

本次是 Markdown 技能文档整理，不涉及 Swift 源码行为变更，因此不运行 Xcode 测试。验证重点是：

- `rg` 审计入口与新增文档不存在下游项目索引式内容。
- `rg` 审计不引入已知过期 API 表述。
- `qmd update` 与 `qmd embed` 成功。
- `qmd query --collection SectionKit` 能检索到 skill routing / task router / API keyword map。

