import '../../core/network/api_result.dart';
import '../../core/network/dio_client.dart';
import '../models/reminder_model.dart';
import '../services/customer_service.dart';

class CustomerRepository {
  CustomerRepository(this._service);
  final CustomerService _service;

  Future<ApiResult<List<ReminderModel>>> listReminders() async {
    try {
      return Success(await _service.listReminders());
    } catch (e) {
      return Error(mapDioError(e));
    }
  }

  Future<ApiResult<ReminderModel>> createReminder({required int medicationId, int frequencyDays = 30}) async {
    try {
      return Success(await _service.createReminder(medicationId: medicationId, frequencyDays: frequencyDays));
    } catch (e) {
      return Error(mapDioError(e));
    }
  }

  Future<ApiResult<void>> cancelReminder(int id) async {
    try {
      await _service.cancelReminder(id);
      return const Success(null);
    } catch (e) {
      return Error(mapDioError(e));
    }
  }

  Future<ApiResult<LoyaltyAccountModel>> loyalty() async {
    try {
      return Success(await _service.loyalty());
    } catch (e) {
      return Error(mapDioError(e));
    }
  }
}
