import 'package:dio/dio.dart';
import '../../core/constants/api_endpoints.dart';
import '../models/prescription_model.dart';

class PrescriptionService {
  PrescriptionService(this._dio);
  final Dio _dio;

  Future<PrescriptionAnalysisResultModel> upload(String filePath) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath, filename: filePath.split('/').last),
    });
    final response = await _dio.post(ApiPaths.prescriptionUpload, data: formData);
    return PrescriptionAnalysisResultModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<List<PrescriptionModel>> mine() async {
    final response = await _dio.get(ApiPaths.prescriptionsMine);
    return (response.data as List<dynamic>).map((e) => PrescriptionModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<PrescriptionModel>> queue() async {
    final response = await _dio.get(ApiPaths.prescriptionsQueue);
    return (response.data as List<dynamic>).map((e) => PrescriptionModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<PrescriptionModel> getById(int id) async {
    final response = await _dio.get(ApiPaths.prescriptionDetail(id));
    return PrescriptionModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<PrescriptionModel> updateItem(int itemId, Map<String, dynamic> payload) async {
    final response = await _dio.patch(ApiPaths.prescriptionItemUpdate(itemId), data: payload);
    return PrescriptionModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<PrescriptionModel> review(int id, {required String status, String? notes}) async {
    final response = await _dio.patch(ApiPaths.prescriptionReview(id), data: {
      'status': status,
      if (notes != null && notes.isNotEmpty) 'pharmacist_notes': notes,
    });
    return PrescriptionModel.fromJson(response.data as Map<String, dynamic>);
  }
}
