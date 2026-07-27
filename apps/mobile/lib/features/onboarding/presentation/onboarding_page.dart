import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../shared/presentation/app_widgets.dart';
import '../application/onboarding_providers.dart';

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({this.replay = false, super.key});

  final bool replay;

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  bool _isSaving = false;
  bool _saveFailed = false;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return Scaffold(
      key: Key(
        widget.replay ? 'onboarding-replay-page' : 'first-use-onboarding-page',
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: AppPageScrollView(
                children: [
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: ShadBadge.secondary(
                      child: Text('No account required'),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    widget.replay
                        ? 'How Mandarin Mission works'
                        : 'Learn Mandarin for real moments',
                    style: theme.textTheme.h2,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Build useful Mandarin in short scene-based lessons, then keep it fresh with local review.',
                    style: theme.textTheme.muted,
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  const _OnboardingBenefit(
                    icon: LucideIcons.clock3,
                    title: 'About 10 minutes a day',
                    description:
                        'Practice understanding, listening, and speaking in one focused mission.',
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const _OnboardingBenefit(
                    icon: LucideIcons.cloudOff,
                    title: 'Downloaded lessons work offline',
                    description:
                        'Core lessons and reviews stay usable without a connection.',
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const _OnboardingBenefit(
                    icon: LucideIcons.shieldCheck,
                    title: 'Your learning data stays under your control',
                    description:
                        'Progress is stored on this device and can be cleared from Settings.',
                  ),
                ],
              ),
            ),
            AppContentFrame(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.sm,
                  AppSpacing.lg,
                  AppSpacing.lg,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_saveFailed) ...[
                      ShadCard(
                        key: const Key('onboarding-save-error'),
                        width: double.infinity,
                        padding: AppLayout.compactCardPadding,
                        backgroundColor: theme.colorScheme.destructive,
                        border: ShadBorder.none,
                        child: Text(
                          'Your choice was not saved. Try again to continue.',
                          style: theme.textTheme.small.copyWith(
                            color: theme.colorScheme.destructiveForeground,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                    ],
                    ShadButton(
                      key: Key(
                        widget.replay
                            ? 'close-onboarding-replay'
                            : 'complete-first-use-onboarding',
                      ),
                      width: double.infinity,
                      height: 0,
                      expands: true,
                      padding: const EdgeInsets.all(AppSpacing.md),
                      onPressed: _isSaving ? null : _handlePrimaryAction,
                      child: Text(
                        widget.replay
                            ? 'Back to Settings'
                            : _isSaving
                            ? 'Starting…'
                            : 'Start learning',
                      ),
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

  Future<void> _handlePrimaryAction() async {
    if (widget.replay) {
      context.go('/settings');
      return;
    }
    setState(() {
      _isSaving = true;
      _saveFailed = false;
    });
    try {
      await ref.read(onboardingCompletedProvider.notifier).complete();
    } on Object {
      if (!mounted) return;
      setState(() {
        _isSaving = false;
        _saveFailed = true;
      });
    }
  }
}

class _OnboardingBenefit extends StatelessWidget {
  const _OnboardingBenefit({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return ShadCard(
      width: double.infinity,
      padding: AppLayout.cardPadding,
      child: AppLeadingRow(
        leading: AppIconTile(
          icon: icon,
          backgroundColor: theme.colorScheme.accent,
          foregroundColor: theme.colorScheme.accentForeground,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.large),
            const SizedBox(height: AppSpacing.xxs),
            Text(description, style: theme.textTheme.muted),
          ],
        ),
      ),
    );
  }
}
