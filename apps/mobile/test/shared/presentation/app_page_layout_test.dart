import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mandarin_mission/core/theme/app_layout.dart';
import 'package:mandarin_mission/core/theme/app_text_styles.dart';
import 'package:mandarin_mission/core/theme/app_theme.dart';
import 'package:mandarin_mission/shared/presentation/app_page_layout.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

void main() {
  test('typography exposes stable semantic line heights', () {
    expect(AppTextStyles.pageTitle.height, 36 / 30);
    expect(AppTextStyles.body.height, 28 / 16);
    expect(AppTextStyles.label.height, 20 / 14);
    expect(AppTextStyles.fontFamilyFallback, contains('Noto Sans SC'));
  });

  testWidgets('content frame stays centered at all QA widths', (tester) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    tester.view.devicePixelRatio = 1;

    for (final width in [768.0, 1024.0, 1280.0, 1440.0]) {
      tester.view.physicalSize = Size(width, 900);
      await tester.pumpWidget(
        _TestApp(
          child: AppContentFrame(
            key: const Key('frame'),
            child: Container(key: const Key('content')),
          ),
        ),
      );

      final frame = tester.getRect(find.byKey(const Key('frame')));
      final content = tester.getRect(find.byKey(const Key('content')));
      expect(frame.width, width);
      expect(content.width, AppLayout.contentMaxWidth);
      expect(content.left, closeTo((width - 640) / 2, 0.01));
    }
  });

  testWidgets('section content shares one horizontal baseline', (tester) async {
    await tester.pumpWidget(
      const _TestApp(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: AppSection(
            title: Text('Title', key: Key('title')),
            description: Text('Description', key: Key('description')),
            child: SizedBox(key: Key('body'), height: 40),
          ),
        ),
      ),
    );

    final title = tester.getTopLeft(find.byKey(const Key('title')));
    final description = tester.getTopLeft(find.byKey(const Key('description')));
    final body = tester.getTopLeft(find.byKey(const Key('body')));
    expect(description.dx, title.dx);
    expect(body.dx, title.dx);
  });

  testWidgets('list row keeps multiline text and trailing action aligned', (
    tester,
  ) async {
    await tester.pumpWidget(
      const _TestApp(
        child: SizedBox(
          width: 360,
          child: AppListRow(
            leading: SizedBox(key: Key('leading'), width: 24, height: 24),
            title: Text('A title that can wrap onto another line'),
            subtitle: Text('Supporting text also remains in the text column.'),
            trailing: SizedBox(key: Key('trailing'), width: 20, height: 20),
          ),
        ),
      ),
    );

    final row = tester.getRect(find.byType(AppListRow));
    final leading = tester.getRect(find.byKey(const Key('leading')));
    final trailing = tester.getRect(find.byKey(const Key('trailing')));
    expect(row.height, greaterThanOrEqualTo(AppLayout.listItemMinHeight));
    expect(leading.center.dy, closeTo(row.center.dy, 0.01));
    expect(trailing.center.dy, closeTo(row.center.dy, 0.01));
  });
}

class _TestApp extends StatelessWidget {
  const _TestApp({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = buildAppShadTheme();
    return ShadApp.custom(
      theme: theme,
      appBuilder: (context) => MaterialApp(
        theme: buildAppMaterialTheme(Theme.of(context), theme),
        home: Scaffold(body: child),
        builder: (context, child) =>
            ShadAppBuilder(child: child ?? const SizedBox.shrink()),
      ),
    );
  }
}
