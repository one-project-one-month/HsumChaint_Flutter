import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart' hide Response;

class ApiFailure implements Exception {
  final String message;
  const ApiFailure(this.message);
  @override
  String toString() => message;
}

class ApiService extends GetxService {
  final Dio dio;
  String? _authToken, _refreshToken;
  int? _userId;
  int _sessionVersion = 0;
  Future<void>? _refreshing;
  VoidCallback? onSessionExpired;
  ApiService({Dio? client})
    : dio =
          client ??
          Dio(
            BaseOptions(
              baseUrl: const String.fromEnvironment(
                'API_BASE_URL',
                defaultValue: 'https://localhost:7067',
              ),
              connectTimeout: const Duration(seconds: 20),
              receiveTimeout: const Duration(seconds: 30),
            ),
          ) {
    if (!kIsWeb && dio.httpClientAdapter is IOHttpClientAdapter) {
      (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
        final client = HttpClient();
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) => true;
        return client;
      };
    }
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (_authToken != null) {
            options.headers['Authorization'] = 'Bearer $_authToken';
          }
          handler.next(options);
        },
      ),
    );
  }
  void setAuthToken(String? token) => _authToken = token;
  void setSession(String token, String refreshToken, int userId) {
    _sessionVersion++;
    _authToken = token;
    _refreshToken = refreshToken;
    _userId = userId;
  }

  void clearSession() {
    _sessionVersion++;
    _refreshing = null;
    _authToken = null;
    _refreshToken = null;
    _userId = null;
  }

  Future<void> _refresh() async {
    final version = _sessionVersion;
    final userId = _userId;
    try {
      final response = await dio.post(
        '/api/v1/auth/refresh-token',
        data: {'userId': _userId, 'refreshToken': _refreshToken},
      );
      final envelope = response.data as Map<String, dynamic>;
      if (envelope['isSuccess'] != true) {
        throw const ApiFailure('Session expired');
      }
      final data = envelope['data'] as Map<String, dynamic>;
      if (version != _sessionVersion) {
        throw const ApiFailure('Session changed.');
      }
      setSession(data['accessToken'], data['refreshToken'], userId!);
    } catch (_) {
      if (version == _sessionVersion) {
        clearSession();
        onSessionExpired?.call();
      }
      throw const ApiFailure('အကောင့် ပြန်ဝင်ပေးပါ။');
    }
  }

  Future<Response<dynamic>> request(
    String method,
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    bool retry = true,
  }) async {
    try {
      final response = await dio.request<dynamic>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: Options(method: method),
      );
      if (response.data is Map && response.data['isSuccess'] == false) {
        throw ApiFailure(
          response.data['message']?.toString() ?? 'လုပ်ဆောင်မှု မအောင်မြင်ပါ။',
        );
      }
      return response;
    } on DioException catch (error) {
      if (error.response?.statusCode == 401 &&
          retry &&
          _refreshToken != null &&
          !path.contains('/auth/')) {
        final pending = _refreshing ??= _refresh();
        try {
          await pending;
        } finally {
          if (identical(_refreshing, pending)) _refreshing = null;
        }
        return request(
          method,
          path,
          data: data,
          queryParameters: queryParameters,
          retry: false,
        );
      }
      if (error.response?.statusCode == 401 && !path.contains('/auth/')) {
        clearSession();
        onSessionExpired?.call();
      }
      final body = error.response?.data;
      throw ApiFailure(
        body is Map
            ? (body['message'] ?? body['title'] ?? 'Request failed').toString()
            : 'ဆာဗာနှင့် ချိတ်ဆက်မရပါ။ ပြန်ကြိုးစားပါ။',
      );
    }
  }

  Future<Response<dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) => request('GET', path, queryParameters: queryParameters);
  Future<Response<dynamic>> post(String path, {dynamic data}) =>
      request('POST', path, data: data);
  Future<Response<dynamic>> put(String path, {dynamic data}) =>
      request('PUT', path, data: data);
  Future<Response<dynamic>> delete(String path, {dynamic data}) =>
      request('DELETE', path, data: data);
}
