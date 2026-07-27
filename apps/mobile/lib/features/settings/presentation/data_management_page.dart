import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../shared/presentation/app_widgets.dart';
import '../application/trust_center_providers.dart';

class DataManagementPage extends ConsumerWidget {
  const DataManagementPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ShadTheme.of(context);
    final actions = ref.watch(settingsActionControllerProvider);
    return Scaffold(
      key: const Key('data-management-page'),
      body: SafeArea(
        child: AppPageScrollView(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: ShadButton.outline(
                key: const Key('back-from-data-management'),
                width: AppLayout.minimumTouchTarget,
                height: AppLayout.minimumTouchTarget,
                padding: EdgeInsets.zero,
                onPressed: () => context.go('/settings'),
                child: const Icon(LucideIcons.chevronLeft, size: 20),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('Data management', style: theme.textTheme.h2),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Control learning data stored locally on this device.',
              style: theme.textTheme.muted,
            ),
            const SizedBox(height: AppSpacing.xl),
            ShadCard(
              width: double.infinity,
              padding: AppLayout.cardPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Clear local learning data', style: theme.textTheme.h3),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'This removes lesson progress, mastery, review history, speaking self-check history, and pending sync events from this device.',
                    style: theme.textTheme.muted,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppLeadingRow(
                    leadingWidth: AppLayout.noticeIconSlot,
                    gap: AppSpacing.sm,
                    leading: Icon(
                      LucideIcons.packageCheck,
                      size: 20,
                      color: theme.colorScheme.primary,
                    ),
                    child: Text(
                      'Downloaded course content stays installed, so you can start again offline.',
                      style: theme.textTheme.small,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  ConstrainedBox(
                    constraints: const BoxConstraints(
                      minHeight: AppLayout.controlHeight,
                    ),
                    child: Semantics(
                      label: 'Clear local learning data',
                      button: true,
                      child: ShadButton.destructive(
                        key: const Key('clear-local-learning-data'),
                        width: double.infinity,
                        height: 0,
                        expands: true,
                        enabled: !actions.isClearingLearningData,
                        onPressed: actions.isClearingLearningData
                            ? null
                            : () => _confirmAndClear(context, ref),
                        leading: Icon(
                          actions.isClearingLearningData
                              ? LucideIcons.loaderCircle
                              : LucideIcons.trash2,
                          size: 18,
                        ),
                        child: Text(
                          actions.isClearingLearningData
                              ? 'Clearing…'
                              : 'Clear data',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (actions.learningDataCleared) ...[
              const SizedBox(height: AppSpacing.md),
              ShadCard(
                key: const Key('local-learning-data-cleared'),
                width: double.infinity,
                padding: AppLayout.compactCardPadding,
                backgroundColor: theme.colorScheme.custom['success'],
                border: ShadBorder.none,
                child: AppLeadingRow(
                  leadingWidth: AppLayout.noticeIconSlot,
                  gap: AppSpacing.sm,
                  leading: Icon(
                    LucideIcons.circleCheckBig,
                    size: 20,
                    color: theme.colorScheme.foreground,
                  ),
                  child: Text(
                    'Local learning data was cleared. Downloaded course content remains available.',
                    style: theme.textTheme.small,
                  ),
                ),
              ),
            ],
            if (actions.clearDataError != null) ...[
              const SizedBox(height: AppSpacing.md),
              ShadCard(
                key: const Key('clear-local-learning-data-error'),
                width: double.infinity,
                padding: AppLayout.compactCardPadding,
                child: AppLeadingRow(
                  leadingWidth: AppLayout.noticeIconSlot,
                  gap: AppSpacing.sm,
                  leading: Icon(
                    LucideIcons.circleAlert,
                    size: 20,
                    color: theme.colorScheme.destructive,
                  ),
                  child: Text(
                    actions.clearDataError!,
                    style: theme.textTheme.small,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _confirmAndClear(BuildContext context, WidgetRef ref) async {
    final confirmed = await showShadDialog<bool>(
      context: context,
      builder: (dialogContext) => ShadDialog.alert(
        title: const Text('Clear local learning data?'),
        description: const Text(
          'This cannot be undone. Your lesson progress, mastery, review history, speaking history, and pending sync events will be removed from this device. Downloaded lessons stay installed.',
        ),
        actions: [
          ShadButton.outline(
            key: const Key('cancel-clear-local-data'),
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          ShadButton.destructive(
            key: const Key('confirm-clear-local-data'),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Clear data'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref
        .read(settingsActionControllerProvider.notifier)
        .clearLearningData();
  }
}
