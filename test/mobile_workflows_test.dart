import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart' hide fail;
import 'package:get/get.dart';
import 'package:hsum_chaint/data/models/mobile_models.dart';
import 'package:hsum_chaint/data/models/user_model.dart';
import 'package:hsum_chaint/data/providers/auth_provider.dart';
import 'package:hsum_chaint/data/repositories/auth_repository.dart';
import 'package:hsum_chaint/data/repositories/mobile_repository.dart';
import 'package:hsum_chaint/features/authentication/controllers/auth_controller.dart';
import 'package:hsum_chaint/features/mobile/donation_form.dart';
import 'package:hsum_chaint/features/mobile/monasteries_screen.dart';
import 'package:hsum_chaint/features/mobile/notifications_screen.dart';
import 'package:hsum_chaint/features/mobile/profile_screen.dart';
import 'widget_test.dart'
    show FakeAdapter, ok, fail, service, pagination, session;

final donor = UserModel.fromJson({...session, 'name': 'Donor'});
final monk = UserModel.fromJson({
  ...session,
  'roleId': 2,
  'name': 'Monk',
  'permissions': [
    'Donation.Create',
    'Donation.Review',
    'Donation.Schedule',
    'Donation.Delete',
  ],
});
const mine = [Monastery(id: 4, name: 'ကျောင်းတိုက်', roleId: 1, isOwner: true)];

