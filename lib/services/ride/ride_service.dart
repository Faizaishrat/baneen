// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import '../../core/constants/api_constants.dart';
// import '../../core/constants/app_constants.dart';
// import '../storage/storage_service.dart' as secure_storage;
//
// /// Ride API: request, accept, cancel, start, complete, rate.
// /// Reads token from every place login/OTP might have saved it.
// class RideService {
//   /// Token from same keys login uses: SharedPreferences (access_token, auth_token) then secure storage.
//   Future<String?> _getAccessToken() async {
//     final prefs = await SharedPreferences.getInstance();
//     // Login saves to both; use same keys as login_controller and storage_services
//     String? token = prefs.getString('access_token');
//     if (token != null && token.isNotEmpty) return token;
//     token = prefs.getString(AppConstants.storageToken); // 'auth_token'
//     if (token != null && token.isNotEmpty) return token;
//     // Some flows use secure storage (services/storage)
//     final secure = await secure_storage.getStorageService();
//     return await secure.getToken();
//   }
//
//   Future<String?> _getRefreshToken() async {
//     final prefs = await SharedPreferences.getInstance();
//     String? token = prefs.getString('refresh_token');
//     if (token != null && token.isNotEmpty) return token;
//     final secure = await secure_storage.getStorageService();
//     return await secure.getRefreshToken();
//   }
//
//   /// Same headers as login: Authorization Bearer + Cookie (accessToken; refreshToken).
//   /// Tokens read from same storage login writes to.
//   Future<Map<String, String>> _headers() async {
//     final accessToken = await _getAccessToken();
//     final refreshToken = await _getRefreshToken();
//     final headers = <String, String>{
//       'Content-Type': ApiConstants.contentType,
//     };
//     if (accessToken != null && accessToken.isNotEmpty) {
//       headers[ApiConstants.authorization] = '${ApiConstants.bearer} $accessToken';
//       final cookieParts = <String>['accessToken=$accessToken'];
//       if (refreshToken != null && refreshToken.isNotEmpty) {
//         cookieParts.add('refreshToken=$refreshToken');
//       }
//       headers['Cookie'] = cookieParts.join('; ');
//       print('[Rides] Using same token as login: Cookie + Authorization');
//     } else {
//       print('[Rides] No token in storage (login storage: access_token / auth_token)');
//     }
//     return headers;
//   }
//
//   /// POST /rides/request
//   /// Body: pickupLocation, dropoffLocation, paymentMethod, vehicleType
//   Future<Map<String, dynamic>?> requestRide({
//     required String pickupLocation,
//     required String dropoffLocation,
//     required String paymentMethod,
//     required String vehicleType,
//   }) async {
//     final url = '${ApiConstants.baseUrl}${ApiConstants.requestRide}';
//     final uri = Uri.parse(url);
//     final body = jsonEncode({
//       'pickupLocation': pickupLocation,
//       'dropoffLocation': dropoffLocation,
//       'paymentMethod': paymentMethod,
//       'vehicleType': vehicleType,
//     });
//     final headers = await _headers();
//     final response = await http
//         .post(uri, headers: headers, body: body)
//         .timeout(const Duration(seconds: 30));
//
//     // Debug: print statusCode and response when Confirm Booking is clicked
//     print('[Rides/request] URL: $url');
//     print('[Rides/request] statusCode: ${response.statusCode}');
//     print('[Rides/request] response: ${response.body}');
//
//     if (response.statusCode == 200 || response.statusCode == 201) {
//       final data = jsonDecode(response.body) as Map<String, dynamic>?;
//       return data;
//     }
//     // Surface API error so UI can show it
//     String message = 'Request failed (${response.statusCode})';
//     try {
//       final err = jsonDecode(response.body) as Map<String, dynamic>?;
//       message = err?['message']?.toString() ?? err?['error']?.toString() ?? message;
//     } catch (_) {}
//     throw Exception(message);
//   }
//
//   /// PUT /rides/:id/accept (driver)
//   Future<bool> acceptRide(String rideId) async {
//     final path = ApiConstants.rideAccept(rideId);
//     final uri = Uri.parse('${ApiConstants.baseUrl}$path');
//     final response = await http
//         .put(uri, headers: await _headers())
//         .timeout(const Duration(seconds: 15));
//     return response.statusCode == 200 || response.statusCode == 204;
//   }
//
//   /// PUT /rides/:id/cancel
//   /// Body: reason (optional)
//   Future<bool> cancelRide(String rideId, {String? reason}) async {
//     final path = ApiConstants.rideCancel(rideId);
//     final uri = Uri.parse('${ApiConstants.baseUrl}$path');
//     final body = reason != null ? jsonEncode({'reason': reason}) : '{}';
//     final response = await http
//         .put(uri, headers: await _headers(), body: body)
//         .timeout(const Duration(seconds: 15));
//     return response.statusCode == 200 || response.statusCode == 204;
//   }
//
//   /// PUT /rides/:id/start (driver) - form: startCoords, driverPhoto
//   Future<bool> startRide(
//     String rideId, {
//     required double latitude,
//     required double longitude,
//     String? driverPhotoPath,
//   }) async {
//     final path = ApiConstants.rideStart(rideId);
//     final uri = Uri.parse('${ApiConstants.baseUrl}$path');
//     final headers = await _headers();
//     headers.remove('Content-Type');
//     final request = http.MultipartRequest('PUT', uri);
//     request.headers.addAll(headers);
//     request.fields['startCoords'] =
//         jsonEncode({'latitude': latitude, 'longitude': longitude});
//     if (driverPhotoPath != null && driverPhotoPath.isNotEmpty) {
//       try {
//         request.files.add(await http.MultipartFile.fromPath(
//             'driverPhoto', driverPhotoPath));
//       } catch (_) {}
//     }
//     final streamed = await request.send().timeout(const Duration(seconds: 30));
//     final response = await http.Response.fromStream(streamed);
//     return response.statusCode == 200 || response.statusCode == 204;
//   }
//
//   /// PUT /rides/:id/complete (driver)
//   /// Body: endCoords: { latitude, longitude }
//   Future<bool> completeRide(
//     String rideId, {
//     required double latitude,
//     required double longitude,
//   }) async {
//     final path = ApiConstants.rideComplete(rideId);
//     final uri = Uri.parse('${ApiConstants.baseUrl}$path');
//     final body = jsonEncode({
//       'endCoords': {'latitude': latitude, 'longitude': longitude},
//     });
//     final response = await http
//         .put(uri, headers: await _headers(), body: body)
//         .timeout(const Duration(seconds: 15));
//     return response.statusCode == 200 || response.statusCode == 204;
//   }
//
//   /// PUT /rides/:id/rate
//   Future<bool> rateRide(String rideId, {double? rating, String? comment}) async {
//     final path = ApiConstants.rideRate(rideId);
//     final uri = Uri.parse('${ApiConstants.baseUrl}$path');
//     final body = <String, dynamic>{};
//     if (rating != null) body['rating'] = rating;
//     if (comment != null) body['comment'] = comment;
//     final response = await http
//         .put(uri,
//             headers: await _headers(),
//             body: body.isEmpty ? '{}' : jsonEncode(body))
//         .timeout(const Duration(seconds: 15));
//     return response.statusCode == 200 || response.statusCode == 204;
//   }
//
//   /// GET /rides/:id
//   Future<Map<String, dynamic>?> getRideDetails(String rideId) async {
//     final path = ApiConstants.rideDetails(rideId);
//     final uri = Uri.parse('${ApiConstants.baseUrl}$path');
//     final response = await http
//         .get(uri, headers: await _headers())
//         .timeout(const Duration(seconds: 15));
//     if (response.statusCode != 200) return null;
//     final data = jsonDecode(response.body) as Map<String, dynamic>?;
//     return data;
//   }
// }




