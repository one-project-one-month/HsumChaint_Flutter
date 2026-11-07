import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response;
import '../services/api_service.dart';

class AuthProvider {
  final ApiService _api = Get.find<ApiService>();

  Future<Response<dynamic>> login(String phone, String password) => _api.post(
    '/api/v1/auth/login',
    data: {'phoneNumber': phone, 'password': password},
  );

  Future<Response<dynamic>> signupUser({
    required String phone,
    required String username,
    required String password,
    String? email,
    String? contactPhone,
  }) => _api.post(
    '/api/v1/auth/register',
    data: {
      'phoneNumber': phone,
      'name': username,
      'password': password,
      'roleId': 3,
      'email': email,
      'contactPhoneNumber': contactPhone,
    },
  );

  Future<Response<dynamic>> signupMonk({
    required String phone,
    required String username,
    required String password,
    required String monasteryName,
    required String monasteryAddress,
    String? email,
  }) => _api.post(
    '/api/v1/auth/register',
    data: {
      'phoneNumber': phone,
      'name': username,
      'password': password,
      'roleId': 2,
      'monasteryName': monasteryName,
      'monasteryAddress': monasteryAddress,
      'email': email,
    },
  );

  Future<Response<dynamic>> getProfile(int id) => _api.get('/api/user/$id');

  Future<Response<dynamic>> requestOtp({
    required String destination,
    String channel = 'EMAIL',
    required String purpose,
  }) => _api.post(
    '/api/v1/auth/otp/request',
    data: {
      'destination': destination,
      'channel': channel,
      'purpose': purpose,
    },
  );

  Future<Response<dynamic>> verifyOtp({
    required String destination,
    String channel = 'EMAIL',
    required String purpose,
    required String code,
  }) => _api.post(
    '/api/v1/auth/otp/verify',
    data: {
      'destination': destination,
      'channel': channel,
      'purpose': purpose,
      'code': code,
    },
  );

  Future<Response<dynamic>> forgotPassword(String email) => _api.post(
    '/api/v1/auth/forgot-password',
    data: {
      'destination': email,
      'channel': 'EMAIL',
      'purpose': 'RESET_PASSWORD',
    },
  );

  Future<Response<dynamic>> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) => _api.post(
    '/api/v1/auth/reset-password',
    data: {
      'email': email,
      'otp': otp,
      'newPassword': newPassword,
    },
  );

  Future<Response<dynamic>> requestChangePasswordOtp() =>
      _api.post('/api/v1/auth/change-password/request-otp');

  Future<Response<dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
    required String otp,
  }) => _api.post(
    '/api/v1/auth/change-password',
    data: {
      'currentPassword': currentPassword,
      'newPassword': newPassword,
      'otp': otp,
    },
  );
}
