import 'package:dio/dio.dart';
import '../../core/constants/api_endpoints.dart';
import '../models/alert_model.dart';

class AlertService {
  AlertService(this._dio);
  final Dio _dio;

  Future<List<AlertModel>> list({bool resolved = false}) async {
    final response = await _dio.get(ApiPaths.alerts, queryParameters: {'resolved': resolved});
    return (response.data as List<dynamic>).map((e) => AlertModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<AlertModel>> scan() async {
    final response = await _dio.post(ApiPaths.alertsScan);
    return (response.data as List<dynamic>).map((e) => AlertModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<AlertModel> resolve(int id) async {
    final response = await _dio.patch(ApiPaths.alertResolve(id));
    return AlertModel.fromJson(response.data as Map<String, dynamic>);
  }
}
