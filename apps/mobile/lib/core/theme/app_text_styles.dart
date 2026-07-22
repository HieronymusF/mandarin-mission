import 'package:flutter/widgets.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// Stable semantic typography for Mandarin Mission.
///
/// Feature widgets should consume these styles through [ShadTheme.textTheme]
/// using the mapping documented in the root `WIDGET_LIBRARY.md`.
abstract final class AppTextStyles {
  static const String fontFamily = 'packages/shadcn_ui/Geist';
  static const List<String> fontFamilyFallback = <String>[
    'Noto Sans SC',
    'Microsoft YaHei',
    'PingFang SC',
    'sans-serif',
  ];

  static const TextStyle display = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 48,
    height: 1,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.4,
    textBaseline: TextBaseline.alphabetic,
    leadingDistribution: TextLeadingDistribution.even,
  );

  static const TextStyle heroTitle = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 36,
    height: 40 / 36,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.4,
    textBaseline: TextBaseline.alphabetic,
    leadingDistribution: TextLeadingDistribution.even,
  );

  static const TextStyle pageTitle = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 30,
    height: 36 / 30,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.4,
    textBaseline: TextBaseline.alphabetic,
    leadingDistribution: TextLeadingDistribution.even,
  );

  static const TextStyle sectionTitle = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 24,
    height: 32 / 24,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.4,
    textBaseline: TextBaseline.alphabetic,
    leadingDistribution: TextLeadingDistribution.even,
  );

  static const TextStyle subsectionTitle = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 20,
    height: 28 / 20,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.4,
    textBaseline: TextBaseline.alphabetic,
    leadingDistribution: TextLeadingDistribution.even,
  );

  static const TextStyle body = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 16,
    height: 28 / 16,
    fontWeight: FontWeight.w400,
    textBaseline: TextBaseline.alphabetic,
    leadingDistribution: TextLeadingDistribution.even,
  );

  static const TextStyle quote = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 16,
    height: 24 / 16,
    fontWeight: FontWeight.w400,
    fontStyle: FontStyle.italic,
    textBaseline: TextBaseline.alphabetic,
    leadingDistribution: TextLeadingDistribution.even,
  );

  static const TextStyle tableLabel = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 16,
    height: 24 / 16,
    fontWeight: FontWeight.w700,
    textBaseline: TextBaseline.alphabetic,
    leadingDistribution: TextLeadingDistribution.even,
  );

  static const TextStyle listItem = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 16,
    height: 24 / 16,
    fontWeight: FontWeight.w400,
    textBaseline: TextBaseline.alphabetic,
    leadingDistribution: TextLeadingDistribution.even,
  );

  static const TextStyle lead = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 20,
    height: 28 / 20,
    fontWeight: FontWeight.w400,
    textBaseline: TextBaseline.alphabetic,
    leadingDistribution: TextLeadingDistribution.even,
  );

  static const TextStyle emphasized = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 18,
    height: 28 / 18,
    fontWeight: FontWeight.w600,
    textBaseline: TextBaseline.alphabetic,
    leadingDistribution: TextLeadingDistribution.even,
  );

  static const TextStyle label = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 14,
    height: 20 / 14,
    fontWeight: FontWeight.w500,
    textBaseline: TextBaseline.alphabetic,
    leadingDistribution: TextLeadingDistribution.even,
  );

  static const TextStyle supporting = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 14,
    height: 20 / 14,
    fontWeight: FontWeight.w400,
    textBaseline: TextBaseline.alphabetic,
    leadingDistribution: TextLeadingDistribution.even,
  );

  static ShadTextTheme get shadTextTheme => const ShadTextTheme.custom(
    h1Large: display,
    h1: heroTitle,
    h2: pageTitle,
    h3: sectionTitle,
    h4: subsectionTitle,
    p: body,
    blockquote: quote,
    table: tableLabel,
    list: listItem,
    lead: lead,
    large: emphasized,
    small: label,
    muted: supporting,
    family: fontFamily,
  );
}
