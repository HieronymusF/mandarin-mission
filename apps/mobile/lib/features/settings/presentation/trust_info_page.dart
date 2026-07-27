import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../shared/presentation/app_widgets.dart';
import '../application/trust_center_providers.dart';
import '../data/privacy_data_inventory.dart';
import '../data/trust_center_data_source.dart';

enum TrustInfoPageKind { help, privacy, terms }

class TrustInfoPage extends ConsumerWidget {
  const TrustInfoPage({required this.kind, super.key});

  final TrustInfoPageKind kind;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ShadTheme.of(context);
    final config = ref.watch(trustCenterConfigProvider);
    final actions = ref.watch(settingsActionControllerProvider);
    final resource = _resourceFor(kind);
    final uri = _uriFor(config, kind);
    final isOpening = actions.openingResource == resource;
    final error = actions.failedResource == resource ? actions.linkError : null;

    return Scaffold(
      key: Key('trust-info-${kind.name}-page'),
      body: SafeArea(
        child: AppPageScrollView(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: ShadButton.outline(
                key: Key('back-from-${kind.name}'),
                width: AppLayout.minimumTouchTarget,
                height: AppLayout.minimumTouchTarget,
                padding: EdgeInsets.zero,
                onPressed: () => context.go('/settings'),
                child: const Icon(LucideIcons.chevronLeft, size: 20),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(_titleFor(kind), style: theme.textTheme.h2),
            const SizedBox(height: AppSpacing.xs),
            Text(_descriptionFor(kind), style: theme.textTheme.muted),
            const SizedBox(height: AppSpacing.xl),
            ShadCard(
              width: double.infinity,
              padding: AppLayout.cardPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final entry in _localEntriesFor(kind)) ...[
                    AppLeadingRow(
                      leadingWidth: AppLayout.noticeIconSlot,
                      gap: AppSpacing.sm,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      leading: Icon(
                        LucideIcons.circleCheck,
                        size: 20,
                        color: theme.colorScheme.primary,
                      ),
                      child: Text(entry, style: theme.textTheme.p),
                    ),
                    if (entry != _localEntriesFor(kind).last)
                      const SizedBox(height: AppSpacing.md),
                  ],
                ],
              ),
            ),
            if (kind == TrustInfoPageKind.privacy) ...[
              const SizedBox(height: AppSpacing.xxl),
              const _PrivacyDataInventoryCard(),
            ],
            const SizedBox(height: AppSpacing.xl),
            if (uri == null)
              ShadCard(
                key: Key('${kind.name}-resource-unavailable'),
                width: double.infinity,
                padding: AppLayout.cardPadding,
                backgroundColor: theme.colorScheme.custom['warning'],
                border: ShadBorder.none,
                child: AppLeadingRow(
                  leading: AppIconTile(
                    icon: LucideIcons.clock3,
                    backgroundColor: theme.colorScheme.card,
                    foregroundColor: theme.colorScheme.foreground,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_pendingTitleFor(kind), style: theme.textTheme.h4),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        _pendingMessageFor(kind),
                        style: theme.textTheme.muted,
                      ),
                    ],
                  ),
                ),
              )
            else
              ShadButton(
                key: Key('open-${kind.name}-resource'),
                width: double.infinity,
                height: AppLayout.controlHeight,
                enabled: !isOpening,
                onPressed: isOpening
                    ? null
                    : () => ref
                          .read(settingsActionControllerProvider.notifier)
                          .openExternalResource(resource, uri),
                leading: Icon(
                  isOpening
                      ? LucideIcons.loaderCircle
                      : LucideIcons.externalLink,
                  size: 18,
                ),
                child: Text(isOpening ? 'Opening…' : _actionLabelFor(kind)),
              ),
            if (error != null) ...[
              const SizedBox(height: AppSpacing.md),
              ShadCard(
                key: Key('${kind.name}-resource-error'),
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
                  child: Text(error, style: theme.textTheme.small),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PrivacyDataInventoryCard extends StatelessWidget {
  const _PrivacyDataInventoryCard();

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final inventory = currentPrivacyDataInventory;
    return AppSection(
      title: Text(
        'Data inventory for ${inventory.versionLabel}',
        style: theme.textTheme.h3,
      ),
      description: Text(
        'This versioned summary describes the current app code. It is not a published legal policy or a store privacy declaration.',
        style: theme.textTheme.muted,
      ),
      child: ShadCard(
        key: const Key('privacy-data-inventory'),
        width: double.infinity,
        padding: AppLayout.cardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final section in inventory.sections) ...[
              Text(section.title, style: theme.textTheme.h4),
              const SizedBox(height: AppSpacing.sm),
              for (final entry in section.entries) ...[
                AppLeadingRow(
                  leadingWidth: AppLayout.noticeIconSlot,
                  gap: AppSpacing.sm,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  leading: Icon(
                    LucideIcons.dot,
                    size: 20,
                    color: theme.colorScheme.primary,
                  ),
                  child: Text(entry, style: theme.textTheme.p),
                ),
                if (entry != section.entries.last)
                  const SizedBox(height: AppSpacing.sm),
              ],
              if (section != inventory.sections.last)
                const Divider(height: AppSpacing.xxl),
            ],
          ],
        ),
      ),
    );
  }
}

