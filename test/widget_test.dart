import 'package:hsum_chaint/core/navigation/app_router.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hsum_chaint/data/models/mobile_models.dart';
import 'package:hsum_chaint/data/models/user_model.dart';
import 'package:hsum_chaint/data/providers/auth_provider.dart';
import 'package:hsum_chaint/data/repositories/auth_repository.dart';
import 'package:hsum_chaint/data/repositories/mobile_repository.dart';
import 'package:hsum_chaint/data/services/api_service.dart';
import 'package:hsum_chaint/features/authentication/controllers/auth_controller.dart';
import 'package:hsum_chaint/features/mobile/donation_form.dart';
import 'package:hsum_chaint/features/mobile/donations_screen.dart';
import 'package:hsum_chaint/features/mobile/common.dart';
import 'package:hsum_chaint/main.dart';

class FakeAdapter implements HttpClientAdapter {
  final FutureOr<ResponseBody> Function(RequestOptions) respond;
  final requests = <RequestOptions>[];
  FakeAdapter(this.respond);
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    return respond(options);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody ok(dynamic data, {Json? pagination}) => ResponseBody.fromString(
  jsonEncode({
    'isSuccess': true,
    'message': 'Success',
    'data': data,
    'pagination': ?pagination,
  }),
  200,
  headers: {
    Headers.contentTypeHeader: [Headers.jsonContentType],
  },
);
ResponseBody fail(int status, String message) => ResponseBody.fromString(
  jsonEncode({'isSuccess': false, 'message': message}),
  status,
  headers: {
    Headers.contentTypeHeader: [Headers.jsonContentType],
  },
);
Json get pagination => {
  'pageNumber': 1,
  'pageSize': 10,
  'totalCount': 0,
  'totalPages': 0,
};
Json get session => {
  'id': 7,
  'roleId': 3,
  'roleName': 'User',
  'permissions': ['Donation.View', 'Donation.Create', 'Donation.Cancel'],
  'accessToken': 'access',
  'refreshToken': 'refresh',
};
ApiService service(FakeAdapter adapter) => ApiService(
  client: Dio(BaseOptions(baseUrl: 'https://test.local'))
    ..httpClientAdapter = adapter,
);

void main() {
  tearDown(() {
    Get.reset();
  });

  test(
    'login unwraps backend Result, loads profile, and sets bearer token',
    () async {
      final adapter = FakeAdapter((request) {
        if (request.path == '/api/v1/auth/login') return ok(session);
        expect(request.path, '/api/user/7');
        expect(request.headers['Authorization'], 'Bearer access');
        return ok({
          'id': 7,
          'name': 'အလှူရှင်',
          'phoneNumber': '09123',
          'roleId': 3,
        });
      });
      Get.put(service(adapter));
      final repo = AuthRepository(AuthProvider());
      final (failure, user) = await repo.login('09123', 'secret');
      expect(failure, isNull);
      expect(user!.name, 'အလှူရှင်');
      expect(user.isDonor, isTrue);
      expect(user.can('Donation.Create'), isTrue);
      expect(adapter.requests.first.data, {
        'phoneNumber': '09123',
        'password': 'secret',
      });
    },
  );

  test('register uses one endpoint and numeric system roles', () async {
    final adapter = FakeAdapter((request) => ok(null));
    Get.put(service(adapter));
    final provider = AuthProvider();
    await provider.signupUser(
      phone: '09',
      username: 'Donor',
      password: 'secret',
    );
    await provider.signupMonk(
      phone: '08',
      username: 'Monk',
      password: 'secret',
      monasteryName: 'ကျောင်း',
      monasteryAddress: 'ရန်ကုန်',
    );
    expect(
      adapter.requests.map((r) => r.path),
      everyElement('/api/v1/auth/register'),
    );
    expect(adapter.requests[0].data['roleId'], 3);
    expect(adapter.requests[1].data['roleId'], 2);
    expect(adapter.requests[1].data['monasteryName'], 'ကျောင်း');
    expect(adapter.requests[1].data.containsKey('monastery_name'), isFalse);
  });

  test('admin accounts are not admitted to mobile', () async {
    final adapter = FakeAdapter((_) => ok({...session, 'roleId': 1}));
    Get.put(service(adapter));
    final (failure, user) = await AuthRepository(
      AuthProvider(),
    ).login('09', 'secret');
    expect(failure, isNotNull);
    expect(user, isNull);
    expect(adapter.requests, hasLength(1));
  });

  test('list and search use different paths and keyword parameter', () async {
    final adapter = FakeAdapter((_) => ok([], pagination: pagination));
    final repo = MobileRepository(service(adapter));
    await repo.monasteries();
    await repo.monasteries(keyword: '  Yangon  ', page: 2);
    await repo.monasteries(keyword: ' ');
    expect(adapter.requests[0].path, '/api/v1/monasteries');
    expect(adapter.requests[0].queryParameters.containsKey('keyword'), isFalse);
    expect(adapter.requests[1].path, '/api/v1/monasteries/search');
    expect(adapter.requests[1].queryParameters['keyword'], 'Yangon');
    expect(adapter.requests[1].queryParameters['pageNumber'], 2);
    expect(adapter.requests[2].path, '/api/v1/monasteries');
  });

  test('all joined monasteries are loaded across pages', () async {
    final adapter = FakeAdapter((r) {
      final page = r.queryParameters['pageNumber'];
      return ok(
        [
          {'id': page, 'monasteryName': 'Space $page', 'currentUserRoleId': 4},
        ],
        pagination: {
          ...pagination,
          'pageNumber': page,
          'totalPages': 2,
          'totalCount': 2,
        },
      );
    });
    final spaces = await MobileRepository(service(adapter)).allMine();
    expect(spaces.map((m) => m.id), [1, 2]);
    expect(spaces.first.canOperate, isFalse);
  });

  test(
    'calendar scope and recurring payload follow backend contracts',
    () async {
      final adapter = FakeAdapter(
        (r) => r.path.endsWith('/calendar')
            ? ok({
                'year': 2026,
                'month': 10,
                'totalDonationsCount': 1,
                'totalAmount': 300,
                'days': [
                  {
                    'day': 23,
                    'date': '2026-10-23',
                    'donationsCount': 1,
                    'donations': [],
                  },
                ],
              })
            : ok([]),
      );
      final repo = MobileRepository(service(adapter));
      final summary = await repo.calendar(
        DateTime(2026, 10),
        monasteryId: 4,
        status: 2,
      );
      expect(summary.count, 1);
      expect(adapter.requests.first.queryParameters, {
        'year': 2026,
        'month': 10,
        'monasterySpaceId': 4,
        'status': 2,
      });
      final body = {
        'monasterySpaceId': 4,
        'donationType': 1,
        'dayOfMonth': 31,
        'monthsCount': 3,
        'startDate': '2026-10-01T00:00:00.000Z',
        'pickupTimeOfDay': '00:30:00',
      };
      await repo.donate(body, recurring: true);
      await repo.donate(body, recurring: true, manual: true);
      expect(adapter.requests[1].path, '/api/v1/donations/recurring/request');
      expect(adapter.requests[2].path, '/api/v1/donations/recurring/manual');
      expect(adapter.requests[1].data, body);
    },
  );

  test(
    'review, deletion and notification use backend verb and field names',
    () async {
      final adapter = FakeAdapter((_) => ok(true));
      final repo = MobileRepository(service(adapter));
      await repo.donationAction(
        9,
        'review',
        body: {'status': 3, 'note': 'သာဓု'},
      );
      await repo.donationAction(9, 'delete');
      await repo.notification(12, 7);
      await repo.notification(12, 7, delete: true);
      expect(adapter.requests[0].method, 'POST');
      expect(adapter.requests[0].path, '/api/v1/donations/9/review');
      expect(adapter.requests[1].method, 'DELETE');
      expect(adapter.requests[1].path, '/api/v1/donations/9');
      expect(adapter.requests[2].method, 'PATCH');
      expect(adapter.requests[2].data, {'notificationId': 12, 'userId': 7});
      expect(adapter.requests[3].method, 'DELETE');
      expect(adapter.requests[3].data, {'notificationId': 12, 'userId': 7});
    },
  );

  test('HTTP 200 business failures remain failures', () async {
    final adapter = FakeAdapter(
      (_) => ResponseBody.fromString(
        '{"isSuccess":false,"message":"Completed donations cannot be deleted."}',
        200,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      ),
    );
    await expectLater(
      MobileRepository(service(adapter)).donationAction(3, 'delete'),
      throwsA(
        isA<ApiFailure>().having(
          (e) => e.message,
          'message',
          contains('Completed'),
        ),
      ),
    );
  });

  test(
    'concurrent expired requests share a refresh and retry only once',
    () async {
      var refreshes = 0;
      final adapter = FakeAdapter((r) async {
        if (r.path.endsWith('/refresh-token')) {
          refreshes++;
          expect(r.data, {'userId': 7, 'refreshToken': 'old-refresh'});
          await Future<void>.delayed(const Duration(milliseconds: 20));
          return ok({
            ...session,
            'accessToken': 'new-access',
            'refreshToken': 'new-refresh',
          });
        }
        return r.headers['Authorization'] == 'Bearer new-access'
            ? ok(true)
            : fail(401, 'Expired');
      });
      final api = service(adapter)..setSession('old-access', 'old-refresh', 7);
      await Future.wait([
        api.get('/api/user/7'),
        api.get('/api/user/7/settings'),
      ]);
      expect(refreshes, 1);
      expect(
        adapter.requests.where((r) => r.path.endsWith('/refresh-token')),
        hasLength(1),
      );
    },
  );

  test(
    'refresh failure clears credentials and signals session expiry',
    () async {
      final adapter = FakeAdapter((_) => fail(401, 'Expired'));
      var expired = false;
      final api = service(adapter)
        ..setSession('old', 'refresh', 7)
        ..onSessionExpired = () => expired = true;
      await expectLater(api.get('/api/user/7'), throwsA(isA<ApiFailure>()));
      expect(expired, isTrue);
      expect(adapter.requests, hasLength(2));
    },
  );

  test('recurring times preserve selected local day against UTC base date', () {
    const time = TimeOfDay(hour: 6, minute: 15);
    final date = DateTime(2026, 10, 23);
    final span = recurringTimeSpan(time, date);
    final negative = span.startsWith('-');
    final parts = span.replaceFirst('-', '').split(':').map(int.parse).toList();
    final offset =
        Duration(hours: parts[0], minutes: parts[1]) * (negative ? -1 : 1);
    final result = DateTime.utc(2026, 10, 23).add(offset).toLocal();
    expect(result.day, 23);
    expect(result.hour, 6);
    expect(result.minute, 15);
  });

  testWidgets(
    'Burmese auth renders at narrow mobile width and offers role selection',
    (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();
      expect(find.text('ဝင်ရောက်ရန်'), findsOneWidget);
      expect(find.text('ဖုန်းနံပါတ်'), findsOneWidget);
      expect(find.textContaining('OTP'), findsNothing);
      await tester.tap(find.text('အကောင့်သစ်'));
      await tester.pumpAndSettle();
      expect(find.text('အလှူရှင်'), findsOneWidget);
      await tester.tap(find.text('သံဃာတော်'));
      await tester.pumpAndSettle();
      expect(find.text('ကျောင်းတိုက်အမည်'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets('donor shell has five tabs and notification badge', (
    tester,
  ) async {
    final adapter = FakeAdapter((r) {
      if (r.path.endsWith('/calendar')) {
        return ok({'totalDonationsCount': 0, 'totalAmount': 0, 'days': []});
      }
      if (r.path.endsWith('/notification')) {
        return ok([
          {'id': 1, 'message': 'အသိပေးချက်', 'isRead': false},
        ], pagination: pagination);
      }
      return ok([], pagination: pagination);
    });
    Get.put(service(adapter));
    final auth = Get.put(AuthController(AuthRepository(AuthProvider())));
    auth.currentUser.value = UserModel.fromJson({
      ...session,
      'name': 'အလှူရှင်',
    });
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();
    expect(find.byType(NavigationDestination), findsNWidgets(5));
    expect(find.byType(Badge), findsOneWidget);
    expect(find.text('ဆွမ်းပြက္ခဒိန်'), findsOneWidget);
    await tester.tap(find.text('လှူဒါန်းမှု'));
    await tester.pumpAndSettle();
    expect(find.text('မိမိ၏ လှူဒါန်းမှုများ'), findsOneWidget);
    expect(
      adapter.requests.any(
        (r) =>
            r.path == '/api/v1/donations' && r.queryParameters['donorId'] == 7,
      ),
      isTrue,
    );
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('viewer does not get review schedule or delete actions', (
    tester,
  ) async {
    final adapter = FakeAdapter((_) => ok(true));
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DonationCard(
            donation: const Donation(
              id: 4,
              monasteryId: 1,
              type: 1,
              status: 2,
              donorId: 7,
            ),
            repo: MobileRepository(service(adapter)),
            user: UserModel(
              id: '7',
              name: 'Donor',
              permissions: const ['Donation.Cancel', 'Donation.Review'],
            ),
            mine: const [Monastery(id: 1, name: 'Space', roleId: 4)],
            onChanged: () {},
          ),
        ),
      ),
    );
    await tester.tap(find.byType(PopupMenuButton<String>));
    await tester.pumpAndSettle();
    expect(find.text('ပယ်ဖျက်ရန်'), findsOneWidget);
    expect(find.text('လက်ခံ / ငြင်းပယ်'), findsNothing);
    expect(find.text('အချိန်သတ်မှတ်ရန်'), findsNothing);
    expect(find.text('ဖျက်ရန်'), findsNothing);
  });

  testWidgets('completed donations cannot be cancelled or deleted', (
    tester,
  ) async {
    final adapter = FakeAdapter((_) => ok(true));
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DonationCard(
            donation: const Donation(
              id: 4,
              monasteryId: 1,
              type: 1,
              status: 5,
              donorId: 7,
            ),
            repo: MobileRepository(service(adapter)),
            user: UserModel(
              id: '7',
              name: 'Monk',
              roleId: 2,
              permissions: const [
                'Donation.Cancel',
                'Donation.Delete',
                'Donation.Schedule',
                'Donation.Review',
              ],
            ),
            mine: const [
              Monastery(id: 1, name: 'Space', roleId: 1, isOwner: true),
            ],
            onChanged: () {},
          ),
        ),
      ),
    );
    await tester.tap(find.byType(PopupMenuButton<String>));
    await tester.pumpAndSettle();
    expect(find.text('အသေးစိတ်'), findsOneWidget);
    expect(find.text('ဖျက်ရန်'), findsNothing);
    expect(find.text('ပယ်ဖျက်ရန်'), findsNothing);
    expect(find.text('လက်ခံ / ငြင်းပယ်'), findsNothing);
  });

  test(
    'session persistence: saves session to shared_preferences and restores on startup',
    () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      Get.put<SharedPreferences>(prefs);

      final api = service(FakeAdapter((_) => ok(true)));
      Get.put<ApiService>(api);
      final repo = AuthRepository(AuthProvider());
      final controller = AuthController(repo);
      Get.put<AuthController>(controller);

      expect(controller.isAuthenticated, isFalse);

      final testUser = UserModel(
        id: '42',
        name: 'Test Donor',
        roleId: 3,
        token: 'jwt-access-token',
        refreshToken: 'jwt-refresh-token',
        permissions: const ['Donation.Create'],
      );
      controller.currentUser.value = testUser;

      final stored = prefs.getString(AuthController.sessionKey);
      expect(stored, isNotNull);
      final decoded = jsonDecode(stored!) as Map<String, dynamic>;
      expect(decoded['id'], 42);
      expect(decoded['name'], 'Test Donor');
      expect(decoded['accessToken'], 'jwt-access-token');
      expect(decoded['refreshToken'], 'jwt-refresh-token');

      // Reset Get and simulate fresh launch
      Get.reset();
      Get.put<SharedPreferences>(prefs);
      Get.put<ApiService>(service(FakeAdapter((_) => ok(true))));
      final newController = AuthController(repo);
      Get.put<AuthController>(newController);

      expect(newController.isAuthenticated, isTrue);
      expect(newController.currentUser.value?.id, '42');
      expect(newController.currentUser.value?.name, 'Test Donor');
      expect(newController.currentUser.value?.token, 'jwt-access-token');

      // Test token refresh updates storage
      Get.find<ApiService>().onTokenRefreshed?.call(
        'new-access-token',
        'new-refresh-token',
      );
      final updatedStored = prefs.getString(AuthController.sessionKey);
      final updatedDecoded =
          jsonDecode(updatedStored!) as Map<String, dynamic>;
      expect(updatedDecoded['accessToken'], 'new-access-token');
      expect(updatedDecoded['refreshToken'], 'new-refresh-token');

      // Test clearing session
      newController.currentUser.value = null;
      expect(prefs.getString(AuthController.sessionKey), isNull);
    },
  );

