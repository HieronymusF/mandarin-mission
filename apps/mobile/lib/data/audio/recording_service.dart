import 'dart:async';

/// 录音状态
enum RecordingState {
  /// 空闲状态
  idle,

  /// 请求权限中
  requestingPermission,

  /// 等待录音
  ready,

  /// 录音中
  recording,

  /// 回放中
  playing,

  /// 已停止
  stopped,

  /// 错误状态
  error,

  /// 不可用
  unavailable,
}

/// 录音服务接口
abstract class RecordingService {
  /// 录音功能是否可用
  Future<bool> get isAvailable;

  /// 是否有麦克风权限
  Future<bool> get hasPermission;

  /// 是否已被永久拒绝（需要用户手动去设置中开启）
  Future<bool> get isPermanentlyDenied;

  /// 请求麦克风权限
  Future<bool> requestPermission();

  /// 打开系统设置页面（用于权限被永久拒绝时）
  Future<void> openAppSettings();

  /// 开始录音
  Future<void> startRecording();

  /// 停止录音，返回录音文件路径
  Future<String> stopRecording();

  /// 取消录音
  Future<void> cancelRecording();

  /// 回放录音
  Future<void> playRecording(String filePath);

  /// 停止回放
  Future<void> stopPlayback();

  /// 删除当前会话的临时录音文件
  Future<void> clearRecording();

  /// 录音状态流
  Stream<RecordingState> get recordingState;

  /// 当前录音时长（秒）
  Stream<double> get recordingDuration;

  /// 获取当前音量级别 (0.0-1.0)
  Future<double> getCurrentVolume();

  /// 检查最小音量是否达标
  Future<bool> checkMinimumVolume(double threshold);

  /// 音量级别流（用于显示音量指示器）
  Stream<double> get volumeLevel;

  /// 清理临时录音文件
  Future<void> dispose();
}
