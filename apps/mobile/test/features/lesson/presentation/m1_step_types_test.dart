import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mandarin_mission/core/theme/app_theme.dart';
import 'package:mandarin_mission/data/content/course_content_models.dart';
import 'package:mandarin_mission/features/lesson/presentation/steps/image_choice_step.dart';
import 'package:mandarin_mission/features/lesson/presentation/steps/order_tokens_step.dart';
import 'package:mandarin_mission/features/lesson/presentation/steps/tone_contrast_step.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

void main() {
  final package = _testPackage();
  final lesson = package.lesson('cafe-01');

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  testWidgets('image choice keeps Mandarin options usable at 200%', (
    tester,
  ) async {
    _useSmallView(tester);
    String? selected;
    final step = lesson.steps.singleWhere(
      (step) => step.type == 'image_choice',
    );
    await tester.pumpWidget(
      _StepTestApp(
        builder: (context, setState) => ImageChoiceStep(
          package: package,
          step: step,
          selectedOptionId: selected,
          onSelected: (value) => setState(() => selected = value),
        ),
      ),
    );

    expect(find.byKey(const Key('image-choice-fallback')), findsOneWidget);
    expect(find.text('咖啡'), findsOneWidget);
    expect(find.text('coffee'), findsNothing);
    await tester.ensureVisible(
      find.byKey(const Key('image-option-noun-kafei')),
    );
    await tester.tap(find.byKey(const Key('image-option-noun-kafei')));
    await tester.pump();
    expect(find.byKey(const Key('image-choice-result')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('tone contrast remains usable at 200% text scale', (
    tester,
  ) async {
    _useSmallView(tester);
    String? selected;
    final step = lesson.steps.singleWhere(
      (step) => step.type == 'tone_contrast',
    );
    await tester.pumpWidget(
      _StepTestApp(
        builder: (context, setState) => ToneContrastStep(
          package: package,
          step: step,
          selectedOptionId: selected,
          onSelected: (value) => setState(() => selected = value),
        ),
      ),
    );

    expect(tester.takeException(), isNull);

    await tester.ensureVisible(find.byKey(const Key('tone-option-0')));
    await tester.tap(find.byKey(const Key('tone-option-0')));
    await tester.pump();
    expect(find.byKey(const Key('tone-choice-result')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('token ordering supports selection and removal at 200%', (
    tester,
  ) async {
    _useSmallView(tester);
    var selected = <int>[];
    final step = lesson.steps.singleWhere(
      (step) => step.type == 'order_tokens',
    );
    await tester.pumpWidget(
      _StepTestApp(
        builder: (context, setState) => OrderTokensStep(
          step: step,
          orderedTokenIndexes: selected,
          onToggleToken: (index) => setState(() {
            selected = [...selected];
            selected.contains(index)
                ? selected.remove(index)
                : selected.add(index);
          }),
        ),
      ),
    );

    for (var index = 0; index < step.tokens.length; index++) {
      await tester.tap(find.byKey(Key('order-token-$index')));
      await tester.pump();
    }
    expect(find.byKey(const Key('order-result')), findsOneWidget);
    await tester.tap(find.byKey(const Key('ordered-token-1')));
    await tester.pump();
    expect(find.byKey(const Key('order-result')), findsNothing);
    expect(tester.takeException(), isNull);
  });
}

void _useSmallView(WidgetTester tester) {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = const Size(320, 640);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);
}

CoursePackage _testPackage() {
  return CoursePackage.fromJson({
    'schemaVersion': 1,
    'status': 'draft',
    'version': '0.1.0',
    'knowledgeItems': [
      {
        'id': 'phrase-wo-yao',
        'kind': 'phrase',
        'hanzi': '我要',
        'pinyin': 'wǒ yào',
        'pinyinSyllables': ['wǒ', 'yào'],
        'english': 'I want',
        'audioAssetId': 'audio-wo-yao',
        'tags': <String>[],
      },
      {
        'id': 'noun-kafei',
        'kind': 'word',
        'hanzi': '咖啡',
        'pinyin': 'kāfēi',
        'pinyinSyllables': ['kā', 'fēi'],
        'english': 'coffee',
        'audioAssetId': 'audio-wo-yao',
        'tags': <String>[],
      },
      {
        'id': 'sentence-order-coffee',
        'kind': 'sentence',
        'hanzi': '我要一杯咖啡',
        'pinyin': 'wǒ yào yì bēi kāfēi',
        'pinyinSyllables': ['wǒ', 'yào', 'yì', 'bēi', 'kā', 'fēi'],
        'english': 'I would like a cup of coffee.',
        'audioAssetId': 'audio-wo-yao',
        'tags': <String>[],
      },
    ],
    'lessons': [
      {
        'id': 'cafe-01',
        'locationId': 'cafe',
        'title': 'Order coffee',
        'estimatedMinutes': 1,
        'prerequisites': <String>[],
        'itemIds': ['phrase-wo-yao', 'noun-kafei', 'sentence-order-coffee'],
        'steps': [
          {
            'id': 'cafe-image',
            'type': 'image_choice',
            'dimension': 'meaning',
            'itemId': 'noun-kafei',
            'assetId': 'image-cafe',
            'optionItemIds': [
              'noun-kafei',
              'phrase-wo-yao',
              'sentence-order-coffee',
            ],
          },
          {
            'id': 'cafe-tone',
            'type': 'tone_contrast',
            'dimension': 'tone',
            'itemId': 'phrase-wo-yao',
            'optionTexts': ['wǒ yào', 'wó yáo'],
          },
          {
            'id': 'cafe-order',
            'type': 'order_tokens',
            'dimension': 'meaning',
            'itemId': 'phrase-wo-yao',
            'tokens': ['我', '要'],
          },
        ],
      },
    ],
    'dialogues': <Object?>[],
    'assets': [
      {
        'id': 'image-cafe',
        'kind': 'image',
        'status': 'planned',
        'license': 'internal',
        'credit': 'Mandarin Mission',
      },
      {
        'id': 'audio-wo-yao',
        'kind': 'audio',
        'status': 'planned',
        'license': 'internal',
        'credit': 'Mandarin Mission',
      },
    ],
  }, source: 'test');
}

class _StepTestApp extends StatelessWidget {
  const _StepTestApp({required this.builder});

  final Widget Function(BuildContext context, StateSetter setState) builder;

  @override
  Widget build(BuildContext context) {
    final shadTheme = buildAppShadTheme();
    return ProviderScope(
      child: ShadApp.custom(
        theme: shadTheme,
        appBuilder: (context) => MaterialApp(
          theme: buildAppMaterialTheme(Theme.of(context), shadTheme),
          builder: (context, child) => ShadAppBuilder(
            child: MediaQuery(
              data: MediaQuery.of(context).copyWith(
                size: const Size(320, 640),
                textScaler: const TextScaler.linear(2),
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
        ),
      ),
    );
  }
}
