import 'package:get/get.dart';
import '../models/user_model.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../../core/errors/failures.dart';

class AuthRepository {
  final AuthProvider _provider;
  AuthRepository(this._provider);

  String _errorMessage(Object error) {
    if (error is ApiFailure) return error.message;
    return error.toString();
  }

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
      return (ServerFailure(_errorMessage(e)), null);
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
      return (ServerFailure(_errorMessage(e)), false);
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
      return (ServerFailure(_errorMessage(e)), false);
    }
  }

  Future<(Failure?, bool)> requestOtp({
    required String destination,
    String channel = 'EMAIL',
    required String purpose,
  }) async {
    try {
      await _provider.requestOtp(
        destination: destination,
        channel: channel,
        purpose: purpose,
      );
      return (null, true);
    } catch (e) {
      return (ServerFailure(_errorMessage(e)), false);
    }
  }

  Future<(Failure?, bool)> verifyOtp({
    required String destination,
    String channel = 'EMAIL',
    required String purpose,
    required String otp,
  }) async {
    try {
      await _provider.verifyOtp(
        destination: destination,
        channel: channel,
        purpose: purpose,
        code: otp,
      );
      return (null, true);
    } catch (e) {
      return (ServerFailure(_errorMessage(e)), false);
    }
  }

  Future<(Failure?, bool)> resendOtp({
    required String destination,
    String channel = 'EMAIL',
    required String purpose,
  }) => requestOtp(destination: destination, channel: channel, purpose: purpose);

  Future<(Failure?, bool)> forgotPassword(String email) async {
    try {
      await _provider.forgotPassword(email);
      return (null, true);
    } catch (e) {
      return (ServerFailure(_errorMessage(e)), false);
    }
  }

  Future<(Failure?, bool)> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    try {
      await _provider.resetPassword(
        email: email,
        otp: otp,
        newPassword: newPassword,
      );
      return (null, true);
    } catch (e) {
      return (ServerFailure(_errorMessage(e)), false);
    }
  }

  Future<(Failure?, bool)> requestChangePasswordOtp() async {
    try {
      await _provider.requestChangePasswordOtp();
      return (null, true);
    } catch (e) {
      return (ServerFailure(_errorMessage(e)), false);
    }
  }

  Future<(Failure?, bool)> changePassword({
    required String currentPassword,
    required String newPassword,
    required String otp,
  }) async {
    try {
      await _provider.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
        otp: otp,
      );
      return (null, true);
    } catch (e) {
      return (ServerFailure(_errorMessage(e)), false);
    }
  }
}
