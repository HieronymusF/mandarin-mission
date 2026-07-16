import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mandarin_mission/data/local/app_database.dart';

void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() => database.close());

  test('creates the version 1 schema from an empty database', () async {
    final tables = await database
        .customSelect('''
          SELECT name
          FROM sqlite_schema
          WHERE type = 'table' AND name NOT LIKE 'sqlite_%'
          ORDER BY name
        ''')
        .map((row) => row.read<String>('name'))
        .get();
    final version = await database
        .customSelect('PRAGMA user_version')
        .getSingle();

    expect(tables, const [
      'installed_content_packages',
      'lesson_progress_entries',
      'mastery_states',
      'review_attempts',
      'speaking_attempts',
      'sync_outbox_events',
    ]);
    expect(version.read<int>('user_version'), 1);
  });

  test('persists valid mastery state with database defaults', () async {
    final now = DateTime.utc(2026, 7, 16, 8);
    await database
        .into(database.masteryStates)
        .insert(
          MasteryStatesCompanion.insert(
            itemId: 'phrase-wo-yao',
            dimension: 'meaning',
            box: 1,
            confidence: 0.75,
            dueAt: now.add(const Duration(days: 1)),
            updatedAt: now,
          ),
        );

    final row = await database.select(database.masteryStates).getSingle();
    final storageType = await database
        .customSelect(
          'SELECT typeof(due_at) AS storage_type FROM mastery_states',
        )
        .getSingle();

    expect(row.sameDayRetryCount, 0);
    expect(row.dueAt, now.add(const Duration(days: 1)));
    expect(storageType.read<String>('storage_type'), 'text');
  });

  test('rejects mastery values outside persisted constraints', () async {
    final now = DateTime.utc(2026, 7, 16, 8);

    expect(
      () => database
          .into(database.masteryStates)
          .insert(
            MasteryStatesCompanion.insert(
              itemId: 'phrase-wo-yao',
              dimension: 'context',
              box: 6,
              confidence: 1.5,
              dueAt: now,
              updatedAt: now,
            ),
          ),
      throwsA(isA<Exception>()),
    );
  });
}
