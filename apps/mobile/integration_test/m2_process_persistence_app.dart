import 'dart:async';
import 'dart:io';

import 'package:drift/drift.dart' hide Column;
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learning_core/learning_core.dart';
import 'package:mandarin_mission/app/app.dart';
import 'package:mandarin_mission/data/content/course_content_models.dart';
import 'package:mandarin_mission/data/content/course_content_provider.dart';
import 'package:mandarin_mission/data/content/course_content_repository.dart';
import 'package:mandarin_mission/data/local/app_database.dart';
import 'package:mandarin_mission/data/local/app_database_provider.dart';
import 'package:mandarin_mission/data/progress/lesson_progress_repository.dart';
import 'package:mandarin_mission/data/review/review_queue_repository.dart';
import 'package:mandarin_mission/features/journey/application/journey_progress.dart';
import 'package:path_provider/path_provider.dart';

const _databaseName = String.fromEnvironment('MM_M2_PERSISTENCE_DB');
const _markerPackageId = 'm2-process-persistence-acceptance';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const _PersistenceAcceptanceBootstrap());
}

final class _PersistenceAcceptanceBootstrap extends StatefulWidget {
  const _PersistenceAcceptanceBootstrap();

  @override
  State<_PersistenceAcceptanceBootstrap> createState() =>
      _PersistenceAcceptanceBootstrapState();
}

final class _PersistenceAcceptanceBootstrapState
    extends State<_PersistenceAcceptanceBootstrap> {
  late final Future<_BootstrapResult> _result = _bootstrap();
  ProviderContainer? _container;
  AppDatabase? _database;

  @override
  void dispose() {
    _container?.dispose();
    final database = _database;
    if (database != null) {
      unawaited(database.close());
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_BootstrapResult>(
      future: _result,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _StatusApp(
            title: 'M2 disk acceptance failed',
            detail: snapshot.error.toString(),
            color: Colors.red,
          );
        }
        final result = snapshot.data;
        if (result == null) {
          return const _StatusApp(
            title: 'Checking M2 disk persistence…',
            detail: 'Please wait.',
            color: Colors.blue,
          );
        }
        if (result.container == null) {
          return _StatusApp(
            title: 'M2 disk seed passed',
            detail:
                'PID $pid wrote 15 completions, 208 mastery states, '
                'and 1 review. Force-stop and launch this app again.',
            color: Colors.green,
          );
        }

        _container = result.container;
        _database = result.database;
        return UncontrolledProviderScope(
          container: result.container!,
          child: const MandarinMissionApp(),
        );
      },
    );
  }
}

final class _StatusApp extends StatelessWidget {
  const _StatusApp({
    required this.title,
    required this.detail,
    required this.color,
  });

  final String title;
  final String detail;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.storage, color: color, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(detail, textAlign: TextAlign.center),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

final class _BootstrapResult {
  const _BootstrapResult.seeded() : container = null, database = null;

  const _BootstrapResult.verified({
    required this.container,
    required this.database,
  });

  final ProviderContainer? container;
  final AppDatabase? database;
}

Future<_BootstrapResult> _bootstrap() async {
  _require(
    RegExp(r'^m2_process_acceptance_[a-z0-9_]+$').hasMatch(_databaseName),
    'Build with a unique MM_M2_PERSISTENCE_DB dart-define.',
  );
  final package = await CourseContentRepository(
    assetPath: CourseContentRepository.bundledM2CourseAsset,
  ).loadPackage();
  final database = _openDiskDatabase();
  final marker = await (database.select(
    database.installedContentPackages,
  )..where((row) => row.packageId.equals(_markerPackageId))).getSingleOrNull();

  if (marker == null) {
    try {
      await _seed(database, package);
      debugPrint(
        'M2_DISK_SEED_PASS pid=$pid path=${await _databasePath()} '
        '15 completions, 208 mastery states, 1 review',
      );
      return const _BootstrapResult.seeded();
    } finally {
      await database.close();
    }
  }

  try {
    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(database),
        coursePackageProvider.overrideWith((ref) async => package),
      ],
    );
    try {
      await _verifyDiskState(database, package, container, marker);
      debugPrint(
        'M2_DISK_VERIFY_PASS seedPid=${marker.manifestHash} '
        'verifyPid=$pid path=${await _databasePath()}',
      );
      return _BootstrapResult.verified(
        container: container,
        database: database,
      );
    } catch (_) {
      container.dispose();
      rethrow;
    }
  } catch (_) {
    await database.close();
    rethrow;
  }
}

AppDatabase _openDiskDatabase() {
  return AppDatabase(
    driftDatabase(
      name: _databaseName,
      native: const DriftNativeOptions(
        databaseDirectory: getApplicationSupportDirectory,
      ),
    ),
  );
}

Future<String> _databasePath() async {
  final directory = await getApplicationSupportDirectory();
  return '${directory.path}${Platform.pathSeparator}$_databaseName.sqlite';
}

