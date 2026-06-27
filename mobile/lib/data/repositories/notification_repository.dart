import '../../core/network/api_result.dart';
import '../../core/network/dio_client.dart';
import '../models/notification_model.dart';
import '../services/app_notification_service.dart';

class NotificationRepository {
  NotificationRepository(this._service);
  final AppNotificationService _service;

  Future<ApiResult<List<NotificationModel>>> mine() async {
    try {
      return Success(await _service.mine());
    } catch (e) {
      return Error(mapDioError(e));
    }
  }

  Future<ApiResult<int>> unreadCount() async {
    try {
      return Success(await _service.unreadCount());
    } catch (e) {
      return Error(mapDioError(e));
    }
  }

  Future<ApiResult<NotificationModel>> markRead(int id) async {
    try {
      return Success(await _service.markRead(id));
    } catch (e) {
      return Error(mapDioError(e));
    }
  }

  Future<void> registerDeviceToken(String fcmToken) async {
    try {
      await _service.registerDeviceToken(fcmToken);
    } catch (_) {
      // Best-effort only — push registration failure must never block app usage.
    }
  }
}
