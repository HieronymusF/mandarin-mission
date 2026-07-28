import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../shared/presentation/app_widgets.dart';
import '../application/app_preferences_providers.dart';
import '../data/app_preferences_store.dart';
import '../data/learning_reminder_service.dart';

typedef ReminderTimePicker =
    Future<DailyReminderTime?> Function(
      BuildContext context,
      DailyReminderTime initialTime,
    );

final reminderTimePickerProvider = Provider<ReminderTimePicker>(
  (ref) => (context, initialTime) async {
    final selected = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: initialTime.hour,
        minute: initialTime.minute,
      ),
      helpText: 'Choose reminder time',
    );
    return selected == null
        ? null
        : DailyReminderTime(hour: selected.hour, minute: selected.minute);
  },
);

class AppPreferencesPage extends ConsumerWidget {
  const AppPreferencesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ShadTheme.of(context);
    return Scaffold(
      key: const Key('app-preferences-page'),
      body: SafeArea(
        child: AppPageScrollView(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: ShadButton.outline(
                key: const Key('back-from-app-preferences'),
                width: AppLayout.minimumTouchTarget,
                height: AppLayout.minimumTouchTarget,
                padding: EdgeInsets.zero,
                onPressed: () => context.go('/settings'),
                child: const Icon(LucideIcons.chevronLeft, size: 20),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('App preferences', style: theme.textTheme.h2),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Languages, media behavior, and the services connected to this build.',
              style: theme.textTheme.muted,
            ),
            const SizedBox(height: AppSpacing.xl),
            AppSection(
              title: Text('Languages', style: theme.textTheme.h3),
              child: ShadCard(
                width: double.infinity,
                padding: AppLayout.cardPadding,
                child: const Column(
                  children: [
                    _PreferenceStatus(
                      icon: LucideIcons.messageCircle,
                      label: 'Interface language',
                      value: 'English',
                      description:
                          'Language switching is not available in this build.',
                    ),
                    Divider(height: AppSpacing.xl),
                    _PreferenceStatus(
                      icon: LucideIcons.bookOpen,
                      label: 'Learning content',
                      value: 'Simplified Chinese',
                      description:
                          'Lessons include pinyin and English guidance.',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            AppSection(
              title: Text('Audio & microphone', style: theme.textTheme.h3),
              child: ShadCard(
                width: double.infinity,
                padding: AppLayout.cardPadding,
                child: const Column(
                  children: [
                    _PreferenceStatus(
                      icon: LucideIcons.volume2,
                      label: 'Lesson audio',
                      value: 'Available offline',
                      description:
                          'Downloaded lesson audio does not need a network connection.',
                    ),
                    Divider(height: AppSpacing.xl),
                    _PreferenceStatus(
                      icon: LucideIcons.mic,
                      label: 'Microphone',
                      value: 'Optional',
                      description:
                          'Permission is requested only when you start recording. You can continue with self-check if it is unavailable.',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            AppSection(
              title: Text('Connected services', style: theme.textTheme.h3),
              description: Text(
                'Learning reminders can run locally on Android in this build. Analytics and crash reporting are not connected.',
                style: theme.textTheme.muted,
              ),
              child: _ConnectedServicesCard(
                preferences: ref.watch(appPreferencesControllerProvider),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConnectedServicesCard extends ConsumerStatefulWidget {
  const _ConnectedServicesCard({required this.preferences});

  final AsyncValue<AppPreferences> preferences;

  @override
  ConsumerState<_ConnectedServicesCard> createState() =>
      _ConnectedServicesCardState();
}

class _ConnectedServicesCardState
    extends ConsumerState<_ConnectedServicesCard> {
  LearningReminderUpdate? _notificationUpdate;
  bool _notificationBusy = false;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final preferences = widget.preferences;
    final value = preferences.value;
    return ShadCard(
      width: double.infinity,
      padding: AppLayout.cardPadding,
      child: value == null
          ? _PreferencesUnavailable(
              isLoading: preferences.isLoading,
              onRetry: () => ref.invalidate(appPreferencesControllerProvider),
            )
          : Column(
              children: [
                _PreferenceChoice(
                  switchKey: const Key('notification-preference-switch'),
                  icon: LucideIcons.bell,
                  label: 'Notifications',
                  value: value.notificationsEnabled,
                  enabled: !preferences.isLoading && !_notificationBusy,
                  description: _notificationDescription(context, value),
                  onChanged: (enabled) => _setNotifications(value, enabled),
                ),
                if (_notificationUpdate != null) ...[
                  const SizedBox(height: AppSpacing.md),
                  _ReminderFeedback(
                    update: _notificationUpdate!,
                    onOpenSettings:
                        _notificationUpdate ==
                                LearningReminderUpdate
                                    .permissionPermanentlyDenied ||
                            _notificationUpdate ==
                                LearningReminderUpdate.backgroundRestricted
                        ? () => ref
                              .read(appPreferencesControllerProvider.notifier)
                              .openNotificationSettings()
                        : null,
                  ),
                ],
                const Divider(height: AppSpacing.xl),
                _PreferenceChoice(
                  switchKey: const Key('diagnostics-preference-switch'),
                  icon: LucideIcons.shieldCheck,
                  label: 'Analytics & crash collection',
                  value: value.diagnosticsEnabled,
                  enabled: !preferences.isLoading,
                  description:
                      'Controls future optional diagnostics. No analytics or crash-reporting service sends data in this build.',
                  onChanged: (enabled) => ref
                      .read(appPreferencesControllerProvider.notifier)
                      .setDiagnosticsEnabled(enabled),
                ),
                if (preferences.hasError) ...[
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Your choice was not saved. The previous setting is still active; try again.',
                    key: const Key('app-preferences-save-error'),
                    style: theme.textTheme.muted.copyWith(
                      color: theme.colorScheme.destructive,
                    ),
                  ),
                ],
                const Divider(height: AppSpacing.xl),
                const _PreferenceStatus(
                  icon: LucideIcons.cloudOff,
                  label: 'Account & sync',
                  value: 'Not available',
                  description:
                      'Learning data stays on this device until account and sync support is implemented.',
                ),
              ],
            ),
    );
  }

  String _notificationDescription(
    BuildContext context,
    AppPreferences preferences,
  ) {
    final minutes = preferences.notificationReminderMinutes;
    if (preferences.notificationsEnabled && minutes != null) {
      final time = DailyReminderTime.fromMinutesSinceMidnight(minutes);
      final label = MaterialLocalizations.of(
        context,
      ).formatTimeOfDay(TimeOfDay(hour: time.hour, minute: time.minute));
      return 'A daily reminder is scheduled around $label. It contains no score, lesson detail, or account data.';
    }
    return 'Choose a local time, then allow Android notifications. Reminders use no push token and send no data.';
  }

  Future<void> _setNotifications(
    AppPreferences preferences,
    bool enabled,
  ) async {
    if (_notificationBusy) return;
    DailyReminderTime? selectedTime;
    if (enabled) {
      final savedMinutes = preferences.notificationReminderMinutes;
      final now = TimeOfDay.now();
      final initialTime = savedMinutes == null
          ? DailyReminderTime(hour: now.hour, minute: now.minute)
          : DailyReminderTime.fromMinutesSinceMidnight(savedMinutes);
      selectedTime = await ref.read(reminderTimePickerProvider)(
        context,
        initialTime,
      );
      if (selectedTime == null || !mounted) return;
    }

    setState(() {
      _notificationBusy = true;
      _notificationUpdate = null;
    });
    final controller = ref.read(appPreferencesControllerProvider.notifier);
    final update = enabled
        ? await controller.enableNotifications(selectedTime!)
        : await controller.disableNotifications();
    if (!mounted) return;
    setState(() {
      _notificationBusy = false;
      _notificationUpdate = update;
    });
  }
}

class _ReminderFeedback extends StatelessWidget {
  const _ReminderFeedback({required this.update, this.onOpenSettings});

  final LearningReminderUpdate update;
  final VoidCallback? onOpenSettings;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final (key, message, isError) = switch (update) {
      LearningReminderUpdate.enabled => (
        const Key('notification-reminder-enabled'),
        'Daily learning reminder scheduled on this device.',
        false,
      ),
      LearningReminderUpdate.disabled => (
        const Key('notification-reminder-disabled'),
        'Daily learning reminder cancelled.',
        false,
      ),
      LearningReminderUpdate.permissionDenied => (
        const Key('notification-reminder-permission-denied'),
        'Notification permission was not granted. Reminders stay off.',
        true,
      ),
      LearningReminderUpdate.permissionPermanentlyDenied => (
        const Key('notification-reminder-permission-blocked'),
        'Notifications are blocked in system settings. Reminders stay off.',
        true,
      ),
      LearningReminderUpdate.backgroundRestricted => (
        const Key('notification-reminder-background-restricted'),
        'Background activity is restricted in system settings. Allow it for reminders to arrive while the app is closed.',
        true,
      ),
      LearningReminderUpdate.unavailable => (
        const Key('notification-reminder-unavailable'),
        'Local learning reminders are unavailable on this platform.',
        true,
      ),
      LearningReminderUpdate.failed => (
        const Key('notification-reminder-error'),
        'The reminder could not be updated. Check this setting and try again.',
        true,
      ),
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          message,
          key: key,
          style: theme.textTheme.muted.copyWith(
            color: isError ? theme.colorScheme.destructive : null,
          ),
        ),
        if (onOpenSettings != null) ...[
          const SizedBox(height: AppSpacing.sm),
          ShadButton.outline(
            key: const Key('open-notification-settings'),
            height: AppLayout.controlHeight,
            onPressed: onOpenSettings,
            child: const Text('Open system settings'),
          ),
        ],
      ],
    );
  }
}

class _PreferencesUnavailable extends StatelessWidget {
  const _PreferencesUnavailable({
    required this.isLoading,
    required this.onRetry,
  });

  final bool isLoading;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    if (isLoading) {
      return AppLeadingRow(
        key: const Key('app-preferences-loading'),
        leadingWidth: AppLayout.noticeIconSlot,
        gap: AppSpacing.sm,
        leading: const SizedBox.square(
          dimension: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        child: Text('Loading your choices…', style: theme.textTheme.muted),
      );
    }
    return Column(
      key: const Key('app-preferences-load-error'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Your choices are unavailable', style: theme.textTheme.h4),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Nothing was changed. Try reading the settings stored on this device again.',
          style: theme.textTheme.muted,
        ),
        const SizedBox(height: AppSpacing.md),
        ShadButton.outline(
          key: const Key('retry-app-preferences'),
          height: AppLayout.controlHeight,
          onPressed: onRetry,
          child: const Text('Retry'),
        ),
      ],
    );
  }
}

class _PreferenceChoice extends StatelessWidget {
  const _PreferenceChoice({
    required this.switchKey,
    required this.icon,
    required this.label,
    required this.value,
    required this.enabled,
    required this.description,
    required this.onChanged,
  });

  final Key switchKey;
  final IconData icon;
  final String label;
  final bool value;
  final bool enabled;
  final String description;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return AppListRow(
      leading: AppIconTile(
        icon: icon,
        backgroundColor: theme.colorScheme.muted,
        foregroundColor: theme.colorScheme.mutedForeground,
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.small.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(value ? 'On' : 'Off', style: theme.textTheme.h4),
        ],
      ),
      subtitle: Text(description),
      trailing: Semantics(
        key: switchKey,
        container: true,
        label: label,
        value: value ? 'On' : 'Off',
        toggled: value,
        enabled: enabled,
        onTap: enabled ? () => onChanged(!value) : null,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          excludeFromSemantics: true,
          onTap: enabled ? () => onChanged(!value) : null,
          child: SizedBox.square(
            dimension: AppLayout.minimumTouchTarget,
            child: Center(
              child: ExcludeSemantics(
                child: IgnorePointer(
                  child: ShadSwitch(
                    value: value,
                    enabled: enabled,
                    onChanged: onChanged,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PreferenceStatus extends StatelessWidget {
  const _PreferenceStatus({
    required this.icon,
    required this.label,
    required this.value,
    required this.description,
  });

  final IconData icon;
  final String label;
  final String value;
  final String description;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return AppLeadingRow(
      leading: AppIconTile(
        icon: icon,
        backgroundColor: theme.colorScheme.muted,
        foregroundColor: theme.colorScheme.mutedForeground,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.small.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(value, style: theme.textTheme.h4),
          const SizedBox(height: AppSpacing.xxs),
          Text(description, style: theme.textTheme.muted),
        ],
      ),
    );
  }
}
