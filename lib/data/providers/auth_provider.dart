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
}
