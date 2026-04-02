import 'package:get/get.dart';
import 'package:hsum_chaint/data/controllers.dart/image_controller.dart';
import 'package:hsum_chaint/features/authentication/controllers/auth_controller.dart';

class SettingsController extends GetxController {
  final _authCtrl = Get.find<AuthController>();
  final _imageCtrl = Get.find<ImagePickerController>();

  ImagePickerController get imageCtrl => _imageCtrl;

  void logout() {
    _authCtrl.logout();
  }
}
