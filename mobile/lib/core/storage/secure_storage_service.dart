import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/api_endpoints.dart';

class SecureStorageService {
  SecureStorageService(this._storage);

  final FlutterSecureStorage _storage;

  static const _options = AndroidOptions(encryptedSharedPreferences: true);

  Future<void> saveToken(String token) =>
      _storage.write(key: StorageKeys.accessToken, value: token, aOptions: _options);

  Future<String?> readToken() => _storage.read(key: StorageKeys.accessToken, aOptions: _options);

  Future<void> deleteToken() => _storage.delete(key: StorageKeys.accessToken, aOptions: _options);

  Future<void> clearAll() => _storage.deleteAll(aOptions: _options);
}
