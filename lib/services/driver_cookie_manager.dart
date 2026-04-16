// import 'package:shared_preferences/shared_preferences.dart';
//
// class SimpleDriverCookieManager {
//   static const String refreshTokenKey = 'refreshToken';
//
//   // Save refresh token
//   static Future<void> saveRefreshToken(String token) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString(refreshTokenKey, token);
//   }
//
//   // Get refresh token
//   static Future<String?> getRefreshToken() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getString(refreshTokenKey);
//   }
//
//   // Attach cookie header
//   static Future<Map<String, String>> attachCookie(Map<String, String> headers) async {
//     final token = await getRefreshToken();
//     if (token != null) {
//       headers['Cookie'] = 'refreshToken=$token';
//     }
//     return headers;
//   }
// }



import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SimpleDriverCookieManager {
  static const String refreshTokenKey = 'refreshToken';

  // Save refresh token from body
  static Future<void> saveRefreshToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(refreshTokenKey, token);
    print('Saved refreshToken: $token');
  }

  // Get refresh token
  static Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(refreshTokenKey);
  }

  // Attach cookie header for requests
  static Future<Map<String, String>> attachCookie(Map<String, String> headers) async {
    final token = await getRefreshToken();
    if (token != null) {
      headers['Cookie'] = 'refreshToken=$token';
      print('Sending Cookie: refreshToken=$token');
    } else {
      print('No refreshToken found to send');
    }
    return headers;
  }

  // Save cookie from http.Response (for header 'set-cookie')
  static Future<void> saveCookie(http.Response response) async {
    final rawCookie = response.headers['set-cookie'];
    if (rawCookie != null && rawCookie.isNotEmpty) {
      // Take the first cookie if multiple are set
      final cookieValue = rawCookie.split(',').first.split(';').first.trim();
      if (cookieValue.contains('refreshToken=')) {
        final token = cookieValue.split('=')[1];
        await saveRefreshToken(token);
        print('Saved refreshToken from cookie header: $token');
      }
    }
  }
}