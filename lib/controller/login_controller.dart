import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/api_constants.dart';
import '../core/constants/app_constants.dart';
import '../services/cookie_manager.dart';
import 'storage_services.dart';

class LoginProvider with ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  Map<String, dynamic>? _userData;
  String? _accessToken;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<String, dynamic>? get userData => _userData;
  String? get accessToken => _accessToken;

  Future<bool> login({
    required String identifier,
    required String password,
    required bool isPhoneLogin,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.login}');

      final body = isPhoneLogin
          ? {
        "phone": identifier.trim(),
        "password": password,
      }
          : {
        "email": identifier.trim(),
        "password": password,
      };

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {

        print("StatusCode ${response.statusCode}");
        // API returns { success, message, data: { user, profile, accessToken, refreshToken } }
        final data = responseData['data'] as Map<String, dynamic>? ?? responseData;
        _accessToken = data['accessToken'] ?? data['token'] ?? data['access_token'] ??
            responseData['accessToken'] ?? responseData['token'] ?? responseData['access_token'];
        _userData = data['user'] ?? responseData['user'] ?? data ?? responseData;

        SimpleDriverCookieManager.saveCookie(response);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(AppConstants.prefIsLoggedIn, true);
        final storage = await getStorageService();

        if (_accessToken != null && _accessToken!.isNotEmpty) {
          await prefs.setString(AppConstants.storageToken, _accessToken!);
          await prefs.setString('access_token', _accessToken!);
          await storage.saveAccessToken(_accessToken!);

          final refreshToken = data['refreshToken'] ?? data['refresh_token'] ??
              responseData['refreshToken'] ?? responseData['refresh_token'];
          if (refreshToken != null && refreshToken.toString().isNotEmpty) {
            await prefs.setString('refresh_token', refreshToken.toString());
            await storage.saveRefreshToken(refreshToken.toString());
          }

          SimpleDriverCookieManager.saveCookieFromTokens(_accessToken, refreshToken?.toString());
        }

        // Save role so splash/login can navigate to DriverDashboardScreen or PassengerHomeScreen
        final role = _userData?['role']?.toString().toLowerCase();
        if (role != null && role.isNotEmpty) {
          await storage.saveUserType(role);
        }

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        // Handle error messages from backend
        String msg = responseData['message'] ?? 'Login failed';

        if (msg.toLowerCase().contains('invalid') ||
            msg.toLowerCase().contains('incorrect') ||
            msg.toLowerCase().contains('wrong')) {
          _errorMessage = 'Invalid email/phone or password';
        } else {
          _errorMessage = msg;
        }

        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Something went wrong. Please try again.';
      if (e.toString().contains('SocketException') ||
          e.toString().contains('Failed host')) {
        _errorMessage = 'No internet connection';
      }
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Hits logout API then clears saved token and in-memory state. Call before navigating to login.
  Future<void> logout() async {
    // Get token from same places we use for authenticated requests
    String? token = _accessToken;
    if (token == null || token.isEmpty) {
      final storage = await getStorageService();
      token = await storage.getAccessToken();
    }
    if (token == null || token.isEmpty) {
      final prefs = await SharedPreferences.getInstance();
      token = prefs.getString(AppConstants.storageToken);
    }

    // Hit logout API so server can invalidate session
    if (token != null && token.isNotEmpty) {
      try {
        final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.logout}');
        final response = await http.post(
          url,
          headers: {
            'Content-Type': 'application/json',
            ApiConstants.authorization: '${ApiConstants.bearer} $token',
          },
        ).timeout(const Duration(seconds: 10));
        // Debug: print statusCode and response in terminal
        print('[Auth/logout] URL: $url');
        print('[Auth/logout] statusCode: ${response.statusCode}');
        print('[Auth/logout] response: ${response.body}');
      } catch (e) {
        print('[Auth/logout] request failed: $e');
      }
    }

    SimpleDriverCookieManager.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.storageToken);
    await prefs.remove(AppConstants.prefIsLoggedIn);
    final storage = await getStorageService();
    await storage.clearAll();
    _accessToken = null;
    _userData = null;
    _errorMessage = null;
    notifyListeners();
  }
}