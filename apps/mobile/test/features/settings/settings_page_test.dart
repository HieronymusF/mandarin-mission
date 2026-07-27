import 'dart:async';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mandarin_mission/app/app.dart';
import 'package:mandarin_mission/data/content/course_content_provider.dart';
import 'package:mandarin_mission/data/content/course_content_repository.dart';
import 'package:mandarin_mission/data/local/app_database.dart';
import 'package:mandarin_mission/data/local/app_database_provider.dart';
import 'package:mandarin_mission/features/settings/application/app_preferences_providers.dart';
import 'package:mandarin_mission/features/settings/application/trust_center_providers.dart';
import 'package:mandarin_mission/features/settings/data/app_preferences_store.dart';
import 'package:mandarin_mission/features/settings/data/local_data_repository.dart';
import 'package:mandarin_mission/features/settings/data/trust_center_data_source.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

void main() {
  testWidgets('main navigation opens settings while lessons stay focused', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    try {
      await _pumpApp(tester);

      expect(find.byKey(const Key('main-navigation-shell')), findsOneWidget);
      expect(find.bySemanticsLabel(RegExp('Settings')), findsWidgets);
      await tester.tap(find.byKey(const Key('app-nav-review')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('review-page')), findsOneWidget);
      await _openSettings(tester);

      expect(find.byKey(const Key('settings-page')), findsOneWidget);
      await _revealOnPage(
        tester,
        const Key('settings-page'),
        find.byKey(const Key('app-build-info-ready')),
      );
      expect(find.text('Version 0.2.0 (3)'), findsOneWidget);

      await _revealOnPage(
        tester,
        const Key('settings-page'),
        find.byKey(const Key('open-help-settings')),
      );
      await tester.tap(find.byKey(const Key('open-help-settings')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('trust-info-help-page')), findsOneWidget);
      await _revealOnPage(
        tester,
        const Key('trust-info-help-page'),
        find.byKey(const Key('help-resource-unavailable')),
      );
      expect(
        find.byKey(const Key('help-resource-unavailable')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('open-help-resource')), findsNothing);

      await tester.tap(find.byKey(const Key('app-nav-journey')));
      await tester.pumpAndSettle();
      expect(find.text('Your Mandarin journey'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.byKey(const Key('open-lesson-cafe-01')),
        240,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('open-lesson-cafe-01')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('lesson-overview-page')), findsOneWidget);
      expect(find.byKey(const Key('main-navigation-shell')), findsNothing);
    } finally {
      semantics.dispose();
    }
  });

  testWidgets('shows version loading, failure, and retry states', (
    tester,
  ) async {
    final retry = Completer<AppBuildInfo>();
    var loadCount = 0;
    final source = _FakeTrustCenterDataSource(
      loadBuildInfo: () {
        loadCount += 1;
        if (loadCount == 1) {
          return Future<AppBuildInfo>.error(StateError('platform unavailable'));
        }
        return retry.future;
      },
    );
    await _pumpApp(tester, source: source);
    await _openSettings(tester);

    await _revealOnPage(
      tester,
      const Key('settings-page'),
      find.byKey(const Key('app-build-info-error')),
    );
    expect(find.byKey(const Key('app-build-info-error')), findsOneWidget);

    await _revealOnPage(
      tester,
      const Key('settings-page'),
      find.byKey(const Key('retry-app-build-info')),
    );
    await tester.tap(find.byKey(const Key('retry-app-build-info')));
    await tester.pump();
    expect(find.byKey(const Key('app-build-info-loading')), findsOneWidget);

    retry.complete(const AppBuildInfo(version: '0.2.0', buildNumber: '3'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('app-build-info-ready')), findsOneWidget);
    expect(loadCount, 2);
  });

  testWidgets('settings entries use a clear left-aligned text hierarchy', (
    tester,
  ) async {
    await _pumpApp(tester);
    await _openSettings(tester);
    final titleFinder = find.text('Help & support');
    final subtitleFinder = find.text(
      'Offline answers and support availability',
    );
    await _revealOnPage(tester, const Key('settings-page'), titleFinder);

    final title = tester.widget<Text>(titleFinder);
    final subtitle = tester.widget<Text>(subtitleFinder);
    expect(title.style?.fontSize, 18);
    expect(title.style?.fontWeight, FontWeight.w600);
    expect(title.textAlign, TextAlign.left);
    expect(subtitle.style?.fontSize, 14);
    expect(subtitle.style?.fontWeight, FontWeight.w400);
    expect(subtitle.textAlign, TextAlign.left);
    expect(
      tester.getTopLeft(titleFinder).dx,
      closeTo(tester.getTopLeft(subtitleFinder).dx, 0.01),
    );
  });

  testWidgets('offers honest local choices for optional services', (
    tester,
  ) async {
    await _pumpApp(tester);
    await _openSettings(tester);
    await _revealOnPage(
      tester,
      const Key('settings-page'),
      find.byKey(const Key('open-app-preferences-settings')),
    );
    await tester.tap(find.byKey(const Key('open-app-preferences-settings')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('app-preferences-page')), findsOneWidget);
    await tester.tap(find.byKey(const Key('back-from-app-preferences')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('settings-page')), findsOneWidget);

    await _revealOnPage(
      tester,
      const Key('settings-page'),
      find.byKey(const Key('open-app-preferences-settings')),
    );
    await tester.tap(find.byKey(const Key('open-app-preferences-settings')));
    await tester.pumpAndSettle();
    expect(find.text('Interface language'), findsOneWidget);
    expect(find.text('English'), findsOneWidget);
    expect(find.text('Learning content'), findsOneWidget);
    expect(find.text('Simplified Chinese'), findsOneWidget);
    final interfaceLanguageFinder = find.text('Interface language');
    final interfaceLanguageLabel = tester.widget<Text>(interfaceLanguageFinder);
    final theme = ShadTheme.of(tester.element(interfaceLanguageFinder));
    expect(interfaceLanguageLabel.style?.color, theme.colorScheme.primary);

    await _revealOnPage(
      tester,
      const Key('app-preferences-page'),
      find.text('Audio & microphone'),
    );
    expect(find.text('Audio & microphone'), findsOneWidget);

    await _revealOnPage(
      tester,
      const Key('app-preferences-page'),
      find.text('Account & sync'),
    );
    expect(find.text('Notifications'), findsOneWidget);
    expect(find.text('Analytics & crash collection'), findsOneWidget);
    expect(find.text('Account & sync'), findsOneWidget);
    expect(
      find.byKey(const Key('notification-preference-switch')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('diagnostics-preference-switch')),
      findsOneWidget,
    );
    expect(find.bySemanticsLabel('Notifications'), findsOneWidget);
    expect(
      find.bySemanticsLabel('Analytics & crash collection'),
      findsOneWidget,
    );
    expect(find.text('Off'), findsNWidgets(2));
    expect(find.text('Not available'), findsOneWidget);
  });

  testWidgets('privacy page discloses the current build data inventory', (
    tester,
  ) async {
    await _pumpApp(tester);
    await _openSettings(tester);
    await _revealOnPage(
      tester,
      const Key('settings-page'),
      find.byKey(const Key('open-privacy-settings')),
    );
    await tester.tap(find.byKey(const Key('open-privacy-settings')));
    await tester.pumpAndSettle();

    await _revealOnPage(
      tester,
      const Key('trust-info-privacy-page'),
      find.byKey(const Key('privacy-data-inventory')),
    );
    expect(find.text('Data inventory for 0.2.0 (3)'), findsOneWidget);
    expect(find.text('Stored on this device'), findsOneWidget);
    expect(find.text('Temporary microphone recording'), findsOneWidget);
    expect(find.text('Not sent by this build'), findsOneWidget);
    expect(find.text('When you clear learning data'), findsOneWidget);
  });

  testWidgets(
    'privacy data inventory remains usable at 200 percent text scale',
    (tester) async {
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(360, 800);
      tester.platformDispatcher.textScaleFactorTestValue = 2;

      await _pumpApp(tester);
      await _openSettings(tester);
      await _revealOnPage(
        tester,
        const Key('settings-page'),
        find.byKey(const Key('open-privacy-settings')),
      );
      await tester.tap(find.byKey(const Key('open-privacy-settings')));
      await tester.pumpAndSettle();
      final privacyPage = find.byKey(const Key('trust-info-privacy-page'));
      final scrollable = find.descendant(
        of: privacyPage,
        matching: find.byType(Scrollable),
      );
      final policyStatus = find.byKey(
        const Key('privacy-resource-unavailable'),
      );
      final position = tester.state<ScrollableState>(scrollable.first).position;
      for (
        var attempt = 0;
        attempt < 8 && policyStatus.evaluate().isEmpty;
        attempt++
      ) {
        position.jumpTo(position.maxScrollExtent);
        await tester.pumpAndSettle();
      }

      expect(policyStatus, findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('saves, reloads, and withdraws optional choices', (tester) async {
    final store = _FakeAppPreferencesStore();
    final database = await _pumpApp(tester, appPreferencesStore: store);
    await _openAppPreferences(tester);
    await _revealOnPage(
      tester,
      const Key('app-preferences-page'),
      find.byKey(const Key('diagnostics-preference-switch')),
    );

    await tester.tap(find.byKey(const Key('notification-preference-switch')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('diagnostics-preference-switch')));
    await tester.pumpAndSettle();
    expect(store.preferences.notificationsEnabled, isTrue);
    expect(store.preferences.diagnosticsEnabled, isTrue);

    await _pumpApp(tester, database: database, appPreferencesStore: store);
    await _openAppPreferences(tester);
    await _revealOnPage(
      tester,
      const Key('app-preferences-page'),
      find.byKey(const Key('diagnostics-preference-switch')),
    );
    expect(
      _switchValue(tester, const Key('notification-preference-switch')),
      isTrue,
    );
    expect(
      _switchValue(tester, const Key('diagnostics-preference-switch')),
      isTrue,
    );

    await tester.tap(find.byKey(const Key('diagnostics-preference-switch')));
    await tester.pumpAndSettle();
    expect(store.preferences.diagnosticsEnabled, isFalse);
  });

  testWidgets('keeps the previous choice when saving fails', (tester) async {
    final store = _FakeAppPreferencesStore(
      saveNotifications: (_) async {
        throw StateError('preferences unavailable');
      },
    );
    await _pumpApp(tester, appPreferencesStore: store);
    await _openAppPreferences(tester);
    await _revealOnPage(
      tester,
      const Key('app-preferences-page'),
      find.byKey(const Key('notification-preference-switch')),
    );

    await tester.tap(find.byKey(const Key('notification-preference-switch')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('app-preferences-save-error')), findsOneWidget);
    expect(store.preferences.notificationsEnabled, isFalse);
    expect(
      _switchValue(tester, const Key('notification-preference-switch')),
      isFalse,
    );
  });

  testWidgets('retries when locally stored choices cannot be read', (
    tester,
  ) async {
    var shouldFail = true;
    final store = _FakeAppPreferencesStore(
      read: () async {
        if (shouldFail) throw StateError('preferences unavailable');
        return const AppPreferences();
      },
    );
    await _pumpApp(tester, appPreferencesStore: store);
    await _openAppPreferences(tester);
    await _revealOnPage(
      tester,
      const Key('app-preferences-page'),
      find.byKey(const Key('retry-app-preferences')),
    );
    expect(find.byKey(const Key('app-preferences-load-error')), findsOneWidget);

    shouldFail = false;
    await tester.tap(find.byKey(const Key('retry-app-preferences')));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('notification-preference-switch')),
      findsOneWidget,
    );
  });

  testWidgets('app preferences remain usable at 200 percent text scale', (
    tester,
  ) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 800);
    tester.platformDispatcher.textScaleFactorTestValue = 2;

    await _pumpApp(tester);
    await _openSettings(tester);
    await _revealOnPage(
      tester,
      const Key('settings-page'),
      find.byKey(const Key('open-app-preferences-settings')),
    );
    await tester.tap(find.byKey(const Key('open-app-preferences-settings')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('app-preferences-page')), findsOneWidget);
    await _revealOnPage(
      tester,
      const Key('app-preferences-page'),
      find.text('Account & sync'),
    );
    for (final key in const [
      Key('notification-preference-switch'),
      Key('diagnostics-preference-switch'),
    ]) {
      final rect = tester.getRect(find.byKey(key));
      expect(rect.width, greaterThanOrEqualTo(44));
      expect(rect.height, greaterThanOrEqualTo(44));
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('keeps the policy page open when an external link fails', (
    tester,
  ) async {
    final launch = Completer<bool>();
    final source = _FakeTrustCenterDataSource(
      openExternalUri: (uri) {
        expect(uri, Uri.parse('https://example.com/privacy'));
        return launch.future;
      },
    );
    await _pumpApp(
      tester,
      source: source,
      config: const TrustCenterConfig(
        privacyUrl: 'https://example.com/privacy',
      ),
    );
    await _openSettings(tester);
    await _revealOnPage(
      tester,
      const Key('settings-page'),
      find.byKey(const Key('open-privacy-settings')),
    );
    await tester.tap(find.byKey(const Key('open-privacy-settings')));
    await tester.pumpAndSettle();

    await _revealOnPage(
      tester,
      const Key('trust-info-privacy-page'),
      find.byKey(const Key('open-privacy-resource')),
    );
    await tester.tap(find.byKey(const Key('open-privacy-resource')));
    await tester.pump();
    expect(find.text('Opening…'), findsOneWidget);

    launch.complete(false);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('trust-info-privacy-page')), findsOneWidget);
    expect(find.byKey(const Key('privacy-resource-error')), findsOneWidget);
    expect(find.textContaining('Check your connection'), findsOneWidget);
  });

  testWidgets('requires confirmation before clearing local learning data', (
    tester,
  ) async {
    final database = await _pumpApp(
      tester,
      seed: (database) async {
        final now = DateTime.utc(2026, 7, 27, 8);
        await database.batch((batch) {
          batch.insert(
            database.installedContentPackages,
            InstalledContentPackagesCompanion.insert(
              packageId: 'm2',
              version: '0.2.7',
              schemaVersion: 1,
              manifestHash: 'hash',
              installedAt: now,
              isActive: const Value(true),
            ),
          );
          batch.insert(
            database.lessonProgressEntries,
            LessonProgressEntriesCompanion.insert(
              lessonId: 'cafe-01',
              status: 'completed',
              score: const Value(100),
              contentVersion: '0.2.7',
              updatedAt: now,
            ),
          );
        });
      },
    );
    await _openSettings(tester);
    await _revealOnPage(
      tester,
      const Key('settings-page'),
      find.byKey(const Key('open-data-settings')),
    );
    await tester.tap(find.byKey(const Key('open-data-settings')));
    await tester.pumpAndSettle();

    await _revealOnPage(
      tester,
      const Key('data-management-page'),
      find.byKey(const Key('clear-local-learning-data')),
    );
    await tester.tap(find.byKey(const Key('clear-local-learning-data')));
    await tester.pumpAndSettle();
    expect(find.text('Clear local learning data?'), findsOneWidget);
    await tester.tap(find.byKey(const Key('cancel-clear-local-data')));
    await tester.pumpAndSettle();
    expect(
      await database.select(database.lessonProgressEntries).get(),
      hasLength(1),
    );

    await tester.tap(find.byKey(const Key('clear-local-learning-data')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('confirm-clear-local-data')));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('local-learning-data-cleared')),
      findsOneWidget,
    );
    expect(
      await database.select(database.lessonProgressEntries).get(),
      isEmpty,
    );
    expect(
      await database.select(database.installedContentPackages).get(),
      hasLength(1),
    );
  });

  testWidgets('reports a clear failure without removing local data', (
    tester,
  ) async {
    final clearCompleter = Completer<void>();
    final database = await _pumpApp(
      tester,
      localDataRepository: _ControlledLocalDataRepository(
        clearCompleter.future,
      ),
      seed: (database) async {
        await database
            .into(database.lessonProgressEntries)
            .insert(
              LessonProgressEntriesCompanion.insert(
                lessonId: 'cafe-01',
                status: 'completed',
                score: const Value(100),
                contentVersion: '0.2.7',
                updatedAt: DateTime.utc(2026, 7, 27, 8),
              ),
            );
      },
    );
    await _openSettings(tester);
    await _revealOnPage(
      tester,
      const Key('settings-page'),
      find.byKey(const Key('open-data-settings')),
    );
    await tester.tap(find.byKey(const Key('open-data-settings')));
    await tester.pumpAndSettle();
    await _revealOnPage(
      tester,
      const Key('data-management-page'),
      find.byKey(const Key('clear-local-learning-data')),
    );
    await tester.tap(find.byKey(const Key('clear-local-learning-data')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('confirm-clear-local-data')));
    await tester.pump();
    expect(find.text('Clearing…'), findsOneWidget);

    clearCompleter.completeError(StateError('database unavailable'));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('clear-local-learning-data-error')),
      findsOneWidget,
    );
    expect(
      await database.select(database.lessonProgressEntries).get(),
      hasLength(1),
    );
  });

  testWidgets('settings remain usable at 200 percent text scale', (
    tester,
  ) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 800);
    tester.platformDispatcher.textScaleFactorTestValue = 2;

    await _pumpApp(tester);
    await _openSettings(tester);
    expect(tester.takeException(), isNull);

    await _revealOnPage(
      tester,
      const Key('settings-page'),
      find.byKey(const Key('open-data-settings')),
    );
    await tester.tap(find.byKey(const Key('open-data-settings')));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await _revealOnPage(
      tester,
      const Key('data-management-page'),
      find.byKey(const Key('clear-local-learning-data')),
    );
    final clearButton = tester.getRect(
      find.byKey(const Key('clear-local-learning-data')),
    );
    expect(clearButton.height, greaterThanOrEqualTo(44));
    expect(tester.takeException(), isNull);
  });
}

