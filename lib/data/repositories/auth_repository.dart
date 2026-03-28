import '../models/user_model.dart';
import '../providers/auth_provider.dart';
import '../../core/errors/failures.dart';

class AuthRepository {
  final AuthProvider _provider;

  AuthRepository(this._provider);

  /// Standard pattern using Dart 3 Records: Future<(Failure?, Data?)>
  /// This eliminates the need for heavyweight Either packages like Dartz.
  Future<(Failure?, UserModel?)> login(String phone, String password) async {
    try {
      final response = await _provider.login(phone, password);

      if (response == null) {
        return (const NetworkFailure('Unable to reach server'), null);
      }

      if (response.statusCode == 200) {
        final user = UserModel.fromJson(response.data['user'] ?? {});
        user.token = response.data['token']?.toString();
        return (null, user);
      }

      return (
        ServerFailure(
          response.data?['message']?.toString() ??
              'Login failed. Invalid credentials.',
        ),
        null,
      );
    } catch (e) {
      if (e is TypeError) {
        return (
          const ValidationFailure('Data mapping error from server.'),
          null,
        );
      }
      return (ServerFailure(e.toString()), null);
    }
  }

  /// Signup method
  Future<(Failure?, bool)> signupUser({
    required String phone,
    required String username,
    required String password,
    String? email,
    String? contactPhone,
  }) async {
    try {
      final response = await _provider.signupUser(
        phone: phone,
        username: username,
        password: password,
        email: email,
        contactPhone: contactPhone,
      );

      if (response == null) {
        return (const NetworkFailure('Unable to reach server'), false);
      }

      if (response.statusCode == 201 || response.statusCode == 200) {
        return (null, true);
      }

      return (
        ServerFailure(
          response.data?['message']?.toString() ??
              'Signup failed. Please try again.',
        ),
        false,
      );
    } catch (e) {
      if (e is TypeError) {
        return (
          const ValidationFailure('Data mapping error from server.'),
          false,
        );
      }
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
      final response = await _provider.signupMonk(
        phone: phone,
        username: username,
        password: password,
        monasteryName: monasteryName,
        monasteryAddress: monasteryAddress,
        email: email,
      );

      if (response == null) {
        return (const NetworkFailure('Unable to reach server'), false);
      }

      if (response.statusCode == 201 || response.statusCode == 200) {
        return (null, true);
      }

      return (
        ServerFailure(
          response.data?['message']?.toString() ??
              'Signup failed. Please try again.',
        ),
        false,
      );
    } catch (e) {
      if (e is TypeError) {
        return (
          const ValidationFailure('Data mapping error from server.'),
          false,
        );
      }
      return (ServerFailure(e.toString()), false);
    }
  }

  /// Get Profile method
  Future<(Failure?, UserModel?)> getProfile() async {
    try {
      final response = await _provider.getProfile();

      if (response != null && response.statusCode == 200) {
        final user = UserModel.fromJson(response.data);
        return (null, user);
      } else {
        return (const ServerFailure('Failed to load profile details.'), null);
      }
    } catch (e) {
      return (ServerFailure(e.toString()), null);
    }
  }

  Future<(Failure?, UserModel?)> verifyOtp({
    required String phone,
    required String otp,
  }) async {
    try {
      final response = await _provider.verifyOtp(phone: phone, otp: otp);

      if (response == null) {
        return (const NetworkFailure('Unable to reach server'), null);
      }

      if (response.statusCode == 200) {
        final user = UserModel.fromJson(response.data['user'] ?? {});
        user.token = response.data['token']?.toString();
        return (null, user);
      }

      return (
        ServerFailure(
          response.data?['message']?.toString() ??
              'OTP verification failed. Please try again.',
        ),
        null,
      );
    } catch (e) {
      return (ServerFailure(e.toString()), null);
    }
  }

  Future<(Failure?, bool)> resendOtp({required String phone}) async {
    try {
      final response = await _provider.resendOtp(phone: phone);

      if (response == null) {
        return (const NetworkFailure('Unable to reach server'), false);
      }

      final success = response.statusCode == 200;
      return (
        success
            ? null
            : ServerFailure(
                response.data?['message']?.toString() ??
                    'Unable to resend OTP at the moment.',
              ),
        success,
      );
    } catch (e) {
      return (ServerFailure(e.toString()), false);
    }
  }
}
