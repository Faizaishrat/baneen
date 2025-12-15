import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/constants/app_constants.dart';

class StorageService {
  final SharedPreferences _prefs;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  StorageService._(this._prefs);

  static Future<StorageService> getInstance() async {
    final prefs = await SharedPreferences.getInstance();
    return StorageService._(prefs);
  }

  // Token Management (Secure Storage)
  Future<void> saveToken(String token) async {
    await _secureStorage.write(key: AppConstants.storageToken, value: token);
  }

  Future<String?> getToken() async {
    return await _secureStorage.read(key: AppConstants.storageToken);
  }

  Future<void> saveRefreshToken(String token) async {
    await _secureStorage.write(
      key: AppConstants.storageRefreshToken,
      value: token,
    );
  }

  Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: AppConstants.storageRefreshToken);
  }

  Future<void> clearTokens() async {
    await _secureStorage.delete(key: AppConstants.storageToken);
    await _secureStorage.delete(key: AppConstants.storageRefreshToken);
  }

  // User Data
  Future<void> saveUserType(String userType) async {
    await _prefs.setString(AppConstants.storageUserType, userType);
  }

  String? getUserType() {
    return _prefs.getString(AppConstants.storageUserType);
  }

  Future<void> saveOnboardingComplete(bool complete) async {
    await _prefs.setBool(AppConstants.storageOnboardingComplete, complete);
  }

  bool isOnboardingComplete() {
    return _prefs.getBool(AppConstants.storageOnboardingComplete) ?? false;
  }

  // Language
  Future<void> saveLanguage(String language) async {
    await _prefs.setString(AppConstants.storageLanguage, language);
  }

  String? getLanguage() {
    return _prefs.getString(AppConstants.storageLanguage);
  }

  // Theme
  Future<void> saveTheme(String theme) async {
    await _prefs.setString(AppConstants.storageTheme, theme);
  }

  String? getTheme() {
    return _prefs.getString(AppConstants.storageTheme);
  }

  // Favorite Contact
  Future<void> saveFavoriteContactName(String name) async {
    await _prefs.setString(AppConstants.storageFavoriteContactName, name);
  }

  String? getFavoriteContactName() {
    return _prefs.getString(AppConstants.storageFavoriteContactName);
  }

  // Clear all data
  Future<void> clearAll() async {
    await _prefs.clear();
    await _secureStorage.deleteAll();
  }
}

// Singleton instance
StorageService? _storageServiceInstance;

Future<StorageService> getStorageService() async {
  _storageServiceInstance ??= await StorageService.getInstance();
  return _storageServiceInstance!;
}

