import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

const missionPrimary = Color(0xFF176B52);
const missionPrimaryForeground = Color(0xFFFFFFFF);
const missionBackground = Color(0xFFF7F9F7);
const missionForeground = Color(0xFF17201D);
const missionCard = Color(0xFFFFFFFF);
const missionBorder = Color(0xFFDDE4E0);
const missionMuted = Color(0xFFF0F3F1);
const missionMutedForeground = Color(0xFF66736E);
const missionAccent = Color(0xFFE4F3EC);
const missionAccentForeground = Color(0xFF164C3B);
const missionWarning = Color(0xFFFFF2CC);
const missionWarningForeground = Color(0xFF6A4A00);
const missionSuccess = Color(0xFFDDF4E8);
const missionSuccessForeground = Color(0xFF15543F);

ShadThemeData buildAppShadTheme() {
  final colorScheme = const ShadNeutralColorScheme.light().copyWith(
    background: missionBackground,
    foreground: missionForeground,
    card: missionCard,
    cardForeground: missionForeground,
    popover: missionCard,
    popoverForeground: missionForeground,
    primary: missionPrimary,
    primaryForeground: missionPrimaryForeground,
    secondary: missionMuted,
    secondaryForeground: missionForeground,
    muted: missionMuted,
    mutedForeground: missionMutedForeground,
    accent: missionAccent,
    accentForeground: missionAccentForeground,
    border: missionBorder,
    input: missionBorder,
    ring: missionPrimary,
    selection: missionAccent,
    custom: const {
      'success': missionSuccess,
      'successForeground': missionSuccessForeground,
      'warning': missionWarning,
      'warningForeground': missionWarningForeground,
    },
  );

  return ShadThemeData(
    colorScheme: colorScheme,
    radius: BorderRadius.circular(12),
  );
}

ThemeData buildAppMaterialTheme(ThemeData baseTheme, ShadThemeData shadTheme) {
  final colors = shadTheme.colorScheme;
  return baseTheme.copyWith(
    colorScheme: ColorScheme(
      brightness: Brightness.light,
      primary: colors.primary,
      onPrimary: colors.primaryForeground,
      secondary: colors.secondary,
      onSecondary: colors.secondaryForeground,
      error: colors.destructive,
      onError: colors.destructiveForeground,
      surface: colors.background,
      onSurface: colors.foreground,
      surfaceContainerHighest: colors.muted,
      onSurfaceVariant: colors.mutedForeground,
      outline: colors.border,
      outlineVariant: colors.border,
    ),
    scaffoldBackgroundColor: colors.background,
    canvasColor: colors.background,
    dividerColor: colors.border,
    appBarTheme: AppBarTheme(
      backgroundColor: colors.background,
      foregroundColor: colors.foreground,
      surfaceTintColor: Colors.transparent,
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: colors.card,
      shape: RoundedRectangleBorder(
        borderRadius: shadTheme.radius,
        side: BorderSide(color: colors.border),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(48),
        shape: RoundedRectangleBorder(borderRadius: shadTheme.radius),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: colors.foreground,
      contentTextStyle: TextStyle(color: colors.background),
      behavior: SnackBarBehavior.floating,
    ),
  );
}
