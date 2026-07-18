import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../core/theme/app_layout.dart';
import '../../../../data/content/course_content_models.dart';
import '../../../../shared/presentation/app_leading_row.dart';
import '../../../../shared/presentation/hanzi_pinyin_text.dart';

enum HanziWritingPhase { trace, recall, compare }

typedef HanziWritingSelfCheckChanged =
    void Function(String? value, {required bool usedHint});

class HanziWritingStep extends StatefulWidget {
  const HanziWritingStep({
    required this.item,
    required this.supportText,
    required this.selectedSelfCheck,
    required this.onSelfCheckChanged,
    super.key,
  });

  final CourseKnowledgeItem item;
  final String? supportText;
  final String? selectedSelfCheck;
  final HanziWritingSelfCheckChanged onSelfCheckChanged;

  @override
  State<HanziWritingStep> createState() => _HanziWritingStepState();
}

class _HanziWritingStepState extends State<HanziWritingStep> {
  HanziWritingPhase _phase = HanziWritingPhase.trace;
  List<List<Offset>> _strokes = [];
  bool _usedHint = false;

  bool get _hasInk => _strokes.any((stroke) => stroke.isNotEmpty);

  void _setStrokes(List<List<Offset>> strokes) {
    setState(() => _strokes = strokes);
  }

  void _clear() {
    setState(() => _strokes = []);
  }

  void _beginRecall() {
    if (!_hasInk) return;
    setState(() {
      _phase = HanziWritingPhase.recall;
      _strokes = [];
    });
    widget.onSelfCheckChanged(null, usedHint: _usedHint);
  }

  void _compare() {
    if (!_hasInk) return;
    setState(() => _phase = HanziWritingPhase.compare);
  }

  void _skipDrawing() {
    setState(() {
      _usedHint = true;
      _phase = HanziWritingPhase.compare;
    });
    widget.onSelfCheckChanged(null, usedHint: true);
  }

  void _restart() {
    setState(() {
      _phase = HanziWritingPhase.trace;
      _strokes = [];
      _usedHint = false;
    });
    widget.onSelfCheckChanged(null, usedHint: false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final highTextScale = MediaQuery.textScalerOf(context).scale(1) > 1.5;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ShadCard(
          key: const Key('hanzi-writing-intro'),
          width: double.infinity,
          padding: AppLayout.compactCardPadding,
          backgroundColor: theme.colorScheme.accent,
          border: ShadBorder.none,
          child: AppLeadingRow(
            leadingWidth: AppLayout.noticeIconSlot,
            gap: AppSpacing.sm,
            leading: Icon(
              LucideIcons.pencilLine,
              size: 20,
              color: theme.colorScheme.accentForeground,
            ),
            child: Text(
              widget.supportText ??
                  'Trace the characters, then write them from memory.',
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        _WritingPhaseRow(phase: _phase),
        const SizedBox(height: AppSpacing.md),
        ShadCard(
          key: const Key('hanzi-writing-card'),
          width: double.infinity,
          padding: AppLayout.compactCardPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(_phaseTitle, style: theme.textTheme.h3),
              const SizedBox(height: AppSpacing.xxs),
              Text(_phaseInstruction, style: theme.textTheme.muted),
              const SizedBox(height: AppSpacing.md),
              HanziWritingBoard(
                key: const Key('hanzi-writing-canvas'),
                hanzi: widget.item.hanzi,
                phase: _phase,
                strokes: _strokes,
                onChanged: _setStrokes,
              ),
              const SizedBox(height: AppSpacing.md),
              if (_phase == HanziWritingPhase.trace)
                _DrawingActions(
                  nextKey: const Key('hanzi-writing-start-recall'),
                  nextLabel: 'Write from memory',
                  nextEnabled: _hasInk,
                  onClear: _clear,
                  onNext: _beginRecall,
                )
              else if (_phase == HanziWritingPhase.recall)
                _DrawingActions(
                  nextKey: const Key('hanzi-writing-compare'),
                  nextLabel: 'Compare',
                  nextEnabled: _hasInk,
                  onClear: _clear,
                  onNext: _compare,
                )
              else
                _WritingComparison(
                  item: widget.item,
                  selected: widget.selectedSelfCheck,
                  usedHint: _usedHint,
                  onSelected: (value) =>
                      widget.onSelfCheckChanged(value, usedHint: _usedHint),
                  onRestart: _restart,
                ),
            ],
          ),
        ),
        if (_phase != HanziWritingPhase.compare) ...[
          const SizedBox(height: AppSpacing.sm),
          ShadButton.outline(
            key: const Key('hanzi-writing-skip'),
            height: AppLayout.controlHeight,
            onPressed: _skipDrawing,
            leading: highTextScale
                ? null
                : const Icon(LucideIcons.accessibility, size: 16),
            child: Text(highTextScale ? 'Skip' : 'Skip drawing and self-check'),
          ),
        ],
      ],
    );
  }

