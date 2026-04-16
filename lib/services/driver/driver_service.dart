// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import '../../core/constants/api_constants.dart';
// import '../../core/constants/app_constants.dart';
// import '../storage/storage_service.dart' as secure_storage;
//
// /// Driver APIs: availability, ride requests.
// /// Uses same token as login (SharedPreferences + secure storage).
// class DriverService {
//   Future<String?> _getAccessToken() async {
//     final prefs = await SharedPreferences.getInstance();
//     String? token = prefs.getString('access_token');
//     if (token != null && token.isNotEmpty) return token;
//     token = prefs.getString(AppConstants.storageToken);
//     if (token != null && token.isNotEmpty) return token;
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
//     }
//     return headers;
//   }
//
//   /// PUT {{baseURL}}/drivers/availability — set driver online/offline.
//   /// Body: { "status": "online" } or { "status": "offline" }
//   Future<bool> updateAvailability({required bool isOnline}) async {
//     final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.updateAvailability}');
//     final body = jsonEncode({'status': isOnline ? 'online' : 'offline'});
//     final response = await http
//         .put(uri, headers: await _headers(), body: body)
//         .timeout(const Duration(seconds: 15));
//     return response.statusCode == 200 || response.statusCode == 201;
//   }
//
//   /// GET {{baseURL}}/drivers/rides/requests — fetch pending ride requests for driver.
//   /// Returns list of ride maps (with _id, pickupLocation, dropoffLocation, etc.).
//   Future<List<Map<String, dynamic>>> getRideRequests() async {
//     final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.getRideRequests}');
//     final response = await http
//         .get(uri, headers: await _headers())
//         .timeout(const Duration(seconds: 15));
//     if (response.statusCode != 200) return [];
//     try {
//       final json = jsonDecode(response.body) as Map<String, dynamic>?;
//       final data = json?['data'];
//       final list = data is List ? data : json?['rides'] as List? ?? json?['requests'] as List?;
//       if (list == null) return [];
//       return list
//           .map((e) => e is Map<String, dynamic> ? e : Map<String, dynamic>.from(e as Map))
//           .toList();
//     } catch (_) {
//       return [];
//     }
//   }
// }

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/api_constants.dart';
import '../../core/constants/app_constants.dart';
import '../storage/storage_service.dart' as secure_storage;

/// Driver APIs: availability, ride requests.
/// Auto-refreshes token on 401 and retries the request once.
class DriverService {

  // ─── Token helpers ────────────────────────────────────────────────

  Future<String?> _getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('access_token');
    if (token != null && token.isNotEmpty) return token;
    token = prefs.getString(AppConstants.storageToken);
    if (token != null && token.isNotEmpty) return token;
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

  Future<Map<String, String>> _headers() async {
    final accessToken = await _getAccessToken();
    final refreshToken = await _getRefreshToken();
    final headers = <String, String>{
      'Content-Type': ApiConstants.contentType,
    };
    if (accessToken != null && accessToken.isNotEmpty) {
      headers[ApiConstants.authorization] =
      '${ApiConstants.bearer} $accessToken';
      final cookieParts = <String>['accessToken=$accessToken'];
      if (refreshToken != null && refreshToken.isNotEmpty) {
        cookieParts.add('refreshToken=$refreshToken');
      }
      headers['Cookie'] = cookieParts.join('; ');
    }
    return headers;
  }

  // ─── Auto-refresh token on 401 ────────────────────────────────────

  /// Calls POST /auth/refresh-token with the saved refresh token.
  /// Saves the new access token and returns it, or null on failure.
  Future<String?> _tryRefreshToken() async {
    final refreshToken = await _getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      print('[DriverService] No refresh token — cannot refresh');
      return null;
    }

