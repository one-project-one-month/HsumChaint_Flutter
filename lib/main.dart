import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hsum_chaint/features/authentication/controllers/auth_controller.dart';
import 'package:hsum_chaint/presentation/helpers/appui_helper.dart';
import 'core/bindings/initial_bindings.dart';
import 'core/navigation/app_router.dart';
import 'core/theme/app_theme.dart';

import 'package:hsum_chaint/data/services/session_manager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Get.putAsync(() => SessionManager().init(), permanent: true);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final AppRouter _appRouter;

  @override
  void initState() {
    super.initState();

    if (!Get.isRegistered<AuthController>()) {
      InitialBindings().dependencies();
    }

    _appRouter = AppRouter(authController: Get.find<AuthController>());
  }

  @override
  void dispose() {
    _appRouter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final router = _appRouter.router;

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Hsum Chaint',
      theme: AppTheme.lightTheme,
      //   darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routeInformationProvider: router.routeInformationProvider,
      routeInformationParser: router.routeInformationParser,
      routerDelegate: router.routerDelegate,
      backButtonDispatcher: router.backButtonDispatcher,
      scaffoldMessengerKey: AppUiHelper.messengerKey,
    );
  }
}