Future<AppDatabase> _pumpApp(
  WidgetTester tester, {
  _FakeTrustCenterDataSource? source,
  TrustCenterConfig config = const TrustCenterConfig(),
  LocalDataRepository? localDataRepository,
  AppPreferencesStore? appPreferencesStore,
  AppDatabase? database,
  Future<void> Function(AppDatabase database)? seed,
}) async {
  final resolvedDatabase = database ?? AppDatabase(NativeDatabase.memory());
  if (seed != null) await seed(resolvedDatabase);
  if (database == null) {
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
      await resolvedDatabase.close();
    });
  }
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(resolvedDatabase),
        courseContentRepositoryProvider.overrideWithValue(
          CourseContentRepository(
            assetPath: CourseContentRepository.bundledCafeCourseAsset,
          ),
        ),
        trustCenterDataSourceProvider.overrideWithValue(
          source ?? _FakeTrustCenterDataSource(),
        ),
        trustCenterConfigProvider.overrideWithValue(config),
        localDataRepositoryProvider.overrideWithValue(
          localDataRepository ?? DriftLocalDataRepository(resolvedDatabase),
        ),
        appPreferencesStoreProvider.overrideWithValue(
          appPreferencesStore ?? _FakeAppPreferencesStore(),
        ),
      ],
      child: const MandarinMissionApp(),
    ),
  );
  await tester.pumpAndSettle();
  return resolvedDatabase;
}

