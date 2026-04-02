import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response;
import '../services/api_service.dart';

/// Thin network layer — calls [ApiService] and returns raw [Response].
///
/// **Dev mode:** Login uses a local fake until the real endpoint is ready.
/// Switch the comment blocks to enable the real API at any time.
class AuthProvider {
  final ApiService _apiService = Get.find<ApiService>();

  // ── Login ─────────────────────────────────────────────────────────────────
  Future<Response> login(String phone, String password) async {
    // ── Real API (uncomment when backend is ready) ──
    // return await _apiService.post(
    //   '/auth/login',
    //   data: {'phone': phone, 'password': password},
    // );

    // ── Fake / dev mode ──────────────────────────────────────────────────────
    return _fakeLogin(phone, password);
  }

  /// Simulates the server response so the full error-handling chain can be
  /// tested locally without a real backend.
  Future<Response> _fakeLogin(String phone, String password) async {
    const validPhone = '09123456789';
    const validPassword = 'password123';

    await Future.delayed(const Duration(seconds: 3)); // ✅ works now

    if (phone == validPhone && password == validPassword) {
      return Response(
        requestOptions: RequestOptions(path: '/auth/login'),
        statusCode: 200,
        data: {
          'token': 'fake-jwt-token-abc123',
          'user': {
            'id': 'usr_001',
            'name': 'San Lin',
            'phone': phone,
            'email': 'sanlin@example.com',
            'role': 'user',
          },
        },
      );
    }

    return Response(
      requestOptions: RequestOptions(path: '/auth/login'),
      statusCode: 401,
      data: {'message': 'Invalid phone number or password.'},
    );
  }

  // ── Signup (User) ─────────────────────────────────────────────────────────
  Future<Response> signupUser({
    required String phone,
    required String username,
    required String password,
    String? email,
    String? contactPhone,
  }) async {
    return await _apiService.post(
      '/auth/signup/user',
      data: {
        'phone': phone,
        'username': username,
        'password': password,
        if (email?.isNotEmpty ?? false) 'email': email,
        if (contactPhone?.isNotEmpty ?? false) 'contact_phone': contactPhone,
      },
    );
  }

  // ── Signup (Monk) ─────────────────────────────────────────────────────────
  Future<Response> signupMonk({
    required String phone,
    required String username,
    required String password,
    required String monasteryName,
    required String monasteryAddress,
    String? email,
  }) async {
    return await _apiService.post(
      '/auth/signup/monk',
      data: {
        'phone': phone,
        'username': username,
        'password': password,
        'monastery_name': monasteryName,
        'monastery_address': monasteryAddress,
        if (email?.isNotEmpty ?? false) 'email': email,
      },
    );
  }

  // ── Get Profile ───────────────────────────────────────────────────────────
  Future<Response> getProfile() async {
    return await _apiService.get('/auth/profile');
  }

  // ── Verify OTP ────────────────────────────────────────────────────────────
  Future<Response> verifyOtp({
    required String phone,
    required String otp,
  }) async {
    return await _apiService.post(
      '/auth/verify-otp',
      data: {'phone': phone, 'otp': otp},
    );
  }

  // ── Resend OTP ────────────────────────────────────────────────────────────
  Future<Response> resendOtp({required String phone}) async {
    return await _apiService.post('/auth/resend-otp', data: {'phone': phone});
  }
}
