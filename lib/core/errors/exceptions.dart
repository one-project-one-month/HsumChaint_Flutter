class ServerException implements Exception {
  final String message;
  ServerException([this.message = 'A server error occurred.']);
}

class NetworkException implements Exception {
  final String message;
  NetworkException([this.message = 'No internet connection.']);
}

class CacheException implements Exception {
  final String message;
  CacheException([this.message = 'A cache error occurred.']);
}

class AuthException implements Exception {
  final String message;
  AuthException([this.message = 'Authentication failed.']);
}

class InvalidDataException implements Exception {
  final String message;
  InvalidDataException([this.message = 'Invalid data received.']);
}
