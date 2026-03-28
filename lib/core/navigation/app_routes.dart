abstract final class AppRoutes {
  static const String splashName = 'splash';
  static const String welcomeName = 'welcome';
  static const String homeName = 'home';
  static const String loginName = 'login';
  static const String monkSignupName = 'monk_signup';
  static const String userSignupName = 'user_signup';
  static const String optName = 'otp';
  static const String forgotPasswordName = 'forgot_password';
  static const String changePasswordName = 'change_password';
  static const String resetPasswordName = 'reset_password';

  static const String splashPath = '/splash';
  static const String welcomePath = '/welcome';
  static const String homePath = '/';
  static const String loginPath = '/login';
  static const String monkSignupPath = '/monk_signup';
  static const String userSignupPath = '/user_signup';
  static const String optPath = '/otp';
  static const String forgotPasswordPath = '/forgot_password';
  static const String changePasswordPath = '/change_password';
  static const String resetPasswordPath = '/reset_password';

  static const Set<String> _authLocations = <String>{
    loginPath,
    monkSignupPath,
    userSignupPath,
    optPath,
    forgotPasswordPath,
    changePasswordPath,
    resetPasswordPath,
  };

  static bool isAuthLocation(String location) {
    return _authLocations.contains(location) ||
        location.startsWith('$optPath/');
  }
}
