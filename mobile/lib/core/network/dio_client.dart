import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../constants/api_endpoints.dart';
import 'api_result.dart';
import 'interceptors/auth_interceptor.dart';

class DioClient {
  DioClient({required Future<String?> Function() tokenGetter, required void Function() onUnauthorized}) {
    dio = Dio(
      BaseOptions(
        baseUrl: kApiBaseUrl,
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 30),
        headers: {'Accept': 'application/json'},
      ),
    );

    dio.interceptors.add(AuthInterceptor(tokenGetter: tokenGetter, onUnauthorized: onUnauthorized));

    if (kDebugMode) {
      dio.interceptors.add(LogInterceptor(requestBody: true, responseBody: true, error: true));
    }
  }

  late final Dio dio;
}

/// Maps any thrown exception from a Dio call into a UI-friendly [Failure].
/// Centralizing this means every repository gets consistent error messages
/// (Arabic, matching the backend's own error message style) for free.
Failure mapDioError(Object error) {
  if (error is DioException) {
    switch (error.type) {
      case DioExceptionType.connectionError:
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return Failure.network();
      default:
        final statusCode = error.response?.statusCode;
        if (statusCode == 401) return Failure.unauthorized();

        final data = error.response?.data;
        String message = 'حدث خطأ غير متوقع، يرجى المحاولة لاحقًا';
        if (data is Map && data['detail'] != null) {
          final detail = data['detail'];
          if (detail is String) {
            message = detail;
          } else if (detail is List && detail.isNotEmpty && detail.first['msg'] != null) {
            message = detail.first['msg'].toString();
          }
        }
        return Failure.server(message, statusCode);
    }
  }
  return Failure(message: error.toString());
}
