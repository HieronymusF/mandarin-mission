import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_layout.dart';
import '../../data/audio/audio_providers.dart';

/// 录音控制组件
class RecordingControls extends ConsumerWidget {
  const RecordingControls({
    required this.onRecordingComplete,
    this.maxDuration = 30.0,
    this.minVolumeThreshold = 0.1,
    super.key,
  });

  final ValueChanged<String> onRecordingComplete;
  final double maxDuration;
  final double minVolumeThreshold;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ShadTheme.of(context);
    final recordingState = ref.watch(recordingControllerProvider);
    final controller = ref.read(recordingControllerProvider.notifier);

    // 权限被永久拒绝
    if (recordingState.isPermanentlyDenied) {
      return ShadCard(
        padding: AppLayout.compactCardPadding,
        backgroundColor: theme.colorScheme.destructive.withValues(alpha: .1),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(
                  LucideIcons.shieldAlert,
                  size: 20,
                  color: theme.colorScheme.destructive,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'Microphone permission required',
                    style: theme.textTheme.small.copyWith(
                      color: theme.colorScheme.destructive,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Please enable microphone access in your device settings to use recording features.',
              style: theme.textTheme.small,
            ),
            const SizedBox(height: AppSpacing.sm),
            ShadButton.outline(
              onPressed: controller.openAppSettings,
              child: const Text('Open Settings'),
            ),
          ],
        ),
      );
    }

    // 正在请求权限
    if (recordingState.isRequestingPermission) {
      return ShadCard(
        padding: AppLayout.compactCardPadding,
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: AppSpacing.md),
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Requesting microphone permission...',
                style: theme.textTheme.small,
              ),
              const SizedBox(height: AppSpacing.md),
            ],
          ),
        ),
      );
    }

    // 录音不可用降级
    if (recordingState.isUnavailable) {
      return ShadCard(
        padding: AppLayout.compactCardPadding,
        backgroundColor: theme.colorScheme.muted.withValues(alpha: .3),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(
                  LucideIcons.micOff,
                  size: 20,
                  color: theme.colorScheme.mutedForeground,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'Recording unavailable',
                    style: theme.textTheme.small.copyWith(
                      color: theme.colorScheme.mutedForeground,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'You can still complete this lesson using text-based assessment.',
              style: theme.textTheme.small,
            ),
          ],
        ),
      );
    }

    // 检查权限状态
    if (!recordingState.hasPermission) {
      return _PermissionRequestCard(
        onRequestPermission: controller.requestPermission,
      );
    }

    // 录音主界面
    return ShadCard(
      padding: AppLayout.compactCardPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 音量指示器
          if (recordingState.isRecording)
            _VolumeIndicator(
              volume: recordingState.currentVolume,
              minThreshold: minVolumeThreshold,
            ),

          // 录音时长显示
          if (recordingState.isRecording ||
              recordingState.recordingDuration > 0)
            Text(
              _formatDuration(recordingState.recordingDuration),
              style: theme.textTheme.small.copyWith(
                color: theme.colorScheme.mutedForeground,
              ),
              textAlign: TextAlign.center,
            ),

          const SizedBox(height: AppSpacing.md),

          // 录音控制按钮
          if (!recordingState.hasRecording)
            _RecordingButton(
              isRecording: recordingState.isRecording,
              duration: recordingState.recordingDuration,
              maxDuration: maxDuration,
              onPressed: recordingState.isRecording
                  ? controller.stopRecording
                  : controller.startRecording,
            )
          else
            _PlaybackControls(
              isPlaying: recordingState.isPlayingBack,
              hasRecording: recordingState.hasRecording,
              onReRecord: () {
                controller.cancelRecording();
              },
              onPlay: controller.playRecording,
              onStop: controller.stopPlayback,
              onConfirm: () {
                if (recordingState.recordingPath != null) {
                  onRecordingComplete(recordingState.recordingPath!);
                }
              },
            ),

          if (recordingState.errorMessage != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              recordingState.errorMessage!,
              style: theme.textTheme.small.copyWith(
                color: theme.colorScheme.destructive,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  String _formatDuration(double seconds) {
    final mins = (seconds / 60).floor();
    final secs = (seconds % 60).floor();
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }
}

/// 权限请求卡片
class _PermissionRequestCard extends StatelessWidget {
  const _PermissionRequestCard({required this.onRequestPermission});

  final VoidCallback onRequestPermission;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return ShadCard(
      padding: AppLayout.compactCardPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(LucideIcons.mic, size: 20, color: theme.colorScheme.primary),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'Microphone Access',
                  style: theme.textTheme.small.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'This lesson requires microphone access for speaking practice. Your recordings are stored locally and never uploaded.',
            style: theme.textTheme.small,
          ),
          const SizedBox(height: AppSpacing.md),
          ShadButton(
            onPressed: onRequestPermission,
            child: const Text('Allow Microphone Access'),
          ),
        ],
      ),
    );
  }
}