  testWidgets(
    'logout shows prompt dialog and confirming clears session from shared_preferences',
    (tester) async {
      SharedPreferences.setMockInitialValues({
        AuthController.sessionKey:
            '{"id": 42, "name": "Donor", "phoneNumber": "09123", "roleId": 3, "accessToken": "token", "refreshToken": "refresh"}',
      });
      final prefs = await SharedPreferences.getInstance();
      Get.put<SharedPreferences>(prefs);
      final api = service(FakeAdapter((_) => ok(true)));
      Get.put<ApiService>(api);
      final repo = AuthRepository(AuthProvider());
      final controller = AuthController(repo);
      Get.put<AuthController>(controller);

      final appRouter = AppRouter(authController: controller);
      addTearDown(() {
        appRouter.dispose();
      });

      await tester.pumpWidget(
        GetMaterialApp.router(
          routeInformationProvider: appRouter.router.routeInformationProvider,
          routeInformationParser: appRouter.router.routeInformationParser,
          routerDelegate: appRouter.router.routerDelegate,
          backButtonDispatcher: appRouter.router.backButtonDispatcher,
        ),
      );
      await tester.pumpAndSettle();

      expect(controller.isAuthenticated, isTrue);
      expect(prefs.getString(AuthController.sessionKey), isNotNull);

      controller.logout();
      await tester.pumpAndSettle();

      expect(find.text('အကောင့်မှ ထွက်မည်'), findsOneWidget);
      expect(find.text('ထွက်မည်'), findsOneWidget);

      await tester.tap(find.text('ထွက်မည်'));
      await tester.pumpAndSettle();

      expect(controller.isAuthenticated, isFalse);
      expect(controller.currentUser.value, isNull);
      expect(prefs.getString(AuthController.sessionKey), isNull);
    },
  );

