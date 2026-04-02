import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hsum_chaint/presentation/helpers/appui_helper.dart';
import '../../../data/models/ui_message.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/services/api_service.dart';
import '../../../data/services/session_manager.dart';

class AuthController extends GetxController {
  AuthController(this._authRepository);

  final AuthRepository _authRepository;
  final ApiService _apiService = Get.find<ApiService>();
  final SessionManager _session = Get.find<SessionManager>();

  // ── UI message (screens listen with ever()) ──────────────────────────────
  final Rxn<UiMessage> _uiMessage = Rxn<UiMessage>();
  UiMessage? get uiMessage => _uiMessage.value;
  Rxn<UiMessage> get uiMessageRx => _uiMessage;

  void showError({required String title, required String message}) {
    _uiMessage.value = UiMessage(
      type: UiMessageType.error,
      title: title,
      message: message,
    );
  }

  void showSuccess({required String title, required String message}) {
    _uiMessage.value = UiMessage(
      type: UiMessageType.success,
      title: title,
      message: message,
    );
  }

  void clearUiMessage() => _uiMessage.value = null;

  // ── State ────────────────────────────────────────────────────────────────
  final isLoading = false.obs;
  final isOtpLoading = false.obs;
  final isLoginSuccessful = false.obs; // screens react to navigation

  final Rxn<UserModel> currentUser = Rxn<UserModel>();
  bool get isAuthenticated => currentUser.value != null;

  // ── Form controllers ─────────────────────────────────────────────────────
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final contactPhoneController = TextEditingController();
  final usernameController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final monasteryNameController = TextEditingController();
  final monasteryAddressController = TextEditingController();

  final isPasswordVisible = false.obs;
  final isConfirmPasswordVisible = false.obs;

  void togglePasswordVisibility() =>
      isPasswordVisible.value = !isPasswordVisible.value;
  void toggleConfirmPasswordVisibility() =>
      isConfirmPasswordVisible.value = !isConfirmPasswordVisible.value;

