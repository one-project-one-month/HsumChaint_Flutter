import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response, FormData, MultipartFile;
import '../../presentation/helpers/dialog_helper.dart';

class ApiService extends GetxService {
  late Dio _dio;
  String? _authToken;

  // Replace with your actual API base URL
  final String baseUrl = 'https://api.example.com/v1';

  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        responseType: ResponseType.json,
      ),
    );

    _setupInterceptors();
  }

  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (_authToken != null && _authToken!.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $_authToken';
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          // Handle global success scenarios or logging here
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          _handleGlobalError(e);
          return handler.next(e);
        },
      ),
    );
  }

  /// Global Error Handler mapping HTTP codes to App Exceptions and Dialogs
  void _handleGlobalError(DioException error) {
    String message = 'An unexpected error occurred';

    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      message =
          'Connection timed out. Please check your internet and try again.';
      DialogHelper.showErrorSnackbar(title: 'Timeout', message: message);
    } else if (error.type == DioExceptionType.badResponse) {
      final statusCode = error.response?.statusCode;
      final responseData = error.response?.data;

      if (statusCode == 401) {
        message = 'Unauthorized access. Please login again.';
        DialogHelper.showErrorSnackbar(
          title: 'Session Expired',
          message: message,
        );
        // Optional: Get.offAllNamed('/login'); // Force logout and redirect
      } else if (statusCode == 403) {
        message =
            'Forbidden. You do not have permission to access this resource.';
        DialogHelper.showErrorSnackbar(
          title: 'Access Denied',
          message: message,
        );
      } else if (statusCode == 404) {
        message = 'Resource not found.';
        DialogHelper.showErrorSnackbar(title: 'Not Found', message: message);
      } else if (statusCode == 500) {
        message = 'Internal server error. Please try again later.';
        DialogHelper.showErrorSnackbar(title: 'Server Error', message: message);
      } else {
        // Fallback to server provided error message if available
        message = responseData?['message'] ?? 'Unexpected Error ($statusCode)';
        DialogHelper.showErrorSnackbar(
          title: 'Error $statusCode',
          message: message,
        );
      }
    } else if (error.type == DioExceptionType.unknown) {
      message = 'No internet connection or server unreachable.';
      DialogHelper.showErrorSnackbar(title: 'Network Error', message: message);
    }
  }

  /// REST Methods wrapped with error catching
  void setAuthToken(String? token) {
    _authToken = token;
  }

  Future<Response?> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParameters);
      return response;
    } catch (e) {
      // Error is caught and displayed by interceptor
      return null;
    }
  }

  Future<Response?> post(String path, {dynamic data}) async {
    try {
      final response = await _dio.post(path, data: data);
      return response;
    } catch (e) {
      return null;
    }
  }

  Future<Response?> put(String path, {dynamic data}) async {
    try {
      final response = await _dio.put(path, data: data);
      return response;
    } catch (e) {
      return null;
    }
  }

  Future<Response?> delete(String path, {dynamic data}) async {
    try {
      final response = await _dio.delete(path, data: data);
      return response;
    } catch (e) {
      return null;
    }
  }
}