  String get _phaseTitle => switch (_phase) {
    HanziWritingPhase.trace => 'Trace the shape',
    HanziWritingPhase.recall => 'Now hide the guide',
    HanziWritingPhase.compare => 'Compare your writing',
  };

  String get _phaseInstruction => switch (_phase) {
    HanziWritingPhase.trace =>
      'Follow the light characters. Focus on their overall shape.',
    HanziWritingPhase.recall =>
      'Write the same characters once without the guide.',
    HanziWritingPhase.compare =>
      'Look at the standard form and judge your own attempt.',
  };
}

class HanziWritingBoard extends StatefulWidget {
  const HanziWritingBoard({
    required this.hanzi,
    required this.phase,
    required this.strokes,
    required this.onChanged,
    super.key,
  });

  final String hanzi;
  final HanziWritingPhase phase;
  final List<List<Offset>> strokes;
  final ValueChanged<List<List<Offset>>> onChanged;

  @override
  State<HanziWritingBoard> createState() => _HanziWritingBoardState();
}

class _HanziWritingBoardState extends State<HanziWritingBoard> {
  void _startStroke(PointerDownEvent event) {
    final updated =
        widget.strokes
            .map((stroke) => List<Offset>.of(stroke))
            .toList(growable: true)
          ..add([event.localPosition]);
    widget.onChanged(updated);
  }

