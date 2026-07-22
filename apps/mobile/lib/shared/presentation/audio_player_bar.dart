import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_layout.dart';
import '../../data/audio/audio_providers.dart';

/// 音频播放器进度条组件
class AudioPlayerBar extends ConsumerWidget {
  const AudioPlayerBar({
    required this.assetPath,
    this.showLabel = true,
    this.label = 'Play audio',
    super.key,
  });

  final String? assetPath;
  final bool showLabel;
  final String label;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ShadTheme.of(context);
    if (assetPath == null) {
      return _AudioUnavailableCard(theme: theme);
    }

    final playerState = ref.watch(audioPlayerControllerProvider);
    final controller = ref.read(audioPlayerControllerProvider.notifier);

    // 如果音频不可用，显示提示
    if (playerState.isUnavailable) {
      return _AudioUnavailableCard(theme: theme);
    }

    // 显示播放按钮和进度条
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 播放控制按钮
        Row(
          children: [
            if (playerState.isLoading)
              const SizedBox(
                width: 40,
                height: 40,
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.sm),
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            else if (playerState.isPlaying)
              ShadButton.secondary(
                onPressed: controller.pauseAudio,
                width: 40,
                height: 40,
                padding: EdgeInsets.zero,
                child: const Icon(LucideIcons.pause, size: 16),
              )
            else if (playerState.isPaused)
              ShadButton.secondary(
                onPressed: controller.resumeAudio,
                width: 40,
                height: 40,
                padding: EdgeInsets.zero,
                child: const Icon(LucideIcons.play, size: 16),
              )
            else
              ShadButton.secondary(
                onPressed: () => controller.playAudio(assetPath!),
                width: 40,
                height: 40,
                padding: EdgeInsets.zero,
                child: const Icon(LucideIcons.play, size: 16),
              ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _ProgressBar(
                progress: playerState.currentPosition,
                onChanged: playerState.isPlaying || playerState.isPaused
                    ? (value) => controller.seekTo(value)
                    : null,
              ),
            ),
            if (showLabel) ...[
              const SizedBox(width: AppSpacing.sm),
              Text(label, style: theme.textTheme.small),
            ],
          ],
        ),
        if (playerState.hasError && playerState.errorMessage != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            playerState.errorMessage!,
            style: theme.textTheme.small.copyWith(
              color: theme.colorScheme.destructive,
            ),
          ),
        ],
      ],
    );
  }
}

class _AudioUnavailableCard extends StatelessWidget {
  const _AudioUnavailableCard({required this.theme});

  final ShadThemeData theme;

  @override
  Widget build(BuildContext context) {
    return ShadCard(
      padding: AppLayout.compactCardPadding,
      backgroundColor: theme.colorScheme.muted.withValues(alpha: .3),
      child: Row(
        children: [
          Icon(
            LucideIcons.volume2,
            size: 16,
            color: theme.colorScheme.mutedForeground,
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            'Audio unavailable',
            style: theme.textTheme.small.copyWith(
              color: theme.colorScheme.mutedForeground,
            ),
          ),
        ],
      ),
    );
  }
}

/// 进度条组件
class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.progress, this.onChanged});

  final double progress;
  final ValueChanged<double>? onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final enabled = onChanged != null;

    return LayoutBuilder(
      builder: (context, constraints) {
        return SliderTheme(
          data: SliderThemeData(
            trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
            activeTrackColor: theme.colorScheme.primary,
            inactiveTrackColor: theme.colorScheme.muted.withValues(alpha: .3),
            thumbColor: theme.colorScheme.primary,
            overlayColor: theme.colorScheme.primary.withValues(alpha: .1),
          ),
          child: Slider(
            value: progress.clamp(0.0, 1.0),
            onChanged: enabled
                ? (value) {
                    if (onChanged != null) {
                      onChanged!(value);
                    }
                  }
                : null,
          ),
        );
      },
    );
  }
}

/// Round slider thumb shape
class RoundSliderThumbShape extends SliderComponentShape {
  const RoundSliderThumbShape({this.enabledThumbRadius = 6.0});

  final double enabledThumbRadius;

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required Size sizeWithOverflow,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double textScaleFactor,
    required double value,
  }) {
    final canvas = context.canvas;
    final paint = Paint()
      ..color = sliderTheme.thumbColor ?? Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, enabledThumbRadius, paint);
  }

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size.fromRadius(enabledThumbRadius);
  }
}

/// Round slider overlay shape
class RoundSliderOverlayShape extends SliderComponentShape {
  const RoundSliderOverlayShape({this.overlayRadius = 12.0});

  final double overlayRadius;

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required Size sizeWithOverflow,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double textScaleFactor,
    required double value,
  }) {
    final canvas = context.canvas;
    final paint = Paint()
      ..color = (sliderTheme.thumbColor ?? Colors.white).withValues(alpha: 0.1)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, overlayRadius, paint);
  }

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size.fromRadius(overlayRadius);
  }
}
