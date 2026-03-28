import 'package:get/get.dart';
import 'package:hsum_chaint/core/navigation/app_routes.dart';
import 'package:hsum_chaint/features/authentication/controllers/auth_controller.dart';

class SplashController extends GetxController {
  final AuthController _authCtrl = Get.find<AuthController>();

  Future<String> getNextRoute() async {
    await Future.delayed(const Duration(seconds: 2));

    return _authCtrl.isAuthenticated
        ? AppRoutes.homePath
        : AppRoutes.welcomePath;
  }
}