/// 录音按钮
class _RecordingButton extends StatelessWidget {
  const _RecordingButton({
    required this.isRecording,
    required this.duration,
    required this.maxDuration,
    required this.onPressed,
  });

  final bool isRecording;
  final double duration;
  final double maxDuration;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final progress = duration / maxDuration;
    final isMaxReached = duration >= maxDuration;

    return Column(
      children: [
        // 录音按钮
        GestureDetector(
          onTap: isRecording
              ? onPressed
              : isMaxReached
              ? null
              : onPressed,
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isRecording
                  ? theme.colorScheme.destructive
                  : theme.colorScheme.primary,
              boxShadow: [
                BoxShadow(
                  color:
                      (isRecording
                              ? theme.colorScheme.destructive
                              : theme.colorScheme.primary)
                          .withValues(alpha: 0.3),
                  blurRadius: 12,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: Icon(
              isRecording ? LucideIcons.square : LucideIcons.mic,
              size: 28,
              color: theme.colorScheme.primaryForeground,
            ),
          ),
        ),

        const SizedBox(height: AppSpacing.sm),

        // 提示文本
        Text(
          isRecording
              ? 'Tap to stop'
              : isMaxReached
              ? 'Maximum duration reached'
              : 'Tap to record',
          style: theme.textTheme.small,
          textAlign: TextAlign.center,
        ),

        // 进度条
        if (isRecording)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.sm),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              backgroundColor: theme.colorScheme.muted.withValues(alpha: .3),
              valueColor: AlwaysStoppedAnimation<Color>(
                theme.colorScheme.destructive,
              ),
            ),
          ),
      ],
    );
  }
}

/// 回放控制
class _PlaybackControls extends StatelessWidget {
  const _PlaybackControls({
    required this.isPlaying,
    required this.hasRecording,
    required this.onReRecord,
    required this.onPlay,
    required this.onStop,
    required this.onConfirm,
  });

  final bool isPlaying;
  final bool hasRecording;
  final VoidCallback onReRecord;
  final VoidCallback onPlay;
  final VoidCallback onStop;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 回放按钮
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isPlaying)
              ShadButton.secondary(
                onPressed: onStop,
                width: 48,
                height: 48,
                padding: EdgeInsets.zero,
                child: const Icon(LucideIcons.square, size: 20),
              )
            else
              ShadButton.secondary(
                onPressed: hasRecording ? onPlay : null,
                width: 48,
                height: 48,
                padding: EdgeInsets.zero,
                child: const Icon(LucideIcons.play, size: 20),
              ),
            const SizedBox(width: AppSpacing.sm),
            ShadButton.outline(
              onPressed: onReRecord,
              width: 48,
              height: 48,
              padding: EdgeInsets.zero,
              child: const Icon(LucideIcons.refreshCw, size: 20),
            ),
          ],
        ),

        const SizedBox(height: AppSpacing.md),

        // 确认按钮
        ShadButton(
          onPressed: hasRecording ? onConfirm : null,
          width: double.infinity,
          child: const Text('Use this recording'),
        ),
      ],
    );
  }
}

/// 音量指示器
class _VolumeIndicator extends StatelessWidget {
  const _VolumeIndicator({required this.volume, required this.minThreshold});

  final double volume;
  final double minThreshold;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final isAboveThreshold = volume >= minThreshold;

    return Column(
      children: [
        // 音量条
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: theme.colorScheme.muted.withValues(alpha: .3),
            borderRadius: BorderRadius.circular(AppRadius.xs),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: volume.clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                color: isAboveThreshold ? Colors.green : Colors.orange,
                borderRadius: BorderRadius.circular(AppRadius.xs),
              ),
            ),
          ),
        ),

        const SizedBox(height: AppSpacing.xs),

        // 音量提示
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              isAboveThreshold ? 'Good volume' : 'Speak louder',
              style: theme.textTheme.small.copyWith(
                color: isAboveThreshold ? Colors.green : Colors.orange,
                fontSize: 10,
              ),
            ),
            Icon(
              isAboveThreshold
                  ? LucideIcons.badgeCheck
                  : LucideIcons.alertCircle,
              size: 12,
              color: isAboveThreshold ? Colors.green : Colors.orange,
            ),
          ],
        ),
      ],
    );
  }
}
