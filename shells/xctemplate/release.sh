#!/bin/bash

# SectionKit Release Automation Script
# 用途：自动化 SectionKit2 和 SectionUI 的版本发布流程
# 使用方法：./release.sh <version> [--dry-run]
# 示例：./release.sh 2.5.3

set -e  # 遇到错误立即退出

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 配置
SECTIONKIT2_PODSPEC="SectionKit2.podspec"
SECTIONUI_PODSPEC="SectionUI.podspec"
SKILLS_DIR="SectionUI.skills"
SKILLS_ZIP="sectionui-skills.zip"
CDN_WAIT_TIME=1200  # 20 分钟 = 1200 秒

# 全局变量
DRY_RUN=false
NEW_VERSION=""

#========================================
# 工具函数
#========================================

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[⚠]${NC} $1"
}

log_error() {
    echo -e "${RED}[✗]${NC} $1"
}

# 检查命令是否存在
check_command() {
    if ! command -v $1 &> /dev/null; then
        log_error "$1 未安装。请先安装：$2"
        exit 1
    fi
}

# 检查依赖
check_dependencies() {
    log_info "检查依赖..."
    check_command "git" "brew install git"
    check_command "gh" "brew install gh"
    check_command "bundle" "gem install bundler"
    check_command "pod" "gem install cocoapods"
    check_command "zip" "系统自带"
    
    # 检查 gh 是否已认证
    if ! gh auth status &> /dev/null; then
        log_error "GitHub CLI 未认证。请运行：gh auth login"
        exit 1
    fi
    
    log_success "所有依赖检查通过"
}

