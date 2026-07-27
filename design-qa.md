# Settings 列表文字 Design QA

## 对照条件

- 设计真值：`C:\Users\Jerome\AppData\Local\Temp\codex-clipboard-8d794d37-9e88-4839-9305-b5f933368f88.png`
- 实现截图：`D:\Codex\UserData\.codex\visualizations\2026\07\27\019fa1b8-3091-77a3-bd16-2714a98ded6b\app-settings-typography-fixed.png`
- 页面状态：Android Debug APK，Settings 主页面顶部，未配置外部支持与政策资源
- 视口：Android 模拟器物理尺寸 `1080 × 2400`、密度 `420 dpi`，约 `411 × 914` 逻辑像素
- 像素归一化：设计真值与实现截图均为 `1080 × 2400`，无需缩放；同一完整页面状态直接对照
- 交互证据：从 Journey 点击底部 Settings 进入目标页面；前台 PID 日志中 `RenderFlex overflowed`、`RIGHT OVERFLOWED`、`FlutterError`、`FATAL EXCEPTION` 共 0 条

## 对照历史

### 第一次对照：blocked

- [P1] 四个条目标题缺少层级：设计标注明确要求字号更大、字重更高；原实现由按钮默认正文样式继承，标题 `fontSize` 没有显式值。
- [P1] 多行副标题居中：设计标注要求左对齐；原实现受按钮默认文本对齐影响，多行内容的第二行居中。

修复：只修改 `_SettingsRouteEntry`，标题使用现有 `theme.textTheme.large`（18px、600），标题和副标题显式 `TextAlign.left`；副标题继续使用 `theme.textTheme.muted`（14px、400）。卡片、图标、箭头、间距、颜色、文案、路由和点击行为均未改变。

### 第二次对照：passed

- 四个标题形成一致的 18px/600 层级。
- 四个副标题保持 14px/400，首行与换行均左对齐，标题和副标题左边线一致。
- 图标槽、箭头、分隔线、卡片高度和底部导航没有可见漂移。

## 必查表面

- 字体与排版：通过。标题字号、字重和副标题对齐符合标注；换行自然，无截断或溢出。
- 间距与布局节奏：通过。文字列左边线一致，四行高度、图标和箭头位置保持稳定。
- 颜色与令牌：通过。继续使用既有主题色与 typography token，没有新增颜色或随机字号。
- 图像与图标：通过。本区域没有位图资产；现有 Lucide 图标未替换、未变形。
- 文案与内容：通过。所有可见英文文案保持不变。

## 剩余项

- 无 P0/P1/P2 问题。
- 本轮为 Android 模拟器视觉证据，未连接 Sony 真机。

final result: passed
