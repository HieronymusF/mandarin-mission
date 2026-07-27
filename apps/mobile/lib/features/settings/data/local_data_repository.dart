import '../../../data/local/app_database.dart';

abstract interface class LocalDataRepository {
  Future<void> clearLearningData();
}

final class DriftLocalDataRepository implements LocalDataRepository {
  DriftLocalDataRepository(this._database);

  final AppDatabase _database;

  @override
  Future<void> clearLearningData() {
    return _database.transaction(() async {
      await _database.delete(_database.syncOutboxEvents).go();
      await _database.delete(_database.reviewAttempts).go();
      await _database.delete(_database.speakingAttempts).go();
      await _database.delete(_database.masteryStates).go();
      await _database.delete(_database.lessonProgressEntries).go();
    });
  }
}
