# 音频播放与录音模块需求

## 用户问题与目标

用户在课程中需要听到普通话发音并进行口语练习。当前开发包已接入三条基于 Apache-2.0 Kokoro 模型生成的开发占位音频；自动校验可证明文件、打包和播放链，用户评价当前声线“能用但不满意”，不能把它当作最终课程音色。后续可替换为许可清晰且更自然的商用 TTS；录音与本地回放功能继续按真实设备验收。

**目标**：实现稳定、许可清晰且通过人工发音审核的课程音频播放、本地录音和回放，确保即使音频服务不可用也不阻断课程完成。

## 主路径

### 音频播放
1. 用户进入听力步骤时，自动播放课程音频
2. 用户可点击按钮重新播放音频
3. 播放时显示进度和播放状态
4. 播放完成或用户手动停止时清除状态

### 录音与回放
1. 用户进入口语步骤时，提供录音按钮和权限引导
2. 首次录音前明确说明用途并请求麦克风权限
3. 录音过程中显示录制状态和时长
4. 录音完成后提供回放、重新录制和确认选项
5. 在录制前进行基础音量检查，提示用户调整音量

### 权限处理
1. 首次使用时显示友好的权限说明
2. 权限被拒绝时提供降级路径（文本自评）
3. 系统设置中引导用户手动授予权限

## 必须覆盖的状态

### 音频播放
- **正常状态**：播放中、暂停、完成
- **加载状态**：音频资源加载中
- **错误状态**：音频文件不存在、格式不支持、播放失败
- **降级状态**：音频功能不可用时的文本提示

### 录音功能
- **正常状态**：录音中、回放中、完成
- **权限状态**：未请求、已授权、被拒绝、被永久拒绝
- **错误状态**：录音失败、保存失败、回放失败
- **降级状态**：麦克风不可用时的文本自评

## 数据来源与本地/远端边界

- **音频资源**：正式版本使用许可清晰、记录来源与哈希并通过人工发音审核的预生成文件；真人优先，合格 TTS 可用（R2 CDN 仅用于未来扩展）
- **录音数据**：仅保存在本地临时目录，应用退出后清除
- **权限状态**：本地系统权限 API
- **服务不可用降级**：本地文本自评路径

## 接口与 Repository 契约

### 音频服务接口
```dart
abstract class AudioService {
  Future<bool> get isAvailable;
  Future<void> playAudio(String assetPath);
  Future<void> stopAudio();
  Future<void> pauseAudio();
  Stream<AudioState> get audioState;
  Stream<double> get playbackPosition;
  Duration? get duration;
}

abstract class RecordingService {
  Future<bool> get isAvailable;
  Future<bool> get hasPermission;
  Future<bool> requestPermission();
  Future<void> startRecording();
  Future<String> stopRecording();
  Future<void> playRecording(String path);
  Future<void> stopPlayback();
  Stream<RecordingState> get recordingState;
  Future<double> getRecordingVolume();
  Future<bool> checkMinimumVolume(double threshold);
}
```

### UI 状态契约
```dart
class AudioPlayerState {
  final bool isLoading;
  final bool isPlaying;
  final bool isPaused;
  final bool hasError;
  final String? errorMessage;
  final double currentPosition;
  final double totalDuration;
  final bool isUnavailable;
}

class RecordingControllerState {
  final bool isRequestingPermission;
  final bool hasPermission;
  final bool isRecording;
  final bool isPlayingBack;
  final bool hasRecording;
  final String? recordingPath;
  final double recordingDuration;
  final double currentVolume;
  final String? errorMessage;
  final bool isUnavailable;
}
```

## 验收标准

### 功能验收
0. [x] 打包课程音频可从真实课程入口播放并在完成后复位
1. [ ] Kokoro 课程音频通过普通话人工试听，并可正常播放、暂停、重新播放
2. [x] 录音功能可在首次使用时正确请求权限
3. [x] 录音完成后可回放、重新录制
4. [x] 音量检查能提示用户调整麦克风音量
5. [x] 权限被拒绝时提供明确的文本自评降级
6. [x] 音频/录音服务完全不可用时不阻断课程

### 技术验收
1. [x] 遵循 MVVM 架构，View 不直接调用服务
2. [x] 播放与录音错误状态提供原地重试入口
3. [x] 所有状态变化都有明确的 UI 反馈
4. [x] 本地录音文件在重录或服务释放时清理
5. [x] Widget 测试覆盖播放/录音状态
6. [x] 在真实 Android 设备验证首次授权、普通拒绝/重试、永久拒绝、打开设置和设置返回恢复
7. [x] 切后台或从录音步骤返回上一课程步骤时自动停止媒体并清理当前临时录音

### 性能与稳定性
1. [x] 播放不阻塞 UI 线程
2. [x] 录音文件大小合理（Sony XQ-DQ72 上约 0.9 MB/分钟，AAC-LC 44.1 kHz）
3. [ ] 内存使用不泄露
4. [x] 应用切换到后台时停止录音、释放音频焦点并清理本次临时文件

真机证据（2026-07-23）：Sony `XQ-DQ72`、Android 15。课程第 5 步以 24 kHz 单声道播放包内音频；第 6 步完成权限用途说明、系统授权、普通拒绝后的说明与重试、永久拒绝后的 `Open Settings`、设置授权返回后的实时状态恢复、44.1 kHz 录音、本地 M4A 回放、重新录制、Home 切后台清理，以及录音中返回第 5 步的停止与临时文件清理。约 7 秒录音为 115,228 bytes，回放结束后恢复可播放状态。真实来电中断与恢复尚未在该设备验收。

## 明确不做的范围

1. ❌ 不实现云端语音评测（仅本地回放对比）
2. ❌ 不实现音频编辑功能
3. ❌ 不实现录音云端保存
4. ❌ 不实现实时波形显示（可后续添加）
5. ❌ 不实现背景音乐播放
6. ❌ 不实现音频下载管理（使用捆绑资源）

## 受影响的指标、Schema、迁移和隐私项

### Schema 变更
无需数据库 Schema 变更。录音数据为临时本地文件，不持久化到数据库。

### 隐私影响
- **麦克风权限**：需在 AndroidManifest.xml 声明，首次使用前说明用途
- **录音数据**：仅保存临时文件，应用退出后清除，不上传云端
- **错误报告**：不记录实际音频内容，仅记录操作状态和错误类型

### 权限声明
AndroidManifest.xml 添加：
```xml
<uses-permission android:name="android.permission.RECORD_AUDIO" />
```

录音写入应用临时目录，不申请外部存储权限。

## 依赖外部服务

1. **audioplayers** (pub.dev) - 音频播放
2. **record 7.1.1** (pub.dev) - 音频录制
3. **permission_handler** (pub.dev) - 权限管理
4. **path_provider** (pub.dev) - 临时文件路径

## 风险与限制

### 技术风险
- 不同设备音频编解码器兼容性
- 权限策略变更影响用户体验
- 低端设备录音质量问题

### 降级策略
- 音频播放失败 → 显示文本提示和替代引导
- 录音权限拒绝 → 提供文本自评路径
- 服务崩溃 → 自动重启并恢复状态

### 已知限制
- 首版不支持实时波形显示
- 不支持音频格式转换
- 不支持背景播放（应用切换后暂停）
