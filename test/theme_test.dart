import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hsum_chaint/core/theme/app_theme.dart';
import 'package:hsum_chaint/core/theme/theme_controller.dart';
import 'package:hsum_chaint/features/mobile/common.dart';
import 'package:hsum_chaint/features/mobile/profile_screen.dart';
import 'package:hsum_chaint/presentation/widgets/primary_button.dart';

double contrast(Color a, Color b) {
  final x = a.computeLuminance(), y = b.computeLuminance();
  return x > y ? (x + .05) / (y + .05) : (y + .05) / (x + .05);
}

void main() {
  tearDown(Get.reset);
  test(
    'theme preference restores all modes and falls back for invalid values',
    () async {
      for (final value in ['system', 'light', 'dark', 'invalid']) {
        Get.reset();
        SharedPreferences.setMockInitialValues({'theme_mode': value});
        Get.put(await SharedPreferences.getInstance());
        final controller = Get.put(ThemeController());
        expect(controller.themeMode, switch (value) {
          'light' => ThemeMode.light,
          'dark' => ThemeMode.dark,
          _ => ThemeMode.system,
        });
        await controller.setThemeMode(ThemeMode.dark);
        expect(Get.find<SharedPreferences>().getString('theme_mode'), 'dark');
      }
    },
  );

  test('light and dark text and primary actions meet AA contrast', () {
    for (final theme in [AppTheme.lightTheme, AppTheme.darkTheme]) {
      final scheme = theme.colorScheme;
      for (final bg in [scheme.surface, theme.scaffoldBackgroundColor]) {
        expect(contrast(scheme.onSurface, bg), greaterThanOrEqualTo(4.5));
        expect(
          contrast(scheme.onSurfaceVariant, bg),
          greaterThanOrEqualTo(4.5),
        );
      }
      expect(
        contrast(scheme.primary, scheme.onPrimary),
        greaterThanOrEqualTo(4.5),
      );
      expect(
        contrast(scheme.primaryContainer, scheme.onPrimaryContainer),
        greaterThanOrEqualTo(4.5),
      );
    }
  });

  testWidgets('profile theme selection persists and changes app appearance', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    Get.put(await SharedPreferences.getInstance());
    final controller = Get.put(ThemeController());
    await tester.pumpWidget(
      Obx(
        () => MaterialApp(
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: controller.themeMode,
          home: const Scaffold(
            body: SingleChildScrollView(child: ThemeModeCard()),
          ),
        ),
      ),
    );
    await tester.tap(find.text('ညမှောင်'));
    await tester.pumpAndSettle();
    expect(controller.themeMode, ThemeMode.dark);
    expect(
      Theme.of(tester.element(find.byType(ThemeModeCard))).brightness,
      Brightness.dark,
    );
    expect(Get.find<SharedPreferences>().getString('theme_mode'), 'dark');
    await tester.tap(find.text('စနစ်အတိုင်း'));
    await tester.pumpAndSettle();
    expect(controller.themeMode, ThemeMode.system);
    expect(Get.find<SharedPreferences>().getString('theme_mode'), 'system');
  });

  testWidgets('reduced motion keeps button still and preserves activation', (
    tester,
  ) async {
    var taps = 0;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: Scaffold(
            body: PrimaryButton(text: 'လှူဒါန်းရန်', onPressed: () => taps++),
          ),
        ),
      ),
    );
    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(ElevatedButton)),
    );
    await tester.pump(const Duration(milliseconds: 100));
    expect(tester.widget<AnimatedScale>(find.byType(AnimatedScale)).scale, 1);
    await gesture.up();
    await tester.pumpAndSettle();
    expect(taps, 1);
    expect(
      tester.getSize(find.byType(ElevatedButton)).height,
      greaterThanOrEqualTo(48),
    );
  });

  testWidgets('appearance settings support narrow screens and enlarged text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    Get.put(ThemeController());
    for (final theme in [AppTheme.lightTheme, AppTheme.darkTheme]) {
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: MediaQuery(
            data: const MediaQueryData(textScaler: TextScaler.linear(2)),
            child: const Scaffold(
              body: SingleChildScrollView(child: ThemeModeCard()),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets(
    'status pills have accessible labels and contrast in both themes',
    (tester) async {
      final semantics = tester.ensureSemantics();

      for (final theme in [AppTheme.lightTheme, AppTheme.darkTheme]) {
        await tester.pumpWidget(
          MaterialApp(
            theme: theme,
            home: Scaffold(
              body: Column(
                children: [
                  for (var status = 0; status < 8; status++)
                    StatusBadge(status: status, label: 'Status $status'),
                ],
              ),
            ),
          ),
        );
        for (var status = 0; status < 8; status++) {
          expect(find.bySemanticsLabel('Status $status'), findsOneWidget);
          final text = tester.widget<Text>(find.text('Status $status'));
          final container = tester.widget<Container>(
            find.descendant(
              of: find.byWidgetPredicate(
                (w) => w is StatusBadge && w.status == status,
              ),
              matching: find.byType(Container),
            ),
          );
          expect(
            contrast(
              text.style!.color!,
              (container.decoration! as BoxDecoration).color!,
            ),
            greaterThanOrEqualTo(4.5),
          );
        }
        expect(tester.takeException(), isNull);
      }
      semantics.dispose();
    },
  );
}
