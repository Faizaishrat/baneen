import 'package:shared_preferences/shared_preferences.dart';

abstract class StorageService {
  Future<void> saveAccessToken(String token);
  Future<void> saveRefreshToken(String token);
  Future<String?> getAccessToken();
  Future<String?> getRefreshToken();
  Future<void> saveUserType(String userType);
  Future<String?> getUserType();
  Future<void> clearAll(); // optional - for logout
}

class SharedPrefsStorageService implements StorageService {
  static const _keyAccessToken   = 'access_token';
  static const _keyRefreshToken  = 'refresh_token';
  static const _keyUserType      = 'user_type';

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  @override
  Future<void> saveAccessToken(String token) async {
    await _prefs.setString(_keyAccessToken, token);
  }

  @override
  Future<void> saveRefreshToken(String token) async {
    await _prefs.setString(_keyRefreshToken, token);
  }

  @override
  Future<String?> getAccessToken() async {
    return _prefs.getString(_keyAccessToken);
  }

  @override
  Future<String?> getRefreshToken() async {
    return _prefs.getString(_keyRefreshToken);
  }

  @override
  Future<void> saveUserType(String userType) async {
    await _prefs.setString(_keyUserType, userType);
  }

  @override
  Future<String?> getUserType() async {
    return _prefs.getString(_keyUserType);
  }

  @override
  Future<void> clearAll() async {
    await _prefs.remove(_keyAccessToken);
    await _prefs.remove(_keyRefreshToken);
    await _prefs.remove(_keyUserType);
    // add more keys if you have them
  }
}

// Factory / singleton pattern (recommended)
Future<StorageService> getStorageService() async {
  final service = SharedPrefsStorageService();
  await service.init();
  return service;
}