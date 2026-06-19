#!/bin/bash

# Publish SectionUI Only Script
# 用途：在 SectionKit2 已发布的情况下，等待 CDN 同步后发布 SectionUI
# 使用场景：当 SectionKit2 已成功发布，但后续流程中断时使用
# 使用方法：./publish_sectionui_only.sh [--skip-wait]

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 配置
SECTIONUI_PODSPEC="SectionUI.podspec"
SKILLS_ZIP="sectionui.skill.zip"
CDN_WAIT_TIME=1200  # 20 分钟 = 1200 秒

# 全局变量
SKIP_WAIT=false

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

# 等待 CDN 延时（带进度条）
wait_for_cdn() {
    local wait_time=$CDN_WAIT_TIME
    
    log_info "等待 CocoaPods CDN 同步 (${wait_time}秒 / 20分钟)..."
    log_warning "这是为了确保 SectionKit2 在 CDN 上可用，SectionUI 才能正确依赖它"
    
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

# 发布到 CocoaPods
publish_to_cocoapods() {
    local podspec=$1
    local pod_name=$(basename "$podspec" .podspec)
    
    log_info "发布 $pod_name 到 CocoaPods..."
    
    pod trunk push "$podspec" --allow-warnings
    
    log_success "已发布 $pod_name"
}

# 清理临时文件
cleanup_skills_zip() {
    if [[ -f "$SKILLS_ZIP" ]]; then
        log_info "清理临时文件 $SKILLS_ZIP..."
        rm -f "$SKILLS_ZIP"
        log_success "已清理临时文件"
    fi
}

# 检查 SectionKit2 是否已在 CocoaPods 上
check_sectionkit2_published() {
    local version=$(grep "s\.version[[:space:]]*=" "SectionKit2.podspec" | head -1 | sed -E "s/.*'([0-9.]+)'.*/\1/")
    
    log_info "检查 SectionKit2 $version 是否已在 CocoaPods 上..."
    
    # 尝试搜索 pod
    if pod search SectionKit2 2>/dev/null | grep -q "$version"; then
        log_success "SectionKit2 $version 已在 CocoaPods 上"
        return 0
    else
        log_warning "SectionKit2 $version 尚未在 CocoaPods 上找到"
        log_warning "这可能是因为 CDN 尚未同步，或者版本尚未发布"
        return 1
    fi
}

# 显示使用说明
usage() {
    cat <<EOF
用法：./publish_sectionui_only.sh [--skip-wait]

参数：
  --skip-wait    跳过 20 分钟等待，直接发布（仅当确认 SectionKit2 已在 CDN 上时使用）

功能：
  此脚本用于在 SectionKit2 已发布的情况下，只发布 SectionUI

执行步骤：
  1. 等待 20 分钟 (CDN 同步时间)
  2. 发布 SectionUI 到 CocoaPods
  3. 清理临时文件

使用场景：
  - SectionKit2 已成功发布到 CocoaPods
  - 发布流程在等待或 SectionUI 发布时中断
  - 重复发布 SectionKit2 出现 "duplicate entry" 错误

示例：
  ./publish_sectionui_only.sh           # 等待 20 分钟后发布
  ./publish_sectionui_only.sh --skip-wait  # 立即发布（跳过等待）

注意：
  - 确保 SectionKit2 已成功发布到 CocoaPods
  - 如果跳过等待，请确认 SectionKit2 已在 CDN 上可用
EOF
}

#========================================
# 主流程
#========================================

main() {
    echo ""
    log_info "📦 Publish SectionUI Only"
    echo ""
    
    # 解析参数
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        usage
        exit 0
    fi
    
    if [[ "$1" == "--skip-wait" ]]; then
        SKIP_WAIT=true
        log_warning "⚠️  跳过 CDN 等待时间"
        echo ""
    fi
    
    # 检查 podspec 文件是否存在
    if [[ ! -f "$SECTIONUI_PODSPEC" ]]; then
        log_error "$SECTIONUI_PODSPEC 文件不存在"
        exit 1
    fi
    
    # 1. 等待 CDN（如果未跳过）
    if [[ "$SKIP_WAIT" == false ]]; then
        log_info "步骤 1/2: 等待 CocoaPods CDN 同步"
        wait_for_cdn
        echo ""
    else
        log_info "步骤 1/2: 已跳过 CDN 等待"
        echo ""
    fi
    
    # 2. 发布 SectionUI
    log_info "步骤 2/2: 发布 SectionUI 到 CocoaPods"
    publish_to_cocoapods "$SECTIONUI_PODSPEC"
    echo ""
    
    # 3. 清理临时文件
    cleanup_skills_zip
    echo ""
    
    # 完成
    log_success "🎉 SectionUI 发布完成！"
    echo ""
    log_info "验证发布："
    echo "  - CocoaPods: pod search SectionUI"
    echo "  - 或访问: https://cocoapods.org/pods/SectionUI"
    echo ""
}

# 捕获退出信号，确保清理临时文件
trap cleanup_skills_zip EXIT

# 执行主流程
main "$@"
