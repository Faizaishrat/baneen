import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:shared_preferences/shared_preferences.dart';
import '../storage/storage_service.dart' as secure_storage;
import '../../core/constants/app_constants.dart';

/// Singleton Socket.IO service for Baneen.
/// Connect when driver goes online → listen for ride requests.
/// Disconnect when driver goes offline.
class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  IO.Socket? _socket;

  static const String _serverUrl = 'https://baneen-fullbackend.onrender.com';

  bool get isConnected => _socket?.connected ?? false;

  // ─── Callbacks set by DriverDashboardScreen ───────────────────────
  Function(Map<String, dynamic>)? onNewRideRequest;
  Function(Map<String, dynamic>)? onRideCancelled;
  Function(Map<String, dynamic>)? onRideUpdated;
  VoidCallback? onConnected;
  VoidCallback? onDisconnected;
  Function(String)? onError;

  // ─── Get token ────────────────────────────────────────────────────
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('access_token');
    if (token != null && token.isNotEmpty) return token;
    token = prefs.getString(AppConstants.storageToken);
    if (token != null && token.isNotEmpty) return token;
    final secure = await secure_storage.getStorageService();
    return await secure.getToken();
  }

  // ─── CONNECT ──────────────────────────────────────────────────────
  /// Call this when driver taps "Go Online" AND the REST API succeeds.
  Future<void> connect() async {
    if (_socket != null && _socket!.connected) {
      print('[Socket] Already connected');
      return;
    }

    final token = await _getToken();
    print('[Socket] Connecting to $_serverUrl');
    print('[Socket] Token: ${token != null ? "${token.substring(0, 20)}..." : "NULL ⚠️"}');

    _socket = IO.io(
      _serverUrl,
      IO.OptionBuilder()
          .setTransports(['websocket', 'polling']) // try websocket first
          .setAuth({'token': token})               // pass JWT to server
          .setExtraHeaders({
        if (token != null) 'Authorization': 'Bearer $token',
      })
          .enableAutoConnect()
          .enableReconnection()
          .setReconnectionAttempts(5)
          .setReconnectionDelay(2000)
          .build(),
    );

    _registerListeners();
    _socket!.connect();
  }

  // ─── DISCONNECT ───────────────────────────────────────────────────
  /// Call this when driver taps "Go Offline".
  void disconnect() {
    print('[Socket] Disconnecting...');
    _socket?.emit('driver:offline'); // tell server driver is going offline
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    print('[Socket] Disconnected');
  }

  // ─── REGISTER ALL LISTENERS ───────────────────────────────────────
  void _registerListeners() {
    if (_socket == null) return;

    // ── Connection events ──
    _socket!.onConnect((_) {
      print('[Socket] ✅ Connected! id: ${_socket?.id}');

      // Tell server this driver is online and ready
      _socket!.emit('driver:online');

      onConnected?.call();
    });

    _socket!.onDisconnect((reason) {
      print('[Socket] ❌ Disconnected: $reason');
      onDisconnected?.call();
    });

    _socket!.onConnectError((err) {
      print('[Socket] Connect error: $err');
      onError?.call('Connection error: $err');
    });

    _socket!.onError((err) {
      print('[Socket] Error: $err');
      onError?.call('Socket error: $err');
    });

    _socket!.onReconnect((_) {
      print('[Socket] 🔄 Reconnected');
      _socket!.emit('driver:online');
    });

    // ── Ride request events ──
    // Listen for ALL common event names backends use
    for (final event in [
      'ride:new',
      'new_ride_request',
      'rideRequest',
      'ride_request',
      'newRideRequest',
    ]) {
      _socket!.on(event, (data) {
        print('[Socket] 🚗 New ride request event "$event": $data');
        final ride = _parseMap(data);
        if (ride != null) onNewRideRequest?.call(ride);
      });
    }

    // ── Ride cancelled ──
    for (final event in ['ride:cancelled', 'rideCancelled', 'ride_cancelled']) {
      _socket!.on(event, (data) {
        print('[Socket] 🚫 Ride cancelled "$event": $data');
        final ride = _parseMap(data);
        if (ride != null) onRideCancelled?.call(ride);
      });
    }

    // ── Ride updated ──
    for (final event in ['ride:updated', 'rideUpdated', 'ride_updated']) {
      _socket!.on(event, (data) {
        print('[Socket] 🔄 Ride updated "$event": $data');
        final ride = _parseMap(data);
        if (ride != null) onRideUpdated?.call(ride);
      });
    }
  }

  // ─── EMIT: Driver location update ─────────────────────────────────
  void updateLocation(double lat, double lng) {
    if (!isConnected) return;
    _socket!.emit('driver:location', {'latitude': lat, 'longitude': lng});
  }

  // ─── EMIT: Driver accepted a ride ─────────────────────────────────
  void emitRideAccepted(String rideId) {
    if (!isConnected) return;
    _socket!.emit('driver:accept_ride', {'rideId': rideId});
    print('[Socket] Emitted driver:accept_ride for $rideId');
  }

  // ─── EMIT: Driver rejected a ride ─────────────────────────────────
  void emitRideRejected(String rideId) {
    if (!isConnected) return;
    _socket!.emit('driver:reject_ride', {'rideId': rideId});
    print('[Socket] Emitted driver:reject_ride for $rideId');
  }

  // ─── Helper ───────────────────────────────────────────────────────
  Map<String, dynamic>? _parseMap(dynamic data) {
    try {
      if (data is Map<String, dynamic>) return data;
      if (data is Map) return Map<String, dynamic>.from(data);
    } catch (e) {
      print('[Socket] Parse error: $e');
    }
    return null;
  }
}