import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/services/api_service.dart';
import '../../../presentation/helpers/dialog_helper.dart';

class AuthController extends GetxController {
  AuthController(this._authRepository);

  static const String sessionKey = 'user_session';

  final AuthRepository _authRepository;
  final ApiService _apiService = Get.find<ApiService>();

  SharedPreferences? get _prefs =>
      Get.isRegistered<SharedPreferences>() ? Get.find<SharedPreferences>() : null;

  final RxBool isLoading = false.obs;
  final RxBool isOtpLoading = false.obs;
  final Rxn<UserModel> currentUser = Rxn<UserModel>();
  bool get isAuthenticated => currentUser.value != null;

  @override
  void onInit() {
    super.onInit();

    // 1. Restore persistent session if present.
    final raw = _prefs?.getString(sessionKey);
    if (raw != null) {
      try {
        final map = jsonDecode(raw) as Map<String, dynamic>;
        final user = UserModel.fromJson(map);
        final userId = int.tryParse(user.id);
        if (user.token != null && user.refreshToken != null && userId != null) {
          _apiService.setSession(user.token!, user.refreshToken!, userId);
        }
        currentUser.value = user;
      } catch (_) {
        _prefs?.remove(sessionKey);
      }
    }

    // 2. Automatically synchronize local storage whenever currentUser changes.
    ever(currentUser, (user) {
      if (user != null) {
        _prefs?.setString(sessionKey, jsonEncode(user.toJson()));
      } else {
        _prefs?.remove(sessionKey);
      }
    });

    // 3. Keep storage synchronized when tokens are refreshed.
    _apiService.onTokenRefreshed = (newAccess, newRefresh) {
      final current = currentUser.value;
      if (current != null) {
        currentUser.value = UserModel.fromJson({
          ...current.toJson(),
          'accessToken': newAccess,
          'refreshToken': newRefresh,
        });
      }
    };

    // 4. Handle expired session.
    _apiService.onSessionExpired = () {
      _prefs?.remove(sessionKey);
      currentUser.value = null;
    };
  }

  // Inputs
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();

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
      title: 'အကောင့်ဖွင့်ပြီးပါပြီ',
      message: 'ဖုန်းနံပါတ်နှင့် စကားဝှက်ဖြင့် ဝင်ရောက်ပါ။',
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
      title: 'အကောင့်ဖွင့်ပြီးပါပြီ',
      message: 'ဖုန်းနံပါတ်နှင့် စကားဝှက်ဖြင့် ဝင်ရောက်ပါ။',
    );
    return true;
  }

  void logout() {
    DialogHelper.showPromptDialog(
      title: 'အကောင့်မှ ထွက်မည်',
      description: 'အကောင့်မှ ထွက်ရန် သေချာပါသလား။',
      confirmText: 'ထွက်မည်',
      cancelText: 'မထွက်ပါ',
      onConfirm: () async {
        await _prefs?.remove(sessionKey);
        _apiService.clearSession();
        currentUser.value = null;
        clearControllers();
        DialogHelper.showSuccessSnackbar(
          title: 'ထွက်ပြီးပါပြီ',
          message: 'အကောင့်မှ အောင်မြင်စွာ ထွက်ပြီးပါပြီ။',
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
