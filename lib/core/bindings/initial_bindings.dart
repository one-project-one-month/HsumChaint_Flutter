import 'package:get/get.dart';
import 'package:hsum_chaint/data/controllers.dart/image_controller.dart';
import 'package:hsum_chaint/features/navigation/navigation_controller.dart';
import 'package:hsum_chaint/features/settings/controllers/settings_controller.dart';

import 'package:hsum_chaint/presentation/screens/splash/splash_controller.dart';
import '../../data/providers/auth_provider.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/services/api_service.dart';
import '../../features/authentication/controllers/auth_controller.dart';
import '../theme/theme_controller.dart';

class InitialBindings extends Bindings {
  @override
  void dependencies() {
    // 1. Core Services — must be registered BEFORE any controller that uses them
    Get.put(ApiService(), permanent: true);

    // 2. Data layer
    Get.lazyPut(AuthProvider.new, fenix: true);
    Get.lazyPut(() => AuthRepository(Get.find<AuthProvider>()), fenix: true);
    Get.lazyPut(() => ImagePickerController(), fenix: true);

    // 3. App Controllers
    Get.put(ThemeController(), permanent: true);
    Get.put(AuthController(Get.find<AuthRepository>()), permanent: true);
    Get.put(SplashController(), permanent: true);
    Get.put(NavigationController(), permanent: true);
    Get.put(SettingsController(), permanent: true);
  }
}