  void _extendStroke(PointerMoveEvent event) {
    if (widget.strokes.isEmpty) return;
    final updated = widget.strokes
        .map((stroke) => List<Offset>.of(stroke))
        .toList(growable: true);
    updated.last.add(event.localPosition);
    widget.onChanged(updated);
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final characters = _writingCharacters(widget.hanzi);
    final aspectRatio = math.max(1.0, characters.length.toDouble());
    final guideVisible = widget.phase != HanziWritingPhase.recall;
    final label = switch (widget.phase) {
      HanziWritingPhase.trace => 'Hanzi tracing canvas with guide',
      HanziWritingPhase.recall => 'Blank Hanzi writing canvas',
      HanziWritingPhase.compare => 'Hanzi comparison canvas',
    };

    return Semantics(
      container: true,
      label: '$label for ${widget.hanzi}',
      child: AspectRatio(
        aspectRatio: aspectRatio,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: RawGestureDetector(
            behavior: HitTestBehavior.opaque,
            gestures: widget.phase == HanziWritingPhase.compare
                ? const {}
                : {
                    EagerGestureRecognizer:
                        GestureRecognizerFactoryWithHandlers<
                          EagerGestureRecognizer
                        >(EagerGestureRecognizer.new, (recognizer) {}),
                  },
            child: Listener(
              behavior: HitTestBehavior.opaque,
              onPointerDown: widget.phase == HanziWritingPhase.compare
                  ? null
                  : _startStroke,
              onPointerMove: widget.phase == HanziWritingPhase.compare
                  ? null
                  : _extendStroke,
              child: CustomPaint(
                painter: _HanziWritingPainter(
                  characters: characters,
                  strokes: widget.strokes,
                  showGuide: guideVisible,
                  guideColor: theme.colorScheme.mutedForeground.withValues(
                    alpha: widget.phase == HanziWritingPhase.compare
                        ? .34
                        : .18,
                  ),
                  gridColor: theme.colorScheme.border,
                  inkColor: theme.colorScheme.foreground,
                  backgroundColor: theme.colorScheme.background,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DrawingActions extends StatelessWidget {
  const _DrawingActions({
    required this.nextKey,
    required this.nextLabel,
    required this.nextEnabled,
    required this.onClear,
    required this.onNext,
  });

  final Key nextKey;
  final String nextLabel;
  final bool nextEnabled;
  final VoidCallback onClear;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final highTextScale = MediaQuery.textScalerOf(context).scale(1) > 1.5;
        final stack = constraints.maxWidth < 360 || highTextScale;
        final clear = ShadButton.outline(
          key: const Key('hanzi-writing-clear'),
          height: AppLayout.controlHeight,
          onPressed: onClear,
          leading: const Icon(LucideIcons.eraser, size: 16),
          child: const Text('Clear'),
        );
        final next = ShadButton(
          key: nextKey,
          height: AppLayout.controlHeight,
          enabled: nextEnabled,
          onPressed: nextEnabled ? onNext : null,
          leading: highTextScale
              ? null
              : const Icon(LucideIcons.arrowRight, size: 16),
          child: Text(highTextScale ? 'Next' : nextLabel),
        );
        if (stack) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              clear,
              const SizedBox(height: AppSpacing.sm),
              next,
            ],
          );
        }
        return Row(
          children: [
            Expanded(child: clear),
            const SizedBox(width: AppSpacing.sm),
            Expanded(flex: 2, child: next),
          ],
        );
      },
    );
  }
}

class _WritingComparison extends StatelessWidget {
  const _WritingComparison({
    required this.item,
    required this.selected,
    required this.usedHint,
    required this.onSelected,
    required this.onRestart,
  });

  final CourseKnowledgeItem item;
  final String? selected;
  final bool usedHint;
  final ValueChanged<String> onSelected;
  final VoidCallback onRestart;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final highTextScale = MediaQuery.textScalerOf(context).scale(1) > 1.5;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: AppLayout.compactCardPadding,
          decoration: BoxDecoration(
            color: theme.colorScheme.muted,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Text('Standard form', style: theme.textTheme.small),
              const SizedBox(height: AppSpacing.sm),
              HanziPinyinText(
                hanzi: item.hanzi,
                pinyinSyllables: item.pinyinSyllables,
                hanziFontSize: 36,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(item.english, style: theme.textTheme.muted),
            ],
          ),
        ),
        if (usedHint) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Drawing was skipped. This attempt will be saved as using a hint.',
            style: theme.textTheme.muted,
            textAlign: TextAlign.center,
          ),
        ],
        const SizedBox(height: AppSpacing.md),
        Text('How close was your writing?', style: theme.textTheme.h4),
        const SizedBox(height: AppSpacing.sm),
        LayoutBuilder(
          builder: (context, constraints) {
            final stack =
                constraints.maxWidth < 360 ||
                MediaQuery.textScalerOf(context).scale(1) > 1.5;
            final needsPractice = ShadButton.outline(
              key: const Key('hanzi-writing-needs-practice'),
              height: AppLayout.controlHeight,
              onPressed: () => onSelected('needs-practice'),
              backgroundColor: selected == 'needs-practice'
                  ? theme.colorScheme.accent
                  : theme.colorScheme.card,
              child: Text(highTextScale ? 'Retry' : 'Needs practice'),
            );
            final looksClose = ShadButton.outline(
              key: const Key('hanzi-writing-looks-close'),
              height: AppLayout.controlHeight,
              onPressed: () => onSelected('looks-close'),
              backgroundColor: selected == 'looks-close'
                  ? theme.colorScheme.accent
                  : theme.colorScheme.card,
              child: Text(highTextScale ? 'Close' : 'Looks close'),
            );
            if (stack) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  needsPractice,
                  const SizedBox(height: AppSpacing.sm),
                  looksClose,
                ],
              );
            }
            return Row(
              children: [
                Expanded(child: needsPractice),
                const SizedBox(width: AppSpacing.sm),
                Expanded(child: looksClose),
              ],
            );
          },
        ),
        const SizedBox(height: AppSpacing.sm),
        ShadButton.outline(
          key: const Key('hanzi-writing-restart'),
          height: AppLayout.controlHeight,
          onPressed: onRestart,
          leading: highTextScale
              ? null
              : const Icon(LucideIcons.rotateCcw, size: 16),
          child: Text(highTextScale ? 'Retry' : 'Practice again'),
        ),
      ],
    );
  }
}

