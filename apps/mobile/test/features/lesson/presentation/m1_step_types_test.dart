import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mandarin_mission/core/theme/app_theme.dart';
import 'package:mandarin_mission/data/content/course_content_models.dart';
import 'package:mandarin_mission/features/lesson/presentation/steps/image_choice_step.dart';
import 'package:mandarin_mission/features/lesson/presentation/steps/order_tokens_step.dart';
import 'package:mandarin_mission/features/lesson/presentation/steps/scene_intro_step.dart';
import 'package:mandarin_mission/features/lesson/presentation/steps/summary_step.dart';
import 'package:mandarin_mission/features/lesson/presentation/steps/teach_card_step.dart';
import 'package:mandarin_mission/features/lesson/presentation/steps/tone_contrast_step.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

void main() {
  final package = _testPackage();
  final lesson = package.lesson('cafe-01');

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  testWidgets('teach card does not invent a lesson-wide build order', (
    tester,
  ) async {
    final item = package.knowledgeItem('sentence-order-coffee');
    await tester.pumpWidget(
      _StepTestApp(
        builder: (context, setState) => TeachCardStep(
          item: item,
          supportText: item.english,
          audioAssetPath: null,
        ),
      ),
    );

    expect(find.text('SENTENCE'), findsOneWidget);
    expect(find.text('Build the order'), findsNothing);
    expect(find.text(item.english), findsOneWidget);
  });

  testWidgets('scene intro does not invent café-only lesson copy', (
    tester,
  ) async {
    const step = CourseLessonStep(
      id: 'market-intro',
      type: 'scene_intro',
      title: 'Ask about this item',
      text: 'You see an item you like. Ask whether it is suitable.',
    );
    await tester.pumpWidget(
      _StepTestApp(
        builder: (context, setState) =>
            const SceneIntroStep(step: step, locationTitle: 'Market'),
      ),
    );

    expect(find.text(step.text!), findsOneWidget);
    expect(find.text('MARKET'), findsOneWidget);
    expect(find.text('At the market'), findsNothing);
    expect(find.text('CAFÉ'), findsNothing);
    expect(find.text('At the café counter'), findsNothing);
    expect(find.text('你好！'), findsNothing);
    expect(
      find.text('You will learn one complete order, then use it yourself.'),
      findsNothing,
    );
  });

  testWidgets('scene intro does not infer a sentence from Metro', (
    tester,
  ) async {
    const step = CourseLessonStep(
      id: 'metro-intro',
      type: 'scene_intro',
      title: 'Find the metro station',
      text: 'You need the metro. Ask where the station is.',
    );
    await tester.pumpWidget(
      _StepTestApp(
        builder: (context, setState) =>
            const SceneIntroStep(step: step, locationTitle: 'Metro'),
      ),
    );

    expect(find.text(step.text!), findsOneWidget);
    expect(find.text('METRO'), findsOneWidget);
    expect(find.text('At the metro'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('summary uses the lesson outcome instead of café-only copy', (
    tester,
  ) async {
    await tester.pumpWidget(const _StepTestApp(builder: _summaryStep));

    expect(find.text('Mission complete'), findsOneWidget);
    expect(
      find.text('You can now choose a hot or iced drink.'),
      findsOneWidget,
    );
    expect(find.text('You practiced understanding Mandarin.'), findsOneWidget);
    expect(find.text('You completed the speaking practice.'), findsOneWidget);
    expect(find.text('Available after a successful review.'), findsOneWidget);
    expect(find.text('Café stamp earned'), findsNothing);
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
    expect(find.text('Correct — that’s the right order.'), findsOneWidget);
    await tester.tap(find.byKey(const Key('ordered-token-1')));
    await tester.pump();
    expect(find.byKey(const Key('order-result')), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('token bank shuffles once instead of using a fixed reverse', (
    tester,
  ) async {
    var selected = <int>[];
    const step = CourseLessonStep(
      id: 'shuffle-order',
      type: 'order_tokens',
      tokens: ['我', '想', '去', '北京'],
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

    final initialOrder = _visibleTokenBankIndexes(tester);
    expect(initialOrder, isNot(equals([0, 1, 2, 3])));
    expect(initialOrder, isNot(equals([3, 2, 1, 0])));

    final firstIndex = initialOrder.first;
    await tester.tap(find.byKey(Key('order-token-$firstIndex')));
    await tester.pump();
    await tester.tap(find.byKey(Key('ordered-token-$firstIndex')));
    await tester.pump();

    expect(_visibleTokenBankIndexes(tester), initialOrder);
  });
}

List<int> _visibleTokenBankIndexes(WidgetTester tester) {
  final bank = tester.widget<Wrap>(
    find
        .descendant(
          of: find.byType(OrderTokensStep),
          matching: find.byType(Wrap),
        )
        .last,
  );
  return bank.children.map((child) {
    final key = child.key! as ValueKey<String>;
    return int.parse(key.value.replaceFirst('order-token-', ''));
  }).toList();
}

Widget _summaryStep(BuildContext context, StateSetter setState) {
  return const SummaryStep(
    supportText: 'You can now choose a hot or iced drink.',
  );
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
    'locations': [
      {
        'id': 'cafe',
        'title': 'Café',
        'order': 1,
        'lessonIds': ['cafe-01'],
        'challengeId': 'cafe-challenge',
      },
    ],
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
