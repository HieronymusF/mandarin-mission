import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../shared/presentation/app_widgets.dart';
import '../application/trust_center_providers.dart';
import '../data/trust_center_data_source.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ShadTheme.of(context);
    return Scaffold(
      key: const Key('settings-page'),
      body: SafeArea(
        child: AppPageScrollView(
          children: [
            Text('Settings', style: theme.textTheme.h2),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Help, privacy, local data, and the build running on this device.',
              style: theme.textTheme.muted,
            ),
            const SizedBox(height: AppSpacing.xl),
            ShadCard(
              key: const Key('settings-offline-status'),
              width: double.infinity,
              padding: AppLayout.compactCardPadding,
              backgroundColor: theme.colorScheme.accent,
              border: ShadBorder.none,
              child: AppLeadingRow(
                leadingWidth: AppLayout.noticeIconSlot,
                gap: AppSpacing.sm,
                leading: Icon(
                  LucideIcons.cloudOff,
                  size: 20,
                  color: theme.colorScheme.accentForeground,
                ),
                child: Text(
                  'These pages and your downloaded lessons stay available offline. External support and policy links need a connection.',
                  style: theme.textTheme.small,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            AppSection(
              title: Text('Trust & support', style: theme.textTheme.h3),
              description: Text(
                'Find help, see what is published, and control local learning data.',
                style: theme.textTheme.muted,
              ),
              child: ShadCard(
                width: double.infinity,
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    _SettingsRouteEntry(
                      key: const Key('open-onboarding-settings'),
                      icon: LucideIcons.compass,
                      title: 'How this app works',
                      subtitle: 'Review the first-use guide',
                      onPressed: () => context.go('/settings/onboarding'),
                    ),
                    const Divider(height: 1),
                    _SettingsRouteEntry(
                      key: const Key('open-help-settings'),
                      icon: LucideIcons.circleHelp,
                      title: 'Help & support',
                      subtitle: 'Offline answers and support availability',
                      onPressed: () => context.go('/settings/help'),
                    ),
                    const Divider(height: 1),
                    _SettingsRouteEntry(
                      key: const Key('open-privacy-settings'),
                      icon: LucideIcons.shieldCheck,
                      title: 'Privacy',
                      subtitle: 'Local data summary and policy status',
                      onPressed: () => context.go('/settings/privacy'),
                    ),
                    const Divider(height: 1),
                    _SettingsRouteEntry(
                      key: const Key('open-terms-settings'),
                      icon: LucideIcons.fileText,
                      title: 'Terms of service',
                      subtitle: 'Current terms publication status',
                      onPressed: () => context.go('/settings/terms'),
                    ),
                    const Divider(height: 1),
                    _SettingsRouteEntry(
                      key: const Key('open-data-settings'),
                      icon: LucideIcons.database,
                      title: 'Data management',
                      subtitle: 'Clear learning data stored on this device',
                      onPressed: () => context.go('/settings/data'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            AppSection(
              title: Text('About', style: theme.textTheme.h3),
              child: _BuildInfoCard(info: ref.watch(appBuildInfoProvider)),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsRouteEntry extends StatelessWidget {
  const _SettingsRouteEntry({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onPressed,
    super.key,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return ShadButton.ghost(
      width: double.infinity,
      height: 0,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      mainAxisAlignment: MainAxisAlignment.start,
      expands: true,
      onPressed: onPressed,
      child: AppListRow(
        leading: AppIconTile(
          icon: icon,
          backgroundColor: theme.colorScheme.muted,
          foregroundColor: theme.colorScheme.mutedForeground,
        ),
        title: Text(
          title,
          textAlign: TextAlign.left,
          style: theme.textTheme.large,
        ),
        subtitle: Text(
          subtitle,
          textAlign: TextAlign.left,
          style: theme.textTheme.muted,
        ),
        trailing: const Icon(LucideIcons.chevronRight, size: 20),
      ),
    );
  }
}

class _BuildInfoCard extends ConsumerWidget {
  const _BuildInfoCard({required this.info});

  final AsyncValue<AppBuildInfo> info;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ShadTheme.of(context);
    return ShadCard(
      width: double.infinity,
      padding: AppLayout.cardPadding,
      child: info.when(
        skipLoadingOnRefresh: false,
        loading: () => AppLeadingRow(
          key: const Key('app-build-info-loading'),
          leadingWidth: AppLayout.noticeIconSlot,
          gap: AppSpacing.sm,
          leading: const SizedBox.square(
            dimension: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          child: Text('Loading app version…', style: theme.textTheme.muted),
        ),
        error: (_, _) => Column(
          key: const Key('app-build-info-error'),
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('App version is unavailable', style: theme.textTheme.h4),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Other settings remain available. Try reading the installed build again.',
              style: theme.textTheme.muted,
            ),
            const SizedBox(height: AppSpacing.md),
            ShadButton.outline(
              key: const Key('retry-app-build-info'),
              height: AppLayout.controlHeight,
              onPressed: () => ref.invalidate(appBuildInfoProvider),
              child: const Text('Retry'),
            ),
          ],
        ),
        data: (value) => AppListRow(
          key: const Key('app-build-info-ready'),
          leading: AppIconTile(
            icon: LucideIcons.info,
            backgroundColor: theme.colorScheme.muted,
            foregroundColor: theme.colorScheme.mutedForeground,
          ),
          title: const Text('Mandarin Mission'),
          subtitle: Text('Version ${value.version} (${value.buildNumber})'),
        ),
      ),
    );
  }
}
