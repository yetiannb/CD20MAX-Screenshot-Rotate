#!/system/bin/sh

MODDIR="/data/adb/modules/screenshot_rotate_fix"
TOOLS_DIR="$MODDIR/tools"
SCREENSHOT_DIR="/storage/emulated/0/Pictures/Screenshots"
LOG_FILE="/data/local/tmp/screenshot_rotate.log"
SIGNAL_FILE="/data/local/tmp/do_rotate"
LAST_FILE="/data/local/tmp/screenshot_last.txt"
CONFIG="$MODDIR/config.sh"

# 等待系统启动完成
sleep 30

. "$CONFIG"

echo "$(date): 服务启动 模式=$MODE" >> "$LOG_FILE"

do_rotate() {
  local FILE="$1"
  local TMP_FILE="${FILE}.rotating"

  LD_LIBRARY_PATH="$TOOLS_DIR" \
  "$TOOLS_DIR/pngtopnm" "$FILE" | \
  "$TOOLS_DIR/pamflip" -rotate180 | \
  "$TOOLS_DIR/pnmtopng" > "$TMP_FILE" 2>> "$LOG_FILE"

  if [ -s "$TMP_FILE" ]; then
    mv "$TMP_FILE" "$FILE"
    am broadcast -a android.intent.action.MEDIA_SCANNER_SCAN_FILE \
      -d "file://$FILE" > /dev/null 2>&1
    echo "$FILE" > "$LAST_FILE"
    echo "$(date): 旋转成功 $FILE" >> "$LOG_FILE"
    service call toast 1 s16 "截图旋转成功" > /dev/null 2>&1
    return 0
  else
    rm -f "$TMP_FILE"
    echo "$(date): 旋转失败 $FILE" >> "$LOG_FILE"
    service call toast 1 s16 "截图旋转失败" > /dev/null 2>&1
    return 1
  fi
}

while true; do
  . "$CONFIG"

  if [ "$MODE" = "auto" ]; then
    LATEST=$(find "$SCREENSHOT_DIR" -name "Screenshot_*.png" 2>/dev/null | xargs ls -t 2>/dev/null | head -1)
    LAST=$(cat "$LAST_FILE" 2>/dev/null)

    if [ -n "$LATEST" ] && [ "$LATEST" != "$LAST" ] && [ -s "$LATEST" ]; then
      sleep 1
      do_rotate "$LATEST"
    fi

  elif [ "$MODE" = "signal" ]; then
    if [ -f "$SIGNAL_FILE" ]; then
      rm -f "$SIGNAL_FILE"
      sleep 1

      LATEST=$(find "$SCREENSHOT_DIR" -name "Screenshot_*.png" 2>/dev/null | xargs ls -t 2>/dev/null | head -1)

      if [ -n "$LATEST" ] && [ -s "$LATEST" ]; then
        do_rotate "$LATEST"
      else
        service call toast 1 s16 "截图旋转失败：未找到文件" > /dev/null 2>&1
      fi
    fi
  fi

  sleep 2
done &