Future<void> _seed(AppDatabase database, CoursePackage package) async {
  _require(
    (await database.select(database.lessonProgressEntries).get()).isEmpty,
    'The isolated acceptance database already contains lesson progress.',
  );
  _require(
    (await database.select(database.masteryStates).get()).isEmpty,
    'The isolated acceptance database already contains mastery state.',
  );
  _require(
    (await database.select(database.reviewAttempts).get()).isEmpty,
    'The isolated acceptance database already contains review attempts.',
  );

  final completedAt = DateTime.now().toUtc().subtract(const Duration(days: 31));
  final progressRepository = LessonProgressRepository(database);
  for (final location in package.locations) {
    for (final lessonId in location.lessonIds) {
      await _completeLesson(
        progressRepository,
        package,
        package.lesson(lessonId),
        completedAt,
      );
    }
    await _completeLesson(
      progressRepository,
      package,
      package.locationChallenge(location),
      completedAt,
    );
  }

  final reviewRepository = ReviewQueueRepository(database, progressRepository);
  final reviewedAt = DateTime.now().toUtc();
  final dueItems = await reviewRepository.dueItems(now: reviewedAt, limit: 100);
  _require(dueItems.length == 100, 'Expected the capped 100-item due queue.');
  await reviewRepository.submitAttempt(
    item: dueItems.first,
    contentVersion: package.version,
    rating: ReviewRating.remembered,
    correct: true,
    usedHint: false,
    latencyMs: 1,
    answeredAt: reviewedAt,
  );

  await database
      .into(database.installedContentPackages)
      .insert(
        InstalledContentPackagesCompanion.insert(
          packageId: _markerPackageId,
          version: package.version,
          schemaVersion: package.schemaVersion,
          manifestHash: pid.toString(),
          installedAt: reviewedAt,
          isActive: const Value(true),
        ),
      );

  _require(
    (await database.select(database.lessonProgressEntries).get()).length == 15,
    'Expected 15 completed lessons and challenges.',
  );
  _require(
    (await database.select(database.masteryStates).get()).length == 208,
    'Expected 208 mastery states.',
  );
  _require(
    (await database.select(database.reviewAttempts).get()).length == 1,
    'Expected one saved review attempt.',
  );
}

Future<void> _completeLesson(
  LessonProgressRepository repository,
  CoursePackage package,
  CourseLesson lesson,
  DateTime completedAt,
) async {
  await repository.startLesson(
    lessonId: lesson.id,
    contentVersion: package.version,
    startedAt: completedAt,
  );
  await repository.completeLesson(
    lessonId: lesson.id,
    itemIds: lesson.itemIds,
    contentVersion: package.version,
    score: 100,
    completedAt: completedAt,
  );
}

Future<void> _verifyDiskState(
  AppDatabase database,
  CoursePackage package,
  ProviderContainer container,
  InstalledContentPackage marker,
) async {
  _require(
    int.parse(marker.manifestHash) != pid,
    'Verification must run in a new Android process.',
  );
  _require(marker.version == package.version, 'The M2 version changed.');
  _require(
    marker.schemaVersion == package.schemaVersion,
    'The M2 schema version changed.',
  );

  final progressRows = await database
      .select(database.lessonProgressEntries)
      .get();
  _require(progressRows.length == 15, 'Expected 15 restored progress rows.');
  _require(
    progressRows.every((row) => row.status == 'completed'),
    'Every restored lesson and challenge must be completed.',
  );

  final masteryRows = await database.select(database.masteryStates).get();
  _require(masteryRows.length == 208, 'Expected 208 restored mastery states.');
  final attempts = await database.select(database.reviewAttempts).get();
  _require(attempts.length == 1, 'Expected one restored review attempt.');
  final reviewedState = masteryRows.singleWhere(
    (row) =>
        row.itemId == attempts.single.itemId &&
        row.dimension == attempts.single.dimension,
  );
  _require(
    reviewedState.lastResult == 'remembered',
    'The restored review result must be remembered.',
  );
  _require(
    reviewedState.lastReviewedAt == attempts.single.createdAt,
    'The restored review timestamp must match its attempt.',
  );

  final restored = await container.read(journeyProgressProvider.future);
  for (final location in package.locations) {
    _require(
      restored.isLocationUnlocked(location),
      '${location.id} must be unlocked after restart.',
    );
    _require(
      restored.isChallengeUnlocked(location),
      '${location.challengeId} must be unlocked after restart.',
    );
    _require(
      restored.isCompleted(location.challengeId),
      '${location.challengeId} must be completed after restart.',
    );
    for (final lessonId in location.lessonIds) {
      _require(
        restored.isCompleted(lessonId),
        '$lessonId must be completed after restart.',
      );
    }
  }
}

void _require(bool condition, String message) {
  if (!condition) {
    throw StateError(message);
  }
}
