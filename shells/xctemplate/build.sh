echo "开始删除旧的SectionKit模板..."
sudo rm -rf "/Applications/Xcode.app/Contents/Developer/Library/Xcode/Templates/File Templates/SectionKit"
echo "旧的SectionKit模板已删除！"

echo "开始复制新的SectionKit模板..."
sudo cp -R SectionKit "/Applications/Xcode.app/Contents/Developer/Library/Xcode/Templates/File Templates/"
echo "新的SectionKit模板已复制完成！"