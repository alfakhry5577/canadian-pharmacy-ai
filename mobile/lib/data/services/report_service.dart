import 'package:dio/dio.dart';
import '../../core/constants/api_endpoints.dart';
import '../models/report_model.dart';

class ReportService {
  ReportService(this._dio);
  final Dio _dio;

  Future<SalesSummaryModel> salesSummary({int days = 30}) async {
    final response = await _dio.get(ApiPaths.salesSummary, queryParameters: {'days': days});
    return SalesSummaryModel.fromJson(response.data as Map<String, dynamic>);
  }
}
