#!/system/bin/sh
ui_print "- 安装截图自动旋转修复模块 v3.0..."
ui_print "- 正在部署工具链..."

MODTOOLS="$MODPATH/tools"
mkdir -p "$MODTOOLS"

chmod 755 "$MODTOOLS/"* 2>/dev/null

ui_print "- 默认模式：自动检测截图"
ui_print "- 执行 Action 可手动处理截图或切换模式"
ui_print "- 详细说明请查看模块目录下 README.md"
ui_print "- 安装完成，重启后生效"
