import 'dart:math' as math;
import 'package:intl/intl.dart';

class Helpers {
  // Format Currency
  static String formatCurrency(double amount) {
    return NumberFormat.currency(
      symbol: 'PKR ',
      decimalDigits: 0,
    ).format(amount);
  }

  // Format Date
  static String formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  // Format DateTime
  static String formatDateTime(DateTime dateTime) {
    return DateFormat('MMM dd, yyyy hh:mm a').format(dateTime);
  }

  // Format Time
  static String formatTime(DateTime dateTime) {
    return DateFormat('hh:mm a').format(dateTime);
  }

  // Calculate Distance (Haversine formula)
  static double calculateDistance(
      double lat1,
      double lon1,
      double lat2,
      double lon2,
      ) {
    const double earthRadius = 6371; // km

    final double dLat = _toRadians(lat2 - lat1);
    final double dLon = _toRadians(lon2 - lon1);

    final double a = (dLat / 2) * (dLat / 2) +
        _cos(_toRadians(lat1)) *
            _cos(_toRadians(lat2)) *
            (dLon / 2) *
            (dLon / 2);
    final double c = 2 * _atan2(_sqrt(a), _sqrt(1 - a));

    return earthRadius * c;
  }

  static double _toRadians(double degrees) {
    return degrees * (3.141592653589793 / 180);
  }

  static double _cos(double radians) {
    return math.cos(radians);
  }

  static double _sqrt(double value) {
    return math.sqrt(value);
  }

  static double _atan2(double y, double x) {
    return math.atan2(y, x);
  }

  // Format Distance
  static String formatDistance(double distanceKm) {
    if (distanceKm < 1) {
      return '${(distanceKm * 1000).round()} m';
    }
    return '${distanceKm.toStringAsFixed(1)} km';
  }

  // Format Duration
  static String formatDuration(Duration duration) {
    if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    }
    return '${duration.inMinutes}m';
  }

  // Mask Phone Number
  static String maskPhone(String phone) {
    if (phone.length < 4) return phone;
    return '${phone.substring(0, 2)}****${phone.substring(phone.length - 2)}';
  }

  // Mask CNIC
  static String maskCNIC(String cnic) {
    if (cnic.length < 5) return cnic;
    return '${cnic.substring(0, 5)}-*******-${cnic.substring(cnic.length - 1)}';
  }
}


