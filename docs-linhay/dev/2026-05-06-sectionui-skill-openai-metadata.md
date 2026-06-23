# SectionUI.skills OpenAI UI 元数据补充

## 背景

根据 `skill-creator` 的建议，skill 可以提供 `agents/openai.yaml` 作为 UI 侧展示与默认调用提示的机器可读元数据。`SectionUI.skills` 此前没有该文件，影响技能列表中的快速识别与默认 prompt 提示。

## 验收场景

1. `SectionUI.skills/agents/openai.yaml` 存在。
2. 文件只包含必要 UI 元数据：展示名、短描述、默认 prompt 与隐式触发策略。
3. `default_prompt` 明确包含 `$SectionUI`。
4. 不添加图标、外部依赖或额外说明文档。

## 更新内容

- 新增 `SectionUI.skills/agents/openai.yaml`。
- 使用 `SectionUI` 作为展示名。
- 使用 “Data-driven UICollectionView architecture” 作为短描述。
- 默认 prompt 强调 data-driven UICollectionView、sections、state ownership 与 row updates。

## 验证策略

本次是 skill 元数据更新，不涉及 Swift 源码行为变更。验证重点是：

- YAML 文本格式符合 `skill-creator` 约束。
- `rg` 审计不引入下游项目索引式内容。
- `qmd update` 与 `qmd embed` 成功。

