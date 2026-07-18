import 'package:flutter/widgets.dart';

abstract final class AppSpacing {
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 32;
}

abstract final class AppRadius {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
}

abstract final class AppLayout {
  static const double contentMaxWidth = 640;
  static const double loadingMaxWidth = 240;
  static const double errorMaxWidth = 440;

  static const double minimumTouchTarget = 44;
  static const double controlHeight = 48;
  static const double answerControlHeight = 72;
  static const double mediaPanelHeight = 80;

  static const double iconTileSize = 48;
  static const double noticeIconSlot = 24;
  static const double listIconSlot = 32;

  static const EdgeInsets cardPadding = EdgeInsets.all(AppSpacing.lg);
  static const EdgeInsets compactCardPadding = EdgeInsets.all(AppSpacing.md);
  static const EdgeInsets pagePadding = EdgeInsets.fromLTRB(
    AppSpacing.lg,
    AppSpacing.lg,
    AppSpacing.lg,
    AppSpacing.xxl,
  );
  static const EdgeInsets lessonBodyPadding = EdgeInsets.fromLTRB(
    AppSpacing.lg,
    AppSpacing.xl,
    AppSpacing.lg,
    AppSpacing.lg,
  );
  static const EdgeInsets lessonActionPadding = EdgeInsets.fromLTRB(
    AppSpacing.lg,
    AppSpacing.sm,
    AppSpacing.lg,
    AppSpacing.lg,
  );
}
