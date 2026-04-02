/// Base class for all app-level exceptions thrown from the data layer.
/// Carries the raw [message] from the server (or a default) and the HTTP
/// [statusCode] so the repository can map them precisely to [Failure] types.
abstract class AppException implements Exception {
  final String message;
  final int? statusCode;
  const AppException(this.message, {this.statusCode});

  @override
  String toString() => 'AppException($statusCode): $message';
}

/// 4xx / 5xx HTTP responses with a known status code.
class ServerException extends AppException {
  const ServerException([
    super.message = 'A server error occurred.',
    int? statusCode,
  ]) : super(statusCode: statusCode);
}

/// 401 – token missing or expired.
class UnauthorizedException extends AppException {
  const UnauthorizedException([
    super.message = 'Session expired. Please log in again.',
  ]) : super(statusCode: 401);
}

/// 403 – authenticated but not allowed.
class ForbiddenException extends AppException {
  const ForbiddenException([
    super.message = 'You do not have permission to do this.',
  ]) : super(statusCode: 403);
}

/// 404 – endpoint or resource not found.
class NotFoundException extends AppException {
  const NotFoundException([
    super.message = 'The requested resource was not found.',
  ]) : super(statusCode: 404);
}

/// 422 / 400 – server-side validation rejected the payload.
class ValidationException extends AppException {
  const ValidationException([
    super.message = 'Please check your input and try again.',
  ]) : super(statusCode: 422);
}

/// No internet or socket-level failures.
class NetworkException extends AppException {
  const NetworkException([
    super.message = 'No internet connection. Please try again.',
  ]) : super(statusCode: null);
}

/// Connect / receive timeout.
class TimeoutException extends AppException {
  const TimeoutException([
    super.message = 'Request timed out. Please try again.',
  ]) : super(statusCode: null);
}

/// Unexpected response shape – can't parse the data.
class InvalidDataException extends AppException {
  const InvalidDataException([
    super.message = 'Unexpected data received from server.',
  ]) : super(statusCode: null);
}

/// Local cache / storage failures.
class CacheException extends AppException {
  const CacheException([
    super.message = 'A local storage error occurred.',
  ]) : super(statusCode: null);
}