  testWidgets('LoadView renders ShimmerSkeletonList while loading', (tester) async {
    final completer = Completer<String>();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LoadView<String>(
            future: completer.future,
            retry: () {},
            builder: (data) => Text(data),
          ),
        ),
      ),
    );

    expect(find.byType(ShimmerSkeletonList), findsOneWidget);
    expect(find.byType(ShimmerSkeletonCard), findsWidgets);

    completer.complete('Loaded Content');
    await tester.pumpAndSettle();

    expect(find.byType(ShimmerSkeletonList), findsNothing);
    expect(find.text('Loaded Content'), findsOneWidget);
  });

  testWidgets('EmptyStateView renders icon, title, description, and optional action', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: EmptyStateView(
            icon: Icons.volunteer_activism_outlined,
            title: 'လှူဒါန်းမှု မှတ်တမ်း မရှိသေးပါ',
            description: 'ဆွမ်း သို့မဟုတ် ဝတ္ထုငွေ လှူဒါန်းမှုများကို ဤနေရာတွင် စာရင်းသွင်း ကြည့်ရှုနိုင်ပါသည်။',
            actionLabel: 'လှူဒါန်းရန်',
            onAction: () => tapped = true,
          ),
        ),
      ),
    );

    expect(find.text('လှူဒါန်းမှု မှတ်တမ်း မရှိသေးပါ'), findsOneWidget);
    expect(find.text('ဆွမ်း သို့မဟုတ် ဝတ္ထုငွေ လှူဒါန်းမှုများကို ဤနေရာတွင် စာရင်းသွင်း ကြည့်ရှုနိုင်ပါသည်။'), findsOneWidget);
    expect(find.text('လှူဒါန်းရန်'), findsOneWidget);

    await tester.tap(find.text('လှူဒါန်းရန်'));
    expect(tapped, isTrue);
  });
}
