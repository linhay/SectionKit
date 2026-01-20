#!/bin/bash

# Resume Release Script - 从中断点继续发布
# 用于当主发布脚本意外中断后，只执行剩余的步骤

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 配置
SECTIONKIT2_PODSPEC="SectionKit2.podspec"
SECTIONUI_PODSPEC="SectionUI.podspec"
CDN_WAIT_TIME=1200  # 20 分钟

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

# 发布到 CocoaPods
publish_to_cocoapods() {
    local podspec=$1
    local pod_name=$(basename "$podspec" .podspec)
    
    log_info "发布 $pod_name 到 CocoaPods..."
    
    pod trunk push "$podspec" --allow-warnings
    
    log_success "已发布 $pod_name"
}

# 等待 CDN 延时
wait_for_cdn() {
    local wait_time=$CDN_WAIT_TIME
    
    log_info "等待 CocoaPods CDN 同步 (${wait_time}秒 / 20分钟)..."
    
    local elapsed=0
    local interval=30
    
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

usage() {
    cat << EOF
用法：./resume_release.sh

此脚本用于从中断点继续 CocoaPods 发布流程。

执行步骤：
  1. 发布 SectionKit2 到 CocoaPods
  2. 等待 20 分钟 (CDN 延时)
  3. 发布 SectionUI 到 CocoaPods

使用场景：
  - 主发布脚本在 CocoaPods 发布步骤失败
  - Git 标签和 GitHub Release 已创建
  - 只需要完成 pod 发布

注意：确保已经完成前面的步骤（版本更新、Git 标签、GitHub Release）
EOF
}

main() {
    echo ""
    log_info "📦 Resume Release - 继续 CocoaPods 发布"
    echo ""
    
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        usage
        exit 0
    fi
    
    # 1. 发布 SectionKit2
    log_info "步骤 1/3: 发布 SectionKit2 到 CocoaPods"
    publish_to_cocoapods "$SECTIONKIT2_PODSPEC"
    echo ""
    
    # 2. 等待 CDN
    log_info "步骤 2/3: 等待 CocoaPods CDN 同步"
    wait_for_cdn
    echo ""
    
    # 3. 发布 SectionUI
    log_info "步骤 3/3: 发布 SectionUI 到 CocoaPods"
    publish_to_cocoapods "$SECTIONUI_PODSPEC"
    echo ""
    
    log_success "🎉 CocoaPods 发布完成！"
    echo ""
    log_info "验证发布："
    echo "  - CocoaPods: pod search SectionKit2"
    echo "  - CocoaPods: pod search SectionUI"
    echo ""
}

main "$@"
