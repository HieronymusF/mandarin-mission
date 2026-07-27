import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../shared/presentation/app_widgets.dart';

class AppPreferencesPage extends StatelessWidget {
  const AppPreferencesPage({super.key});

  @override
  Widget build(BuildContext context) {
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
                'Unavailable services do not run in the background or send data.',
                style: theme.textTheme.muted,
              ),
              child: ShadCard(
                width: double.infinity,
                padding: AppLayout.cardPadding,
                child: const Column(
                  children: [
                    _PreferenceStatus(
                      icon: LucideIcons.cloudOff,
                      label: 'Notifications',
                      value: 'Not connected',
                      description:
                          'This build does not request notification permission.',
                    ),
                    Divider(height: AppSpacing.xl),
                    _PreferenceStatus(
                      icon: LucideIcons.shieldCheck,
                      label: 'Analytics & crash collection',
                      value: 'Not connected',
                      description:
                          'No analytics or crash-reporting service sends diagnostic data.',
                    ),
                    Divider(height: AppSpacing.xl),
                    _PreferenceStatus(
                      icon: LucideIcons.cloudOff,
                      label: 'Account & sync',
                      value: 'Not available',
                      description:
                          'Learning data stays on this device until account and sync support is implemented.',
                    ),
                  ],
                ),
              ),
            ),
          ],
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