import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/api_constants.dart';
import '../../core/constants/app_constants.dart';
import '../storage/storage_service.dart' as secure_storage;

/// Ride API: request, accept, cancel, start, complete, rate.
/// Reads token from every place login/OTP might have saved it.
class RideService {
  /// Token from same keys login uses: SharedPreferences (access_token, auth_token) then secure storage.
  Future<String?> _getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    // Login saves to both; use same keys as login_controller and storage_services
    String? token = prefs.getString('access_token');
    if (token != null && token.isNotEmpty) return token;
    token = prefs.getString(AppConstants.storageToken); // 'auth_token'
    if (token != null && token.isNotEmpty) return token;
    // Some flows use secure storage (services/storage)
    final secure = await secure_storage.getStorageService();
    return await secure.getToken();
  }

  Future<String?> _getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('refresh_token');
    if (token != null && token.isNotEmpty) return token;
    final secure = await secure_storage.getStorageService();
    return await secure.getRefreshToken();
  }

  /// Same headers as login: Authorization Bearer + Cookie (accessToken; refreshToken).
  /// Tokens read from same storage login writes to.
  Future<Map<String, String>> _headers() async {
    final accessToken = await _getAccessToken();
    final refreshToken = await _getRefreshToken();
    final headers = <String, String>{
      'Content-Type': ApiConstants.contentType,
    };
    if (accessToken != null && accessToken.isNotEmpty) {
      headers[ApiConstants.authorization] = '${ApiConstants.bearer} $accessToken';
      final cookieParts = <String>['accessToken=$accessToken'];
      if (refreshToken != null && refreshToken.isNotEmpty) {
        cookieParts.add('refreshToken=$refreshToken');
      }
      headers['Cookie'] = cookieParts.join('; ');

    }
    return headers;
  }

  /// Refresh expired token — called automatically on 401 responses.
  Future<String?> _tryRefreshToken() async {
    final refreshToken = await _getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) return null;

    print('[RideService] Token expired — refreshing...');
    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.refreshToken}');
    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': ApiConstants.contentType},
        body: jsonEncode({'refreshToken': refreshToken}),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final json = jsonDecode(response.body) as Map<String, dynamic>?;
        final data = json?['data'] ?? json;
        final newToken = data?['accessToken'] ?? data?['token']
            ?? json?['accessToken'] ?? json?['token'];
        if (newToken != null && newToken.toString().isNotEmpty) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('access_token', newToken.toString());
          await prefs.setString(AppConstants.storageToken, newToken.toString());
          final secure = await secure_storage.getStorageService();
          await secure.saveAccessToken(newToken.toString());
          print('[RideService] Token refreshed OK');
          return newToken.toString();
        }
      }
    } catch (e) {
      print('[RideService] Refresh error: $e');
    }
    return null;
  }

  /// POST /rides/request
  /// Body: pickupLocation, dropoffLocation, paymentMethod, vehicleType
  Future<Map<String, dynamic>?> requestRide({
    required String pickupLocation,
    required String dropoffLocation,
    required String paymentMethod,
    required String vehicleType,
    double? pickupLat,
    double? pickupLng,
    double? dropoffLat,
    double? dropoffLng,
    double? passengerLat,
    double? passengerLng,
  }) async {
    final url = '${ApiConstants.baseUrl}${ApiConstants.requestRide}';
    final uri = Uri.parse(url);

    // Exact fields confirmed from Postman:
    // pickupLocation, dropoffLocation, paymentMethod, vehicleType
    final Map<String, dynamic> bodyMap = {
      'pickupLocation': pickupLocation,
      'dropoffLocation': dropoffLocation,
      'paymentMethod': paymentMethod,
      'vehicleType': vehicleType,
    };

    final body = jsonEncode(bodyMap);
    final headers = await _headers();

    print('[Rides/request] URL: $url');
    print('[Rides/request] body: $bodyMap');

    final response = await http
        .post(uri, headers: headers, body: body)
        .timeout(const Duration(seconds: 30));

    print('[Rides/request] statusCode: ${response.statusCode}');
    print('[Rides/request] response: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body) as Map<String, dynamic>?;
      return data;
    }
    String message = 'Request failed (${response.statusCode})';
    try {
      final err = jsonDecode(response.body) as Map<String, dynamic>?;
      message = err?['message']?.toString() ?? err?['error']?.toString() ?? message;
    } catch (_) {}
    throw Exception(message);
  }

  /// PUT /rides/:id/accept (driver)
  Future<bool> acceptRide(String rideId) async {
    final path = ApiConstants.rideAccept(rideId);
    final uri = Uri.parse('${ApiConstants.baseUrl}$path');
    final response = await http
        .put(uri, headers: await _headers())
        .timeout(const Duration(seconds: 15));
    return response.statusCode == 200 || response.statusCode == 204;
  }

  /// PUT /rides/:id/cancel
  /// Body: reason (optional)
  Future<bool> cancelRide(String rideId, {String? reason}) async {
    final path = ApiConstants.rideCancel(rideId);
    final uri = Uri.parse('${ApiConstants.baseUrl}$path');
    final body = reason != null ? jsonEncode({'reason': reason}) : '{}';
    final response = await http
        .put(uri, headers: await _headers(), body: body)
        .timeout(const Duration(seconds: 15));
    return response.statusCode == 200 || response.statusCode == 204;
  }

  /// PUT /rides/:id/start (driver) - form: startCoords, driverPhoto
  Future<bool> startRide(
      String rideId, {
        required double latitude,
        required double longitude,
        String? driverPhotoPath,
      }) async {
    final path = ApiConstants.rideStart(rideId);
    final uri = Uri.parse('${ApiConstants.baseUrl}$path');
    final headers = await _headers();
    headers.remove('Content-Type');
    final request = http.MultipartRequest('PUT', uri);
    request.headers.addAll(headers);
    request.fields['startCoords'] =
        jsonEncode({'latitude': latitude, 'longitude': longitude});
    if (driverPhotoPath != null && driverPhotoPath.isNotEmpty) {
      try {
        request.files.add(await http.MultipartFile.fromPath(
            'driverPhoto', driverPhotoPath));
      } catch (_) {}
    }
    final streamed = await request.send().timeout(const Duration(seconds: 30));
    final response = await http.Response.fromStream(streamed);
    return response.statusCode == 200 || response.statusCode == 204;
  }

  /// PUT /rides/:id/complete (driver)
  /// Body: endCoords: { latitude, longitude }
  Future<bool> completeRide(
      String rideId, {
        required double latitude,
        required double longitude,
      }) async {
    final path = ApiConstants.rideComplete(rideId);
    final uri = Uri.parse('${ApiConstants.baseUrl}$path');
    final body = jsonEncode({
      'endCoords': {'latitude': latitude, 'longitude': longitude},
    });
    final response = await http
        .put(uri, headers: await _headers(), body: body)
        .timeout(const Duration(seconds: 15));
    return response.statusCode == 200 || response.statusCode == 204;
  }

  /// PUT /rides/:id/rate
  Future<bool> rateRide(String rideId, {double? rating, String? comment}) async {
    final path = ApiConstants.rideRate(rideId);
    final uri = Uri.parse('${ApiConstants.baseUrl}$path');
    final body = <String, dynamic>{};
    if (rating != null) body['rating'] = rating;
    if (comment != null) body['comment'] = comment;
    final response = await http
        .put(uri,
        headers: await _headers(),
        body: body.isEmpty ? '{}' : jsonEncode(body))
        .timeout(const Duration(seconds: 15));
    return response.statusCode == 200 || response.statusCode == 204;
  }

  /// GET /rides/:id
  Future<Map<String, dynamic>?> getRideDetails(String rideId) async {
    final path = ApiConstants.rideDetails(rideId);
    final uri = Uri.parse('${ApiConstants.baseUrl}$path');
    final response = await http
        .get(uri, headers: await _headers())
        .timeout(const Duration(seconds: 15));
    if (response.statusCode != 200) return null;
    final data = jsonDecode(response.body) as Map<String, dynamic>?;
    return data;
  }
}