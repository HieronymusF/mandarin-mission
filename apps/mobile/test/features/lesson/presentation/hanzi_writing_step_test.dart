import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mandarin_mission/core/theme/app_theme.dart';
import 'package:mandarin_mission/data/content/course_content_models.dart';
import 'package:mandarin_mission/features/lesson/presentation/steps/hanzi_writing_step.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

void main() {
  const item = CourseKnowledgeItem(
    id: 'noun-kafei',
    kind: 'word',
    hanzi: '咖啡',
    pinyin: 'kāfēi',
    pinyinSyllables: ['kā', 'fēi'],
    english: 'coffee',
    audioAssetId: 'audio-kafei',
    tags: ['cafe'],
  );

  testWidgets('requires trace and recall ink before self-check', (
    tester,
  ) async {
    String? selected;
    bool? recordedHint;
    await tester.pumpWidget(
      _WritingTestApp(
        builder: (context, setState) => HanziWritingStep(
          item: item,
          supportText: 'Trace, then write from memory.',
          selectedSelfCheck: selected,
          onSelfCheckChanged: (value, {required usedHint}) {
            setState(() {
              selected = value;
              recordedHint = usedHint;
            });
          },
        ),
      ),
    );

    expect(find.text('Trace the shape'), findsOneWidget);
    await tester.ensureVisible(
      find.byKey(const Key('hanzi-writing-start-recall')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('hanzi-writing-start-recall')));
    await tester.pump();
    expect(find.text('Trace the shape'), findsOneWidget);

    await _drawOnCanvas(tester);
    await tester.ensureVisible(
      find.byKey(const Key('hanzi-writing-start-recall')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('hanzi-writing-start-recall')));
    await tester.pumpAndSettle();
    expect(find.text('Now hide the guide'), findsOneWidget);

    await tester.ensureVisible(find.byKey(const Key('hanzi-writing-compare')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('hanzi-writing-compare')));
    await tester.pump();
    expect(find.text('Now hide the guide'), findsOneWidget);

    await _drawOnCanvas(tester);
    await tester.ensureVisible(find.byKey(const Key('hanzi-writing-compare')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('hanzi-writing-compare')));
    await tester.pumpAndSettle();
    expect(find.text('Compare your writing'), findsOneWidget);

    await tester.ensureVisible(
      find.byKey(const Key('hanzi-writing-looks-close')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('hanzi-writing-looks-close')));
    await tester.pumpAndSettle();
    expect(selected, 'looks-close');
    expect(recordedHint, isFalse);

    await tester.ensureVisible(find.byKey(const Key('hanzi-writing-restart')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('hanzi-writing-restart')));
    await tester.pumpAndSettle();
    expect(find.text('Trace the shape'), findsOneWidget);
    expect(selected, isNull);
  });

  testWidgets('offers a non-gesture fallback and records hint use', (
    tester,
  ) async {
    String? selected;
    bool? recordedHint;
    await tester.pumpWidget(
      _WritingTestApp(
        builder: (context, setState) => HanziWritingStep(
          item: item,
          supportText: null,
          selectedSelfCheck: selected,
          onSelfCheckChanged: (value, {required usedHint}) {
            setState(() {
              selected = value;
              recordedHint = usedHint;
            });
          },
        ),
      ),
    );

    await tester.ensureVisible(find.byKey(const Key('hanzi-writing-skip')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('hanzi-writing-skip')));
    await tester.pumpAndSettle();
    expect(find.text('Compare your writing'), findsOneWidget);
    expect(find.textContaining('saved as using a hint'), findsOneWidget);

    await tester.ensureVisible(
      find.byKey(const Key('hanzi-writing-needs-practice')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('hanzi-writing-needs-practice')));
    await tester.pumpAndSettle();
    expect(selected, 'needs-practice');
    expect(recordedHint, isTrue);
  });

  testWidgets('fits a small screen at 200 percent text scale', (tester) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 800);

    await tester.pumpWidget(
      _WritingTestApp(
        textScaler: const TextScaler.linear(2),
        builder: (context, setState) => HanziWritingStep(
          item: item,
          supportText: null,
          selectedSelfCheck: null,
          onSelfCheckChanged: (value, {required usedHint}) {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byKey(const Key('hanzi-writing-canvas')), findsOneWidget);
    expect(find.text('Next'), findsOneWidget);

    await tester.ensureVisible(find.byKey(const Key('hanzi-writing-skip')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('hanzi-writing-skip')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(
      find.byKey(const Key('hanzi-writing-looks-close')),
    );
    await tester.pumpAndSettle();
    expect(find.text('Close'), findsOneWidget);
    expect(find.byKey(const Key('hanzi-writing-restart')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

Future<void> _drawOnCanvas(WidgetTester tester) async {
  final canvas = find.byKey(const Key('hanzi-writing-canvas'));
  await tester.ensureVisible(canvas);
  await tester.pumpAndSettle();
  final rect = tester.getRect(canvas);
  await tester.dragFrom(
    Offset(rect.left + rect.width * .25, rect.top + rect.height * .25),
    Offset(rect.width * .18, rect.height * .42),
  );
  await tester.pump();
}

class _WritingTestApp extends StatelessWidget {
  const _WritingTestApp({required this.builder, this.textScaler});

  final Widget Function(BuildContext context, StateSetter setState) builder;
  final TextScaler? textScaler;

  @override
  Widget build(BuildContext context) {
    final shadTheme = buildAppShadTheme();
    return ShadApp.custom(
      theme: shadTheme,
      appBuilder: (context) {
        return MaterialApp(
          theme: buildAppMaterialTheme(Theme.of(context), shadTheme),
          builder: (context, child) => ShadAppBuilder(
            child: MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: textScaler ?? MediaQuery.textScalerOf(context),
              ),
              child: child ?? const SizedBox.shrink(),
            ),
          ),
          home: Scaffold(
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: StatefulBuilder(builder: builder),
              ),
            ),
          ),
        );
      },
    );
  }
}
