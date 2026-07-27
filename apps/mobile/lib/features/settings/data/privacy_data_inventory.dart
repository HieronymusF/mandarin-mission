final class PrivacyDataInventory {
  const PrivacyDataInventory({
    required this.version,
    required this.buildNumber,
    required this.sections,
  });

  final String version;
  final String buildNumber;
  final List<PrivacyDataInventorySection> sections;

  String get versionLabel => '$version ($buildNumber)';
}

final class PrivacyDataInventorySection {
  const PrivacyDataInventorySection({
    required this.title,
    required this.entries,
  });

  final String title;
  final List<String> entries;
}

const currentPrivacyDataInventory = PrivacyDataInventory(
  version: '0.2.0',
  buildNumber: '3',
  sections: [
    PrivacyDataInventorySection(
      title: 'Stored on this device',
      entries: [
        'Lesson progress, review answers, speaking self-check scores, and pending local learning events.',
        'Bundled lesson content and audio, first-use completion, and your notification and diagnostics choices.',
      ],
    ),
    PrivacyDataInventorySection(
      title: 'Temporary microphone recording',
      entries: [
        'Created only after you start speaking practice and grant permission.',
        'Used for local playback, never transcribed or uploaded, and removed when you replace it, cancel, or leave the practice flow.',
      ],
    ),
    PrivacyDataInventorySection(
      title: 'Not sent by this build',
      entries: [
        'No account identity, learning history, recording, transcript, notification token, analytics, crash report, or purchase record is sent to a service.',
        'Turning on a future-service choice does not request notification permission or start data collection in this build.',
      ],
    ),
    PrivacyDataInventorySection(
      title: 'When you clear learning data',
      entries: [
        'Lesson progress, mastery, review, speaking self-check, and pending local learning events are removed.',
        'Bundled course content, first-use completion, and app preference choices remain. Device app-data controls and uninstall behavior are managed by the operating system, including any backup or restore.',
      ],
    ),
  ],
);
