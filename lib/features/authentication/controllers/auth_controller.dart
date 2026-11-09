import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/services/api_service.dart';
import '../../../presentation/helpers/dialog_helper.dart';

class AuthController extends GetxController {
  AuthController(
    this._authRepository, {
    FlutterSecureStorage? secureStorage,
    String? initialSession,
  }) : _secureStorage = secureStorage ??
           (Get.isRegistered<FlutterSecureStorage>()
               ? Get.find<FlutterSecureStorage>()
               : const FlutterSecureStorage()),
       _initialSession = initialSession ??
           (Get.isRegistered<String>(tag: 'initial_session')
               ? Get.find<String>(tag: 'initial_session')
               : null);

  static const String sessionKey = 'user_session';

  final AuthRepository _authRepository;
  final ApiService _apiService = Get.find<ApiService>();
  final FlutterSecureStorage _secureStorage;
  final String? _initialSession;

  SharedPreferences? get _prefs =>
      Get.isRegistered<SharedPreferences>() ? Get.find<SharedPreferences>() : null;

  final RxBool isLoading = false.obs;
  final RxBool isOtpLoading = false.obs;
  final Rxn<UserModel> currentUser = Rxn<UserModel>();
  bool get isAuthenticated => currentUser.value != null;

  @override
  void onInit() {
    super.onInit();

    // 1. Restore persistent session: if pre-read in main(), use immediately.
    // Otherwise read asynchronously from FlutterSecureStorage with SharedPreferences migration fallback.
    if (_initialSession != null) {
      _applySessionString(_initialSession);
    } else {
      _restoreSession();
    }

    // 2. Automatically synchronize secure storage whenever currentUser changes.
    ever(currentUser, (user) async {
      try {
        if (user != null) {
          await _secureStorage.write(
            key: sessionKey,
            value: jsonEncode(user.toJson()),
          );
        } else {
          await _secureStorage.delete(key: sessionKey);
        }
      } catch (_) {}
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
      _secureStorage.delete(key: sessionKey);
      _prefs?.remove(sessionKey);
      currentUser.value = null;
    };
  }

  bool _applySessionString(String raw) {
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final user = UserModel.fromJson(map);
      final userId = int.tryParse(user.id);
      if (user.token != null && user.refreshToken != null && userId != null) {
        _apiService.setSession(user.token!, user.refreshToken!, userId);
      }
      currentUser.value = user;
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> _restoreSession() async {
    try {
      final raw = await _secureStorage.read(key: sessionKey);
      if (raw != null) {
        if (!_applySessionString(raw)) {
          await _secureStorage.delete(key: sessionKey);
        }
        return;
      }
      // One-time fallback: read legacy unencrypted session from SharedPreferences, migrate, and clean up.
      final oldRaw = _prefs?.getString(sessionKey);
      if (oldRaw != null) {
        if (_applySessionString(oldRaw)) {
          await _secureStorage.write(key: sessionKey, value: oldRaw);
        }
        await _prefs?.remove(sessionKey);
      }
    } catch (_) {
      await _secureStorage.delete(key: sessionKey);
      await _prefs?.remove(sessionKey);
    }
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
    final identifier = emailController.text.trim().isNotEmpty
        ? emailController.text.trim()
        : phoneController.text.trim();
    final password = passwordController.text;

    if (identifier.isEmpty || password.isEmpty) {
      DialogHelper.showErrorSnackbar(
        title: 'Missing fields',
        message: 'Email and password are required.',
      );
      return;
    }

    // Hide keyboard
    FocusManager.instance.primaryFocus?.unfocus();
    isLoading.value = true;

    final (failure, user) = await _authRepository.login(identifier, password);

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

    final email = emailController.text.trim();
    final username = usernameController.text.trim();
    final password = passwordController.text;
    final phone = phoneController.text.trim();
    final contactPhone = contactPhoneController.text.trim();

    final (failure, ok) = await _authRepository.signupUser(
      phone: phone.isEmpty ? null : phone,
      username: username,
      password: password,
      email: email,
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
      message: 'အီးမေးလ်နှင့် စကားဝှက်ဖြင့် ဝင်ရောက်ပါ။',
    );
    return true;
  }

  Future<bool> signupMonk() async {
    // Hide keyboard
    FocusManager.instance.primaryFocus?.unfocus();
    isLoading.value = true;

    final email = emailController.text.trim();
    final username = usernameController.text.trim();
    final password = passwordController.text;
    final monasteryName = monasteryNameController.text.trim();
    final monasteryAddress = monasteryAddressController.text.trim();
    final phone = phoneController.text.trim();

    final (failure, ok) = await _authRepository.signupMonk(
      phone: phone.isEmpty ? null : phone,
      username: username,
      password: password,
      monasteryName: monasteryName,
      monasteryAddress: monasteryAddress,
      email: email,
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
      message: 'အီးမေးလ်နှင့် စကားဝှက်ဖြင့် ဝင်ရောက်ပါ။',
    );
    return true;
  }

  void logout() {
    DialogHelper.showPromptDialog(
      title: 'အကောင့်မှ ထွက်မည်',
      description: 'အကောင့်မှ ထွက်ရန် သေချာပါသလား။',
      confirmText: 'ထွက်မည်',
      cancelText: 'မထွက်ပါ',
      confirmTextColor: Colors.redAccent,
      onConfirm: () async {
        final refreshToken = currentUser.value?.refreshToken;
        final (failure, ok) =
            await _authRepository.logout(refreshToken: refreshToken);
        if (failure != null || !ok) {
          DialogHelper.showErrorSnackbar(
            title: 'ထွက်၍ မရပါ',
            message: failure?.message ??
                'အင်တာနက်လိုင်း ချိတ်ဆက်၍ မရပါ။ လိုင်းကောင်းမှ ပြန်လည်ကြိုးစားပါ။',
          );
          return;
        }

        await _secureStorage.delete(key: sessionKey);
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

  Future<bool> requestOtp({
    required String destination,
    String channel = 'EMAIL',
    required String purpose,
  }) async {
    isOtpLoading.value = true;
    final (failure, ok) = await _authRepository.requestOtp(
      destination: destination,
      channel: channel,
      purpose: purpose,
    );
    isOtpLoading.value = false;

    if (failure != null || !ok) {
      DialogHelper.showErrorSnackbar(
        title: 'ကုဒ် ပို့မရပါ',
        message: failure?.message ?? 'အတည်ပြုကုဒ် ပေးပို့၍ မရသေးပါ။',
      );
      return false;
    }

    DialogHelper.showSuccessSnackbar(
      title: 'ကုဒ် ပို့ပြီးပါပြီ',
      message: '$destination သို့ အတည်ပြုကုဒ် ပေးပို့ထားပြီး ဖြစ်ပါသည်။',
    );
    return true;
  }

  Future<bool> verifyOtp({
    required String destination,
    String channel = 'EMAIL',
    required String purpose,
    required String otp,
  }) async {
    if (otp.isEmpty || otp.length < 6) {
      DialogHelper.showErrorSnackbar(
        title: 'ကုဒ် မမှန်ကန်ပါ',
        message: 'ကျေးဇူးပြု၍ ဂဏန်း ၆ လုံးပါ အတည်ပြုကုဒ်ကို ရိုက်ထည့်ပါ။',
      );
      return false;
    }

    isOtpLoading.value = true;
    final (failure, ok) = await _authRepository.verifyOtp(
      destination: destination,
      channel: channel,
      purpose: purpose,
      otp: otp,
    );
    isOtpLoading.value = false;

    if (failure != null || !ok) {
      DialogHelper.showErrorSnackbar(
        title: 'အတည်ပြု မအောင်မြင်ပါ',
        message: failure?.message ?? 'အတည်ပြုကုဒ် မှန်ကန်မှု မရှိပါ။ ပြန်လည် စစ်ဆေးပေးပါ။',
      );
      return false;
    }

    DialogHelper.showSuccessSnackbar(
      title: 'အတည်ပြုပြီးပါပြီ',
      message: 'အီးမေးလ် အတည်ပြုခြင်း အောင်မြင်ပါသည်။',
    );
    return true;
  }

  Future<void> resendOtp({
    required String destination,
    String channel = 'EMAIL',
    required String purpose,
  }) async {
    final (failure, success) = await _authRepository.resendOtp(
      destination: destination,
      channel: channel,
      purpose: purpose,
    );

    if (failure != null || !success) {
      DialogHelper.showErrorSnackbar(
        title: 'ပြန်ပို့ မအောင်မြင်ပါ',
        message: failure?.message ?? 'လောလောဆယ် ကုဒ်ပြန်ပို့၍ မရသေးပါ။',
      );
    } else {
      DialogHelper.showSuccessSnackbar(
        title: 'ကုဒ် ပို့ပြီးပါပြီ',
        message: 'အတည်ပြုကုဒ် အသစ်တစ်စောင် ပေးပို့ထားပြီး ဖြစ်ပါသည်။',
      );
    }
  }

  Future<bool> forgotPassword(String email) async {
    final cleanEmail = email.trim().toLowerCase();
    if (cleanEmail.isEmpty || !cleanEmail.contains('@')) {
      DialogHelper.showErrorSnackbar(
        title: 'Invalid Email',
        message: 'Please enter a valid email address.',
      );
      return false;
    }

    isLoading.value = true;
    final (failure, ok) = await _authRepository.forgotPassword(cleanEmail);
    isLoading.value = false;

    if (failure != null || !ok) {
      DialogHelper.showErrorSnackbar(
        title: 'Request Failed',
        message: failure?.message ?? 'Unable to send password reset code.',
      );
      return false;
    }

    DialogHelper.showSuccessSnackbar(
      title: 'Code Sent',
      message: 'Password reset code has been sent to $cleanEmail.',
    );
    return true;
  }

  Future<bool> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    if (newPassword.length < 6) {
      DialogHelper.showErrorSnackbar(
        title: 'Invalid Password',
        message: 'Password must be at least 6 characters.',
      );
      return false;
    }

    isLoading.value = true;
    final (failure, ok) = await _authRepository.resetPassword(
      email: email.trim().toLowerCase(),
      otp: otp.trim(),
      newPassword: newPassword,
    );
    isLoading.value = false;

    if (failure != null || !ok) {
      DialogHelper.showErrorSnackbar(
        title: 'Reset Failed',
        message: failure?.message ?? 'Unable to reset password.',
      );
      return false;
    }

    DialogHelper.showSuccessSnackbar(
      title: 'Success',
      message: 'Password reset successful. Please log in.',
    );
    clearControllers();
    return true;
  }

  Future<bool> requestChangePasswordOtp() async {
    isOtpLoading.value = true;
    final (failure, ok) = await _authRepository.requestChangePasswordOtp();
    isOtpLoading.value = false;

    if (failure != null || !ok) {
      DialogHelper.showErrorSnackbar(
        title: 'Request Failed',
        message: failure?.message ?? 'Unable to send verification code.',
      );
      return false;
    }

    DialogHelper.showSuccessSnackbar(
      title: 'OTP Sent',
      message: 'Verification code has been sent to your email.',
    );
    return true;
  }

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
    required String otp,
  }) async {
    if (newPassword.length < 6) {
      DialogHelper.showErrorSnackbar(
        title: 'Invalid Password',
        message: 'New password must be at least 6 characters.',
      );
      return false;
    }

    isLoading.value = true;
    final (failure, ok) = await _authRepository.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
      otp: otp.trim(),
    );
    isLoading.value = false;

    if (failure != null || !ok) {
      DialogHelper.showErrorSnackbar(
        title: 'Change Password Failed',
        message: failure?.message ?? 'Unable to change password.',
      );
      return false;
    }

    DialogHelper.showSuccessSnackbar(
      title: 'Success',
      message: 'Password changed successfully. Please log in again.',
    );
    await _secureStorage.delete(key: sessionKey);
    await _prefs?.remove(sessionKey);
    _apiService.clearSession();
    currentUser.value = null;
    clearControllers();
    return true;
  }
}
