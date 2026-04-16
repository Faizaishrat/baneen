import 'package:http/http.dart' as http;

class SimpleDriverCookieManager {
  static String? _cookie;

  /// Save cookie from server response (Set-Cookie header).
  /// Takes only name=value (before first ;) — Expires has comma in date so we avoid splitting by comma.
  static void saveCookie(http.Response response) {
    final rawCookie = response.headers['set-cookie'] ?? response.headers['Set-Cookie'];
    if (rawCookie != null && rawCookie.isNotEmpty) {
      _cookie = rawCookie.split(';').first.trim();
      print('🍪 Saved Cookie: $_cookie');
    } else {
      print('❌ No cookie received from server');
    }
  }

  /// Attach saved cookie to request headers (same as passenger OTP uses).
  static Map<String, String> attachCookie(Map<String, String> headers) {
    if (_cookie != null && _cookie!.isNotEmpty) {
      headers['Cookie'] = _cookie!;
      print('📤 Sending Cookie: $_cookie');
    }
    return headers;
  }

  static void clear() {
    _cookie = null;
  }

  /// Save cookie from raw Set-Cookie header string (e.g. from Dio response).
  /// Takes only name=value (before first ;) — Expires date contains comma.
  static void saveCookieFromString(String? rawCookie) {
    if (rawCookie != null && rawCookie.isNotEmpty) {
      _cookie = rawCookie.split(';').first.trim();
      print('🍪 Saved Cookie: $_cookie');
    } else {
      print('❌ No cookie string provided');
    }
  }

  /// Save cookie from token values (e.g. when login/OTP returns tokens in body).
  /// Use this so ride request and other APIs can send Cookie via attachCookie().
  static void saveCookieFromTokens(String? accessToken, String? refreshToken) {
    if (accessToken == null || accessToken.isEmpty) {
      print('❌ No accessToken to save as cookie');
      return;
    }
    final parts = <String>['accessToken=$accessToken'];
    if (refreshToken != null && refreshToken.isNotEmpty) {
      parts.add('refreshToken=$refreshToken');
    }
    _cookie = parts.join('; ');
    print('🍪 Saved Cookie from tokens: $_cookie');
  }
}