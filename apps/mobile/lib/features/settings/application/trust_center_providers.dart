import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/local/app_database_provider.dart';
import '../../journey/application/journey_progress.dart';
import '../../lesson/application/lesson_providers.dart';
import '../../review/application/review_providers.dart';
import '../data/local_data_repository.dart';
import '../data/trust_center_data_source.dart';

final trustCenterDataSourceProvider = Provider<TrustCenterDataSource>(
  (ref) => PlatformTrustCenterDataSource(),
);

final trustCenterConfigProvider = Provider<TrustCenterConfig>(
  (ref) => TrustCenterConfig.fromEnvironment(),
);

final appBuildInfoProvider = FutureProvider<AppBuildInfo>(
  (ref) => ref.read(trustCenterDataSourceProvider).loadBuildInfo(),
);

final localDataRepositoryProvider = Provider<LocalDataRepository>(
  (ref) => DriftLocalDataRepository(ref.watch(appDatabaseProvider)),
);

final settingsActionControllerProvider =
    NotifierProvider<SettingsActionController, SettingsActionState>(
      SettingsActionController.new,
    );

enum TrustResourceKind { support, privacy, terms }

final class SettingsActionState {
  const SettingsActionState({
    this.openingResource,
    this.failedResource,
    this.linkError,
    this.isClearingLearningData = false,
    this.learningDataCleared = false,
    this.clearDataError,
  });

  final TrustResourceKind? openingResource;
  final TrustResourceKind? failedResource;
  final String? linkError;
  final bool isClearingLearningData;
  final bool learningDataCleared;
  final String? clearDataError;

  static const _unset = Object();

  SettingsActionState copyWith({
    Object? openingResource = _unset,
    Object? failedResource = _unset,
    Object? linkError = _unset,
    bool? isClearingLearningData,
    bool? learningDataCleared,
    Object? clearDataError = _unset,
  }) {
    return SettingsActionState(
      openingResource: identical(openingResource, _unset)
          ? this.openingResource
          : openingResource as TrustResourceKind?,
      failedResource: identical(failedResource, _unset)
          ? this.failedResource
          : failedResource as TrustResourceKind?,
      linkError: identical(linkError, _unset)
          ? this.linkError
          : linkError as String?,
      isClearingLearningData:
          isClearingLearningData ?? this.isClearingLearningData,
      learningDataCleared: learningDataCleared ?? this.learningDataCleared,
      clearDataError: identical(clearDataError, _unset)
          ? this.clearDataError
          : clearDataError as String?,
    );
  }
}

final class SettingsActionController extends Notifier<SettingsActionState> {
  @override
  SettingsActionState build() => const SettingsActionState();

  Future<bool> openExternalResource(TrustResourceKind resource, Uri uri) async {
    if (state.openingResource != null) return false;
    state = state.copyWith(
      openingResource: resource,
      failedResource: null,
      linkError: null,
    );
    try {
      final opened = await ref
          .read(trustCenterDataSourceProvider)
          .openExternalUri(uri);
      if (!opened) {
        state = state.copyWith(
          openingResource: null,
          failedResource: resource,
          linkError:
              'This resource could not be opened. Check your connection and try again.',
        );
        return false;
      }
      state = state.copyWith(openingResource: null);
      return true;
    } on Object {
      state = state.copyWith(
        openingResource: null,
        failedResource: resource,
        linkError:
            'This resource could not be opened. Check your connection and try again.',
      );
      return false;
    }
  }

  Future<bool> clearLearningData() async {
    if (state.isClearingLearningData) return false;
    state = state.copyWith(
      isClearingLearningData: true,
      learningDataCleared: false,
      clearDataError: null,
    );
    try {
      await ref.read(localDataRepositoryProvider).clearLearningData();
      ref.invalidate(journeyProgressProvider);
      ref.invalidate(dueReviewSummaryProvider);
      ref.invalidate(reviewSessionControllerProvider);
      ref.invalidate(lessonProgressProvider);
      state = state.copyWith(
        isClearingLearningData: false,
        learningDataCleared: true,
      );
      return true;
    } on Object {
      state = state.copyWith(
        isClearingLearningData: false,
        learningDataCleared: false,
        clearDataError:
            'Your local learning data could not be cleared. Nothing is marked as removed; try again.',
      );
      return false;
    }
  }
}