final class _ControlledLocalDataRepository implements LocalDataRepository {
  _ControlledLocalDataRepository(this.result);

  final Future<void> result;

  @override
  Future<void> clearLearningData() => result;
}

Future<void> _openSettings(WidgetTester tester) async {
  await tester.tap(find.byKey(const Key('app-nav-settings')));
  await tester.pumpAndSettle();
  expect(find.byKey(const Key('settings-page')), findsOneWidget);
}

Future<void> _openAppPreferences(WidgetTester tester) async {
  await _openSettings(tester);
  await _revealOnPage(
    tester,
    const Key('settings-page'),
    find.byKey(const Key('open-app-preferences-settings')),
  );
  await tester.tap(find.byKey(const Key('open-app-preferences-settings')));
  await tester.pumpAndSettle();
  expect(find.byKey(const Key('app-preferences-page')), findsOneWidget);
}

Future<void> _revealOnPage(
  WidgetTester tester,
  Key pageKey,
  Finder target,
) async {
  final scrollable = find.descendant(
    of: find.byKey(pageKey),
    matching: find.byType(Scrollable),
  );
  await tester.scrollUntilVisible(target, 200, scrollable: scrollable.first);
  await tester.pumpAndSettle();
}

bool _switchValue(WidgetTester tester, Key key) {
  return tester
      .widget<ShadSwitch>(
        find.descendant(of: find.byKey(key), matching: find.byType(ShadSwitch)),
      )
      .value;
}

