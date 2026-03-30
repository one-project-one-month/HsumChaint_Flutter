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
import 'package:hsum_chaint/features/home/screens/notification_screen.dart';
import 'package:hsum_chaint/features/home/screens/space/create_space.dart';
import 'package:hsum_chaint/features/home/screens/space/edit_space.dart';
import 'package:hsum_chaint/features/home/screens/space/space_info_screen.dart';
import 'package:hsum_chaint/features/home/screens/space/space_screen.dart';
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
    ///TODO: Set initialLocation to splash after implementing splash screen
    // initialLocation: AppRoutes.splashPath,
    initialLocation: AppRoutes.spaceInfoScreenPath,
    refreshListenable: _refreshNotifier,
    // redirect: _redirect,
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

      //Home
      GoRoute(
        path: AppRoutes.createSpacePath,
        name: AppRoutes.createSpaceName,
        builder: (context, state) => const CreateSpaceScreen(),
      ),
      GoRoute(
        path: AppRoutes.editSpacePath,
        name: AppRoutes.editSpaceName,
        builder: (context, state) => const EditSpaceInfoScreen(),
      ),
      GoRoute(
        path: AppRoutes.notificationPath,
        name: AppRoutes.notificationName,
        builder: (context, state) => const NotificationScreen(),
      ),
      GoRoute(
        path: AppRoutes.spaceScreenPath,
        name: AppRoutes.spaceScreenName,
        builder: (context, state) => const SpaceScreen(),
      ),
      GoRoute(
        path: AppRoutes.spaceInfoScreenPath,
        name: AppRoutes.spaceInfoScreenName,
        builder: (context, state) => const SpaceInfoScreen(),
      ),
    ],
    errorBuilder: (context, state) => RouteErrorScreen(error: state.error),
  );

  ///TODO: Implement route guards and redirection logic based on authentication state
  // String? _redirect(BuildContext context, GoRouterState state) {
  //   final bool isAuthenticated = _authController.isAuthenticated;
  //   final bool isAuthLocation = AppRoutes.isAuthLocation(state.matchedLocation);
  //   final bool isSplashLocation = state.matchedLocation == AppRoutes.splashPath;

  //   if (isSplashLocation) {
  //     return null;
  //   }

  //   if (!isAuthenticated && !isAuthLocation) {
  //     return AppRoutes.welcomePath;
  //   }

  //   if (isAuthenticated && isAuthLocation) {
  //     return AppRoutes.homePath;
  //   }

  //   return null;
  // }

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
