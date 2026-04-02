/// Base failure type returned from the repository layer.
/// Screens / controller react to these via [AuthResult].
abstract class Failure {
  final String message;
  const Failure(this.message);
}

/// Generic server error (5xx, unexpected status codes).
class ServerFailure extends Failure {
  final int? statusCode;
  const ServerFailure([
    super.message = 'Server error occurred.',
    this.statusCode,
  ]);
}

/// 401 – session expired.
class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure([
    super.message = 'Session expired. Please log in again.',
  ]);
}

/// 403 – permission denied.
class ForbiddenFailure extends Failure {
  const ForbiddenFailure([
    super.message = 'You do not have permission to do this.',
  ]);
}

/// 404 – resource not found.
class NotFoundFailure extends Failure {
  const NotFoundFailure([
    super.message = 'The requested resource was not found.',
  ]);
}

/// 400 / 422 – server validation rejected the payload.
class ValidationFailure extends Failure {
  const ValidationFailure([
    super.message = 'Please check your input and try again.',
  ]);
}

/// No internet / socket closed.
class NetworkFailure extends Failure {
  const NetworkFailure([
    super.message = 'No internet connection. Please try again.',
  ]);
}

/// Connect / receive timeout.
class TimeoutFailure extends Failure {
  const TimeoutFailure([
    super.message = 'Request timed out. Please try again.',
  ]);
}

/// Can't parse the server's response.
class InvalidDataFailure extends Failure {
  const InvalidDataFailure([
    super.message = 'Unexpected data received from server.',
  ]);
}

/// Local storage / cache error.
class CacheFailure extends Failure {
  const CacheFailure([super.message = 'A local storage error occurred.']);
}
