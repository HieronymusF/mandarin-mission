import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mandarin_mission/features/settings/data/learning_reminder_service.dart';
import 'package:mandarin_mission/features/settings/data/local_learning_reminder_service.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('schedules and cancels one Android local reminder', (
    tester,
  ) async {
    final service = LocalLearningReminderService();
    final now = DateTime.now().add(const Duration(minutes: 5));

    await service.scheduleDaily(
      DailyReminderTime(hour: now.hour, minute: now.minute),
    );
    await service.cancelDaily();
  });
}
