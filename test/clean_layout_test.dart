import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'package:hsum_chaint/data/providers/auth_provider.dart';
import 'package:hsum_chaint/data/repositories/auth_repository.dart';
import 'package:hsum_chaint/features/authentication/controllers/auth_controller.dart';
import 'package:hsum_chaint/features/home/screens/home_screen.dart';
import 'package:hsum_chaint/core/theme/app_theme.dart';
import 'package:hsum_chaint/data/models/user_model.dart';
import 'package:hsum_chaint/data/repositories/mobile_repository.dart';
import 'package:hsum_chaint/features/mobile/calendar_screen.dart';
import 'widget_test.dart' as fixtures;

void main() {
  testWidgets('calendar day selection and today do not refetch the month', (
    tester,
  ) async {
    final adapter = fixtures.FakeAdapter(
      (_) =>
          fixtures.ok({'totalDonationsCount': 0, 'totalAmount': 0, 'days': []}),
    );
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: CalendarScreen(
            repo: MobileRepository(fixtures.service(adapter)),
            user: UserModel.fromJson(fixtures.session),
            mine: const [],
            onChanged: () {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final month = DateTime.now();
    final label =
        '${DateFormat.yMMMd().format(DateTime(month.year, month.month, 15))} · 0 လှူဒါန်းမှု';
    await tester.ensureVisible(find.bySemanticsLabel(label));
    await tester.tap(find.bySemanticsLabel(label));
    await tester.pumpAndSettle();
    expect(find.text('ရက်အားလုံး'), findsOneWidget);
    expect(adapter.requests, hasLength(1));
    await tester.tap(find.text('ရက်အားလုံး'));
    await tester.pumpAndSettle();
    expect(find.text('ရက်အားလုံး'), findsNothing);
    await tester.ensureVisible(find.text('ယနေ့'));
    await tester.tap(find.text('ယနေ့'));
    await tester.pumpAndSettle();
    expect(find.text('ရက်အားလုံး'), findsOneWidget);
    expect(adapter.requests, hasLength(1));
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'calendar filters apply once and cancelling leaves results unchanged',
    (tester) async {
      final adapter = fixtures.FakeAdapter(
        (_) => fixtures.ok({
          'totalDonationsCount': 0,
          'totalAmount': 0,
          'days': [],
        }),
      );
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: CalendarScreen(
              repo: MobileRepository(fixtures.service(adapter)),
              user: UserModel.fromJson(fixtures.session),
              mine: const [],
              onChanged: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('စစ်ထုတ်ရန်'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('အားလုံး'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('လှူဒါန်းမှုပြီးစီး').last);
      await tester.tap(find.text('လှူဒါန်းမှုပြီးစီး').last);
      await tester.pumpAndSettle();
      expect(adapter.requests, hasLength(1));
      await tester.tap(find.text('ရလဒ်များ ပြရန်'));
      await tester.pumpAndSettle();
      expect(adapter.requests, hasLength(2));
      expect(adapter.requests.last.queryParameters['status'], 5);
      await tester.tap(find.text('စစ်ထုတ်ထားသည်'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('စစ်ထုတ်မှုများ ရှင်းရန်'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('ပိတ်ရန်'));
      await tester.pumpAndSettle();
      expect(adapter.requests, hasLength(2));
      expect(find.text('စစ်ထုတ်ထားသည်'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'shell adapts between desktop sidebar and mobile tabs with enlarged text',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(Get.reset);
      Get.put(
        fixtures.service(
          fixtures.FakeAdapter((r) {
            if (r.path.endsWith('/calendar')) {
              return fixtures.ok({
                'totalDonationsCount': 0,
                'totalAmount': 0,
                'days': [],
              });
            }
            return fixtures.ok([], pagination: fixtures.pagination);
          }),
        ),
      );
      final auth = Get.put(AuthController(AuthRepository(AuthProvider())));
      auth.currentUser.value = UserModel.fromJson({
        ...fixtures.session,
        'name': 'အလှူရှင်',
      });
      for (final (size, scale, dark) in [
        (const Size(1440, 1000), 1.0, false),
        (const Size(390, 844), 1.0, true),
        (const Size(320, 900), 2.0, false),
      ]) {
        tester.view.physicalSize = size;
        await tester.pumpWidget(
          MaterialApp(
            theme: dark ? AppTheme.darkTheme : AppTheme.lightTheme,
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: TextScaler.linear(scale)),
              child: child!,
            ),
            home: HomeScreen(key: ValueKey(size)),
          ),
        );
        await tester.pumpAndSettle();
        expect(
          find.byType(NavigationDestination),
          size.width >= 1000 ? findsNothing : findsNWidgets(5),
        );
        if (size.width >= 1000) expect(find.byType(ListTile), findsNWidgets(5));
        expect(tester.takeException(), isNull);
      }
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );
}