# 验证版本号格式 (semantic versioning)
validate_version() {
    local version=$1
    if [[ ! $version =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        log_error "版本号格式无效：$version"
        log_error "请使用语义化版本格式，例如：2.5.3"
        exit 1
    fi
}

# 更新 podspec 文件中的版本号
update_podspec_version() {
    local podspec_file=$1
    local version=$2
    
    log_info "更新 $podspec_file 版本号为 $version..."
    
    if [[ "$DRY_RUN" == true ]]; then
        log_warning "[DRY RUN] 将更新 $podspec_file 中的版本号"
        return
    fi
    
    # 使用 sed 更新版本号
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        sed -i '' "s/s\.version[[:space:]]*=.*/s.version          = '$version'/" "$podspec_file"
    else
        # Linux
        sed -i "s/s\.version[[:space:]]*=.*/s.version          = '$version'/" "$podspec_file"
    fi
    
    log_success "已更新 $podspec_file"
}

# 更新 SectionUI 的依赖版本
update_dependency_version() {
    local version=$1
    
    log_info "更新 SectionUI 依赖版本为 >= $version..."
    
    if [[ "$DRY_RUN" == true ]]; then
        log_warning "[DRY RUN] 将更新 SectionUI 依赖版本"
        return
    fi
    
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '' "s/s\.dependency 'SectionKit2',.*/s.dependency 'SectionKit2', '>= $version'/" "$SECTIONUI_PODSPEC"
    else
        sed -i "s/s\.dependency 'SectionKit2',.*/s.dependency 'SectionKit2', '>= $version'/" "$SECTIONUI_PODSPEC"
    fi
    
    log_success "已更新依赖版本"
}

# 检查版本号一致性
check_version_consistency() {
    # 在 dry-run 模式下，由于文件未实际更新，跳过检查
    if [[ "$DRY_RUN" == true ]]; then
        log_warning "[DRY RUN] 跳过版本一致性检查（文件未实际更新）"
        return
    fi
    
    
    local sectionkit2_version=$(grep "s\.version[[:space:]]*=" "$SECTIONKIT2_PODSPEC" | head -1 | sed -E "s/.*'([0-9.]+)'.*/\1/")
    local sectionui_version=$(grep "s\.version[[:space:]]*=" "$SECTIONUI_PODSPEC" | head -1 | sed -E "s/.*'([0-9.]+)'.*/\1/")
    local dependency_version=$(grep "s\.dependency 'SectionKit2'" "$SECTIONUI_PODSPEC" | sed -E "s/.*'>= ([0-9.]+)'.*/\1/")
    
    log_info "版本一致性检查："
    echo "  SectionKit2: $sectionkit2_version"
    echo "  SectionUI: $sectionui_version"
    echo "  SectionUI 依赖: >= $dependency_version"

    
    if [[ "$sectionkit2_version" != "$sectionui_version" ]]; then
        log_error "SectionKit2 和 SectionUI 版本号不一致！"
        exit 1
    fi
    
    if [[ "$sectionkit2_version" != "$dependency_version" ]]; then
        log_error "SectionUI 依赖版本与 SectionKit2 版本不一致！"
        exit 1
    fi
    
    log_success "版本号一致性检查通过"
}

# 提交更改
commit_changes() {
    local version=$1
    local commit_message="chore: bump version to $version"
    
    log_info "提交 podspec 版本更新..."
    
    if [[ "$DRY_RUN" == true ]]; then
        log_warning "[DRY RUN] 将提交更改：$commit_message"
        return
    fi
    
    # 检查是否已经有这个版本的提交
    if git log -1 --pretty=%B | grep -q "$commit_message"; then
        log_warning "版本 $version 的更改已经提交，跳过此步骤"
        return
    fi
    
    # 检查是否有更改需要提交
    git add "$SECTIONKIT2_PODSPEC" "$SECTIONUI_PODSPEC"
    if git diff --cached --quiet; then
        log_warning "没有更改需要提交（可能已经提交过）"
        return
    fi
    
    git commit -m "$commit_message"
    
    log_success "已提交更改"
}

# 创建并推送标签
create_and_push_tag() {
    local version=$1
    local tag="$version"
    
    log_info "创建标签 $tag..."
    
    if [[ "$DRY_RUN" == true ]]; then
        log_warning "[DRY RUN] 将创建并推送标签 $tag"
        return
    fi
    
    # 检查远程是否已有此标签
    if git ls-remote --tags origin | grep -q "refs/tags/$tag$"; then
        log_warning "标签 $tag 已存在于远程仓库，跳过创建和推送"
        # 确保本地也有此标签
        if ! git rev-parse "$tag" >/dev/null 2>&1; then
            git fetch origin "refs/tags/$tag:refs/tags/$tag"
        fi
        return
    fi
    
    # 检查本地标签是否已存在
    if git rev-parse "$tag" >/dev/null 2>&1; then
        log_warning "本地标签 $tag 已存在，删除后重新创建..."
        git tag -d "$tag"
    fi
    
    git tag -a "$tag" -m "Release version $version"
    
    # 推送 main 分支（如果有更改）
    if ! git diff origin/main --quiet 2>/dev/null; then
        git push origin main
    else
        log_info "main 分支无更改，跳过推送"
    fi
    
    git push origin "$tag"
    
    log_success "已创建并推送标签 $tag"
}

# 打包 skills 文档
package_skills() {
    log_info "打包 skills 文档..."
    
    if [[ ! -d "$SKILLS_DIR" ]]; then
        log_error "Skills 目录不存在：$SKILLS_DIR"
        exit 1
    fi
    
    if [[ "$DRY_RUN" == true ]]; then
        log_warning "[DRY RUN] 将打包 $SKILLS_DIR 为 $SKILLS_ZIP"
        return
    fi
    
    # 清理旧的 zip 文件
    if [[ -f "$SKILLS_ZIP" ]]; then
        log_warning "删除旧的 $SKILLS_ZIP"
        rm -f "$SKILLS_ZIP"
    fi
    
    # 使用相对路径打包，避免包含完整目录结构
    (cd "$(dirname "$SKILLS_DIR")" && zip -r - "$(basename "$SKILLS_DIR")") > "$SKILLS_ZIP"
    
    log_success "已创建 $SKILLS_ZIP ($(du -h "$SKILLS_ZIP" | cut -f1))"
}

# 创建 GitHub Release
create_github_release() {
    local version=$1
    local tag="$version"
    
    log_info "创建 GitHub Release $tag..."
    
    if [[ "$DRY_RUN" == true ]]; then
        log_warning "[DRY RUN] 将创建 GitHub Release $tag 并上传 $SKILLS_ZIP"
        return
    fi
    
    # 检查 Release 是否已存在
    if gh release view "$tag" >/dev/null 2>&1; then
        log_warning "GitHub Release $tag 已存在，跳过创建"
        return
    fi
    
    # 生成 Release notes
    local release_notes="## Release $version

### 变更内容
自动发布版本 $version

### 附件
- \`sectionui-skills.zip\`: SectionUI 技能文档包

---
发布时间: $(date '+%Y-%m-%d %H:%M:%S')
"
    
    # 创建 Release 并上传 skills 包
    gh release create "$tag" \
        --title "Release $version" \
        --notes "$release_notes" \
        --target main \
        "$SKILLS_ZIP"
    
    log_success "已创建 GitHub Release $tag"
}

# 清理临时文件
cleanup_skills_zip() {
    if [[ -f "$SKILLS_ZIP" ]]; then
        log_info "清理临时文件 $SKILLS_ZIP..."
        rm -f "$SKILLS_ZIP"
        log_success "已清理临时文件"
    fi
}

# 发布到 CocoaPods
publish_to_cocoapods() {
    local podspec=$1
    local pod_name=$(basename "$podspec" .podspec)
    
    log_info "发布 $pod_name 到 CocoaPods..."
    
    if [[ "$DRY_RUN" == true ]]; then
        log_warning "[DRY RUN] 将执行：pod trunk push $podspec --allow-warnings"
        return
    fi
    
    # 使用确保使用项目的 Gemfile 依赖
    pod trunk push "$podspec" --allow-warnings
    
    log_success "已发布 $pod_name"
}

# 等待 CDN 延时（带进度条）
wait_for_cdn() {
    local wait_time=$CDN_WAIT_TIME
    
    log_info "等待 CocoaPods CDN 同步 (${wait_time}秒 / 20分钟)..."
    
    if [[ "$DRY_RUN" == true ]]; then
        log_warning "[DRY RUN] 将等待 $wait_time 秒"
        return
    fi
    
    local elapsed=0
    local interval=30  # 每30秒更新一次进度
    
    while [[ $elapsed -lt $wait_time ]]; do
        local remaining=$((wait_time - elapsed))
        local minutes=$((remaining / 60))
        local seconds=$((remaining % 60))
        printf "\r${BLUE}[INFO]${NC} 剩余时间：%02d:%02d" $minutes $seconds
        sleep $interval
        elapsed=$((elapsed + interval))
    done
    
    printf "\n"
    log_success "CDN 同步等待完成"
}

# 显示使用说明
usage() {
    cat << EOF
用法：./release.sh <version> [--dry-run]

参数：
  version     版本号，格式为 X.Y.Z (例如：2.5.3)
  --dry-run   演练模式，不会实际执行关键操作

示例：
  ./release.sh 2.5.3          # 正式发布 2.5.3 版本
  ./release.sh 2.5.3 --dry-run  # 演练发布流程

流程说明：
  1. 更新 SectionKit2.podspec 和 SectionUI.podspec 版本号
  2. 提交更改并创建 Git 标签
  3. 打包 skills 文档
  4. 创建 GitHub Release 并上传 skills 包
  5. 发布 SectionKit2 到 CocoaPods
  6. 等待 20 分钟 (CDN 延时)
  7. 发布 SectionUI 到 CocoaPods
  8. 清理临时文件

注意事项：
  - 确保已安装并配置 gh (GitHub CLI)
  - 确保有 CocoaPods trunk push 权限
  - 脚本会自动验证版本号一致性
EOF
}

#========================================
# 主流程
#========================================

main() {
    echo ""
    log_info "🚀 SectionKit Release Automation Script"
    echo ""
    
    # 解析参数
    if [[ $# -lt 1 ]]; then
        usage
        exit 1
    fi
    
    NEW_VERSION=$1
    
    if [[ "$2" == "--dry-run" ]]; then
        DRY_RUN=true
        log_warning "⚠️  DRY RUN 模式 - 不会执行实际操作"
        echo ""
    fi
    
    # 1. 验证版本号
    validate_version "$NEW_VERSION"
    log_success "版本号格式有效：$NEW_VERSION"
    echo ""
    
    # 2. 检查依赖
    check_dependencies
    echo ""
    
    # 3. 更新版本号
    log_info "步骤 1/8: 更新版本号"
    update_podspec_version "$SECTIONKIT2_PODSPEC" "$NEW_VERSION"
    update_podspec_version "$SECTIONUI_PODSPEC" "$NEW_VERSION"
    update_dependency_version "$NEW_VERSION"
    check_version_consistency
    echo ""
    
    # 4. 提交更改
    log_info "步骤 2/8: 提交版本更改"
    commit_changes "$NEW_VERSION"
    echo ""
    
    # 5. 创建标签
    log_info "步骤 3/8: 创建并推送 Git 标签"
    create_and_push_tag "$NEW_VERSION"
    echo ""
    
    # 6. 打包 skills
    log_info "步骤 4/8: 打包 skills 文档"
    package_skills
    echo ""
    
    # 7. 创建 GitHub Release
    log_info "步骤 5/8: 创建 GitHub Release"
    create_github_release "$NEW_VERSION"
    echo ""
    
    # 8. 发布 SectionKit2
    log_info "步骤 6/8: 发布 SectionKit2 到 CocoaPods"
    publish_to_cocoapods "$SECTIONKIT2_PODSPEC"
    echo ""
    
    # 9. 等待 CDN
    log_info "步骤 7/8: 等待 CocoaPods CDN 同步"
    wait_for_cdn
    echo ""
    
    # 10. 发布 SectionUI
    log_info "步骤 8/8: 发布 SectionUI 到 CocoaPods"
    publish_to_cocoapods "$SECTIONUI_PODSPEC"
    echo ""
    
    # 11. 清理临时文件
    cleanup_skills_zip
    echo ""
    
    # 完成
    log_success "🎉 发布完成！版本 $NEW_VERSION 已成功发布"
    echo ""
    log_info "验证发布："
    echo "  - GitHub Release: https://github.com/linhay/SectionKit/releases/tag/$NEW_VERSION"
    echo "  - CocoaPods: pod search SectionKit2"
    echo "  - CocoaPods: pod search SectionUI"
    echo ""
}

# 捕获退出信号，确保清理临时文件
trap cleanup_skills_zip EXIT

# 执行主流程
main "$@"