    print('[DriverService] Token expired — refreshing...');
    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.refreshToken}');

    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': ApiConstants.contentType},
        body: jsonEncode({'refreshToken': refreshToken}),
      ).timeout(const Duration(seconds: 15));

      print('[DriverService] Refresh status: ${response.statusCode}');
      print('[DriverService] Refresh body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final json = jsonDecode(response.body) as Map<String, dynamic>?;
        final data = json?['data'] ?? json;
        final newToken = data?['accessToken']
            ?? data?['token']
            ?? data?['access_token']
            ?? json?['accessToken']
            ?? json?['token'];

        if (newToken != null && newToken.toString().isNotEmpty) {
          // Save new token to all storage locations
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('access_token', newToken.toString());
          await prefs.setString(AppConstants.storageToken, newToken.toString());
          final secure = await secure_storage.getStorageService();
          await secure.saveAccessToken(newToken.toString());
          print('[DriverService] Token refreshed successfully');
          return newToken.toString();
        }
      }
    } catch (e) {
      print('[DriverService] Refresh error: $e');
    }
    return null;
  }

  // ─── Send GPS Location to Backend ───────────────────────────────────

  /// POST /drivers/location — send driver GPS coordinates to backend.
  /// Called once on Go Online, then every 10 seconds while online.
  /// PUT /rides/:id/location — update driver location during an active ride.
  /// rideId is optional; if null, location update is skipped gracefully.
  Future<void> updateLocation({
    required double latitude,
    required double longitude,
    String? rideId,
  }) async {
    // Only send if we have an active ride id
    if (rideId == null || rideId.isEmpty) {
      print('[DriverService] No active rideId — skipping location update');
      return;
    }
    final uri = Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.rideLocation(rideId)}');
    // Backend says no body, but send coords as query params just in case
    final uriWithParams = Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.rideLocation(rideId)}?latitude=$latitude&longitude=$longitude');

    print('[DriverService] Location update: $uriWithParams');
    try {
      var response = await http
          .put(uriWithParams, headers: await _headers())
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 401) {
        await _tryRefreshToken();
        response = await http
            .put(uriWithParams, headers: await _headers())
            .timeout(const Duration(seconds: 10));
      }
      print('[DriverService] Location sent → ${response.statusCode}');
    } catch (e) {
      print('[DriverService] Location update error: $e');
    }
  }

  // ─── Go Online / Offline ──────────────────────────────────────────

  /// POST /drivers/online — with auto token refresh on 401
  Future<bool> updateAvailability({
    required bool isOnline,
    double? latitude,
    double? longitude,
  }) async {
    // Use correct confirmed endpoints
    final endpoint = isOnline
        ? ApiConstants.driverGoOnline   // POST /drivers/online
        : ApiConstants.driverGoOffline; // POST /drivers/offline ✅
    final uri = Uri.parse('${ApiConstants.baseUrl}$endpoint');

    // Send location with online request
    final Map<String, dynamic> bodyMap = {};
    if (isOnline && latitude != null && longitude != null) {
      bodyMap['latitude'] = latitude;
      bodyMap['longitude'] = longitude;
      bodyMap['currentLocation'] = {
        'latitude': latitude,
        'longitude': longitude,
      };
    }
    final body = bodyMap.isEmpty ? '{}' : jsonEncode(bodyMap);

    print('[DriverService] ${isOnline ? "Going ONLINE" : "Going OFFLINE"}: $uri');

    try {
      var response = await http
          .post(uri, headers: await _headers(), body: body)
          .timeout(const Duration(seconds: 15));

      print('[DriverService] status: ${response.statusCode}');

      // Token expired → refresh and retry once
      if (response.statusCode == 401) {
        final newToken = await _tryRefreshToken();
        if (newToken != null) {
          response = await http
              .post(uri, headers: await _headers(), body: body)
              .timeout(const Duration(seconds: 15));
          print('[DriverService] retry status: ${response.statusCode}');
          print('[DriverService] retry body: ${response.body}');
        } else {
          print('[DriverService] Token refresh failed — user must login again');
          return false;
        }
      }

      print('[DriverService] body: ${response.body}');
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      print('[DriverService] error: $e');
      return false;
    }
  }

  // ─── Reject Ride ──────────────────────────────────────────────────

  /// POST /matching/ride-response/:rideId — driver rejects a ride
  Future<bool> rejectRide(String rideId) async {
    final uri = Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.rejectRide}/$rideId');
    print('[DriverService] Rejecting ride: $uri');
    try {
      var response = await http
          .post(uri, headers: await _headers(), body: '{}')
          .timeout(const Duration(seconds: 15));
      if (response.statusCode == 401) {
        await _tryRefreshToken();
        response = await http
            .post(uri, headers: await _headers(), body: '{}')
            .timeout(const Duration(seconds: 15));
      }
      print('[DriverService] Reject status: ${response.statusCode}');
      print('[DriverService] Reject body: ${response.body}');
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('[DriverService] Reject error: $e');
      return false;
    }
  }

  // ─── Ride Requests ────────────────────────────────────────────────

  /// GET /drivers/rides/requests — with auto token refresh on 401
  /// Backend returns 500 when no rides — treat as empty list silently.
  Future<List<Map<String, dynamic>>> getRideRequests() async {
    final uri = Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.getRideRequests}');

    try {
      var response = await http
          .get(uri, headers: await _headers())
          .timeout(const Duration(seconds: 15));

      // Token expired → refresh and retry once
      if (response.statusCode == 401) {
        final newToken = await _tryRefreshToken();
        if (newToken != null) {
          response = await http
              .get(uri, headers: await _headers())
              .timeout(const Duration(seconds: 15));
        } else {
          return [];
        }
      }

      // 500 = backend bug (no rides) — return empty silently
      if (response.statusCode == 500) return [];
      if (response.statusCode != 200) return [];

      final json = jsonDecode(response.body) as Map<String, dynamic>?;
      final data = json?['data'];
      final list = data is List
          ? data
          : json?['rides'] as List?
          ?? json?['requests'] as List?
          ?? json?['pendingRides'] as List?;
      if (list == null) return [];
      return list
          .map((e) =>
      e is Map<String, dynamic> ? e : Map<String, dynamic>.from(e as Map))
          .toList();
    } catch (e) {
      return [];
    }
  }
}