class _WritingPhaseRow extends StatelessWidget {
  const _WritingPhaseRow({required this.phase});

  final HanziWritingPhase phase;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Writing step ${phase.index + 1} of 3',
      child: Row(
        children: HanziWritingPhase.values.indexed
            .map((entry) {
              final active = entry.$1 <= phase.index;
              return Expanded(
                child: Container(
                  key: Key('hanzi-writing-phase-${entry.$2.name}'),
                  height: 6,
                  margin: EdgeInsets.only(
                    right: entry.$1 == HanziWritingPhase.values.length - 1
                        ? 0
                        : AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: active
                        ? ShadTheme.of(context).colorScheme.primary
                        : ShadTheme.of(context).colorScheme.muted,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              );
            })
            .toList(growable: false),
      ),
    );
  }
}

class _HanziWritingPainter extends CustomPainter {
  const _HanziWritingPainter({
    required this.characters,
    required this.strokes,
    required this.showGuide,
    required this.guideColor,
    required this.gridColor,
    required this.inkColor,
    required this.backgroundColor,
  });

  final List<String> characters;
  final List<List<Offset>> strokes;
  final bool showGuide;
  final Color guideColor;
  final Color gridColor;
  final Color inkColor;
  final Color backgroundColor;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = backgroundColor);
    final cellWidth = size.width / characters.length;
    final grid = Paint()
      ..color = gridColor
      ..strokeWidth = 1;

    for (var index = 0; index < characters.length; index++) {
      final left = cellWidth * index;
      final rect = Rect.fromLTWH(left, 0, cellWidth, size.height);
      canvas.drawRect(rect.deflate(.5), grid..style = PaintingStyle.stroke);
      canvas.drawLine(
        Offset(left + cellWidth / 2, 0),
        Offset(left + cellWidth / 2, size.height),
        grid..style = PaintingStyle.stroke,
      );
      canvas.drawLine(
        Offset(left, size.height / 2),
        Offset(left + cellWidth, size.height / 2),
        grid,
      );

      if (showGuide) {
        final painter = TextPainter(
          text: TextSpan(
            text: characters[index],
            style: TextStyle(
              color: guideColor,
              fontSize: math.min(cellWidth, size.height) * .72,
              fontWeight: FontWeight.w600,
              height: 1,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout(maxWidth: cellWidth);
        painter.paint(
          canvas,
          Offset(
            left + (cellWidth - painter.width) / 2,
            (size.height - painter.height) / 2,
          ),
        );
      }
    }

    final ink = Paint()
      ..color = inkColor
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;
    for (final stroke in strokes) {
      if (stroke.isEmpty) continue;
      if (stroke.length == 1) {
        canvas.drawCircle(stroke.single, ink.strokeWidth / 2, ink);
        continue;
      }
      final path = Path()..moveTo(stroke.first.dx, stroke.first.dy);
      for (final point in stroke.skip(1)) {
        path.lineTo(point.dx, point.dy);
      }
      canvas.drawPath(path, ink);
    }
  }

  @override
  bool shouldRepaint(covariant _HanziWritingPainter oldDelegate) {
    return oldDelegate.strokes != strokes ||
        oldDelegate.showGuide != showGuide ||
        oldDelegate.guideColor != guideColor ||
        oldDelegate.gridColor != gridColor ||
        oldDelegate.inkColor != inkColor ||
        oldDelegate.backgroundColor != backgroundColor;
  }
}

List<String> _writingCharacters(String hanzi) {
  final characters = hanzi.runes
      .map(String.fromCharCode)
      .where((character) => !_hanziPunctuation.contains(character))
      .toList(growable: false);
  return characters.isEmpty ? [hanzi] : characters;
}

const _hanziPunctuation = {'。', '，', '！', '？', '、', '；', '：', '“', '”'};
