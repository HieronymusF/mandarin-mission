import 'dart:async';

/// 音频播放状态
enum AudioState {
  /// 空闲状态
  idle,

  /// 加载中
  loading,

  /// 播放中
  playing,

  /// 已暂停
  paused,

  /// 已停止
  stopped,

  /// 错误状态
  error,

  /// 不可用
  unavailable,
}

/// 音频服务接口
abstract class AudioService {
  /// 音频功能是否可用
  Future<bool> get isAvailable;

  /// 播放指定音频资源
  Future<void> playAudio(String assetPath);

  /// 停止播放
  Future<void> stopAudio();

  /// 暂停播放
  Future<void> pauseAudio();

  /// 继续播放
  Future<void> resumeAudio();

  /// 跳转到指定位置
  Future<void> seekTo(Duration position);

  /// 音频状态流
  Stream<AudioState> get audioState;

  /// 播放位置流（0.0-1.0）
  Stream<double> get playbackPosition;

  /// 当前音频总时长
  Duration? get duration;

  /// 释放资源
  Future<void> dispose();

  /// 设置音量 (0.0-1.0)
  Future<void> setVolume(double volume);
}
