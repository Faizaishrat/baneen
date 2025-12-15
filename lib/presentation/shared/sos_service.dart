import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../services/location/location_service.dart';
import '../../services/api/api_service.dart';
import '../../core/constants/api_constants.dart';

class SosService {
  final LocationService _locationService = LocationService();
  final ApiService _apiService = ApiService();

  Future<void> triggerSOS(BuildContext context) async {
    try {
      // Get current location
      final position = await _locationService.getCurrentPosition();

      // Get address
      final address = await _locationService.getAddressFromCoordinates(
        position.latitude,
        position.longitude,
      );

      // Send SOS to backend
      await _apiService.post(
        ApiConstants.triggerSos,
        data: {
          'latitude': position.latitude,
          'longitude': position.longitude,
          'address': address,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      // Call emergency number
      await _callEmergencyNumber();

      // Show confirmation
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('SOS alert sent to emergency contacts and admin'),
            backgroundColor: AppTheme.sosColor,
            duration: Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send SOS: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  Future<void> _callEmergencyNumber() async {
    final Uri phoneUri = Uri(scheme: 'tel', path: AppConstants.emergencyNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }

  Widget buildSOSButton({
    required VoidCallback onPressed,
    bool isLarge = false,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.warning),
      label: Text(isLarge ? 'SOS EMERGENCY' : 'SOS'),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.sosColor,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(
          horizontal: isLarge ? 24 : 16,
          vertical: isLarge ? 16 : 12,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(isLarge ? 12 : 8),
        ),
      ),
    );
  }
}

