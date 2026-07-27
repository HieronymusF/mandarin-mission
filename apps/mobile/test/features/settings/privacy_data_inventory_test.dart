import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mandarin_mission/features/settings/data/privacy_data_inventory.dart';

void main() {
  test('inventory version matches the app package version', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();

    expect(
      pubspec,
      contains(
        'version: ${currentPrivacyDataInventory.version}+'
        '${currentPrivacyDataInventory.buildNumber}',
      ),
    );
  });

  test('inventory covers storage, recording, transmission, and deletion', () {
    expect(
      currentPrivacyDataInventory.sections.map((section) => section.title),
      containsAll(const [
        'Stored on this device',
        'Temporary microphone recording',
        'Not sent by this build',
        'When you clear learning data',
      ]),
    );
  });
}
