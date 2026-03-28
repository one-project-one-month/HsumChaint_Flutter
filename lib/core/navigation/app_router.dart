import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hsum_chaint/features/authentication/controllers/auth_controller.dart';
import 'package:hsum_chaint/features/authentication/screens/chagepwd_screen.dart';
import 'package:hsum_chaint/features/authentication/screens/forgotpwd_screen.dart';
import 'package:hsum_chaint/features/authentication/screens/login_screen.dart';
import 'package:hsum_chaint/features/authentication/screens/monk_signup_screen.dart';
import 'package:hsum_chaint/features/authentication/screens/opt_screen.dart';
import 'package:hsum_chaint/features/authentication/screens/resetpwd_screen.dart';
import 'package:hsum_chaint/features/authentication/screens/user_signup_screen.dart';
import 'package:hsum_chaint/features/home/screens/home_screen.dart';
import 'package:hsum_chaint/presentation/screens/splash/splash_screen.dart';
import 'package:hsum_chaint/presentation/screens/welcome/welcome_screen.dart';
import 'app_routes.dart';
import 'router_refresh_notifier.dart';

class AppRouter {
  AppRouter({required AuthController authController})
    : _authController = authController,
      _refreshNotifier = RouterRefreshNotifier(authController.currentUser);

  final AuthController _authController;
  final RouterRefreshNotifier _refreshNotifier;

  late final GoRouter router = GoRouter(
    initialLocation: AppRoutes.splashPath,
    refreshListenable: _refreshNotifier,
    redirect: _redirect,
    routes: <RouteBase>[
      GoRoute(
        path: AppRoutes.splashPath,
        name: AppRoutes.splashName,
        builder: (context, state) => const SplashScreen(),
      ),

      GoRoute(
        path: AppRoutes.welcomePath,
        name: AppRoutes.welcomeName,
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.homePath,
        name: AppRoutes.homeName,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.loginPath,
        name: AppRoutes.loginName,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.monkSignupPath,
        name: AppRoutes.monkSignupName,
        builder: (context, state) => const MonkSignUpScreen(),
      ),
      GoRoute(
        path: AppRoutes.userSignupPath,
        name: AppRoutes.userSignupName,
        builder: (context, state) => const UserSignUpScreen(),
      ),
      GoRoute(
        path: '${AppRoutes.optPath}/:phone', // Path becomes /otp/:phone
        name: AppRoutes.optName,
        builder: (context, state) {
          // Extract the parameter from the state
          final phone = state.pathParameters['phone']!;
          return OtpVerificationScreen(phoneNumber: phone);
        },
      ),
      GoRoute(
        path: AppRoutes.forgotPasswordPath,
        name: AppRoutes.forgotPasswordName,
        builder: (context, state) => const ForgotPasswordPhoneScreen(),
      ),
      GoRoute(
        path: AppRoutes.changePasswordPath,
        name: AppRoutes.changePasswordName,
        builder: (context, state) => const ChangePasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.resetPasswordPath,
        name: AppRoutes.resetPasswordName,
        builder: (context, state) => const ForgotPasswordResetScreen(),
      ),
    ],
    errorBuilder: (context, state) => RouteErrorScreen(error: state.error),
  );

  String? _redirect(BuildContext context, GoRouterState state) {
    final bool isAuthenticated = _authController.isAuthenticated;
    final bool isAuthLocation = AppRoutes.isAuthLocation(state.matchedLocation);
    final bool isSplashLocation = state.matchedLocation == AppRoutes.splashPath;

    if (isSplashLocation) {
      return null;
    }

    if (!isAuthenticated && !isAuthLocation) {
      return AppRoutes.welcomePath;
    }

    if (isAuthenticated && isAuthLocation) {
      return AppRoutes.homePath;
    }

    return null;
  }

  void dispose() {
    _refreshNotifier.dispose();
    router.dispose();
  }
}

class RouteErrorScreen extends StatelessWidget {
  const RouteErrorScreen({super.key, this.error});

  final Exception? error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Route Error')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            error?.toString() ?? 'Unknown navigation error.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
