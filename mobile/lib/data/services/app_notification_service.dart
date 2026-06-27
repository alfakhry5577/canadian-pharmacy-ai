import 'package:dio/dio.dart';
import '../../core/constants/api_endpoints.dart';
import '../models/notification_model.dart';

class AppNotificationService {
  AppNotificationService(this._dio);
  final Dio _dio;

  Future<List<NotificationModel>> mine() async {
    final response = await _dio.get(ApiPaths.notificationsMine);
    return (response.data as List<dynamic>).map((e) => NotificationModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<int> unreadCount() async {
    final response = await _dio.get(ApiPaths.notificationsUnreadCount);
    return (response.data as Map<String, dynamic>)['count'] as int;
  }

  Future<NotificationModel> markRead(int id) async {
    final response = await _dio.patch(ApiPaths.notificationMarkRead(id));
    return NotificationModel.fromJson(response.data as Map<String, dynamic>);
  }

  /// NOTE: `/api/notifications/device-token` does not exist on the backend yet.
  /// This call is written defensively (catches the 404) so the rest of the app
  /// keeps working even before that endpoint is added — see mobile/README.md.
  Future<bool> registerDeviceToken(String fcmToken) async {
    try {
      await _dio.post(ApiPaths.registerDeviceToken, data: {'fcm_token': fcmToken, 'platform': 'android'});
      return true;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return false;
      rethrow;
    }
  }
}
