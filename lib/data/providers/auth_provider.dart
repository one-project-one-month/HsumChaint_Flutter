import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response;
import '../services/api_service.dart';

class AuthProvider {
  // Inject the ApiService global singleton
  final ApiService _apiService = Get.find<ApiService>();

  /// Login Provider Method
  Future<Response?> login(String phone, String password) async {
    return await _apiService.post(
      '/auth/login',
      data: {'phone': phone, 'password': password},
    );
  }

  /// Signup Provider Method
  Future<Response?> signupUser({
    required String phone,
    required String username,
    required String password,
    String? email,
    String? contactPhone,
  }) async {
    return await _apiService.post('/auth/signup/user', data: {
      'phone': phone,
      'username': username,
      'password': password,
      if (email?.isNotEmpty ?? false) 'email': email,
      if (contactPhone?.isNotEmpty ?? false) 'contact_phone': contactPhone,
    });
  }

  Future<Response?> signupMonk({
    required String phone,
    required String username,
    required String password,
    required String monasteryName,
    required String monasteryAddress,
    String? email,
  }) async {
    return await _apiService.post('/auth/signup/monk', data: {
      'phone': phone,
      'username': username,
      'password': password,
      'monastery_name': monasteryName,
      'monastery_address': monasteryAddress,
      if (email?.isNotEmpty ?? false) 'email': email,
    });
  }

  /// Get Profile Provider Method
  Future<Response?> getProfile() async {
    return await _apiService.get('/auth/profile');
  }

  Future<Response?> verifyOtp({
    required String phone,
    required String otp,
  }) async {
    return await _apiService.post('/auth/verify-otp', data: {
      'phone': phone,
      'otp': otp,
    });
  }

  Future<Response?> resendOtp({required String phone}) async {
    return await _apiService.post('/auth/resend-otp', data: {'phone': phone});
  }
}
