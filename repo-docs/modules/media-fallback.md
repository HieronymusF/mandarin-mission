# 媒体能力与降级：能听、能录，也能在不可用时继续

媒体模块当前解决的是状态与边界：课程知道何时有可播放资产，播放与录音服务把平台能力包装成状态流，Controller 把错误、权限和回放状态变成 UI。真人资产和 Android 真机验收仍是计划中工作。

## 播放链从内容状态开始

听力或教学步骤不会根据知识点 ID 猜文件名。`CoursePackage.audioAssetPathForItem` 先通过知识点的 `audioAssetId` 找资产，再要求资产为 `audio + ready`。只有拿到路径后，播放 Controller 才调用服务。

| 内容或服务状态 | UI 应看到什么 | 当前证据 |
| --- | --- | --- |
| ready 路径、服务可用 | 加载、播放/暂停、进度、结束复位 | Controller 与内容路径测试；缺真人资产真机证据 |
| 资产 planned 或缺失 | 明确显示课程音频不可用 | 当前 Fixture 与内容模型 |
| 播放异常 | 错误提示和重试入口 | `AudioPlayerState.errorMessage` 与播放条分支 |
| 服务不可用 | 本地文本/自评降级，课程可继续 | Controller 测试和课程 UI |

[媒体播放条](../../apps/mobile/lib/shared/presentation/audio_player_bar.dart) 只渲染状态并发送播放、暂停、继续和重试意图；实际平台调用在 [音频 Service 实现](../../apps/mobile/lib/data/audio/audio_service_impl.dart)。

## 录音权限不是一个布尔值

录音 Controller 区分：尚未请求、已授权、拒绝、永久拒绝、服务不可用。永久拒绝需要引导打开系统设置；服务不可用则直接进入降级，不能伪装成用户拒绝权限。

获得权限后，录音状态会产生时长与归一化音量；停止后保存临时路径，允许回放、停止、重录和确认。重录或释放服务时清理旧临时文件，原始录音不上传。

课程页会监听应用生命周期。App 进入非 `resumed` 状态或用户离开课程页时，录音 Controller 会结束当前媒体会话：停止共享播放器、取消正在进行的录音或停止回放，并删除当前临时录音。连续到来的生命周期事件会共用同一次清理，避免重复取消录音；开始下一次录音前也会先清掉旧文件。

[录音控件](../../apps/mobile/lib/shared/presentation/recording_controls.dart) 承担这些可见状态，[录音 Service](../../apps/mobile/lib/data/audio/recording_service_impl.dart) 包装 `record`、权限和临时目录，[媒体 Controller 测试](../../apps/mobile/test/data/audio/audio_controller_test.dart) 已确认已有权限恢复、永久拒绝与不可用区分、回放完成复位。

[媒体组件测试](../../apps/mobile/test/shared/presentation/media_controls_test.dart) 继续覆盖播放 loading/playing/paused/error、无资产降级、权限请求/拒绝/永久拒绝/服务不可用，以及录音、音量、回放和确认。[媒体生命周期测试](../../apps/mobile/test/features/lesson/lesson_media_lifecycle_test.dart) 覆盖切后台和离开课程页时的停止与清理，[Controller 测试](../../apps/mobile/test/data/audio/audio_controller_test.dart) 覆盖结束会话的状态竞态。加载时显示 40 × 40 进度反馈；录音服务不可用时优先显示文本自评降级，不会被普通权限卡遮住。

## 当前未确认的边界

- 真人普通话资产尚未加入，三个音频资产仍为 `planned`。
- 尚未在 Android 真机验证首次权限、拒绝、永久拒绝、录音、回放和音量提示。
- 切后台和页面离开的自动停止/清理已有 Widget 测试；来电中断、恢复后的真实播放器/录音器状态仍未在 Android 真机验收。
- 文件大小与长期内存行为尚无真机测量。

这些缺口不妨碍文本降级完成课程，但会阻止 M1 媒体里程碑标记完成。

## 最小验证入口

```powershell
Set-Location apps/mobile
flutter test test/data/audio/audio_controller_test.dart
flutter test test/shared
flutter analyze
flutter build apk --debug
```

自动测试只能证明状态与构建。真实设备验收仍应按根目录 `docs/requirements/audio-recording.md` 逐项执行。媒体接入课程的位置可从 [代码地图的 data 与 shared 区域](../code-map.md#appsmobilelibdata)继续定位。

证据状态：除特别标注外，本页基于当前源码已确认。