TrustResourceKind _resourceFor(TrustInfoPageKind kind) {
  return switch (kind) {
    TrustInfoPageKind.help => TrustResourceKind.support,
    TrustInfoPageKind.privacy => TrustResourceKind.privacy,
    TrustInfoPageKind.terms => TrustResourceKind.terms,
  };
}

Uri? _uriFor(TrustCenterConfig config, TrustInfoPageKind kind) {
  return switch (kind) {
    TrustInfoPageKind.help => config.supportUri,
    TrustInfoPageKind.privacy => config.privacyUri,
    TrustInfoPageKind.terms => config.termsUri,
  };
}

String _titleFor(TrustInfoPageKind kind) => switch (kind) {
  TrustInfoPageKind.help => 'Help & support',
  TrustInfoPageKind.privacy => 'Privacy',
  TrustInfoPageKind.terms => 'Terms of service',
};

String _descriptionFor(TrustInfoPageKind kind) => switch (kind) {
  TrustInfoPageKind.help =>
    'Answers stored with the app, plus the current support channel status.',
  TrustInfoPageKind.privacy =>
    'A plain-language summary of this build. It is not a published legal policy.',
  TrustInfoPageKind.terms =>
    'The service terms publication status for this pre-release build.',
};

List<String> _localEntriesFor(TrustInfoPageKind kind) => switch (kind) {
  TrustInfoPageKind.help => const [
    'Downloaded lessons, review, and these help notes work without a network connection.',
    'Microphone access is requested only when you start a speaking activity; you can continue with self-check when it is unavailable.',
    'A problem report should include the app version, Android or iOS version, and an anonymous error number—not recordings, transcripts, tokens, or purchase receipts.',
  ],
  TrustInfoPageKind.privacy => const [
    'Learning progress, review history, and speaking self-check results are stored locally in this build.',
    'Temporary recordings are kept only for the current playback flow and are not uploaded by the current implementation.',
    'Account sync, analytics, crash collection, purchases, and marketing notifications are not connected in this build.',
  ],
  TrustInfoPageKind.terms => const [
    'This GitHub pre-release is an evaluation build, not a store release or paid service.',
    'Learning content can be used offline, but no account, cloud sync, subscription, or purchase entitlement is offered by this build.',
    'Production terms must identify the operating entity, supported regions, eligibility, subscriptions, refunds, and contact channel before public release.',
  ],
};

String _pendingTitleFor(TrustInfoPageKind kind) => switch (kind) {
  TrustInfoPageKind.help => 'Support channel not configured',
  TrustInfoPageKind.privacy => 'Production privacy policy not published',
  TrustInfoPageKind.terms => 'Production terms not published',
};

String _pendingMessageFor(TrustInfoPageKind kind) => switch (kind) {
  TrustInfoPageKind.help =>
    'No real support email or webpage has been supplied, so this build does not show a fake contact link.',
  TrustInfoPageKind.privacy =>
    'A real public HTTPS policy and legal operator details are still required before this gate can pass.',
  TrustInfoPageKind.terms =>
    'A real public HTTPS terms page and legal operator details are still required before this gate can pass.',
};

String _actionLabelFor(TrustInfoPageKind kind) => switch (kind) {
  TrustInfoPageKind.help => 'Contact support',
  TrustInfoPageKind.privacy => 'Open privacy policy',
  TrustInfoPageKind.terms => 'Open terms of service',
};
