import 'package:dio/dio.dart';
import '../../core/constants/api_endpoints.dart';
import '../models/medication_model.dart';

class MedicationService {
  MedicationService(this._dio);
  final Dio _dio;

  Future<List<MedicationSearchResultModel>> search(String query) async {
    final response = await _dio.get(ApiPaths.medicationSearch, queryParameters: {'q': query});
    return (response.data as List<dynamic>)
        .map((e) => MedicationSearchResultModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<MedicationModel> getById(int id) async {
    final response = await _dio.get(ApiPaths.medicationDetail(id));
    return MedicationModel.fromJson(response.data as Map<String, dynamic>);
  }
}
