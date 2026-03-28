abstract class Failure {
  final String message;
  const Failure(this.message);
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Server error occurred.']);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection.']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Cache error occurred.']);
}

class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Authentication failed.']);
}

class ValidationFailure extends Failure {
  const ValidationFailure([super.message = 'Validation error.']);
}
