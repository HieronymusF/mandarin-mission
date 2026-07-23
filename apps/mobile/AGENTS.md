# Mobile App Rules

本文件适用于 `apps/mobile/`。先遵守根目录 `AGENTS.md`，再应用以下移动端规则。

## 代码边界

- Flutter/Dart，Android 优先；架构为功能优先目录 + MVVM + Riverpod + go_router + Drift。
- View 只渲染状态和转发意图；异步提交、判分、Repository 调用和错误恢复放在 Controller/ViewModel。
- 本地操作先写 Drift 事务，再进入同步 Outbox；UI 不等待云端成功才更新。
- 外部媒体、网络和云能力通过 Service/Provider 接入；失败时保留可完成的本地降级路径。
- 不手工修改 `*.g.dart`、Drift 生成文件或平台工具生成结果。

## UI

- UI 任务先读根目录 `WIDGET_LIBRARY.md`、`docs/design-system.md` 和 `docs/development-workflow.md`。
- 单一代码基线是 `lib/core/theme/` 与 `lib/shared/presentation/app_widgets.dart`；继续使用固定版本的 `shadcn_ui` 和 Lucide，不混入 React/Tailwind 或第二套 UI 框架。
- 标准页面直接组合现有组件；品牌插画、复杂新交互或高成本方向比较时才使用 Figma/静态视觉稿。
- 新页面覆盖适用的正常、加载、空、错误、不可用和提交中状态。
- UI Bug 先在相同页面、状态、viewport 和文字缩放下复现并保存证据；优先修父容器、constraints、Flex 和共享 token。
- 新共享组件必须有两个真实生产调用点。

## 媒体与隐私

- 麦克风使用前说明用途并请求权限；普通拒绝、永久拒绝和服务不可用必须有不同且可恢复的状态。
- 原始录音默认只保留当前回放所需临时文件；离开页面、切后台、重录或释放资源时停止媒体并清理。
- 课程媒体路径必须来自内容包 `audioAssetId -> assets[].path`；Widget 不得根据 item ID 猜文件名。
- `ready` 只表示技术资源可用，不表示音色已获最终批准。

## 验证

优先调用 `$verify-mandarin-mission`，或从仓库根运行：

```powershell
.\tools\scripts\verify.ps1 -Scope mobile
```

涉及 Drift schema 时还要运行生成与迁移检查；涉及真实媒体、生命周期、权限或 UI 视觉时，自动测试不能替代 Android 真机/模拟器对应验收，并要明确证据等级。
