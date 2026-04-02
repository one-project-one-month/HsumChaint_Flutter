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
  static const String settingsName = 'settings';
  static const String editProfileName = 'edit_profile';
  static const String profileName = 'profile';
  static const String navigationName = 'navigation';

  //Home
  static const String createSpaceName = 'create_space';
  static const String editSpaceName = 'edit_space';
  static const String notificationName = 'notification';
  static const String spaceScreenName = 'space';
  static const String spaceInfoScreenName = 'space_info';

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
  static const String settingsPath = '/settings';
  static const String editProfilePath = '/edit_profile';
  static const String profilePath = '/profile';
  static const String navigationPath = '/navigation';

  //Home
  static const String createSpacePath = '/create_space';
  static const String editSpacePath = '/edit_space';
  static const String notificationPath = '/notification';
  static const String spaceScreenPath = '/space';
  static const String spaceInfoScreenPath = '/space_info';

  static const Set<String> _authLocations = <String>{
    loginPath,
    monkSignupPath,
    userSignupPath,
    optPath,
    forgotPasswordPath,
    resetPasswordPath,
  };

  static bool isAuthLocation(String location) {
    return _authLocations.contains(location) ||
        location.startsWith('$optPath/');
  }
}
