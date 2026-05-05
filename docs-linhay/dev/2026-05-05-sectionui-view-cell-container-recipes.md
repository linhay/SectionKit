# SectionUI.skills 视图 Cell 与容器深挖更新

## 背景

本次继续更新通用 SectionUI 框架 skill，重点从下游重复出现的 Cell/View 加载协议、配置与尺寸契约、Adaptive、自定义 wrapper、supplementary wrapper、`SKCollectionView`、`SKCollectionViewController` 与 SwiftUI bridge 用法中提炼通用 recipes。下游代码只作为取样来源，不在 skill 或项目文档中建立项目索引。

## 验收场景

1. `SectionUI.skills/SKILL.md` 能导航到视图 Cell 与容器 recipes。
2. `SectionUI.skills/references/view-cell-container-recipes.md` 能说明 `SKLoadViewProtocol`、`SKLoadNibProtocol`、`SKConfigurableView`、`SKAdaptive`、wrapper cell/view、supplementary wrapper、`SKCollectionView`、`SKCollectionViewController`、`SKUIView`、`SKUIController` 与排障路径。
3. 旧 `cell.md` 中 `SKLoadViewProtocol` 职责描述已校正为 identifier/nib，而不是 preferredSize。
4. 文档不包含下游项目路径、项目名、业务模块名、源码清单、扫描命中数或页面索引。
5. 本次不修改 Swift 源码，不改变运行时行为。

## 泛化边界

- 可以沉淀：SectionUI API 语义、加载/注册/出队、配置/尺寸、Auto Layout 测量、wrapper 选型、容器生命周期、SwiftUI bridge 所有权。
- 不应沉淀：具体设计系统组件名、品牌 spacing、业务页面层级、项目目录、具体文件来源、统计数字。

## 更新内容

- 新增 `SectionUI.skills/references/view-cell-container-recipes.md`。
- 更新 `SectionUI.skills/SKILL.md`，在生产实践导航和 Reference Documentation 中加入新 reference。
- 校正 `SectionUI.skills/references/cell.md` 中 `SKLoadViewProtocol` 的职责描述。
- 更新 2026-05-05 记忆，记录本次视图 Cell 与容器层泛化结果。

## 验证策略

本次是 Markdown 技能文档更新，不涉及 Swift 源码行为变更，因此不运行 Xcode 测试。验证重点是：

- `rg` 审计新增 skill/reference/doc/memory 中不存在下游项目索引式内容。
- `qmd update` 与 `qmd embed` 成功。
- `qmd query --collection SectionKit` 能检索到新增 view/cell/container recipes。
