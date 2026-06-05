# CursorEnter

`CursorEnter` 是一个仅支持 macOS 的工具集，主入口是原生菜单栏 App。  
它会持续只对 Cursor 的 `Cursor Agents` 窗口发送 `Enter`，并尽量不抢占其他前台应用。

## 功能

- 菜单栏图标显示开 / 关状态
- 左键直接启动 / 停止
- 右键打开菜单（各菜单项带图标）
- 仅针对目标标题窗口发送 `Enter`（默认 `Cursor Agents`，可在设置中修改）
- 频率可调：`40 / 80 / 120 / 180 / 250 / 300 ms`
- 支持录制全局快捷键来切换开关
- 可打包为可双击安装的 `.app` / `.dmg`

## 运行要求

- macOS 13+
- 已安装桌面版 Cursor
- 已为 `CursorEnter` 授予“辅助功能”权限
- Cursor 中存在标题为 `Cursor Agents` 的窗口

## 快速开始

### 从 GitHub Release 安装

1. 打开本仓库的 Release 页面
2. 下载 `CursorEnter-<version>.dmg`
3. 双击打开 `.dmg`
4. 将 `CursorEnter.app` 拖到 `Applications`
5. 从 `Applications` 启动 `CursorEnter`
6. 首次运行后，在“系统设置 -> 隐私与安全性 -> 辅助功能”中允许 `CursorEnter`

如果第一次启动被 Gatekeeper 拦截：

1. 打开“系统设置 -> 隐私与安全性”
2. 找到被阻止的 `CursorEnter.app`
3. 手动选择“仍要打开”或允许它运行

当前 Release 安装包是本地 `ad-hoc` 签名版本，还没有做 Developer ID 签名和 notarization。

### 本地运行菜单栏 App

```bash
./script/build_and_run.sh
```

运行后：

- 左键菜单栏图标：直接切换开 / 关
- 右键菜单栏图标：打开菜单
- `Settings...`：录制全局快捷键

### 打包 `.app` / `.dmg`

```bash
./script/package_app.sh
```

生成产物：

- `artifacts/CursorEnter.app`
- `artifacts/CursorEnter-<version>.dmg`

### 使用方式

- 左键菜单栏图标：直接切换开始 / 停止
- 右键菜单栏图标：打开菜单
- `Frequency`：选择回车频率
- `Settings...`：录制全局快捷键
- `Quit`：退出应用

## 设置快捷键

右键菜单栏图标后：

1. 打开 `Settings...`
2. 点击快捷键输入框
3. 按下带修饰键的组合键
4. 保存后即可全局切换开始 / 停止

支持的修饰键：

- `Command`
- `Control`
- `Option`
- `Shift`

## 设置目标窗口标题

右键菜单栏图标后：

1. 打开 `Settings...`
2. 在 `Target Window Title` 输入框填写目标窗口标题
3. 失焦或回车后自动保存（留空会回退为默认的 `Cursor Agents`）

## 验证窗口定位

```bash
cd helper
swift run cursor-enter-helper --mode ax-dry-run --window-title "Cursor Agents"
```

成功时会看到类似输出：

```text
Cursor Agents    AXWindow    AXStandardWindow
```

## 开发

运行 Swift 测试：

```bash
cd helper
swift test
```

## 项目结构

- `helper/`：Swift 菜单栏 App、helper、测试
- `script/`：运行、测试和打包原生 App 的脚本

## 当前限制

- 当前打包产物是本地 `ad-hoc` 签名，不是 Developer ID 签名
- 还没有做 notarization
