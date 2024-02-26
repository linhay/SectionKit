#!/bin/bash

# 获取当前选定的 Xcode 的路径
xcode_path=$(xcode-select -p)

# 路径变量
sectionKit_old="$xcode_path/Library/Xcode/Templates/File Templates/SectionKit"
sectionKit_new="SectionKit"

# 检查是否成功获取路径
if [ -n "$xcode_path" ]; then
    echo "开始删除旧的SectionKit模板..."
    if sudo rm -rf "$sectionKit_old"; then
        echo "旧的SectionKit模板已删除！"
    else
        echo "删除旧的SectionKit模板失败。"
        exit 1
    fi

    echo "开始复制新的SectionKit模板..."
    if sudo cp -R "$sectionKit_new" "$xcode_path/Library/Xcode/Templates/File Templates/"; then
        echo "新的SectionKit模板已复制完成！"
    else
        echo "复制新的SectionKit模板失败。"
        exit 1
    fi
else
    echo "没有检测到安装的 Xcode。"
fi
