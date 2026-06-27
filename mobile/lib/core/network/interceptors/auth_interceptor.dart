import 'package:dio/dio.dart';

/// Attaches `Authorization: Bearer <token>` to every request, and invokes
/// [onUnauthorized] exactly once per 401 response so the caller (the auth
/// provider) can clear session state and redirect to login. Kept decoupled
/// from Riverpod so this file has zero state-management dependencies.
class AuthInterceptor extends Interceptor {
  AuthInterceptor({required this.tokenGetter, required this.onUnauthorized});

  final Future<String?> Function() tokenGetter;
  final void Function() onUnauthorized;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await tokenGetter();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      onUnauthorized();
    }
    handler.next(err);
  }
}
