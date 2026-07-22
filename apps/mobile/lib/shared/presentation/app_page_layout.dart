import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../core/theme/app_layout.dart';

/// Centers one stable content column and caps it at the project max width.
class AppContentFrame extends StatelessWidget {
  const AppContentFrame({
    required this.child,
    this.maxWidth = AppLayout.contentMaxWidth,
    super.key,
  });

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: SizedBox(width: double.infinity, child: child),
      ),
    );
  }
}

/// Standard scrollable page body with one horizontal alignment baseline.
class AppPageScrollView extends StatelessWidget {
  const AppPageScrollView({
    required this.children,
    this.padding = AppLayout.pagePadding,
    this.maxWidth = AppLayout.contentMaxWidth,
    this.controller,
    super.key,
  });

  final List<Widget> children;
  final EdgeInsetsGeometry padding;
  final double maxWidth;
  final ScrollController? controller;

  @override
  Widget build(BuildContext context) {
    return AppContentFrame(
      maxWidth: maxWidth,
      child: ListView(
        controller: controller,
        padding: padding,
        children: children,
      ),
    );
  }
}

/// Keeps a section heading, description, and body on the same left edge.
class AppSection extends StatelessWidget {
  const AppSection({
    required this.title,
    required this.child,
    this.description,
    this.headerGap = AppSpacing.xs,
    this.contentGap = AppSpacing.md,
    super.key,
  });

  final Widget title;
  final Widget? description;
  final Widget child;
  final double headerGap;
  final double contentGap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        title,
        if (description != null) ...[SizedBox(height: headerGap), description!],
        SizedBox(height: contentGap),
        child,
      ],
    );
  }
}

/// Stable row for an icon, multiline text, and a right-side action.
class AppListRow extends StatelessWidget {
  const AppListRow({
    required this.title,
    this.leading,
    this.subtitle,
    this.trailing,
    this.minHeight = AppLayout.listItemMinHeight,
    this.leadingWidth = AppLayout.iconTileSize,
    this.gap = AppSpacing.md,
    super.key,
  });

  final Widget? leading;
  final Widget title;
  final Widget? subtitle;
  final Widget? trailing;
  final double minHeight;
  final double leadingWidth;
  final double gap;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final text = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DefaultTextStyle.merge(style: theme.textTheme.p, child: title),
        if (subtitle != null) ...[
          const SizedBox(height: AppSpacing.xxs),
          DefaultTextStyle.merge(
            style: theme.textTheme.muted,
            child: subtitle!,
          ),
        ],
      ],
    );

    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: minHeight),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (leading != null) ...[
            SizedBox(
              width: leadingWidth,
              child: Align(alignment: Alignment.centerLeft, child: leading),
            ),
            SizedBox(width: gap),
          ],
          Expanded(child: text),
          if (trailing != null) ...[
            SizedBox(width: gap),
            ConstrainedBox(
              constraints: const BoxConstraints(
                minWidth: AppLayout.trailingActionMinWidth,
                minHeight: AppLayout.minimumTouchTarget,
              ),
              child: Center(child: trailing),
            ),
          ],
        ],
      ),
    );
  }
}
