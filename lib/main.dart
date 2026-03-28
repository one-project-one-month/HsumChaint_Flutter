import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hsum_chaint/features/authentication/controllers/auth_controller.dart';
import 'core/bindings/initial_bindings.dart';
import 'core/navigation/app_router.dart';
import 'core/theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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

    return GetMaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Hsum Chaint',
      theme: AppTheme.lightTheme,
      //   darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routeInformationProvider: router.routeInformationProvider,
      routeInformationParser: router.routeInformationParser,
      routerDelegate: router.routerDelegate,
      backButtonDispatcher: router.backButtonDispatcher,
    );
  }
}
