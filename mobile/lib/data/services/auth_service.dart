import 'package:dio/dio.dart';
import '../../core/constants/api_endpoints.dart';
import '../models/user_model.dart';

class AuthService {
  AuthService(this._dio);
  final Dio _dio;

  Future<Map<String, dynamic>> register({
    required String fullName,
    required String email,
    String? phone,
    required String password,
    String role = 'customer',
  }) async {
    final response = await _dio.post(ApiPaths.register, data: {
      'full_name': fullName,
      'email': email,
      if (phone != null && phone.isNotEmpty) 'phone': phone,
      'password': password,
      'role': role,
    });
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> login({required String email, required String password}) async {
    final response = await _dio.post(ApiPaths.login, data: {'email': email, 'password': password});
    return response.data as Map<String, dynamic>;
  }

  Future<UserModel> me() async {
    final response = await _dio.get(ApiPaths.me);
    return UserModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<UserModel> addAllergy(String substanceName) async {
    final response = await _dio.post(ApiPaths.addAllergy, data: {'substance_name': substanceName});
    return UserModel.fromJson(response.data as Map<String, dynamic>);
  }
}
