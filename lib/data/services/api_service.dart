import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response, FormData, MultipartFile;
import '../../core/errors/exceptions.dart';

/// Low-level HTTP client.
///
/// Every public method THROWS a typed [AppException] on failure.
/// The repository layer is responsible for catching and converting to [Failure].
class ApiService extends GetxService {
  late Dio _dio;
  String? _authToken;

  // ── Replace with your real base URL ──────────────────────────────────────
  final String baseUrl = 'https://api.example.com/v1';

  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        responseType: ResponseType.json,
        headers: {'Accept': 'application/json'},
      ),
    );
    _setupInterceptors();
  }

  // ── Token management ─────────────────────────────────────────────────────
  void setAuthToken(String? token) => _authToken = token;
  void clearAuthToken() => _authToken = null;

  // ── Interceptors ─────────────────────────────────────────────────────────
  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (_authToken?.isNotEmpty == true) {
            options.headers['Authorization'] = 'Bearer $_authToken';
          }
          handler.next(options);
        },
        onResponse: (response, handler) => handler.next(response),
        onError: (DioException e, handler) => handler.next(e),
      ),
    );
  }

  // ── Error mapping ─────────────────────────────────────────────────────────
  /// Converts a [DioException] into the appropriate [AppException] subtype.
  /// Call this inside every try/catch in the REST methods below.
  AppException _mapError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const TimeoutException();

      case DioExceptionType.badResponse:
        final code = e.response?.statusCode;
        // Try to extract the server-side message from common JSON shapes
        final serverMsg = _extractMessage(e.response?.data);

        return switch (code) {
          400 => ValidationException(
              serverMsg ?? 'Invalid request. Please check your input.',
            ),
          401 => UnauthorizedException(
              serverMsg ?? 'Session expired. Please log in again.',
            ),
          403 => ForbiddenException(
              serverMsg ?? 'You do not have permission.',
            ),
          404 => NotFoundException(
              serverMsg ?? 'Resource not found.',
            ),
          422 => ValidationException(
              serverMsg ?? 'Validation failed. Please check your input.',
            ),
          500 || 502 || 503 => ServerException(
              serverMsg ?? 'Internal server error. Please try again later.',
              code,
            ),
          _ => ServerException(
              serverMsg ?? 'Unexpected error ($code).',
              code,
            ),
        };

      case DioExceptionType.connectionError:
      case DioExceptionType.unknown:
        // Check if the underlying cause is connectivity
        return const NetworkException();

      default:
        return ServerException(e.message ?? 'An unexpected error occurred.');
    }
  }

  /// Safely extracts a human-readable message from JSON response bodies.
  /// Supports: { "message": "..." }, { "error": "..." }, { "errors": [...] }
  String? _extractMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      if (data['message'] is String) return data['message'] as String;
      if (data['error'] is String) return data['error'] as String;
      if (data['errors'] is List) {
        final errors = data['errors'] as List;
        if (errors.isNotEmpty) return errors.first?.toString();
      }
    }
    return null;
  }

  // ── REST methods ──────────────────────────────────────────────────────────

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      return await _dio.get(path, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<Response> post(String path, {dynamic data}) async {
    try {
      return await _dio.post(path, data: data);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<Response> put(String path, {dynamic data}) async {
    try {
      return await _dio.put(path, data: data);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<Response> patch(String path, {dynamic data}) async {
    try {
      return await _dio.patch(path, data: data);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<Response> delete(String path, {dynamic data}) async {
    try {
      return await _dio.delete(path, data: data);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }
}
