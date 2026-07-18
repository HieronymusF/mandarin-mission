import 'package:flutter/material.dart';

import '../../core/theme/app_layout.dart';

class AppLeadingRow extends StatelessWidget {
  const AppLeadingRow({
    required this.leading,
    required this.child,
    this.leadingWidth = AppLayout.iconTileSize,
    this.gap = AppSpacing.md,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    super.key,
  });

  final Widget leading;
  final Widget child;
  final double leadingWidth;
  final double gap;
  final CrossAxisAlignment crossAxisAlignment;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: crossAxisAlignment,
      children: [
        SizedBox(
          width: leadingWidth,
          child: Align(alignment: Alignment.centerLeft, child: leading),
        ),
        SizedBox(width: gap),
        Expanded(child: child),
      ],
    );
  }
}

class AppIconTile extends StatelessWidget {
  const AppIconTile({
    required this.icon,
    required this.backgroundColor,
    required this.foregroundColor,
    this.size = AppLayout.iconTileSize,
    this.iconSize = AppLayout.noticeIconSlot,
    super.key,
  });

  final IconData icon;
  final Color backgroundColor;
  final Color foregroundColor;
  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Icon(icon, color: foregroundColor, size: iconSize),
    );
  }
}
