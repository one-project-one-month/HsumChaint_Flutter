import 'package:get/get.dart';
import '../models/user_model.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../../core/errors/failures.dart';

class AuthRepository {
  final AuthProvider _provider;
  AuthRepository(this._provider);
  Future<(Failure?, UserModel?)> login(String phone, String password) async {
    final api = Get.find<ApiService>();
    try {
      final response = await _provider.login(phone, password);
      final session = Map<String, dynamic>.from(response.data['data']);
      if (session['roleId'] != 2 && session['roleId'] != 3) {
        return (
          const ValidationFailure(
            'ဤ app သည် အလှူရှင်နှင့် သံဃာတော်များအတွက်သာ ဖြစ်ပါသည်။',
          ),
          null,
        );
      }
      final id = (session['id'] ?? session['ID']) as int;
      api.setSession(session['accessToken'], session['refreshToken'], id);
      final profile = await _provider.getProfile(id);
      return (
        null,
        UserModel.fromJson({
          ...Map<String, dynamic>.from(profile.data['data']),
          ...session,
        }),
      );
    } catch (e) {
      api.clearSession();
      return (ServerFailure(e.toString()), null);
    }
  }

  Future<(Failure?, bool)> signupUser({
    required String phone,
    required String username,
    required String password,
    String? email,
    String? contactPhone,
  }) async {
    try {
      await _provider.signupUser(
        phone: phone,
        username: username,
        password: password,
        email: email,
        contactPhone: contactPhone,
      );
      return (null, true);
    } catch (e) {
      return (ServerFailure(e.toString()), false);
    }
  }

  Future<(Failure?, bool)> signupMonk({
    required String phone,
    required String username,
    required String password,
    required String monasteryName,
    required String monasteryAddress,
    String? email,
  }) async {
    try {
      await _provider.signupMonk(
        phone: phone,
        username: username,
        password: password,
        monasteryName: monasteryName,
        monasteryAddress: monasteryAddress,
        email: email,
      );
      return (null, true);
    } catch (e) {
      return (ServerFailure(e.toString()), false);
    }
  }

  // Legacy screens are no longer routed: the backend has no OTP endpoints.
  Future<(Failure?, UserModel?)> verifyOtp({
    required String phone,
    required String otp,
  }) async =>
      (const ValidationFailure('OTP is not supported by the backend.'), null);
  Future<(Failure?, bool)> resendOtp({required String phone}) async =>
      (const ValidationFailure('OTP is not supported by the backend.'), false);
}
