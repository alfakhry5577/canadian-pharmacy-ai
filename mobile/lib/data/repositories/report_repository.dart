import '../../core/network/api_result.dart';
import '../../core/network/dio_client.dart';
import '../models/report_model.dart';
import '../services/report_service.dart';

class ReportRepository {
  ReportRepository(this._service);
  final ReportService _service;

  Future<ApiResult<SalesSummaryModel>> salesSummary({int days = 30}) async {
    try {
      return Success(await _service.salesSummary(days: days));
    } catch (e) {
      return Error(mapDioError(e));
    }
  }
}