Future<void> fill(WidgetTester tester, String label, String value) async {
  final field = find.widgetWithText(TextFormField, label);
  await tester.scrollUntilVisible(
    field,
    180,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.enterText(field, value);
}

Future<void> submit(WidgetTester tester, String text) async {
  final button = find.widgetWithText(FilledButton, text);
  await tester.scrollUntilVisible(
    button,
    200,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.tap(button);
  await tester.pumpAndSettle();
}

Future<void> launchForm(
  WidgetTester tester,
  MobileRepository repo,
  UserModel user, {
  void Function(bool)? result,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () async {
              final saved = await showDonationForm(context, repo, user, mine);
              result?.call(saved);
            },
            child: const Text('Open'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Open'));
  await tester.pumpAndSettle();
}

void main() {
  tearDown(() {
    Get.reset();
  });

  testWidgets(
    'one-time donation submits real form payload and returns success',
    (tester) async {
      final adapter = FakeAdapter((_) => ok({'id': 3}));
      var saved = false;
      await launchForm(
        tester,
        MobileRepository(service(adapter)),
        donor,
        result: (v) => saved = v,
      );
      await fill(tester, 'အလှူငွေ (ကျပ်)', '1200');
      await fill(tester, 'အရေအတွက်', '2');
      await submit(tester, 'တင်သွင်းရန်');
      expect(saved, isTrue);
      expect(adapter.requests.single.path, '/api/v1/donations/request');
      expect(adapter.requests.single.data['monasterySpaceId'], 4);
      expect(adapter.requests.single.data['amount'], 1200);
      expect(adapter.requests.single.data['quantity'], 2);
      expect(adapter.requests.single.data['donationType'], 1);
    },
  );

  testWidgets(
    'recurring form validates limits and sends backend series fields',
    (tester) async {
      final adapter = FakeAdapter((_) => ok([]));
      await launchForm(tester, MobileRepository(service(adapter)), donor);
      await tester.tap(find.text('လစဉ် ပုံမှန်လှူဒါန်းမည်'));
      await tester.pumpAndSettle();
      await fill(tester, 'လစဉ် ရက် (၁–၃၁)', '32');
      await fill(tester, 'လအရေအတွက် (၁–၂၄)', '25');
      await submit(tester, 'တင်သွင်းရန်');
      expect(adapter.requests, isEmpty);
      expect(find.text('၁ မှ ၂၄ အတွင်း ဖြည့်ပါ။'), findsOneWidget);
      await fill(tester, 'လစဉ် ရက် (၁–၃၁)', '31');
      await fill(tester, 'လအရေအတွက် (၁–၂၄)', '3');
      await submit(tester, 'တင်သွင်းရန်');
      expect(
        adapter.requests.single.path,
        '/api/v1/donations/recurring/request',
      );
      expect(adapter.requests.single.data['dayOfMonth'], 31);
      expect(adapter.requests.single.data['monthsCount'], 3);
      expect(adapter.requests.single.data.containsKey('startDate'), isTrue);
      expect(
        adapter.requests.single.data.containsKey('pickupTimeOfDay'),
        isTrue,
      );
      expect(adapter.requests.single.data.containsKey('pickupTime'), isFalse);
    },
  );

  testWidgets(
    'manual form requires donor identity and supports batch payload',
    (tester) async {
      final adapter = FakeAdapter((_) => ok([]));
      await launchForm(tester, MobileRepository(service(adapter)), monk);
      await submit(tester, 'တင်သွင်းရန်');
      expect(adapter.requests, isEmpty);
      await fill(tester, 'အလှူရှင်အမည်', 'ဒေါ်မြ');
      final add = find.widgetWithText(
        OutlinedButton,
        'အစုလိုက်စာရင်းထဲ ထည့်ရန်',
      );
      await tester.scrollUntilVisible(
        add,
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(add);
      await tester.pumpAndSettle();
      await submit(tester, 'အစုလိုက် 1 ခု တင်သွင်းရန်');
      expect(adapter.requests.single.path, '/api/v1/donations/batch');
      expect(adapter.requests.single.data['monasterySpaceId'], 4);
      expect(adapter.requests.single.data['donations'], hasLength(1));
      expect(
        adapter.requests.single.data['donations'][0]['donorName'],
        'ဒေါ်မြ',
      );
    },
  );

  testWidgets('failed submission keeps form and permits retry', (tester) async {
    var attempts = 0;
    final adapter = FakeAdapter(
      (_) => ++attempts == 1 ? fail(403, 'Permission denied') : ok({'id': 3}),
    );
    await launchForm(tester, MobileRepository(service(adapter)), donor);
    await submit(tester, 'တင်သွင်းရန်');
    expect(find.text('Permission denied'), findsOneWidget);
    expect(find.byType(DonationForm), findsOneWidget);
    await submit(tester, 'တင်သွင်းရန်');
    expect(attempts, 2);
    expect(find.byType(DonationForm), findsNothing);
  });

  testWidgets('invitation acceptance sends numeric status to backend', (
    tester,
  ) async {
    var accepted = false;
    var changed = false;
    final adapter = FakeAdapter((r) {
      if (r.method == 'POST') {
        accepted = true;
        return ok(true);
      }
      if (r.path.endsWith('/invitations')) {
        return ok([
          {
            'id': 9,
            'monasterySpaceName': 'ကျောင်းတိုက်',
            'spaceRoleId': 4,
            'status': accepted ? 1 : 0,
          },
        ], pagination: pagination);
      }
      return ok([], pagination: pagination);
    });
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MonasteriesScreen(
            repo: MobileRepository(service(adapter)),
            user: donor,
            mine: const [],
            onChanged: () => changed = true,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('ဖိတ်ကြားချက်'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('လက်ခံရန်'));
    await tester.pumpAndSettle();
    expect(accepted, isTrue);
    expect(changed, isTrue);
    final request = adapter.requests.singleWhere((r) => r.method == 'POST');
    expect(request.path, '/api/v1/monasteries/invitations/9/respond');
    expect(request.data, {'status': 1});
  });

  testWidgets('profile and settings screens use unversioned user routes', (
    tester,
  ) async {
    final adapter = FakeAdapter((r) {
      if (r.path.endsWith('/settings')) return ok({'userId': 7});
      if (r.path.endsWith('/monk-profile')) {
        return ok({'monasteryName': 'ကျောင်း', 'monasteryAddress': 'ရန်ကုန်'});
      }
      if (r.method == 'PUT') return ok(true);
      return ok({'id': 7, 'name': 'Monk', 'phoneNumber': '09123', 'roleId': 2});
    });
    Get.put(service(adapter));
    final auth = AuthController(AuthRepository(AuthProvider()));
    auth.currentUser.value = monk;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProfileScreen(repo: MobileRepository(Get.find()), auth: auth),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      adapter.requests.map((r) => r.path),
      containsAll([
        '/api/user/7',
        '/api/user/7/settings',
        '/api/user/7/monk-profile',
      ]),
    );
    await tester.tap(find.byTooltip('ပြင်ဆင်ရန်'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'အမည်'),
      'ဆရာတော်',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'သိမ်းရန်'));
    await tester.pumpAndSettle();
    final request = adapter.requests.singleWhere((r) => r.method == 'PUT');
    expect(request.path, '/api/user');
    expect(request.data['id'], 7);
    expect(request.data['roleId'], 2);
    expect(request.data['name'], 'ဆရာတော်');
    expect(auth.currentUser.value!.name, 'ဆရာတော်');
    expect(auth.currentUser.value!.permissions, monk.permissions);
  });

  testWidgets('notifications mark read and refresh unread count', (
    tester,
  ) async {
    var read = false;
    var changed = 0;
    final adapter = FakeAdapter((r) {
      if (r.method == 'PATCH') {
        read = true;
        return ok(true);
      }
      return ok([
        {
          'id': 8,
          'message': 'လှူဒါန်းမှု လက်ခံပြီး',
          'isRead': read,
          'createdAt': '2026-10-23T00:00:00Z',
        },
      ], pagination: pagination);
    });
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: NotificationsScreen(
            repo: MobileRepository(service(adapter)),
            userId: 7,
            onChanged: () => changed++,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('လှူဒါန်းမှု လက်ခံပြီး'));
    await tester.pumpAndSettle();
    expect(read, isTrue);
    expect(changed, 1);
    final request = adapter.requests.singleWhere((r) => r.method == 'PATCH');
    expect(request.path, '/api/v1/notifications/read-noti');
    expect(request.data, {'notificationId': 8, 'userId': 7});
  });

  test(
    'refresh completing after logout cannot overwrite a new account session',
    () async {
      final pending = Completer<ResponseBody>();
      final adapter = FakeAdapter((r) {
        if (r.path.endsWith('/refresh-token')) return pending.future;
        return r.headers['Authorization'] == 'Bearer new-user'
            ? ok(true)
            : fail(401, 'Expired');
      });
      final api = service(adapter)..setSession('old', 'old-refresh', 7);
      final oldRequest = api.get('/api/user/7');
      // Install the error expectation before completing the pending refresh.
      final failed = expectLater(oldRequest, throwsA(isA<Exception>()));
      while (!adapter.requests.any((r) => r.path.endsWith('/refresh-token'))) {
        await Future<void>.delayed(Duration.zero);
      }
      api.clearSession();
      api.setSession('new-user', 'new-user-refresh', 9);
      pending.complete(ok({...session, 'accessToken': 'old-refreshed'}));
      await failed;
      await api.get('/api/user/9');
      expect(adapter.requests.last.headers['Authorization'], 'Bearer new-user');
    },
  );
}
