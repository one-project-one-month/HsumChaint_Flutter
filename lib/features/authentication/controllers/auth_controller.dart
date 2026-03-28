import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/services/api_service.dart';
import '../../../presentation/helpers/dialog_helper.dart';

class AuthController extends GetxController {
  AuthController(this._authRepository);

  final AuthRepository _authRepository;
  final ApiService _apiService = Get.find<ApiService>();

  final RxBool isLoading = false.obs;
  final RxBool isOtpLoading = false.obs;
  final Rxn<UserModel> currentUser = Rxn<UserModel>();
  bool get isAuthenticated => currentUser.value != null;

  // Inputs
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();

  // final loginFormKey = GlobalKey<FormState>();
  // final signupFormKey = GlobalKey<FormState>();

  final isPasswordVisible = false.obs;

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  final contactPhoneController = TextEditingController();
  final usernameController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final monasteryNameController = TextEditingController();
  final monasteryAddressController = TextEditingController();

  final isConfirmPasswordVisible = false.obs;

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordVisible.value = !isConfirmPasswordVisible.value;
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    phoneController.dispose();
    usernameController.dispose();
    confirmPasswordController.dispose();
    monasteryNameController.dispose();
    monasteryAddressController.dispose();
    contactPhoneController.dispose();
    super.onClose();
  }

  void clearControllers() {
    emailController.clear();
    passwordController.clear();
    nameController.clear();
    phoneController.clear();
    usernameController.clear();
    confirmPasswordController.clear();
    monasteryNameController.clear();
    monasteryAddressController.clear();
    contactPhoneController.clear();
  }

  Future<void> login() async {
    if (Get.isSnackbarOpen) Get.back();
    final phone = phoneController.text.trim();
    final password = passwordController.text;

    if (phone.isEmpty || password.isEmpty) {
      DialogHelper.showErrorSnackbar(
        title: 'Missing fields',
        message: 'Phone number and password are required.',
      );
      return;
    }

    // Hide keyboard
    FocusManager.instance.primaryFocus?.unfocus();
    isLoading.value = true;

    final (failure, user) = await _authRepository.login(phone, password);

    isLoading.value = false;

    if (failure != null) {
      DialogHelper.showErrorSnackbar(
        title: 'Login Failed',
        message: failure.message,
      );
    } else if (user != null) {
      _apiService.setAuthToken(user.token);
      currentUser.value = user;
      DialogHelper.showSuccessSnackbar(
        title: 'Success',
        message: 'Welcome back, ${user.name}!',
      );
      clearControllers();
      // GoRouter redirects authenticated users away from auth routes.
    }
  }

  Future<bool> signupUser() async {
    // Hide keyboard
    FocusManager.instance.primaryFocus?.unfocus();
    isLoading.value = true;

    final phone = phoneController.text.trim();
    final username = usernameController.text.trim();
    final password = passwordController.text;
    final email = emailController.text.trim();
    final contactPhone = contactPhoneController.text.trim();

    final (failure, ok) = await _authRepository.signupUser(
      phone: phone,
      username: username,
      password: password,
      email: email.isEmpty ? null : email,
      contactPhone: contactPhone.isEmpty ? null : contactPhone,
    );

    isLoading.value = false;

    if (failure != null || !ok) {
      DialogHelper.showErrorSnackbar(
        title: 'Signup Failed',
        message: failure?.message ?? 'Unable to create your account.',
      );
      return false;
    }

    DialogHelper.showSuccessSnackbar(
      title: 'OTP Sent',
      message: 'We sent a verification code to $phone.',
    );
    return true;
  }

  Future<bool> signupMonk() async {
    // Hide keyboard
    FocusManager.instance.primaryFocus?.unfocus();
    isLoading.value = true;

    final phone = phoneController.text.trim();
    final username = usernameController.text.trim();
    final password = passwordController.text;
    final monasteryName = monasteryNameController.text.trim();
    final monasteryAddress = monasteryAddressController.text.trim();
    final email = emailController.text.trim();

    final (failure, ok) = await _authRepository.signupMonk(
      phone: phone,
      username: username,
      password: password,
      monasteryName: monasteryName,
      monasteryAddress: monasteryAddress,
      email: email.isEmpty ? null : email,
    );

    isLoading.value = false;

    if (failure != null || !ok) {
      DialogHelper.showErrorSnackbar(
        title: 'Signup Failed',
        message: failure?.message ?? 'Unable to create your account.',
      );
      return false;
    }

    DialogHelper.showSuccessSnackbar(
      title: 'OTP Sent',
      message: 'We sent a verification code to $phone.',
    );
    return true;
  }

  void logout() {
    DialogHelper.showPromptDialog(
      title: 'Logout',
      description: 'Are you sure you want to log out?',
      onConfirm: () {
        currentUser.value = null;
        clearControllers();
        DialogHelper.showSuccessSnackbar(
          title: 'Logged Out',
          message: 'You have been logged out successfully.',
        );
        // GoRouter redirects guests back to the login route.
      },
    );
  }

  Future<bool> verifyOtp({required String phone, required String otp}) async {
    if (otp.isEmpty || otp.length < 4) {
      DialogHelper.showErrorSnackbar(
        title: 'Invalid OTP',
        message: 'Please enter the verification code.',
      );
      return false;
    }

    isOtpLoading.value = true;
    final (failure, user) = await _authRepository.verifyOtp(
      phone: phone,
      otp: otp,
    );
    isOtpLoading.value = false;

    if (failure != null || user == null) {
      DialogHelper.showErrorSnackbar(
        title: 'Verification Failed',
        message: failure?.message ?? 'Please check the code and try again.',
      );
      return false;
    }

    currentUser.value = user;
    _apiService.setAuthToken(user.token);
    DialogHelper.showSuccessSnackbar(
      title: 'Verified',
      message: 'Your phone number has been verified.',
    );
    clearControllers();
    return true;
  }

  Future<void> resendOtp(String phone) async {
    final (failure, success) = await _authRepository.resendOtp(phone: phone);

    if (failure != null || !success) {
      DialogHelper.showErrorSnackbar(
        title: 'Resend Failed',
        message: failure?.message ?? 'Unable to resend OTP right now.',
      );
    } else {
      DialogHelper.showSuccessSnackbar(
        title: 'OTP Sent',
        message: 'A new verification code has been sent.',
      );
    }
  }
}
