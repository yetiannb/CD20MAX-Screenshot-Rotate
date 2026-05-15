# 截图自动旋转修复模块
版本：v3.0 | 作者：yetiannb
GitHub：https://github.com/yetiannb/CD20MAX-Screenshot-Rotate

## 模块说明
本模块用于修复安卓手表截图翻转180度的问题，
支持两种工作模式，可随时切换。

## 工作模式

### 模式1：自动检测（默认）
- 模块在后台自动监听截图文件夹
- 发现新截图立即自动旋转180度
- 无需任何额外操作

### 模式2：信号触发
- 模块等待触发器发送信号后再处理
- 适合配合Xposed Edge Pro等触发器使用
- 触发器设置方法（以Xposed Edge Pro为例）：
  ① 新建手势/按键动作
  ② 选择多重动作
  ③ 第一步：系统截图
  ④ 第二步：延迟1秒
  ⑤ 第三步：执行Shell命令：
     touch /data/local/tmp/do_rotate

## 手动操作（Action）
在Magisk模块页面点击Action按钮可以：
- 查看当前模式和使用说明
- 手动处理最新截图
- 切换工作模式（20秒内再次点击即切换）

## 切换模式方法
1. 点击一次Action：手动处理截图
2. 在20秒内再次点击Action：切换模式
3. 切换后立即生效，无需重启

## 截图保存目录
/storage/emulated/0/Pictures/Screenshots/

## 注意事项
- 仅处理文件名以 Screenshot_ 开头的PNG文件
- 模块工具链位于模块目录 tools/ 文件夹下
- 运行日志位于 /data/local/tmp/screenshot_rotate.log
- 本模块专为DotOS系统CD20MAX手表适配
  其他设备截图若无翻转问题请勿安装

## 依赖工具
- pngtopnm / pamflip / pnmtopng（netpbm）
- inotifywait（inotify-tools）
- 以上工具已内置于模块，无需额外安装
