# 媒体能力与降级：能听、能录，也能在不可用时继续

媒体模块当前解决的是状态与边界：课程知道何时有可播放资产，播放与录音服务把平台能力包装成状态流，Controller 把错误、权限和回放状态变成 UI。三条 Kokoro TTS 开发占位音频已进入课程包；当前声线能用于流程验证，但用户未通过最终听感验收，后续可能替换为许可清晰的商用 TTS。

## 播放链从内容状态开始

听力或教学步骤不会根据知识点 ID 猜文件名。`CoursePackage.audioAssetPathForItem` 先通过知识点的 `audioAssetId` 找资产，再要求资产为 `audio + ready`。只有拿到路径后，播放 Controller 才调用服务。

| 内容或服务状态 | UI 应看到什么 | 当前证据 |
| --- | --- | --- |
| ready 路径、服务可用 | 加载、播放/暂停、进度、结束复位 | Controller、内容路径测试、模拟器与 Sony 真机打包音频播放 |
| 资产 planned 或缺失 | 明确显示课程音频不可用 | 内容模型与无资产 Widget 测试；当前图片仍 planned |
| 播放异常 | 错误提示和原地重试入口 | `AudioPlayerState.errorMessage` 与播放条分支 |
| 服务不可用 | 本地文本/自评降级，课程可继续 | Controller 测试和课程 UI |

[媒体播放条](../../apps/mobile/lib/shared/presentation/audio_player_bar.dart) 只渲染状态并发送播放、暂停、继续和重试意图；实际平台调用在 [音频 Service 实现](../../apps/mobile/lib/data/audio/audio_service_impl.dart)。

到期复习的 listening 题也复用同一条内容路径。复习条目从 `audioAssetId` 解析 `ready` 音频并显示播放器；`planned`、缺失或无路径时显示书面降级。只有走书面降级后揭晓答案才会记录 `usedHint: true`，正常播放路径揭晓不会被误记为提示。

播放失败时，`Try again` 会用当前 asset 路径重新调用播放器；录音失败时，`Try recording again` 会在当前口语步骤重新开始录制。已保存录音的回放失败时，控件会保留临时文件，显示专用错误说明，并通过 `Try playback again` 重试同一路径。三条路径都保留课程上下文，不要求用户退出页面。

## 录音权限不是一个布尔值

录音 Controller 区分：尚未请求、已授权、拒绝、永久拒绝、服务不可用。普通拒绝会显示独立说明、再次授权入口，并指出用户仍可继续无录音自评；永久拒绝需要引导打开系统设置；服务不可用则直接进入降级，不能伪装成用户拒绝权限。

获得权限后，录音状态会产生时长与归一化音量；停止后保存临时路径，允许回放、停止、重录和确认。重录或释放服务时清理旧临时文件，原始录音不上传。

课程页会监听应用生命周期。App 进入非 `resumed` 状态时，录音 Controller 会结束当前媒体会话；恢复到 `resumed` 时会重新读取平台麦克风权限，因此用户在系统设置授权后返回 App，不会停留在旧的“永久拒绝”状态。页面销毁和课程头部的步骤返回共用同一个幂等清理 Future：停止共享播放器、取消正在进行的录音或停止回放，并删除当前临时录音；步骤返回会等待清理完成后再导航。连续生命周期事件会复用同一次清理，开始下一次录音前也会先清掉旧文件。

[录音控件](../../apps/mobile/lib/shared/presentation/recording_controls.dart) 承担这些可见状态，[录音 Service](../../apps/mobile/lib/data/audio/recording_service_impl.dart) 包装 `record`、权限和临时目录，[媒体 Controller 测试](../../apps/mobile/test/data/audio/audio_controller_test.dart) 已确认已有权限恢复、永久拒绝与不可用区分、回放完成复位。

[媒体组件测试](../../apps/mobile/test/shared/presentation/media_controls_test.dart) 继续覆盖播放 loading/playing/paused/error、无资产降级、权限请求/拒绝/永久拒绝/服务不可用，以及录音、音量、回放、回放失败重试和确认。[媒体生命周期测试](../../apps/mobile/test/features/lesson/lesson_media_lifecycle_test.dart) 覆盖切后台、设置返回刷新和从录音步骤返回时的停止与清理，[Controller 测试](../../apps/mobile/test/data/audio/audio_controller_test.dart) 覆盖回放失败保留文件、结束会话的状态竞态和平台权限刷新。加载时显示 40 × 40 进度反馈；录音服务不可用时优先显示文本自评降级，不会被普通权限卡遮住。

新 APK 已在模拟器从 Journey 的真实到期队列进入 listening 复习。页面显示 `Play prompt` 且没有音频不可用提示；点击后 Android 日志确认当前 App 获取音频焦点并解码 24 kHz、单声道 `audio/raw`，播放结束后释放焦点。这证明复习入口使用了打包音频，不证明发音质量或真机行为。

Sony `XQ-DQ72`（Android 15）已完成课程媒体主路径和权限分支真机验证：第 5 步播放 24 kHz 单声道包内音频并在结束后释放音频焦点；第 6 步从用途说明进入系统授权，以 44.1 kHz 录制本地 M4A，再回放同一文件并在结束后复位。普通拒绝会显示重试与无录音继续入口；永久拒绝会显示 `Open Settings`，在设置中授权并返回后页面立即恢复 `Tap to record`。重新录制、录音中按 Home，以及录音中返回第 5 步都会停止媒体并删除当前临时文件。约 7 秒录音为 115,228 bytes，折算约 0.9 MB/分钟；音频内容没有导出或读取。

## 当前未确认的边界

- 三条音频由 Kokoro-82M v1.0 的 `zf_xiaoxiao`（speaker 47、0.95 语速）声线生成，模型和 `sherpa-onnx 1.13.4` 工具采用 Apache-2.0；旧 `zf_xiaoyi` 因机械感明显被否决，当前声线也只获得“能用但不满意”的反馈，属于开发占位。后续可以换用更自然的商用 TTS，但仍要核验输出发布权、声线授权、数据条款、价格并重新完成人工试听。
- Sony 真机已验证首次授权、普通拒绝与重试、永久拒绝、打开设置和设置返回恢复；服务不可用分支仍只有自动测试证据。
- Home 切后台和从第 6 步返回第 5 步的自动停止/清理已在 Sony 真机通过；真实来电中断与恢复仍未完成真机验收。
- 单次短录音的文件大小已有真机测量；长时间录制的内存与文件增长仍未验证。

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
