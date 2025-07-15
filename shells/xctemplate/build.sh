#!/bin/bash

# 获取所有安装的 Xcode 路径
xcode_paths=$(mdfind "kMDItemCFBundleIdentifier == 'com.apple.dt.Xcode'")

# 遍历所有 Xcode 路径
for xcode_path in $xcode_paths; do
    
    echo ""

    # 验证 Xcode 路径
    if [ -d "$xcode_path/Contents/Developer/usr/bin" ]; then
        echo "检测到 Xcode 安装在: $xcode_path"
    else
        echo "路径 $xcode_path 不是有效的 Xcode 安装路径。"
        continue
    fi

    # 路径变量
    sectionKit_old="$xcode_path/Contents/Developer/Library/Xcode/Templates/File Templates/SectionKit"
    sectionKit_new="SectionKit"

    echo "开始删除旧的SectionKit模板..."
    echo ""
    
    if sudo rm -rf "$sectionKit_old"; then
        echo "✅ 旧的SectionKit模板已删除！"
    else
        echo "❌ 删除旧的SectionKit模板失败。"
        continue
    fi
    echo ""

    echo "开始复制新的SectionKit模板..."
    if [ -d "$sectionKit_new" ]; then
        # 检查是否有权限写入目标目录
        if [ -w "$xcode_path/Contents/Developer/Library/Xcode/Templates/File Templates/" ]; then
            if sudo cp -R "$sectionKit_new" "$xcode_path/Contents/Developer/Library/Xcode/Templates/File Templates/"; then
                echo "✅ 新的SectionKit模板已复制完成！"
            else
                echo "❌ 复制新的SectionKit模板失败。"
                continue
            fi
        else
            echo ""
            echo "⚠️  没有权限写入目录, 请手动前往以下路径: $xcode_path/Contents/Developer/Library/Xcode/Templates/File Templates/"
            echo "⚠️  复制 SectionKit 文件夹到此目录。"
            continue
        fi
    else
        echo "新的SectionKit模板路径无效：$sectionKit_new"
        continue
    fi
done