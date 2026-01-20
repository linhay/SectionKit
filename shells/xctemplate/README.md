# SectionKit Release Scripts

本目录包含 SectionKit 项目的发布自动化脚本。

## 📜 脚本列表

### 1. `release.sh` - 完整发布流程
**用途**：自动化 SectionKit2 和 SectionUI 的完整版本发布流程

**使用方法**：
```bash
./release.sh <version> [--dry-run]
```

**示例**：
```bash
# 正式发布 2.5.3 版本
./release.sh 2.5.3

# 演练发布流程（不执行实际操作）
./release.sh 2.5.3 --dry-run
```

**执行步骤**：
1. ✏️ 更新 `SectionKit2.podspec` 和 `SectionUI.podspec` 版本号
2. 📝 提交版本更改到 Git
3. 🏷️ 创建并推送 Git 标签
4. 📦 打包 skills 文档为 zip
5. 🚀 创建 GitHub Release 并上传 skills 包
6. 📤 发布 SectionKit2 到 CocoaPods
7. ⏳ 等待 20 分钟（CDN 同步时间）
8. 📤 发布 SectionUI 到 CocoaPods
9. 🧹 清理临时文件

**注意事项**：
- 确保已安装并配置 `gh` (GitHub CLI)
- 确保有 CocoaPods trunk push 权限
- 脚本会自动验证版本号一致性

---

### 2. `resume_release.sh` - 恢复发布流程
**用途**：从中断点继续 CocoaPods 发布流程

**使用方法**：
```bash
./resume_release.sh
```

**执行步骤**：
1. 📤 发布 SectionKit2 到 CocoaPods
2. ⏳ 等待 20 分钟（CDN 同步时间）
3. 📤 发布 SectionUI 到 CocoaPods

**适用场景**：
- 主发布脚本在 CocoaPods 发布步骤失败
- Git 标签和 GitHub Release 已创建
- 只需要完成 pod 发布

---

### 3. `publish_sectionui_only.sh` - 仅发布 SectionUI
**用途**：在 SectionKit2 已发布的情况下，只发布 SectionUI

**使用方法**：
```bash
# 标准模式（等待 20 分钟）
./publish_sectionui_only.sh

# 跳过等待模式（如果 SectionKit2 已在 CDN 上）
./publish_sectionui_only.sh --skip-wait
```

**执行步骤**：
1. ⏳ 等待 20 分钟（CDN 同步时间，可跳过）
2. 📤 发布 SectionUI 到 CocoaPods
3. 🧹 清理临时文件

**适用场景**：
- SectionKit2 已成功发布到 CocoaPods
- 发布流程在等待或 SectionUI 发布时中断
- 重复发布 SectionKit2 出现 "duplicate entry" 错误

---

### 4. `build.sh` - Xcode 模板构建脚本
**用途**：构建 Xcode 项目模板

---

## 🔧 依赖要求

所有发布脚本需要以下工具：

- ✅ **git** - 版本控制
- ✅ **gh** - GitHub CLI（需要认证：`gh auth login`）
- ✅ **bundle** - Ruby 依赖管理
- ✅ **pod** - CocoaPods
- ✅ **zip** - 文件压缩（系统自带）

## 📝 发布流程说明

### 正常发布流程
```bash
# 1. 执行完整发布
./release.sh 2.5.4

# 如果中途失败，根据失败位置选择：
# - 如果在 CocoaPods 发布前失败：重新运行 release.sh
# - 如果在 CocoaPods 发布时失败：运行 resume_release.sh
# - 如果 SectionKit2 已发布但 SectionUI 未发布：运行 publish_sectionui_only.sh
```

### 异常恢复流程

#### 场景 1：SectionKit2 发布失败
```bash
./resume_release.sh
```

#### 场景 2：SectionKit2 已发布（重复发布错误）
```bash
# 如果刚发布（需要等待 CDN）
./publish_sectionui_only.sh

# 如果发布已超过 20 分钟
./publish_sectionui_only.sh --skip-wait
```

#### 场景 3：CocoaPods 服务器错误
等待官方服务恢复后重试：
- 检查服务状态：https://twitter.com/CocoaPods
- 等待几分钟后重新运行相应脚本

## 🎯 最佳实践

1. **发布前检查**：
   - 确保所有测试通过
   - 确保 CHANGELOG 已更新
   - 确保版本号符合语义化版本规范

2. **演练模式**：
   - 首次使用建议先用 `--dry-run` 模式演练
   - 确认流程无误后再正式发布

3. **版本一致性**：
   - 脚本会自动检查 SectionKit2、SectionUI 和依赖版本的一致性
   - 如果检查失败，请手动检查 podspec 文件

4. **CDN 延时**：
   - CocoaPods CDN 同步通常需要 15-20 分钟
   - 不要跳过等待时间，否则 SectionUI 可能因找不到依赖而发布失败

## 📚 相关资源

- [SectionKit GitHub](https://github.com/linhay/SectionKit)
- [CocoaPods](https://cocoapods.org/)
- [语义化版本](https://semver.org/lang/zh-CN/)
