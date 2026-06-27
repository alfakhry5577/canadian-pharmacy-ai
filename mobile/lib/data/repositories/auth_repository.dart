import '../../core/network/api_result.dart';
import '../../core/network/dio_client.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthRepository {
  AuthRepository(this._service);
  final AuthService _service;

  Future<ApiResult<({String token, UserModel user})>> register({
    required String fullName,
    required String email,
    String? phone,
    required String password,
    String role = 'customer',
  }) async {
    try {
      final json = await _service.register(fullName: fullName, email: email, phone: phone, password: password, role: role);
      return Success((token: json['access_token'] as String, user: UserModel.fromJson(json['user'] as Map<String, dynamic>)));
    } catch (e) {
      return Error(mapDioError(e));
    }
  }

  Future<ApiResult<({String token, UserModel user})>> login({required String email, required String password}) async {
    try {
      final json = await _service.login(email: email, password: password);
      return Success((token: json['access_token'] as String, user: UserModel.fromJson(json['user'] as Map<String, dynamic>)));
    } catch (e) {
      return Error(mapDioError(e));
    }
  }

  Future<ApiResult<UserModel>> me() async {
    try {
      return Success(await _service.me());
    } catch (e) {
      return Error(mapDioError(e));
    }
  }

  Future<ApiResult<UserModel>> addAllergy(String substanceName) async {
    try {
      return Success(await _service.addAllergy(substanceName));
    } catch (e) {
      return Error(mapDioError(e));
    }
  }
}
