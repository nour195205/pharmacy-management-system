import 'dart:io';
import 'package:dio/dio.dart';
import 'package:desktop/core/errors/failures.dart';
import 'package:desktop/core/utils/constants.dart';
import 'package:desktop/services/database_service.dart';

class ApiService {
  final Dio _dio;

  String get baseUrl => _dio.options.baseUrl;
  set baseUrl(String url) {
    _dio.options.baseUrl = url;
  }

  Future<void> loadCustomBaseUrl(DatabaseService dbService) async {
    final customUrl = await dbService.getSetting('api_base_url');
    if (customUrl != null && customUrl.isNotEmpty) {
      _dio.options.baseUrl = customUrl;
    }
  }

  ApiService(this._dio) {
    _dio.options = BaseOptions(
      baseUrl: AppConstants.baseApiUrl,
      connectTimeout: const Duration(milliseconds: AppConstants.apiConnectTimeoutMs),
      receiveTimeout: const Duration(milliseconds: AppConstants.apiReceiveTimeoutMs),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    // Logging & Auth Interceptors can be added here
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Prepare for JWT/Sanctum tokens later
        // final token = await _getToken();
        // if (token != null) {
        //   options.headers['Authorization'] = 'Bearer $token';
        // }
        return handler.next(options);
      },
      onError: (DioException e, handler) {
        return handler.next(e);
      },
    ));
  }

  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.get(path, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<Response> post(String path, {dynamic data}) async {
    try {
      return await _dio.post(path, data: data);
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<Response> put(String path, {dynamic data}) async {
    try {
      return await _dio.put(path, data: data);
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<Response> delete(String path) async {
    try {
      return await _dio.delete(path);
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Exception _handleDioException(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.error is SocketException) {
      return ServerException('مشكلة في الاتصال بالخادم، يرجى التحقق من الشبكة');
    }

    if (e.response != null) {
      final statusCode = e.response?.statusCode;
      final message = e.response?.data?['message'] ?? 'حدث خطأ غير متوقع في الخادم';
      
      if (statusCode == 422) {
        // Validation Errors from Laravel
        final errors = e.response?.data?['errors'] as Map<String, dynamic>?;
        if (errors != null) {
          final buffer = StringBuffer();
          for (var fieldErrors in errors.values) {
            if (fieldErrors is List) {
              for (var err in fieldErrors) {
                buffer.writeln(err);
              }
            }
          }
          return ServerException(buffer.toString().trim());
        }
      }
      return ServerException(message);
    }

    return ServerException('خطأ في الاتصال بالخادم: ${e.message}');
  }
}
