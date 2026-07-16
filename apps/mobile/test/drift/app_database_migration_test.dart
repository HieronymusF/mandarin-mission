import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mandarin_mission/data/local/app_database.dart';

import 'generated/schema.dart';

void main() {
  late SchemaVerifier verifier;

  setUpAll(() {
    verifier = SchemaVerifier(GeneratedHelper());
  });

  test('version 1 snapshot matches the application schema', () async {
    final connection = await verifier.startAt(1);
    final database = AppDatabase(connection);
    addTearDown(database.close);

    await verifier.migrateAndValidate(database, 1);
  });
}
