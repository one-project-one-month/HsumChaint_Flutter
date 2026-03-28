import 'package:get/get.dart';
import 'package:hsum_chaint/presentation/screens/splash/splash_controller.dart';
import '../../data/providers/auth_provider.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/services/api_service.dart';
import '../../features/authentication/controllers/auth_controller.dart';
import '../theme/theme_controller.dart';

class InitialBindings extends Bindings {
  @override
  void dependencies() {
    // 1. Core Services (Kept alive during app lifecycle)
    Get.put(ApiService(), permanent: true);

    // 2. Data layer dependencies
    Get.lazyPut(AuthProvider.new, fenix: true);
    Get.lazyPut(() => AuthRepository(Get.find<AuthProvider>()), fenix: true);

    // 3. Core Controllers
    Get.put(ThemeController(), permanent: true);
    Get.put(AuthController(Get.find<AuthRepository>()), permanent: true);
    Get.put(SplashController(), permanent: true);
  }
}
