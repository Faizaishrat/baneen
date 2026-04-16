import 'package:flutter/material.dart';
import '../services/ride/ride_service.dart';

/// Handles all ride-related API calls via Provider.
/// Use [RideProvider] in UI; API logic stays in [RideService].
class RideProvider with ChangeNotifier {
  final RideService _rideService = RideService();

  bool _isLoading = false;
  String? _errorMessage;
  Map<String, dynamic>? _currentRide;
  String? _currentRideId;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<String, dynamic>? get currentRide => _currentRide;
  String? get currentRideId => _currentRideId;

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? msg) {
    _errorMessage = msg;
    notifyListeners();
  }

  /// POST /rides/request — passenger requests a ride.
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
    _setLoading(true);
    _setError(null);
    try {
      final result = await _rideService.requestRide(
        pickupLocation: pickupLocation,
        dropoffLocation: dropoffLocation,
        paymentMethod: paymentMethod,
        vehicleType: vehicleType,
        pickupLat: pickupLat,
        pickupLng: pickupLng,
        dropoffLat: dropoffLat,
        dropoffLng: dropoffLng,
        passengerLat: passengerLat,
        passengerLng: passengerLng,
      );
      if (result != null) {
        _currentRide = result['ride'] ?? result;
        _currentRideId = _currentRide?['_id']?.toString() ?? result['_id']?.toString() ?? result['rideId']?.toString();
      }
      _setLoading(false);
      return result;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return null;
    }
  }

  /// GET /rides/:id — fetch ride details (e.g. for polling until driver accepts).
  Future<Map<String, dynamic>?> getRideDetails(String rideId) async {
    try {
      final details = await _rideService.getRideDetails(rideId);
      if (details != null) {
        _currentRide = details['ride'] ?? details;
        _currentRideId = rideId;
      }
      notifyListeners();
      return details;
    } catch (e) {
      _setError(e.toString());
      notifyListeners();
      return null;
    }
  }

  /// PUT /rides/:id/accept — driver accepts ride.
  Future<bool> acceptRide(String rideId) async {
    _setLoading(true);
    _setError(null);
    try {
      final ok = await _rideService.acceptRide(rideId);
      if (ok) _currentRideId = rideId;
      _setLoading(false);
      return ok;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  /// PUT /rides/:id/cancel — cancel ride (passenger or driver).
  Future<bool> cancelRide(String rideId, {String? reason}) async {
    _setLoading(true);
    _setError(null);
    try {
      final ok = await _rideService.cancelRide(rideId, reason: reason);
      if (ok) {
        if (_currentRideId == rideId) {
          _currentRideId = null;
          _currentRide = null;
        }
      }
      _setLoading(false);
      return ok;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  /// PUT /rides/:id/start — driver starts ride.
  Future<bool> startRide(
      String rideId, {
        required double latitude,
        required double longitude,
        String? driverPhotoPath,
      }) async {
    _setLoading(true);
    _setError(null);
    try {
      final ok = await _rideService.startRide(
        rideId,
        latitude: latitude,
        longitude: longitude,
        driverPhotoPath: driverPhotoPath,
      );
      _setLoading(false);
      return ok;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  /// PUT /rides/:id/complete — driver completes ride.
  Future<bool> completeRide(
      String rideId, {
        required double latitude,
        required double longitude,
      }) async {
    _setLoading(true);
    _setError(null);
    try {
      final ok = await _rideService.completeRide(
        rideId,
        latitude: latitude,
        longitude: longitude,
      );
      _setLoading(false);
      return ok;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  /// PUT /rides/:id/rate — rate ride after completion.
  Future<bool> rateRide(String rideId, {double? rating, String? comment}) async {
    _setLoading(true);
    _setError(null);
    try {
      final ok = await _rideService.rateRide(rideId, rating: rating, comment: comment);
      _setLoading(false);
      return ok;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  /// Clear current ride state (e.g. when leaving active ride).
  void clearCurrentRide() {
    _currentRide = null;
    _currentRideId = null;
    _errorMessage = null;
    notifyListeners();
  }
}



// import 'package:flutter/material.dart';
// import '../services/ride/ride_service.dart';
//
// /// Handles all ride-related API calls via Provider.
// /// Use [RideProvider] in UI; API logic stays in [RideService].
// class RideProvider with ChangeNotifier {
//   final RideService _rideService = RideService();
//
//   bool _isLoading = false;
//   String? _errorMessage;
//   Map<String, dynamic>? _currentRide;
//   String? _currentRideId;
//
//   bool get isLoading => _isLoading;
//   String? get errorMessage => _errorMessage;
//   Map<String, dynamic>? get currentRide => _currentRide;
//   String? get currentRideId => _currentRideId;
//
//   void clearError() {
//     _errorMessage = null;
//     notifyListeners();
//   }
//
//   void _setLoading(bool value) {
//     _isLoading = value;
//     notifyListeners();
//   }
//
//   void _setError(String? msg) {
//     _errorMessage = msg;
//     notifyListeners();
//   }
//
//   /// POST /rides/request — passenger requests a ride.
//   Future<Map<String, dynamic>?> requestRide({
//     required String pickupLocation,
//     required String dropoffLocation,
//     required String paymentMethod,
//     required String vehicleType,
//   }) async {
//     _setLoading(true);
//     _setError(null);
//     try {
//       final result = await _rideService.requestRide(
//         pickupLocation: pickupLocation,
//         dropoffLocation: dropoffLocation,
//         paymentMethod: paymentMethod,
//         vehicleType: vehicleType,
//       );
//       if (result != null) {
//         _currentRide = result['ride'] ?? result;
//         _currentRideId = _currentRide?['_id']?.toString() ?? result['_id']?.toString() ?? result['rideId']?.toString();
//       }
//       _setLoading(false);
//       return result;
//     } catch (e) {
//       _setError(e.toString());
//       _setLoading(false);
//       return null;
//     }
//   }
//
//   /// GET /rides/:id — fetch ride details (e.g. for polling until driver accepts).
//   Future<Map<String, dynamic>?> getRideDetails(String rideId) async {
//     try {
//       final details = await _rideService.getRideDetails(rideId);
//       if (details != null) {
//         _currentRide = details['ride'] ?? details;
//         _currentRideId = rideId;
//       }
//       notifyListeners();
//       return details;
//     } catch (e) {
//       _setError(e.toString());
//       notifyListeners();
//       return null;
//     }
//   }
//
//   /// PUT /rides/:id/accept — driver accepts ride.
//   Future<bool> acceptRide(String rideId) async {
//     _setLoading(true);
//     _setError(null);
//     try {
//       final ok = await _rideService.acceptRide(rideId);
//       if (ok) _currentRideId = rideId;
//       _setLoading(false);
//       return ok;
//     } catch (e) {
//       _setError(e.toString());
//       _setLoading(false);
//       return false;
//     }
//   }
//
//   /// PUT /rides/:id/cancel — cancel ride (passenger or driver).
//   Future<bool> cancelRide(String rideId, {String? reason}) async {
//     _setLoading(true);
//     _setError(null);
//     try {
//       final ok = await _rideService.cancelRide(rideId, reason: reason);
//       if (ok) {
//         if (_currentRideId == rideId) {
//           _currentRideId = null;
//           _currentRide = null;
//         }
//       }
//       _setLoading(false);
//       return ok;
//     } catch (e) {
//       _setError(e.toString());
//       _setLoading(false);
//       return false;
//     }
//   }
//
//   /// PUT /rides/:id/start — driver starts ride.
//   Future<bool> startRide(
//     String rideId, {
//     required double latitude,
//     required double longitude,
//     String? driverPhotoPath,
//   }) async {
//     _setLoading(true);
//     _setError(null);
//     try {
//       final ok = await _rideService.startRide(
//         rideId,
//         latitude: latitude,
//         longitude: longitude,
//         driverPhotoPath: driverPhotoPath,
//       );
//       _setLoading(false);
//       return ok;
//     } catch (e) {
//       _setError(e.toString());
//       _setLoading(false);
//       return false;
//     }
//   }
//
//   /// PUT /rides/:id/complete — driver completes ride.
//   Future<bool> completeRide(
//     String rideId, {
//     required double latitude,
//     required double longitude,
//   }) async {
//     _setLoading(true);
//     _setError(null);
//     try {
//       final ok = await _rideService.completeRide(
//         rideId,
//         latitude: latitude,
//         longitude: longitude,
//       );
//       _setLoading(false);
//       return ok;
//     } catch (e) {
//       _setError(e.toString());
//       _setLoading(false);
//       return false;
//     }
//   }
//
//   /// PUT /rides/:id/rate — rate ride after completion.
//   Future<bool> rateRide(String rideId, {double? rating, String? comment}) async {
//     _setLoading(true);
//     _setError(null);
//     try {
//       final ok = await _rideService.rateRide(rideId, rating: rating, comment: comment);
//       _setLoading(false);
//       return ok;
//     } catch (e) {
//       _setError(e.toString());
//       _setLoading(false);
//       return false;
//     }
//   }
//
//   /// Clear current ride state (e.g. when leaving active ride).
//   void clearCurrentRide() {
//     _currentRide = null;
//     _currentRideId = null;
//     _errorMessage = null;
//     notifyListeners();
//   }
// }
