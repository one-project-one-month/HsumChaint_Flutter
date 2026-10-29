import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import '../../features/authentication/controllers/auth_controller.dart';
import '../../features/authentication/screens/mobile_auth_screen.dart';
import '../../features/home/screens/home_screen.dart';
import 'app_routes.dart';
import 'router_refresh_notifier.dart';

class AppRouter {
  AppRouter({required AuthController authController})
    : _authController = authController,
      _refreshNotifier = RouterRefreshNotifier(authController.currentUser);
  final AuthController _authController;
  final RouterRefreshNotifier _refreshNotifier;
  late final GoRouter router = GoRouter(
    navigatorKey: Get.key,
    initialLocation: '/login',
    refreshListenable: _refreshNotifier,
    redirect: (context, state) {
      final signedIn = _authController.isAuthenticated;
      final auth = AppRoutes.isAuthLocation(state.matchedLocation);
      if (!signedIn && !auth) return '/login';
      if (signedIn && auth) return '/calendar';
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        name: AppRoutes.loginName,
        builder: (_, state) => const MobileAuthScreen(),
      ),
      GoRoute(
        path: '/user_signup',
        name: AppRoutes.userSignupName,
        builder: (_, state) => const MobileAuthScreen(register: true),
      ),
      GoRoute(
        path: '/monk_signup',
        name: AppRoutes.monkSignupName,
        builder: (_, state) =>
            const MobileAuthScreen(register: true, monk: true),
      ),
      GoRoute(
        path: '/',
        name: AppRoutes.homeName,
        redirect: (_, state) => '/calendar',
      ),
      for (final tab in [
        'calendar',
        'donations',
        'monasteries',
        'notifications',
        'profile',
      ])
        GoRoute(
          path: '/$tab',
          builder: (_, state) =>
              HomeScreen(key: const ValueKey('mobile-shell'), tab: tab),
        ),
    ],
  );
  void dispose() {
    _refreshNotifier.dispose();
    router.dispose();
  }
}
