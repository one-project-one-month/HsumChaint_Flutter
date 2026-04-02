import '../models/user_model.dart';
import '../providers/auth_provider.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';

/// Maps [AppException] → [Failure] for every repository method.
Failure _toFailure(Object e) {
  if (e is UnauthorizedException) return UnauthorizedFailure(e.message);
  if (e is ForbiddenException) return ForbiddenFailure(e.message);
  if (e is NotFoundException) return NotFoundFailure(e.message);
  if (e is ValidationException) return ValidationFailure(e.message);
  if (e is NetworkException) return NetworkFailure(e.message);
  if (e is TimeoutException) return TimeoutFailure(e.message);
  if (e is InvalidDataException) return InvalidDataFailure(e.message);
  if (e is ServerException) return ServerFailure(e.message, e.statusCode);
  // Fallback for unexpected runtime errors
  return ServerFailure(e.toString());
}

class AuthRepository {
  final AuthProvider _provider;
  AuthRepository(this._provider);

  // ── Login ───────────────────────────────────────────────────────────────
  /// Returns `(null, UserModel)` on success or `(Failure, null)` on error.
  Future<(Failure?, UserModel?)> login(String phone, String password) async {
    try {
      final response = await _provider.login(phone, password);

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final user = UserModel.fromJson(data['user'] ?? data);
        user.token = data['token']?.toString();
        return (null, user);
      }

      // Non-200 but non-exception (should rarely happen given ApiService throws)
      final msg = (response.data as Map<String, dynamic>?)?['message']
              ?.toString() ??
          'Login failed. Please check your credentials.';
      return (ServerFailure(msg, response.statusCode), null);
    } catch (e) {
      return (_toFailure(e), null);
    }
  }

  // ── Signup (User) ────────────────────────────────────────────────────────
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

      if (response.statusCode == 200 || response.statusCode == 201) {
        return (null, true);
      }

      final msg = (response.data as Map<String, dynamic>?)?['message']
              ?.toString() ??
          'Signup failed. Please try again.';
      return (ServerFailure(msg, response.statusCode), false);
    } catch (e) {
      return (_toFailure(e), false);
    }
  }

  // ── Signup (Monk) ────────────────────────────────────────────────────────
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

      if (response.statusCode == 200 || response.statusCode == 201) {
        return (null, true);
      }

      final msg = (response.data as Map<String, dynamic>?)?['message']
              ?.toString() ??
          'Signup failed. Please try again.';
      return (ServerFailure(msg, response.statusCode), false);
    } catch (e) {
      return (_toFailure(e), false);
    }
  }

  // ── Get Profile ──────────────────────────────────────────────────────────
  Future<(Failure?, UserModel?)> getProfile() async {
    try {
      final response = await _provider.getProfile();

      if (response.statusCode == 200) {
        final user = UserModel.fromJson(
          response.data as Map<String, dynamic>,
        );
        return (null, user);
      }

      return (const ServerFailure('Failed to load profile.'), null);
    } catch (e) {
      return (_toFailure(e), null);
    }
  }

  // ── Verify OTP ───────────────────────────────────────────────────────────
  Future<(Failure?, UserModel?)> verifyOtp({
    required String phone,
    required String otp,
  }) async {
    try {
      final response = await _provider.verifyOtp(phone: phone, otp: otp);

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final user = UserModel.fromJson(data['user'] ?? data);
        user.token = data['token']?.toString();
        return (null, user);
      }

      final msg = (response.data as Map<String, dynamic>?)?['message']
              ?.toString() ??
          'OTP verification failed.';
      return (ServerFailure(msg, response.statusCode), null);
    } catch (e) {
      return (_toFailure(e), null);
    }
  }

  // ── Resend OTP ───────────────────────────────────────────────────────────
  Future<(Failure?, bool)> resendOtp({required String phone}) async {
    try {
      final response = await _provider.resendOtp(phone: phone);

      if (response.statusCode == 200) return (null, true);

      final msg = (response.data as Map<String, dynamic>?)?['message']
              ?.toString() ??
          'Unable to resend OTP at the moment.';
      return (ServerFailure(msg, response.statusCode), false);
    } catch (e) {
      return (_toFailure(e), false);
    }
  }
}
