import 'package:dio/dio.dart';
import '../../core/constants/api_endpoints.dart';
import '../models/reminder_model.dart';

class CustomerService {
  CustomerService(this._dio);
  final Dio _dio;

  Future<List<ReminderModel>> listReminders() async {
    final response = await _dio.get(ApiPaths.customerReminders);
    return (response.data as List<dynamic>).map((e) => ReminderModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<ReminderModel> createReminder({required int medicationId, int frequencyDays = 30}) async {
    final response = await _dio.post(ApiPaths.customerReminders, data: {
      'medication_id': medicationId,
      'frequency_days': frequencyDays,
    });
    return ReminderModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> cancelReminder(int id) => _dio.delete(ApiPaths.customerReminderDelete(id));

  Future<LoyaltyAccountModel> loyalty() async {
    final response = await _dio.get(ApiPaths.customerLoyalty);
    return LoyaltyAccountModel.fromJson(response.data as Map<String, dynamic>);
  }
}
