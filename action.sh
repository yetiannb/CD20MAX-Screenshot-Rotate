#!/system/bin/sh

MODDIR="/data/adb/modules/screenshot_rotate_fix"
TOOLS_DIR="$MODDIR/tools"
SCREENSHOT_DIR="/storage/emulated/0/Pictures/Screenshots"
LAST_FILE="/data/local/tmp/screenshot_last.txt"
LAST_ACTION_FILE="/data/local/tmp/screenshot_last_action.txt"
CONFIG="$MODDIR/config.sh"
PROP="$MODDIR/module.prop"

. "$CONFIG"

MODE_NAME="模式1 - 自动检测"
[ "$MODE" = "signal" ] && MODE_NAME="模式2 - 信号触发"

TIPS='【模式说明】
模式1：系统自动检测截图文件夹，发现新截图立即旋转，无需任何操作
模式2：需配合触发器使用，截图后触发器自动发送信号执行旋转
      触发器设置（以Xposed Edge Pro为例）：
      ① 添加多重动作
      ② 第一步：系统截图
      ③ 第二步：延迟1秒
      ④ 第三步：执行Shell命令：touch /data/local/tmp/do_rotate

【切换模式】
20秒内再次执行Action即可切换模式'

# 检查20秒内是否重复执行
NOW=$(date +%s)
LAST_ACTION=$(cat "$LAST_ACTION_FILE" 2>/dev/null)
echo "$NOW" > "$LAST_ACTION_FILE"

if [ -n "$LAST_ACTION" ]; then
  DIFF=$((NOW - LAST_ACTION))
  if [ "$DIFF" -le 20 ]; then
    # 切换模式
    if [ "$MODE" = "auto" ]; then
      echo 'MODE="signal"' > "$CONFIG"
      sed -i 's/^description=.*/description=【模式2:信号触发】截图后执行: touch \/data\/local\/tmp\/do_rotate | 执行Action查看详情\/手动处理\/切换模式/' "$PROP"
      NEW_MODE="模式2 - 信号触发"
      service call toast 1 s16 "已切换到模式2：信号触发" > /dev/null 2>&1
    else
      echo 'MODE="auto"' > "$CONFIG"
      sed -i 's/^description=.*/description=【模式1:自动检测】发现新截图自动旋转 | 执行Action查看详情\/手动处理\/切换模式/' "$PROP"
      NEW_MODE="模式1 - 自动检测"
      service call toast 1 s16 "已切换到模式1：自动检测" > /dev/null 2>&1
    fi
    echo "==============================="
    echo "检测到20秒内重复执行，正在切换模式..."
    echo "已切换到：$NEW_MODE"
    echo "==============================="
    echo "$TIPS"
    echo "==============================="
    exit 0
  fi
fi

# 正常执行
echo "==============================="
echo "当前模式：$MODE_NAME"
echo "==============================="

LATEST=$(find "$SCREENSHOT_DIR" -name "Screenshot_*.png" 2>/dev/null | xargs ls -t 2>/dev/null | head -1)
LAST=$(cat "$LAST_FILE" 2>/dev/null)

echo "【当前操作结果】"

if [ -z "$LATEST" ]; then
  echo "未找到截图文件"
  service call toast 1 s16 "未找到截图文件" > /dev/null 2>&1
elif [ "$LATEST" = "$LAST" ]; then
  echo "无新截图需要处理"
  echo "（最新截图已处理过）"
  service call toast 1 s16 "无新截图需要处理" > /dev/null 2>&1
else
  echo "正在处理：$LATEST"
  TMP_FILE="${LATEST}.rotating"

  LD_LIBRARY_PATH="$TOOLS_DIR" \
  "$TOOLS_DIR/pngtopnm" "$LATEST" | \
  "$TOOLS_DIR/pamflip" -rotate180 | \
  "$TOOLS_DIR/pnmtopng" > "$TMP_FILE" 2>/dev/null

  if [ -s "$TMP_FILE" ]; then
    mv "$TMP_FILE" "$LATEST"
    am broadcast -a android.intent.action.MEDIA_SCANNER_SCAN_FILE \
      -d "file://$LATEST" > /dev/null 2>&1
    echo "$LATEST" > "$LAST_FILE"
    echo "旋转成功：$(basename $LATEST)"
    service call toast 1 s16 "截图旋转成功" > /dev/null 2>&1
  else
    rm -f "$TMP_FILE"
    echo "旋转失败"
    service call toast 1 s16 "截图旋转失败" > /dev/null 2>&1
  fi
fi

echo ""
echo "$TIPS"
echo "==============================="
