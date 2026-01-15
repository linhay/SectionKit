<p align="center">
  <img src="https://raw.githubusercontent.com/linhay/SectionKit/dev/Documentation/Images/icon.svg" width=450 />
</p>

<p align="center">
<a href="https://deepwiki.com/linhay/SectionKit"><img src="https://deepwiki.com/badge.svg" alt="Platforms"></a>
  <a href="https://cocoapods.org/pods/SectionUI"><img src="https://img.shields.io/cocoapods/v/SectionUI.svg?style=flat" alt="Pods Version"></a>
  <a href="https://instagram.github.io/SectionUI/"><img src="https://img.shields.io/cocoapods/p/SectionUI.svg?style=flat" alt="Platforms"></a>
</p>
---

一个数据驱动的 `UICollectionView`框架，用于构建快速灵活的列表。

|           | 主要特性                                  |
| --------- | ----------------------------------------- |
| &#127968; | 更好的可复用 cell 和组件体系结构          |
| &#128288; | 创建具有多个数据类型的列表                |
| &#128241; | 简化并维持 `UICollectionView`的核心特性 |
| &#9989;   | 超多的插件来帮助你构建更好的列表          |
| &#128038; | Swift 编写, 同时完全支持 SwiftUI          |

## 示例

#### [单组 Section](./Example/01-Introduction.swift)

![01-Introduction](https://github.com/linhay/RepoImages/blob/main/SectionUI/01-Introduction.png?raw=true)

#### [多组 Section](./Example/02-MultipleSection.swift)

![02-MultipleSection](https://github.com/linhay/RepoImages/blob/main/SectionUI/02-MultipleSection.png?raw=true)

#### [设置 Header 和 Footer](./Example/03-FooterAndHeader.swift)

![03-FooterAndHeader](https://github.com/linhay/RepoImages/blob/main/SectionUI/03-FooterAndHeader.png?raw=true)

#### [加载更多数据 / 重置数据](./Example/04-LoadAndPull.swift)

![04-LoadAndPull](https://github.com/linhay/RepoImages/blob/main/SectionUI/04-LoadAndPull.png?raw=true)

#### [使用 Combine 订阅数据](./Example/05-SubscribeDataWithCombine.swift)

![05-SubscribeDataWithCombine](https://github.com/linhay/RepoImages/blob/main/SectionUI/05-SubscribeDataWithCombine.png?raw=true)

### [网格视图](./Example/06-Grid.swift)

![06-Grid](https://github.com/linhay/RepoImages/blob/main/SectionUI/06-Grid.png?raw=true)

### [装饰视图](./Example/07-Decoration.swift)

![07-Decoration](https://github.com/linhay/RepoImages/blob/main/SectionUI/07-Decoration.png?raw=true)

## 前提条件:

- Swift 5.8
- iOS 13.0+

## 安装

- Swift Package Manager

  ```swift
  https://github.com/linhay/SectionKit
  ```
- Cocoapods

  ```ruby
  pod 'SectionUI', '2.4.0'
  ```

## Antigravity Skills

This project includes a set of "Skills" designed for AI coding assistants (like Antigravity). These skills provide context, patterns, and best practices for working with SectionKit.

You can find them in the `.agent/skills` directory:

- **sectionui-section**: Master skill for creating and configuring `SKCSingleTypeSection`.
- **sectionui-cell**: Master skill for creating robust `UICollectionViewCell`s.
- **sectionui-common**: Universal utilities, including wrappers and reactive bindings.
- **sectionui-page**: Memory-efficient pagination.
- **sectionui-selection**: Selection state management.
- **sectionui-preview**: SwiftUI Previews support.

To use these skills, simply ask your AI assistant to read the relevant skill file (e.g., "Read the sectionui-section skill").

### Quick Integration

You can easily enable these skills for other AI coding assistants by creating symbolic links:

**GitHub Copilot**:
```bash
mkdir -p .github
ln -s ../.agent/skills .github/skills
```

**Claude Desktop**:
```bash
mkdir -p .claude
ln -s ../.agent/skills .claude/skills
```

### References

- [Antigravity Skills Documentation](https://antigravity.google/docs/skills)
- [Claude Skills](https://claude.com/skills)
- [GitHub Copilot Agent Skills](https://docs.github.com/en/copilot/concepts/agents/about-agent-skills?utm_source=docs&utm_medium=&utm_campaign=skills-25)

## License

`SectionUI` 遵循[Apache License](./LICENSE)。