  // ── Lifecycle ────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    _restoreSession(); // 🔑 auto-login from persisted session
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    phoneController.dispose();
    contactPhoneController.dispose();
    usernameController.dispose();
    confirmPasswordController.dispose();
    monasteryNameController.dispose();
    monasteryAddressController.dispose();
    super.onClose();
  }

  void clearControllers() {
    emailController.clear();
    passwordController.clear();
    nameController.clear();
    phoneController.clear();
    contactPhoneController.clear();
    usernameController.clear();
    confirmPasswordController.clear();
    monasteryNameController.clear();
    monasteryAddressController.clear();
  }

  // ── Session restore ──────────────────────────────────────────────────────

  /// Called on [onInit]. If a valid session exists the user is silently
  /// logged back in without hitting the network.
  void _restoreSession() {
    if (!_session.hasSession) return;

    final user = _session.savedUser;
    final token = _session.token;

    if (user == null || token == null) return;

    currentUser.value = user;
    _apiService.setAuthToken(token);
    isLoginSuccessful.value = true; // router redirect to home
  }

  // ── Login ────────────────────────────────────────────────────────────────

  Future<void> login() async {
    final phone = phoneController.text.trim();
    final password = passwordController.text.trim();

    if (phone.isEmpty || password.isEmpty) {
      showError(
        title: 'Missing fields',
        message: 'Phone number and password are required.',
      );
      return;
    }
    if (password.length < 6) {
      showError(
        title: 'Invalid password',
        message: 'Password must be at least 6 characters.',
      );
      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();
    isLoading.value = true;
    AppUiHelper.showLoading();

    final (failure, user) = await _authRepository.login(phone, password);
    isLoading.value = false;
    AppUiHelper.hideLoading();
    if (failure != null) {
      showError(title: 'Login Failed', message: failure.message);
      return;
    }

    if (user != null) {
      final token = user.token ?? '';
      // if (token.isNotEmpty) _apiService.setAuthToken(token);

      // ✅ Persist session
      //  await _session.saveSession(user: user, token: token);

      currentUser.value = user;
      isLoginSuccessful.value = true;
      clearControllers();
      showSuccess(title: 'Welcome back', message: 'Logged in as ${user.name}.');
    }
  }

  // ── Signup (User) ────────────────────────────────────────────────────────

  Future<bool> signupUser() async {
    FocusManager.instance.primaryFocus?.unfocus();
    isLoading.value = true;
    AppUiHelper.showLoading();

    final (failure, ok) = await _authRepository.signupUser(
      phone: phoneController.text.trim(),
      username: usernameController.text.trim(),
      password: passwordController.text,
      email: emailController.text.trim().isEmpty
          ? null
          : emailController.text.trim(),
      contactPhone: contactPhoneController.text.trim().isEmpty
          ? null
          : contactPhoneController.text.trim(),
    );

    isLoading.value = false;
    AppUiHelper.hideLoading();
    if (failure != null || !ok) {
      showError(
        title: 'Signup Failed',
        message: failure?.message ?? 'Unable to create your account.',
      );
      return false;
    }

    showSuccess(
      title: 'OTP Sent',
      message: 'We sent a verification code to ${phoneController.text.trim()}.',
    );
    return true;
  }

  // ── Signup (Monk) ────────────────────────────────────────────────────────

  Future<bool> signupMonk() async {
    FocusManager.instance.primaryFocus?.unfocus();
    isLoading.value = true;

    final (failure, ok) = await _authRepository.signupMonk(
      phone: phoneController.text.trim(),
      username: usernameController.text.trim(),
      password: passwordController.text,
      monasteryName: monasteryNameController.text.trim(),
      monasteryAddress: monasteryAddressController.text.trim(),
      email: emailController.text.trim().isEmpty
          ? null
          : emailController.text.trim(),
    );

    isLoading.value = false;

    if (failure != null || !ok) {
      showError(
        title: 'Signup Failed',
        message: failure?.message ?? 'Unable to create your account.',
      );
      return false;
    }

    showSuccess(
      title: 'OTP Sent',
      message: 'We sent a verification code to ${phoneController.text.trim()}.',
    );
    return true;
  }

  // ── Logout ────────────────────────────────────────────────────────────────

  Future<void> logout() async {
    // ✅ Clear persisted session
    await _session.clearSession();
    _apiService.clearAuthToken();

    currentUser.value = null;
    isLoginSuccessful.value = false;
    clearControllers();
    showSuccess(
      title: 'Logged Out',
      message: 'You have been logged out successfully.',
    );
  }

  // ── OTP Verify ───────────────────────────────────────────────────────────

  Future<bool> verifyOtp({required String phone, required String otp}) async {
    if (otp.isEmpty || otp.length < 4) {
      showError(
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
      showError(
        title: 'Verification Failed',
        message: failure?.message ?? 'Please check the code and try again.',
      );
      return false;
    }

    final token = user.token ?? '';
    if (token.isNotEmpty) _apiService.setAuthToken(token);

    // ✅ Persist session after OTP verification (first-time registration)
    await _session.saveSession(user: user, token: token);

    currentUser.value = user;
    isLoginSuccessful.value = true;
    clearControllers();
    showSuccess(
      title: 'Verified',
      message: 'Your phone number has been verified.',
    );
    return true;
  }

  // ── Resend OTP ────────────────────────────────────────────────────────────

  Future<void> resendOtp(String phone) async {
    final (failure, success) = await _authRepository.resendOtp(phone: phone);

    if (failure != null || !success) {
      showError(
        title: 'Resend Failed',
        message: failure?.message ?? 'Unable to resend OTP right now.',
      );
    } else {
      showSuccess(
        title: 'OTP Sent',
        message: 'A new verification code has been sent.',
      );
    }
  }
}
