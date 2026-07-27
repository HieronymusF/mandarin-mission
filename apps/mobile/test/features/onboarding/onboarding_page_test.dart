import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mandarin_mission/app/app.dart';
import 'package:mandarin_mission/data/content/course_content_provider.dart';
import 'package:mandarin_mission/data/content/course_content_repository.dart';
import 'package:mandarin_mission/data/local/app_database.dart';
import 'package:mandarin_mission/data/local/app_database_provider.dart';
import 'package:mandarin_mission/features/onboarding/application/onboarding_providers.dart';
import 'package:mandarin_mission/features/onboarding/data/onboarding_status_store.dart';
import 'package:mandarin_mission/features/settings/application/trust_center_providers.dart';
import 'package:mandarin_mission/features/settings/data/trust_center_data_source.dart';

void main() {
  testWidgets('first launch saves completion before opening Journey', (
    tester,
  ) async {
    final save = Completer<void>();
    final store = _FakeOnboardingStatusStore(save: () => save.future);
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    await _pumpApp(
      tester,
      database: database,
      store: store,
      initialCompleted: false,
    );

    expect(find.byKey(const Key('first-use-onboarding-page')), findsOneWidget);
    expect(find.byKey(const Key('main-navigation-shell')), findsNothing);
    expect(find.text('No account required'), findsOneWidget);

    await tester.tap(find.byKey(const Key('complete-first-use-onboarding')));
    await tester.pump();
    expect(find.text('Starting…'), findsOneWidget);
    expect(find.byKey(const Key('first-use-onboarding-page')), findsOneWidget);

    save.complete();
    await tester.pumpAndSettle();
    expect(store.markCalls, 1);
    expect(find.byKey(const Key('first-use-onboarding-page')), findsNothing);
    expect(find.byKey(const Key('main-navigation-shell')), findsOneWidget);
    expect(find.text('Your Mandarin journey'), findsOneWidget);

    await _pumpApp(
      tester,
      database: database,
      store: store,
      initialCompleted: store.completed,
    );
    expect(find.byKey(const Key('first-use-onboarding-page')), findsNothing);
    expect(find.text('Your Mandarin journey'), findsOneWidget);
  });

  testWidgets('failed completion stays on the guide and can retry', (
    tester,
  ) async {
    var shouldFail = true;
    final store = _FakeOnboardingStatusStore(
      save: () async {
        if (shouldFail) throw StateError('preferences unavailable');
      },
    );
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    await _pumpApp(
      tester,
      database: database,
      store: store,
      initialCompleted: false,
    );

    await tester.tap(find.byKey(const Key('complete-first-use-onboarding')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('first-use-onboarding-page')), findsOneWidget);
    expect(find.byKey(const Key('onboarding-save-error')), findsOneWidget);
    expect(find.textContaining('was not saved'), findsOneWidget);

    shouldFail = false;
    await tester.tap(find.byKey(const Key('complete-first-use-onboarding')));
    await tester.pumpAndSettle();
    expect(store.markCalls, 2);
    expect(find.text('Your Mandarin journey'), findsOneWidget);
  });

  testWidgets('Settings reopens the guide without rewriting completion', (
    tester,
  ) async {
    final store = _FakeOnboardingStatusStore();
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    await _pumpApp(
      tester,
      database: database,
      store: store,
      initialCompleted: true,
    );

    await tester.tap(find.byKey(const Key('app-nav-settings')));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const Key('open-onboarding-settings')),
      200,
      scrollable: find
          .descendant(
            of: find.byKey(const Key('settings-page')),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await tester.tap(find.byKey(const Key('open-onboarding-settings')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('onboarding-replay-page')), findsOneWidget);
    expect(find.text('How Mandarin Mission works'), findsOneWidget);
    await tester.tap(find.byKey(const Key('close-onboarding-replay')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('settings-page')), findsOneWidget);
    expect(store.markCalls, 0);
  });

  testWidgets('onboarding remains usable at 200 percent text scale', (
    tester,
  ) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 800);
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    await _pumpApp(
      tester,
      database: database,
      store: _FakeOnboardingStatusStore(),
      initialCompleted: false,
    );

    expect(tester.takeException(), isNull);
    final button = tester.getRect(
      find.byKey(const Key('complete-first-use-onboarding')),
    );
    expect(button.height, greaterThanOrEqualTo(44));
    expect(tester.takeException(), isNull);
  });

  test('initial read failure does not block the local-first app', () async {
    final store = _FakeOnboardingStatusStore(
      read: () async => throw StateError('preferences unavailable'),
    );

    expect(await loadInitialOnboardingCompleted(store), isTrue);
  });
}

Future<void> _pumpApp(
  WidgetTester tester, {
  required AppDatabase database,
  required OnboardingStatusStore store,
  required bool initialCompleted,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(database),
        courseContentRepositoryProvider.overrideWithValue(
          CourseContentRepository(
            assetPath: CourseContentRepository.bundledCafeCourseAsset,
          ),
        ),
        trustCenterDataSourceProvider.overrideWithValue(
          _FakeTrustCenterDataSource(),
        ),
        onboardingStatusStoreProvider.overrideWithValue(store),
        initialOnboardingCompletedProvider.overrideWithValue(initialCompleted),
      ],
      child: const MandarinMissionApp(),
    ),
  );
  await tester.pumpAndSettle();
}

final class _FakeOnboardingStatusStore implements OnboardingStatusStore {
  _FakeOnboardingStatusStore({this.read, this.save});

  final Future<bool> Function()? read;
  final Future<void> Function()? save;
  bool completed = false;
  int markCalls = 0;

  @override
  Future<bool> isCompleted() => read?.call() ?? Future.value(completed);

  @override
  Future<void> markCompleted() async {
    markCalls += 1;
    await save?.call();
    completed = true;
  }
}

final class _FakeTrustCenterDataSource implements TrustCenterDataSource {
  @override
  Future<AppBuildInfo> loadBuildInfo() async {
    return const AppBuildInfo(version: '0.2.0', buildNumber: '3');
  }

  @override
  Future<bool> openExternalUri(Uri uri) async => true;
}
