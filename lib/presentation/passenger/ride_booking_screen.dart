import 'package:flutter/material.dart';
import '../widgets/baneen_map_widget.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../controller/ride_controller.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../services/location/location_service.dart';
import '../shared/voice_command_service.dart';

class RideBookingScreen extends StatefulWidget {
  final String? pickup;
  final String? destination;
  final String? paymentMethod;

  const RideBookingScreen({
    super.key,
    this.pickup,
    this.destination,
    this.paymentMethod,
  });

  @override
  State<RideBookingScreen> createState() => _RideBookingScreenState();
}

class _RideBookingScreenState extends State<RideBookingScreen> {
  String? _selectedVehicleType = AppConstants.vehicleTypeCar;
  DateTime? _scheduledTime;
  bool _isScheduled = false;
  bool _isLoading = false;
  bool _isListeningPickup = false;
  bool _isListeningDestination = false;
  double? _estimatedDistanceKm;
  final VoiceCommandService _voiceService = VoiceCommandService();
  final LocationService _locationService = LocationService();
  final TextEditingController _pickupController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  // GPS coordinates
  double? _pickupLat, _pickupLng;
  double? _dropoffLat, _dropoffLng;
  double? _passengerLat, _passengerLng;

  @override
  void initState() {
    super.initState();
    _pickupController.text = widget.pickup ?? '';
    _destinationController.text = widget.destination ?? '';
    _pickupController.addListener(_updateEstimate);
    _destinationController.addListener(_updateEstimate);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateEstimate();
      _getPassengerLocation(); // get GPS on screen load
    });
  }

  Future<void> _getPassengerLocation() async {
    try {
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied || perm == LocationPermission.deniedForever) return;

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      if (mounted) {
        setState(() {
          _passengerLat = pos.latitude;
          _passengerLng = pos.longitude;
          // If pickup is empty, auto-fill with current location
          if (_pickupController.text.isEmpty) {
            _pickupLat = pos.latitude;
            _pickupLng = pos.longitude;
          }
        });
        print('[RideBooking] Passenger GPS: ${pos.latitude}, ${pos.longitude}');
      }
    } catch (e) {
      print('[RideBooking] GPS error: $e');
    }
  }

  void _updateEstimate() async {
    final pickup = _pickupController.text.trim();
    final dest = _destinationController.text.trim();
    if (pickup.isEmpty || dest.isEmpty) {
      setState(() => _estimatedDistanceKm = null);
      return;
    }
    try {
      final pickupCoords = await _locationService.getCoordinatesFromAddress(pickup);
      final destCoords = await _locationService.getCoordinatesFromAddress(dest);
      if (pickupCoords == null || destCoords == null || !mounted) return;
      // Save coordinates for API call
      setState(() {
        _pickupLat = pickupCoords['latitude'];
        _pickupLng = pickupCoords['longitude'];
        _dropoffLat = destCoords['latitude'];
        _dropoffLng = destCoords['longitude'];
      });
      final km = _locationService.calculateDistance(
        pickupCoords['latitude']!,
        pickupCoords['longitude']!,
        destCoords['latitude']!,
        destCoords['longitude']!,
      ) / 1000;
      if (mounted) setState(() => _estimatedDistanceKm = km);
      print('[RideBooking] Pickup coords: $_pickupLat, $_pickupLng');
      print('[RideBooking] Dropoff coords: $_dropoffLat, $_dropoffLng');
    } catch (_) {
      if (mounted) setState(() => _estimatedDistanceKm = null);
    }
  }

  @override
  void dispose() {
    _pickupController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  Future<void> _bookRide() async {
    final pickup = _pickupController.text.trim();
    final dest = _destinationController.text.trim();
    if (pickup.isEmpty || dest.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter pickup and destination'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    final rideProvider = Provider.of<RideProvider>(context, listen: false);

    try {
      final result = await rideProvider.requestRide(
        pickupLocation: pickup,
        dropoffLocation: dest,
        paymentMethod: widget.paymentMethod ?? AppConstants.paymentMethodCash,
        vehicleType: _selectedVehicleType ?? AppConstants.vehicleTypeCar,
        pickupLat: _pickupLat,
        pickupLng: _pickupLng,
        dropoffLat: _dropoffLat,
        dropoffLng: _dropoffLng,
        passengerLat: _passengerLat,
        passengerLng: _passengerLng,
      );

      if (!mounted) return;
      if (result == null) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to request ride. Please try again.'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
        return;
      }

      // API returns { success, message, data: { rideId, status, ... } }
      final data = result['data'] ?? result;
      final rideId = data['rideId']?.toString() ?? result['ride']?['_id']?.toString() ?? result['_id']?.toString() ?? result['rideId']?.toString();
      if (rideId == null || rideId.isEmpty) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ride created but no ride ID returned.'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
        return;
      }

      setState(() => _isLoading = false);
      if (!mounted) return;
      // Build ride object for ActiveRideScreen (status: pending for "searching for driver")
      final rideForScreen = Map<String, dynamic>.from(data);
      if (!rideForScreen.containsKey('status')) rideForScreen['status'] = 'pending';
      context.push('/active-ride', extra: {
        'rideId': rideId,
        'ride': rideForScreen,
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        final msg = e is Exception ? e.toString().replaceFirst('Exception: ', '') : e.toString();
        final displayMessage = msg.isNotEmpty ? msg : 'Failed to request ride. Please try again.';
        // When no drivers available (400), show message clearly
        if (displayMessage.toLowerCase().contains('no drivers') ||
            displayMessage.toLowerCase().contains('driver') && displayMessage.toLowerCase().contains('not available')) {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('No drivers available'),
              content: Text(displayMessage),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(displayMessage),
              backgroundColor: AppTheme.errorColor,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    }
  }

  Future<void> _selectScheduleTime() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 7)),
    );

    if (picked != null) {
      final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (time != null) {
        setState(() {
          _scheduledTime = DateTime(
            picked.year,
            picked.month,
            picked.day,
            time.hour,
            time.minute,
          );
          _isScheduled = true;
        });
      }
    }
  }

  Future<void> _startVoiceInput(String type) async {
    if (type == 'pickup') {
      setState(() {
        _isListeningPickup = true;
      });
    } else {
      setState(() {
        _isListeningDestination = true;
      });
    }

    try {
      final result = await _voiceService.startListening();

      if (mounted && result != null && result.isNotEmpty) {
        setState(() {
          if (type == 'pickup') {
            _pickupController.text = result;
            _isListeningPickup = false;
          } else {
            _destinationController.text = result;
            _isListeningDestination = false;
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Voice input received: $result'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      } else if (mounted) {
        setState(() {
          _isListeningPickup = false;
          _isListeningDestination = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isListeningPickup = false;
          _isListeningDestination = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Voice input error: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  String _getEstimatedFare() {
    const baseCar = 150.0;
    const perKmCar = 45.0;
    const baseBike = 80.0;
    const perKmBike = 25.0;
    final km = _estimatedDistanceKm;
    if (km != null && km > 0) {
      if (_selectedVehicleType == AppConstants.vehicleTypeCar) {
        return 'PKR ${(baseCar + perKmCar * km).round()}';
      }
      if (_selectedVehicleType == AppConstants.vehicleTypeBike) {
        return 'PKR ${(baseBike + perKmBike * km).round()}';
      }
      return 'PKR ${(baseCar + perKmCar * km).round()}';
    }
    if (_selectedVehicleType == AppConstants.vehicleTypeCar) return 'PKR 250';
    if (_selectedVehicleType == AppConstants.vehicleTypeBike) return 'PKR 150';
    return 'PKR 250';
  }

  String _getPaymentMethodName() {
    switch (widget.paymentMethod) {
      case AppConstants.paymentMethodCash:
        return 'Cash';
      case AppConstants.paymentMethodEasyPaisa:
        return 'EasyPaisa';
      case AppConstants.paymentMethodJazzCash:
        return 'JazzCash';
      default:
        return 'Cash';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text('Book Ride'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Real OpenStreetMap
            BaneenMapWidget(
              height: 280,
              pickupLat: _pickupLat,
              pickupLng: _pickupLng,
              dropoffLat: _dropoffLat,
              dropoffLng: _dropoffLng,
              showMyLocation: true,
              showRoute: _pickupLat != null && _dropoffLat != null,
            ),
            const SizedBox(height: 24),
            // Location Summary
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.radio_button_checked,
                            color: AppTheme.successColor),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _pickupController,
                            decoration: InputDecoration(
                              hintText: 'Pickup Location',
                              border: InputBorder.none,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isListeningPickup
                                      ? Icons.mic
                                      : Icons.mic_none,
                                  color: _isListeningPickup
                                      ? AppTheme.errorColor
                                      : AppTheme.primaryColor,
                                ),
                                onPressed: () => _startVoiceInput('pickup'),
                                tooltip: 'Voice input for pickup',
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Icon(Icons.location_on,
                            color: AppTheme.primaryColor),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _destinationController,
                            decoration: InputDecoration(
                              hintText: 'Destination',
                              border: InputBorder.none,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isListeningDestination
                                      ? Icons.mic
                                      : Icons.mic_none,
                                  color: _isListeningDestination
                                      ? AppTheme.errorColor
                                      : AppTheme.primaryColor,
                                ),
                                onPressed: () => _startVoiceInput('destination'),
                                tooltip: 'Voice input for destination',
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Vehicle Type Selection
            Text(
              'Select Vehicle Type',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildVehicleTypeCard(
                    AppConstants.vehicleTypeCar,
                    Icons.directions_car,
                    'Car',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildVehicleTypeCard(
                    AppConstants.vehicleTypeBike,
                    Icons.two_wheeler,
                    'Bike',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Schedule Ride Option
            Card(
              child: SwitchListTile(
                title: const Text('Schedule Ride'),
                subtitle: _isScheduled && _scheduledTime != null
                    ? Text(
                  'Scheduled for ${_scheduledTime!.toString().substring(0, 16)}',
                )
                    : null,
                value: _isScheduled,
                onChanged: (value) {
                  if (value) {
                    _selectScheduleTime();
                  } else {
                    setState(() {
                      _isScheduled = false;
                      _scheduledTime = null;
                    });
                  }
                },
              ),
            ),
            const SizedBox(height: 24),
            // Estimated Fare (by distance when available)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Estimated Fare',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getEstimatedFare(),
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium
                          ?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    if (_estimatedDistanceKm != null && _estimatedDistanceKm! > 0) ...[
                      const SizedBox(height: 4),
                      Text(
                        '~${_estimatedDistanceKm!.toStringAsFixed(1)} km',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Text(
                      'Payment Method: ${_getPaymentMethodName()}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            // Book Ride Button
            ElevatedButton(
              onPressed: _isLoading ? null : _bookRide,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor:
                  AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
                  : const Text('Confirm Booking'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleTypeCard(String type, IconData icon, String label) {
    final isSelected = _selectedVehicleType == type;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedVehicleType = type;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryLight.withOpacity(0.3)
              : Colors.white,
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 40,
              color: isSelected ? AppTheme.primaryColor : AppTheme.textSecondary,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? AppTheme.primaryColor : AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}




// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:provider/provider.dart';
// import '../../controller/ride_controller.dart';
// import '../../core/theme/app_theme.dart';
// import '../../core/constants/app_constants.dart';
// import '../../services/location/location_service.dart';
// import '../shared/voice_command_service.dart';
//
// class RideBookingScreen extends StatefulWidget {
//   final String? pickup;
//   final String? destination;
//   final String? paymentMethod;
//
//   const RideBookingScreen({
//     super.key,
//     this.pickup,
//     this.destination,
//     this.paymentMethod,
//   });
//
//   @override
//   State<RideBookingScreen> createState() => _RideBookingScreenState();
// }
//
// class _RideBookingScreenState extends State<RideBookingScreen> {
//   String? _selectedVehicleType = AppConstants.vehicleTypeCar;
//   DateTime? _scheduledTime;
//   bool _isScheduled = false;
//   bool _isLoading = false;
//   bool _isListeningPickup = false;
//   bool _isListeningDestination = false;
//   double? _estimatedDistanceKm;
//   final VoiceCommandService _voiceService = VoiceCommandService();
//   final LocationService _locationService = LocationService();
//   final TextEditingController _pickupController = TextEditingController();
//   final TextEditingController _destinationController = TextEditingController();
//
//   @override
//   void initState() {
//     super.initState();
//     _pickupController.text = widget.pickup ?? '';
//     _destinationController.text = widget.destination ?? '';
//     _pickupController.addListener(_updateEstimate);
//     _destinationController.addListener(_updateEstimate);
//     WidgetsBinding.instance.addPostFrameCallback((_) => _updateEstimate());
//   }
//
//   void _updateEstimate() async {
//     final pickup = _pickupController.text.trim();
//     final dest = _destinationController.text.trim();
//     if (pickup.isEmpty || dest.isEmpty) {
//       setState(() => _estimatedDistanceKm = null);
//       return;
//     }
//     try {
//       final pickupCoords = await _locationService.getCoordinatesFromAddress(pickup);
//       final destCoords = await _locationService.getCoordinatesFromAddress(dest);
//       if (pickupCoords == null || destCoords == null || !mounted) return;
//       final km = _locationService.calculateDistance(
//         pickupCoords['latitude']!,
//         pickupCoords['longitude']!,
//         destCoords['latitude']!,
//         destCoords['longitude']!,
//       ) / 1000;
//       if (mounted) setState(() => _estimatedDistanceKm = km);
//     } catch (_) {
//       if (mounted) setState(() => _estimatedDistanceKm = null);
//     }
//   }
//
//   @override
//   void dispose() {
//     _pickupController.dispose();
//     _destinationController.dispose();
//     super.dispose();
//   }
//
//   Future<void> _bookRide() async {
//     final pickup = _pickupController.text.trim();
//     final dest = _destinationController.text.trim();
//     if (pickup.isEmpty || dest.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Please enter pickup and destination'),
//           backgroundColor: AppTheme.errorColor,
//         ),
//       );
//       return;
//     }
//
//     setState(() => _isLoading = true);
//     final rideProvider = Provider.of<RideProvider>(context, listen: false);
//
//     try {
//       final result = await rideProvider.requestRide(
//         pickupLocation: pickup,
//         dropoffLocation: dest,
//         paymentMethod: widget.paymentMethod ?? AppConstants.paymentMethodCash,
//         vehicleType: _selectedVehicleType ?? AppConstants.vehicleTypeCar,
//       );
//
//       if (!mounted) return;
//       if (result == null) {
//         setState(() => _isLoading = false);
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Failed to request ride. Please try again.'),
//             backgroundColor: AppTheme.errorColor,
//           ),
//         );
//         return;
//       }
//
//       // API returns { success, message, data: { rideId, status, ... } }
//       final data = result['data'] ?? result;
//       final rideId = data['rideId']?.toString() ?? result['ride']?['_id']?.toString() ?? result['_id']?.toString() ?? result['rideId']?.toString();
//       if (rideId == null || rideId.isEmpty) {
//         setState(() => _isLoading = false);
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Ride created but no ride ID returned.'),
//             backgroundColor: AppTheme.errorColor,
//           ),
//         );
//         return;
//       }
//
//       setState(() => _isLoading = false);
//       if (!mounted) return;
//       // Build ride object for ActiveRideScreen (status: pending for "searching for driver")
//       final rideForScreen = Map<String, dynamic>.from(data);
//       if (!rideForScreen.containsKey('status')) rideForScreen['status'] = 'pending';
//       context.push('/active-ride', extra: {
//         'rideId': rideId,
//         'ride': rideForScreen,
//       });
//     } catch (e) {
//       if (mounted) {
//         setState(() => _isLoading = false);
//         final msg = e is Exception ? e.toString().replaceFirst('Exception: ', '') : e.toString();
//         final displayMessage = msg.isNotEmpty ? msg : 'Failed to request ride. Please try again.';
//         // When no drivers available (400), show message clearly
//         if (displayMessage.toLowerCase().contains('no drivers') ||
//             displayMessage.toLowerCase().contains('driver') && displayMessage.toLowerCase().contains('not available')) {
//           showDialog(
//             context: context,
//             builder: (ctx) => AlertDialog(
//               title: const Text('No drivers available'),
//               content: Text(displayMessage),
//               actions: [
//                 TextButton(
//                   onPressed: () => Navigator.of(ctx).pop(),
//                   child: const Text('OK'),
//                 ),
//               ],
//             ),
//           );
//         } else {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text(displayMessage),
//               backgroundColor: AppTheme.errorColor,
//               duration: const Duration(seconds: 4),
//             ),
//           );
//         }
//       }
//     }
//   }
//
//   Future<void> _selectScheduleTime() async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: DateTime.now(),
//       firstDate: DateTime.now(),
//       lastDate: DateTime.now().add(const Duration(days: 7)),
//     );
//
//     if (picked != null) {
//       final TimeOfDay? time = await showTimePicker(
//         context: context,
//         initialTime: TimeOfDay.now(),
//       );
//
//       if (time != null) {
//         setState(() {
//           _scheduledTime = DateTime(
//             picked.year,
//             picked.month,
//             picked.day,
//             time.hour,
//             time.minute,
//           );
//           _isScheduled = true;
//         });
//       }
//     }
//   }
//
//   Future<void> _startVoiceInput(String type) async {
//     if (type == 'pickup') {
//       setState(() {
//         _isListeningPickup = true;
//       });
//     } else {
//       setState(() {
//         _isListeningDestination = true;
//       });
//     }
//
//     try {
//       final result = await _voiceService.startListening();
//
//       if (mounted && result != null && result.isNotEmpty) {
//         setState(() {
//           if (type == 'pickup') {
//             _pickupController.text = result;
//             _isListeningPickup = false;
//           } else {
//             _destinationController.text = result;
//             _isListeningDestination = false;
//           }
//         });
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Voice input received: $result'),
//             backgroundColor: AppTheme.successColor,
//           ),
//         );
//       } else if (mounted) {
//         setState(() {
//           _isListeningPickup = false;
//           _isListeningDestination = false;
//         });
//       }
//     } catch (e) {
//       if (mounted) {
//         setState(() {
//           _isListeningPickup = false;
//           _isListeningDestination = false;
//         });
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Voice input error: $e'),
//             backgroundColor: AppTheme.errorColor,
//           ),
//         );
//       }
//     }
//   }
//
//   String _getEstimatedFare() {
//     const baseCar = 150.0;
//     const perKmCar = 45.0;
//     const baseBike = 80.0;
//     const perKmBike = 25.0;
//     final km = _estimatedDistanceKm;
//     if (km != null && km > 0) {
//       if (_selectedVehicleType == AppConstants.vehicleTypeCar) {
//         return 'PKR ${(baseCar + perKmCar * km).round()}';
//       }
//       if (_selectedVehicleType == AppConstants.vehicleTypeBike) {
//         return 'PKR ${(baseBike + perKmBike * km).round()}';
//       }
//       return 'PKR ${(baseCar + perKmCar * km).round()}';
//     }
//     if (_selectedVehicleType == AppConstants.vehicleTypeCar) return 'PKR 250';
//     if (_selectedVehicleType == AppConstants.vehicleTypeBike) return 'PKR 150';
//     return 'PKR 250';
//   }
//
//   String _getPaymentMethodName() {
//     switch (widget.paymentMethod) {
//       case AppConstants.paymentMethodCash:
//         return 'Cash';
//       case AppConstants.paymentMethodEasyPaisa:
//         return 'EasyPaisa';
//       case AppConstants.paymentMethodJazzCash:
//         return 'JazzCash';
//       default:
//         return 'Cash';
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: () => Navigator.of(context).maybePop(),
//         ),
//         title: const Text('Book Ride'),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             // Simple Map Image
//             ClipRRect(
//               borderRadius: BorderRadius.circular(12),
//               child: Container(
//                 height: 300,
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(12),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.1),
//                       blurRadius: 8,
//                       offset: const Offset(0, 4),
//                     ),
//                   ],
//                 ),
//                 child: Image.asset(
//                   'assets/images/googlemap.jpeg', // <-- your map image path
//                   width: double.infinity,
//                   height: double.infinity,
//                   fit: BoxFit.cover,
//                 ),
//               ),
//             ),
//             const SizedBox(height: 24),
//             // Location Summary
//             Card(
//               child: Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Column(
//                   children: [
//                     Row(
//                       children: [
//                         const Icon(Icons.radio_button_checked,
//                             color: AppTheme.successColor),
//                         const SizedBox(width: 12),
//                         Expanded(
//                           child: TextField(
//                             controller: _pickupController,
//                             decoration: InputDecoration(
//                               hintText: 'Pickup Location',
//                               border: InputBorder.none,
//                               suffixIcon: IconButton(
//                                 icon: Icon(
//                                   _isListeningPickup
//                                       ? Icons.mic
//                                       : Icons.mic_none,
//                                   color: _isListeningPickup
//                                       ? AppTheme.errorColor
//                                       : AppTheme.primaryColor,
//                                 ),
//                                 onPressed: () => _startVoiceInput('pickup'),
//                                 tooltip: 'Voice input for pickup',
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 16),
//                     const Divider(),
//                     const SizedBox(height: 16),
//                     Row(
//                       children: [
//                         const Icon(Icons.location_on,
//                             color: AppTheme.primaryColor),
//                         const SizedBox(width: 12),
//                         Expanded(
//                           child: TextField(
//                             controller: _destinationController,
//                             decoration: InputDecoration(
//                               hintText: 'Destination',
//                               border: InputBorder.none,
//                               suffixIcon: IconButton(
//                                 icon: Icon(
//                                   _isListeningDestination
//                                       ? Icons.mic
//                                       : Icons.mic_none,
//                                   color: _isListeningDestination
//                                       ? AppTheme.errorColor
//                                       : AppTheme.primaryColor,
//                                 ),
//                                 onPressed: () => _startVoiceInput('destination'),
//                                 tooltip: 'Voice input for destination',
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             const SizedBox(height: 24),
//             // Vehicle Type Selection
//             Text(
//               'Select Vehicle Type',
//               style: Theme.of(context).textTheme.titleLarge,
//             ),
//             const SizedBox(height: 12),
//             Row(
//               children: [
//                 Expanded(
//                   child: _buildVehicleTypeCard(
//                     AppConstants.vehicleTypeCar,
//                     Icons.directions_car,
//                     'Car',
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: _buildVehicleTypeCard(
//                     AppConstants.vehicleTypeBike,
//                     Icons.two_wheeler,
//                     'Bike',
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 24),
//             // Schedule Ride Option
//             Card(
//               child: SwitchListTile(
//                 title: const Text('Schedule Ride'),
//                 subtitle: _isScheduled && _scheduledTime != null
//                     ? Text(
//                   'Scheduled for ${_scheduledTime!.toString().substring(0, 16)}',
//                 )
//                     : null,
//                 value: _isScheduled,
//                 onChanged: (value) {
//                   if (value) {
//                     _selectScheduleTime();
//                   } else {
//                     setState(() {
//                       _isScheduled = false;
//                       _scheduledTime = null;
//                     });
//                   }
//                 },
//               ),
//             ),
//             const SizedBox(height: 24),
//             // Estimated Fare (by distance when available)
//             Card(
//               child: Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'Estimated Fare',
//                       style: Theme.of(context).textTheme.bodyMedium,
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       _getEstimatedFare(),
//                       style: Theme.of(context)
//                           .textTheme
//                           .headlineMedium
//                           ?.copyWith(
//                         fontWeight: FontWeight.bold,
//                         color: AppTheme.primaryColor,
//                       ),
//                     ),
//                     if (_estimatedDistanceKm != null && _estimatedDistanceKm! > 0) ...[
//                       const SizedBox(height: 4),
//                       Text(
//                         '~${_estimatedDistanceKm!.toStringAsFixed(1)} km',
//                         style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                           color: AppTheme.textSecondary,
//                         ),
//                       ),
//                     ],
//                     const SizedBox(height: 8),
//                     Text(
//                       'Payment Method: ${_getPaymentMethodName()}',
//                       style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                         color: AppTheme.textSecondary,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             const SizedBox(height: 32),
//             // Book Ride Button
//             ElevatedButton(
//               onPressed: _isLoading ? null : _bookRide,
//               style: ElevatedButton.styleFrom(
//                 padding: const EdgeInsets.symmetric(vertical: 16),
//               ),
//               child: _isLoading
//                   ? const SizedBox(
//                 height: 20,
//                 width: 20,
//                 child: CircularProgressIndicator(
//                   strokeWidth: 2,
//                   valueColor:
//                   AlwaysStoppedAnimation<Color>(Colors.white),
//                 ),
//               )
//                   : const Text('Confirm Booking'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildVehicleTypeCard(String type, IconData icon, String label) {
//     final isSelected = _selectedVehicleType == type;
//     return GestureDetector(
//       onTap: () {
//         setState(() {
//           _selectedVehicleType = type;
//         });
//       },
//       child: Container(
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           color: isSelected
//               ? AppTheme.primaryLight.withOpacity(0.3)
//               : Colors.white,
//           border: Border.all(
//             color: isSelected ? AppTheme.primaryColor : Colors.grey.shade300,
//             width: isSelected ? 2 : 1,
//           ),
//           borderRadius: BorderRadius.circular(12),
//         ),
//         child: Column(
//           children: [
//             Icon(
//               icon,
//               size: 40,
//               color: isSelected ? AppTheme.primaryColor : AppTheme.textSecondary,
//             ),
//             const SizedBox(height: 8),
//             Text(
//               label,
//               style: TextStyle(
//                 fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
//                 color: isSelected ? AppTheme.primaryColor : AppTheme.textSecondary,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
