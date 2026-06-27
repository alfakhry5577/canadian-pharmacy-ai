import '../../core/network/api_result.dart';
import '../../core/network/dio_client.dart';
import '../models/alert_model.dart';
import '../services/alert_service.dart';

class AlertRepository {
  AlertRepository(this._service);
  final AlertService _service;

  Future<ApiResult<List<AlertModel>>> list({bool resolved = false}) async {
    try {
      return Success(await _service.list(resolved: resolved));
    } catch (e) {
      return Error(mapDioError(e));
    }
  }

  Future<ApiResult<List<AlertModel>>> scan() async {
    try {
      return Success(await _service.scan());
    } catch (e) {
      return Error(mapDioError(e));
    }
  }

  Future<ApiResult<AlertModel>> resolve(int id) async {
    try {
      return Success(await _service.resolve(id));
    } catch (e) {
      return Error(mapDioError(e));
    }
  }
}
