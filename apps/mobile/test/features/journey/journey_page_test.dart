import 'package:drift/native.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mandarin_mission/app/app.dart';
import 'package:mandarin_mission/data/content/course_content_models.dart';
import 'package:mandarin_mission/data/content/course_content_provider.dart';
import 'package:mandarin_mission/data/local/app_database.dart';
import 'package:mandarin_mission/data/local/app_database_provider.dart';

void main() {
  testWidgets('renders locations and lessons from the content package', (
    tester,
  ) async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final package = CoursePackage.fromJson(
      _multiLocationPackage,
      source: 'test',
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(database),
          coursePackageProvider.overrideWith((ref) async => package),
        ],
        child: const MandarinMissionApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Stop 1 · Café'), findsOneWidget);
    expect(find.text('Order one coffee'), findsOneWidget);
    expect(find.text('Stop 2 · Market'), findsOneWidget);
    expect(find.text('Buy fruit'), findsOneWidget);
    expect(
      find.byKey(const Key('journey-lesson-market-01-card')),
      findsOneWidget,
    );
    expect(
      tester.getTopLeft(find.text('Order one coffee')).dy,
      lessThan(tester.getTopLeft(find.text('Buy fruit')).dy),
    );
  });
}

final Map<String, Object?> _multiLocationPackage = {
  'schemaVersion': 1,
  'status': 'draft',
  'version': '0.2.0',
  'locations': [
    {
      'id': 'market',
      'title': 'Market',
      'order': 2,
      'lessonIds': ['market-01'],
      'challengeId': 'market-challenge',
    },
    {
      'id': 'cafe',
      'title': 'Café',
      'order': 1,
      'lessonIds': ['cafe-01'],
      'challengeId': 'cafe-challenge',
    },
  ],
  'knowledgeItems': <Object?>[],
  'lessons': [
    {
      'id': 'market-01',
      'locationId': 'market',
      'title': 'Buy fruit',
      'estimatedMinutes': 8,
      'prerequisites': <Object?>[],
      'itemIds': <Object?>[],
      'steps': <Object?>[],
    },
    {
      'id': 'cafe-01',
      'locationId': 'cafe',
      'title': 'Order one coffee',
      'estimatedMinutes': 9,
      'prerequisites': <Object?>[],
      'itemIds': <Object?>[],
      'steps': <Object?>[],
    },
  ],
  'dialogues': <Object?>[],
  'assets': <Object?>[],
};