final class _FakeAppPreferencesStore implements AppPreferencesStore {
  _FakeAppPreferencesStore({this.read, this.saveNotifications});

  final Future<AppPreferences> Function()? read;
  final Future<void> Function(bool enabled)? saveNotifications;
  AppPreferences preferences = const AppPreferences();

  @override
  Future<AppPreferences> load() => read?.call() ?? Future.value(preferences);

  @override
  Future<void> setNotificationsEnabled(bool enabled) async {
    await saveNotifications?.call(enabled);
    preferences = preferences.copyWith(notificationsEnabled: enabled);
  }

  @override
  Future<void> setDiagnosticsEnabled(bool enabled) async {
    preferences = preferences.copyWith(diagnosticsEnabled: enabled);
  }
}

final class _FakeTrustCenterDataSource implements TrustCenterDataSource {
  _FakeTrustCenterDataSource({
    Future<AppBuildInfo> Function()? loadBuildInfo,
    Future<bool> Function(Uri uri)? openExternalUri,
  }) : _loadBuildInfo =
           loadBuildInfo ??
           (() async => const AppBuildInfo(version: '0.2.0', buildNumber: '3')),
       _openExternalUri = openExternalUri ?? ((uri) async => true);

  final Future<AppBuildInfo> Function() _loadBuildInfo;
  final Future<bool> Function(Uri uri) _openExternalUri;

  @override
  Future<AppBuildInfo> loadBuildInfo() => _loadBuildInfo();

  @override
  Future<bool> openExternalUri(Uri uri) => _openExternalUri(uri);
}
