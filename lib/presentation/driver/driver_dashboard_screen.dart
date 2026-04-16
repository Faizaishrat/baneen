// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import '../../core/theme/app_theme.dart';
// import '../../core/utils/helpers.dart';
// import '../../services/driver/driver_service.dart';
// import 'earnings_screen.dart';
// import 'driver_profile_screen.dart';
//
// class DriverDashboardScreen extends StatefulWidget {
//   const DriverDashboardScreen({super.key});
//
//   @override
//   State<DriverDashboardScreen> createState() => _DriverDashboardScreenState();
// }
//
// class _DriverDashboardScreenState extends State<DriverDashboardScreen> {
//   bool _isOnline = false;
//   int _currentIndex = 0;
//   bool _isLoadingRides = false;
//   bool _isTogglingAvailability = false;
//
//   final DriverService _driverService = DriverService();
//   List<Map<String, dynamic>> _allRideRequests = [];
//   final Set<String> _rejectedRideIds = {};
//   Timer? _refreshTimer;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadRideRequestsIfOnline();
//   }
//
//   @override
//   void dispose() {
//     _refreshTimer?.cancel();
//     super.dispose();
//   }
//
//   /// Normalize API ride to display shape (id, passengerName, pickup, destination, distance, fare).
//   Map<String, dynamic> _normalizeRide(Map<String, dynamic> r) {
//     final id = r['_id']?.toString() ?? r['id']?.toString() ?? '';
//     return {
//       ...r,
//       '_id': id,
//       'id': id,
//       'passengerName': r['passenger']?['name'] ?? r['passengerName'] ?? 'Passenger',
//       'pickup': r['pickupLocation'] ?? r['pickup']?.toString() ?? r['pickup'] ?? '—',
//       'destination': r['dropoffLocation'] ?? r['destination']?.toString() ?? r['destination'] ?? '—',
//       'distance': r['distanceText'] ?? r['distance']?.toString() ?? '—',
//       'fare': r['estimatedFare'] ?? r['fare'] ?? 0,
//       'passengerRating': r['passenger']?['rating'] ?? r['passengerRating'] ?? 0,
//     };
//   }
//
//   Future<void> _loadRideRequestsIfOnline() async {
//     if (!_isOnline) return;
//     setState(() => _isLoadingRides = true);
//     try {
//       final list = await _driverService.getRideRequests();
//       if (mounted) {
//         setState(() {
//           _allRideRequests = list.map(_normalizeRide).toList();
//           _isLoadingRides = false;
//         });
//       }
//     } catch (e) {
//       if (mounted) {
//         setState(() => _isLoadingRides = false);
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed to load requests: $e'), backgroundColor: AppTheme.errorColor),
//         );
//       }
//     }
//   }
//
//   Future<void> _toggleAvailability() async {
//     setState(() => _isTogglingAvailability = true);
//     try {
//       final ok = await _driverService.updateAvailability(isOnline: !_isOnline);
//       if (!mounted) return;
//       if (ok) {
//         setState(() {
//           _isOnline = !_isOnline;
//           _isTogglingAvailability = false;
//         });
//         if (_isOnline) {
//           _loadRideRequestsIfOnline();
//           _refreshTimer?.cancel();
//           _refreshTimer = Timer.periodic(const Duration(seconds: 10), (_) => _loadRideRequestsIfOnline());
//         } else {
//           _refreshTimer?.cancel();
//           setState(() => _allRideRequests = []);
//         }
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(_isOnline ? 'You are online' : 'You are offline'),
//             backgroundColor: AppTheme.successColor,
//           ),
//         );
//       } else {
//         setState(() => _isTogglingAvailability = false);
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Failed to update availability'), backgroundColor: AppTheme.errorColor),
//         );
//       }
//     } catch (e) {
//       if (mounted) {
//         setState(() => _isTogglingAvailability = false);
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error: $e'), backgroundColor: AppTheme.errorColor),
//         );
//       }
//     }
//   }
//
//   List<Map<String, dynamic>> get _availableRideRequests {
//     return _allRideRequests
//         .where((ride) {
//           final id = ride['_id']?.toString() ?? ride['id']?.toString();
//           return id != null && !_rejectedRideIds.contains(id);
//         })
//         .toList();
//   }
//
//   List<Map<String, dynamic>> get _displayRideRequests {
//     return _availableRideRequests.take(10).toList();
//   }
//
//   void _rejectRide(String rideId) {
//     setState(() => _rejectedRideIds.add(rideId));
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: IndexedStack(
//         index: _currentIndex,
//         children: [
//           _buildDashboardTab(),
//           const EarningsScreen(),
//           const DriverProfileScreen(),
//         ],
//       ),
//       bottomNavigationBar: BottomNavigationBar(
//         currentIndex: _currentIndex,
//         type: BottomNavigationBarType.fixed,
//         selectedItemColor: AppTheme.primaryColor,
//         unselectedItemColor: AppTheme.textSecondary,
//         onTap: (index) {
//           setState(() {
//             _currentIndex = index;
//           });
//         },
//         items: const [
//           BottomNavigationBarItem(
//             icon: Icon(Icons.dashboard),
//             label: 'Dashboard',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.account_balance_wallet),
//             label: 'Earnings',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.person),
//             label: 'Profile',
//           ),
//         ],
//       ),
//
//       floatingActionButton: Padding(
//         padding: const EdgeInsets.only(bottom: 16.0),
//         child: FloatingActionButton.extended(
//           onPressed: _isTogglingAvailability ? null : _toggleAvailability,
//           label: Text(_isOnline ? 'Go Offline' : 'Go Online'),
//           icon: _isTogglingAvailability
//               ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
//               : Icon(_isOnline ? Icons.toggle_off : Icons.toggle_on),
//         ),
//       ),
//       floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
//
//
//
//       //     floatingActionButton: FloatingActionButton.extended(
//       //       onPressed: () {
//       //         setState(() {
//       //           _isOnline = !_isOnline;
//       //         });
//       //         // TODO: Update availability status via API
//       //       },
//       //       backgroundColor: _isOnline ? AppTheme.successColor : AppTheme.errorColor,
//       //       icon: Icon(_isOnline ? Icons.check_circle : Icons.cancel),
//       //       label: Text(_isOnline ? 'Online' : 'Go Online'),
//       //     ),
//       //     floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
//     );
//   }
//
//   Widget _buildDashboardTab() {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(16.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: [
//           // Status Card
//           Card(
//             color: _isOnline ? AppTheme.successColor : AppTheme.textSecondary,
//             child: Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         _isOnline ? 'You are Online' : 'You are Offline',
//                         style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                           color: Colors.white,
//                         ),
//                       ),
//                       const SizedBox(height: 4),
//                       Text(
//                         _isOnline
//                             ? 'Ready to accept rides'
//                             : 'Tap to go online',
//                         style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                           color: Colors.white70,
//                         ),
//                       ),
//                     ],
//                   ),
//                   Icon(
//                     _isOnline ? Icons.wifi : Icons.wifi_off,
//                     size: 40,
//                     color: Colors.white,
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           const SizedBox(height: 24),
//           // Today's Stats
//           Text(
//             "Today's Stats",
//             style: Theme.of(context).textTheme.titleLarge,
//           ),
//           const SizedBox(height: 12),
//           Row(
//             children: [
//               Expanded(
//                 child: _buildStatCard(
//                   'Rides',
//                   '5',
//                   Icons.directions_car,
//                   AppTheme.primaryColor,
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: _buildStatCard(
//                   'Earnings',
//                   Helpers.formatCurrency(2500),
//                   Icons.account_balance_wallet,
//                   AppTheme.successColor,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 24),
//           // Active Ride Requests - Only show when online
//           if (_isOnline) ...[
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   'Ride Requests',
//                   style: Theme.of(context).textTheme.titleLarge,
//                 ),
//                 if (_displayRideRequests.length > 3)
//                   TextButton(
//                     onPressed: () {
//                       // TODO: Show all requests
//                     },
//                     child: const Text('View All'),
//                   ),
//               ],
//             ),
//             const SizedBox(height: 12),
//             // Show 2-3 ride requests
//             _isLoadingRides
//                 ? const Card(
//                     child: Padding(
//                       padding: EdgeInsets.all(24.0),
//                       child: Center(child: CircularProgressIndicator()),
//                     ),
//                   )
//                 : _displayRideRequests.isEmpty
//                     ? Card(
//                         child: Padding(
//                           padding: const EdgeInsets.all(24.0),
//                           child: Column(
//                             children: [
//                               Icon(
//                                 Icons.directions_car_outlined,
//                                 size: 64,
//                                 color: AppTheme.textSecondary.withOpacity(0.5),
//                               ),
//                               const SizedBox(height: 16),
//                               Text(
//                                 'No ride requests',
//                                 style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                                   color: AppTheme.textSecondary,
//                                 ),
//                               ),
//                               const SizedBox(height: 8),
//                               Text(
//                                 'New ride requests will appear here',
//                                 style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                                   color: AppTheme.textSecondary,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       )
//                 : Column(
//               children: _displayRideRequests.map((ride) {
//                 return Card(
//                   margin: const EdgeInsets.only(bottom: 12),
//                   child: InkWell(
//                     onTap: () {
//                       context.push('/ride-request', extra: {
//                         'ride': ride,
//                       });
//                     },
//                     child: Padding(
//                       padding: const EdgeInsets.all(16.0),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Row(
//                                 children: [
//                                   const CircleAvatar(
//                                     radius: 20,
//                                     backgroundColor: AppTheme.primaryLight,
//                                     child: Icon(Icons.person, size: 20),
//                                   ),
//                                   const SizedBox(width: 12),
//                                   Column(
//                                     crossAxisAlignment: CrossAxisAlignment.start,
//                                     children: [
//                                       Text(
//                                         ride['passengerName'],
//                                         style: Theme.of(context)
//                                             .textTheme
//                                             .titleMedium,
//                                       ),
//                                       Row(
//                                         children: [
//                                           const Icon(Icons.star,
//                                               color: Colors.amber, size: 16),
//                                           const SizedBox(width: 4),
//                                           Text(
//                                             ride['passengerRating'].toString(),
//                                             style: Theme.of(context)
//                                                 .textTheme
//                                                 .bodySmall,
//                                           ),
//                                         ],
//                                       ),
//                                     ],
//                                   ),
//                                 ],
//                               ),
//                               Container(
//                                 padding: const EdgeInsets.symmetric(
//                                   horizontal: 12,
//                                   vertical: 6,
//                                 ),
//                                 decoration: BoxDecoration(
//                                   color: AppTheme.primaryLight.withOpacity(0.3),
//                                   borderRadius: BorderRadius.circular(12),
//                                 ),
//                                 child: Text(
//                                   ride['distance'],
//                                   style: TextStyle(
//                                     color: AppTheme.primaryColor,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                           const SizedBox(height: 12),
//                           Row(
//                             children: [
//                               const Icon(Icons.radio_button_checked,
//                                   color: AppTheme.successColor, size: 16),
//                               const SizedBox(width: 8),
//                               Expanded(
//                                 child: Text(
//                                   ride['pickup'],
//                                   style: Theme.of(context).textTheme.bodyMedium,
//                                 ),
//                               ),
//                             ],
//                           ),
//                           const SizedBox(height: 8),
//                           Row(
//                             children: [
//                               const Icon(Icons.location_on,
//                                   color: AppTheme.primaryColor, size: 16),
//                               const SizedBox(width: 8),
//                               Expanded(
//                                 child: Text(
//                                   ride['destination'],
//                                   style: Theme.of(context).textTheme.bodyMedium,
//                                 ),
//                               ),
//                             ],
//                           ),
//                           const SizedBox(height: 12),
//                           Row(
//                             children: [
//                               Expanded(
//                                 child: OutlinedButton(
//                                   onPressed: () {
//                                     _rejectRide(ride['_id']?.toString() ?? ride['id']?.toString() ?? '');
//                                     ScaffoldMessenger.of(context).showSnackBar(
//                                       const SnackBar(
//                                         content: Text('Ride rejected'),
//                                         backgroundColor: AppTheme.successColor,
//                                         duration: Duration(seconds: 1),
//                                       ),
//                                     );
//                                   },
//                                   child: const Text('Reject'),
//                                 ),
//                               ),
//                               const SizedBox(width: 12),
//                               Expanded(
//                                 child: ElevatedButton(
//                                   onPressed: () async {
//                                     final result = await context.push('/ride-request', extra: {
//                                       'ride': ride,
//                                     });
//
//                                     // If ride was rejected, update the state
//                                     if (result != null && result is Map<String, dynamic>) {
//                                       if (result['rejected'] == true) {
//                                         setState(() {
//                                           _rejectedRideIds.add(result['rideId'] as String);
//                                         });
//                                       }
//                                     }
//                                   },
//                                   child: const Text('Accept'),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 );
//               }).toList(),
//             ),
//           ] else ...[
//             // Show message when offline
//             Card(
//               child: Padding(
//                 padding: const EdgeInsets.all(24.0),
//                 child: Column(
//                   children: [
//                     Icon(
//                       Icons.wifi_off,
//                       size: 64,
//                       color: AppTheme.textSecondary.withOpacity(0.5),
//                     ),
//                     const SizedBox(height: 16),
//                     Text(
//                       'Go Online to See Ride Requests',
//                       style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                         color: AppTheme.textSecondary,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     Text(
//                       'Tap "Go Online" button to start receiving ride requests',
//                       textAlign: TextAlign.center,
//                       style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                         color: AppTheme.textSecondary,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ],
//       ),
//     );
//   }
//
//   Widget _buildStatCard(String label, String value, IconData icon, Color color) {
//     return Card(
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Icon(icon, color: color, size: 32),
//             const SizedBox(height: 12),
//             Text(
//               value,
//               style: Theme.of(context).textTheme.headlineMedium?.copyWith(
//                 fontWeight: FontWeight.bold,
//                 color: color,
//               ),
//             ),
//             const SizedBox(height: 4),
//             Text(
//               label,
//               style: Theme.of(context).textTheme.bodySmall,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//


import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart';
import '../widgets/baneen_map_widget.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/helpers.dart';
import '../../services/driver/driver_service.dart';
import '../../services/location/location_service.dart';
import '../../services/socket/socket_service.dart';
import '../../services/notification/notification_service.dart';
import 'earnings_screen.dart';
import 'driver_profile_screen.dart';

class DriverDashboardScreen extends StatefulWidget {
  const DriverDashboardScreen({super.key});

  @override
  State<DriverDashboardScreen> createState() => _DriverDashboardScreenState();
}

class _DriverDashboardScreenState extends State<DriverDashboardScreen> {
  bool _isOnline = false;
  int _currentIndex = 0;
  bool _isLoadingRides = false;
  bool _isTogglingAvailability = false;

  final DriverService _driverService = DriverService();
  final SocketService _socketService = SocketService();
  final NotificationService _notificationService = NotificationService();
  final LocationService _locationService = LocationService();
  List<Map<String, dynamic>> _allRideRequests = [];
  final Set<String> _rejectedRideIds = {};
  Timer? _refreshTimer;
  Timer? _locationTimer;       // sends GPS every 10s while online
  Position? _currentPosition;  // latest GPS coords

  @override
  void initState() {
    super.initState();
    _notificationService.initialize();
    _loadRideRequestsIfOnline();
    _setupSocketCallbacks();
  }

  void _setupSocketCallbacks() {
    _socketService.onNewRideRequest = (ride) {
      print('[Dashboard] 🚗 Socket new ride request received');
      if (!mounted) return;
      final normalized = _normalizeRide(ride);
      final id = normalized['_id']?.toString() ?? '';
      // Avoid duplicates
      final exists = _allRideRequests.any((r) => r['_id']?.toString() == id);
      if (!exists) {
        setState(() => _allRideRequests.insert(0, normalized));
        // Show local notification
        _notificationService.showRideRequestNotification(
          passengerName: normalized['passengerName'] ?? 'Passenger',
          pickupLocation: normalized['pickup'] ?? '',
        );
      }
    };

    _socketService.onRideCancelled = (data) {
      if (!mounted) return;
      final cancelledId = data['rideId']?.toString() ?? data['_id']?.toString();
      if (cancelledId != null) {
        setState(() {
          _allRideRequests.removeWhere((r) => r['_id']?.toString() == cancelledId);
        });
      }
    };

    _socketService.onConnected = () {
      print('[Dashboard] ✅ Socket connected');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Live ride requests enabled ✅'),
            backgroundColor: AppTheme.successColor,
            duration: Duration(seconds: 2),
          ),
        );
      }
    };

    _socketService.onDisconnected = () {
      print('[Dashboard] Socket disconnected');
    };

    _socketService.onError = (msg) {
      print('[Dashboard] Socket error: $msg');
    };
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _locationTimer?.cancel();
    // Don't disconnect socket on dispose — only disconnect on explicit go-offline
    super.dispose();
  }

  /// Normalize API ride to display shape.
  /// Backend pendingRides format:
  /// { rideId, pickup: {address, coordinates}, dropoff: {address, coordinates},
  ///   fare, distance, passenger: {name, rating}, driverDistance: {text} }
  Map<String, dynamic> _normalizeRide(Map<String, dynamic> r) {
    final id = r['rideId']?.toString()
        ?? r['_id']?.toString()
        ?? r['id']?.toString()
        ?? '';

    // Extract pickup address — could be nested or flat
    String pickupAddr = '—';
    final p = r['pickup'];
    if (p is Map) {
      pickupAddr = p['address']?.toString() ?? '—';
    } else if (p is String) {
      pickupAddr = p;
    } else if (r['pickupLocation'] is String) {
      pickupAddr = r['pickupLocation'];
    }

    // Extract dropoff address — could be nested or flat
    String dropoffAddr = '—';
    final d = r['dropoff'];
    if (d is Map) {
      dropoffAddr = d['address']?.toString() ?? '—';
    } else if (d is String) {
      dropoffAddr = d;
    } else if (r['dropoffLocation'] is String) {
      dropoffAddr = r['dropoffLocation'];
    }

    // Distance — prefer human readable text
    String distance = '—';
    final dd = r['driverDistance'];
    if (dd is Map) {
      distance = dd['text']?.toString() ?? '—';
    } else if (r['distanceText'] is String) {
      distance = r['distanceText'];
    } else if (r['distance'] != null) {
      final km = double.tryParse(r['distance'].toString());
      distance = km != null ? '${(km / 1000).toStringAsFixed(1)} km' : r['distance'].toString();
    }

    // Fare as double
    double fare = 0.0;
    final f = r['fare'] ?? r['estimatedFare'];
    if (f is double) fare = f;
    else if (f is int) fare = f.toDouble();
    else if (f != null) fare = double.tryParse(f.toString()) ?? 0.0;

    // Passenger rating as double
    double rating = 0.0;
    final rt = r['passenger']?['rating'] ?? r['passengerRating'];
    if (rt is double) rating = rt;
    else if (rt is int) rating = rt.toDouble();
    else if (rt != null) rating = double.tryParse(rt.toString()) ?? 0.0;

    return {
      '_id': id,
      'id': id,
      'rideId': id,
      'passengerName': r['passenger']?['name']?.toString() ?? r['passengerName']?.toString() ?? 'Passenger',
      'passengerRating': rating,
      'pickup': pickupAddr,
      'destination': dropoffAddr,
      'distance': distance,
      'fare': fare,
      'paymentMethod': r['paymentMethod']?.toString() ?? 'cash',
      // Keep original for ride_request_screen
      'passenger': r['passenger'],
      'driverDistance': r['driverDistance'],
      'driverETA': r['driverETA'],
    };
  }

  Future<void> _loadRideRequestsIfOnline() async {
    if (!_isOnline) return;
    setState(() => _isLoadingRides = true);
    try {
      final list = await _driverService.getRideRequests();
      if (mounted) {
        setState(() {
          _allRideRequests = list.map(_normalizeRide).toList();
          _isLoadingRides = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingRides = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load requests: $e'), backgroundColor: AppTheme.errorColor),
        );
      }
    }
  }

  // ─── GPS Methods ────────────────────────────────────────────────

  /// Request GPS permission and get current location.
  Future<Position?> _getGPSLocation() async {
    try {
      // Check if GPS is enabled on device
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please enable GPS/Location on your device'),
              backgroundColor: AppTheme.errorColor,
              duration: Duration(seconds: 3),
            ),
          );
        }
        return null;
      }

      // Request permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Location permission is required to go online'),
                backgroundColor: AppTheme.errorColor,
              ),
            );
          }
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Location permission permanently denied. Please enable in Settings.'),
              backgroundColor: AppTheme.errorColor,
              action: SnackBarAction(
                label: 'Settings',
                textColor: Colors.white,
                onPressed: () => Geolocator.openAppSettings(),
              ),
            ),
          );
        }
        return null;
      }

      // Get position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      print('[Dashboard] GPS: ${position.latitude}, ${position.longitude}');
      return position;
    } catch (e) {
      print('[Dashboard] GPS error: $e');
      return null;
    }
  }

  /// Start sending location every 10 seconds while online.
  void _startLocationUpdates({String? rideId}) {
    _locationTimer?.cancel();
    _locationTimer = Timer.periodic(const Duration(seconds: 10), (_) async {
      if (!_isOnline || !mounted) return;
      try {
        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        setState(() => _currentPosition = position);
        // Send via socket always (real-time)
        _socketService.updateLocation(position.latitude, position.longitude);
        // Send to REST API only if active ride exists
        if (rideId != null && rideId.isNotEmpty) {
          await _driverService.updateLocation(
            latitude: position.latitude,
            longitude: position.longitude,
            rideId: rideId,
          );
        }
      } catch (e) {
        print('[Dashboard] Location update error: $e');
      }
    });
  }

  /// Stop location updates when going offline.
  void _stopLocationUpdates() {
    _locationTimer?.cancel();
    _locationTimer = null;
  }

  Future<void> _toggleAvailability() async {
    setState(() => _isTogglingAvailability = true);
    final goingOnline = !_isOnline;
    try {
      // Get GPS first so we can send it with the online request
      Position? prePosition;
      if (goingOnline) {
        prePosition = await _getGPSLocation();
      }

      final ok = await _driverService.updateAvailability(
        isOnline: goingOnline,
        latitude: prePosition?.latitude,
        longitude: prePosition?.longitude,
      );
      if (!mounted) return;
      if (ok) {
        setState(() {
          _isOnline = goingOnline;
          _isTogglingAvailability = false;
        });

        if (goingOnline) {
          // Use the GPS we already got before the API call
          if (prePosition != null) {
            setState(() => _currentPosition = prePosition);
            _socketService.updateLocation(prePosition!.latitude, prePosition!.longitude);
          }
          // Connect socket + start continuous location updates
          await _socketService.connect();
          _startLocationUpdates();
          _loadRideRequestsIfOnline();
          _refreshTimer?.cancel();
          _refreshTimer = Timer.periodic(
            const Duration(seconds: 15),
                (_) => _loadRideRequestsIfOnline(),
          );
        } else {
          // Going OFFLINE: stop location + disconnect socket + stop polling
          _stopLocationUpdates();
          _socketService.disconnect();
          _refreshTimer?.cancel();
          setState(() => _allRideRequests = []);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(goingOnline ? '🟢 You are Online' : '🔴 You are Offline'),
            backgroundColor: goingOnline ? AppTheme.successColor : AppTheme.textSecondary,
          ),
        );
      } else {
        setState(() => _isTogglingAvailability = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update availability'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isTogglingAvailability = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppTheme.errorColor),
        );
      }
    }
  }

  List<Map<String, dynamic>> get _availableRideRequests {
    return _allRideRequests
        .where((ride) {
      final id = ride['_id']?.toString() ?? ride['id']?.toString();
      return id != null && !_rejectedRideIds.contains(id);
    })
        .toList();
  }

  List<Map<String, dynamic>> get _displayRideRequests {
    return _availableRideRequests.take(10).toList();
  }

  void _rejectRide(String rideId) {
    setState(() => _rejectedRideIds.add(rideId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildDashboardTab(),
          const EarningsScreen(),
          const DriverProfileScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: AppTheme.textSecondary,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: 'Earnings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),

      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: FloatingActionButton.extended(
          onPressed: _isTogglingAvailability ? null : _toggleAvailability,
          label: Text(_isOnline ? 'Go Offline' : 'Go Online'),
          icon: _isTogglingAvailability
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : Icon(_isOnline ? Icons.toggle_off : Icons.toggle_on),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,



      //     floatingActionButton: FloatingActionButton.extended(
      //       onPressed: () {
      //         setState(() {
      //           _isOnline = !_isOnline;
      //         });
      //         // TODO: Update availability status via API
      //       },
      //       backgroundColor: _isOnline ? AppTheme.successColor : AppTheme.errorColor,
      //       icon: Icon(_isOnline ? Icons.check_circle : Icons.cancel),
      //       label: Text(_isOnline ? 'Online' : 'Go Online'),
      //     ),
      //     floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildDashboardTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Status Card
          Card(
            color: _isOnline ? AppTheme.successColor : AppTheme.textSecondary,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isOnline ? 'You are Online' : 'You are Offline',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _isOnline
                            ? 'Ready to accept rides'
                            : 'Tap to go online',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                  Icon(
                    _isOnline ? Icons.wifi : Icons.wifi_off,
                    size: 40,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Driver Location Map
          if (_isOnline && _currentPosition != null)
            BaneenMapWidget(
              height: 200,
              driverLat: _currentPosition!.latitude,
              driverLng: _currentPosition!.longitude,
              showMyLocation: false,
              showRoute: false,
            ),
          if (_isOnline && _currentPosition != null)
            const SizedBox(height: 12),
          const SizedBox(height: 12),
          // Today's Stats
          Text(
            "Today's Stats",
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Rides',
                  '5',
                  Icons.directions_car,
                  AppTheme.primaryColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Earnings',
                  Helpers.formatCurrency(2500),
                  Icons.account_balance_wallet,
                  AppTheme.successColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Active Ride Requests - Only show when online
          if (_isOnline) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Ride Requests',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                if (_displayRideRequests.length > 3)
                  TextButton(
                    onPressed: () {
                      // TODO: Show all requests
                    },
                    child: const Text('View All'),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            // Show 2-3 ride requests
            _isLoadingRides
                ? const Card(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Center(child: CircularProgressIndicator()),
              ),
            )
                : _displayRideRequests.isEmpty
                ? Card(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Icon(
                      Icons.directions_car_outlined,
                      size: 64,
                      color: AppTheme.textSecondary.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No ride requests',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'New ride requests will appear here',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            )
                : Column(
              children: _displayRideRequests.map((ride) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    onTap: () {
                      context.push('/ride-request', extra: {
                        'ride': ride,
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const CircleAvatar(
                                    radius: 20,
                                    backgroundColor: AppTheme.primaryLight,
                                    child: Icon(Icons.person, size: 20),
                                  ),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        ride['passengerName'],
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium,
                                      ),
                                      Row(
                                        children: [
                                          const Icon(Icons.star,
                                              color: Colors.amber, size: 16),
                                          const SizedBox(width: 4),
                                          Text(
                                            ride['passengerRating'].toString(),
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryLight.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  ride['distance'],
                                  style: TextStyle(
                                    color: AppTheme.primaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Icon(Icons.radio_button_checked,
                                  color: AppTheme.successColor, size: 16),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  ride['pickup'],
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.location_on,
                                  color: AppTheme.primaryColor, size: 16),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  ride['destination'],
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          // Fare row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.payments_outlined,
                                      color: AppTheme.successColor, size: 16),
                                  const SizedBox(width: 6),
                                  Text(
                                    'PKR ${(ride['fare'] as double? ?? 0.0).toStringAsFixed(0)}',
                                    style: TextStyle(
                                      color: AppTheme.successColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  const Icon(Icons.access_time,
                                      color: AppTheme.textSecondary, size: 14),
                                  const SizedBox(width: 4),
                                  Text(
                                    ride['paymentMethod']?.toString().toUpperCase() ?? 'CASH',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppTheme.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () async {
                                    final rideId = ride['_id']?.toString() ?? ride['id']?.toString() ?? '';
                                    // Call reject API
                                    await _driverService.rejectRide(rideId);
                                    _rejectRide(rideId);
                                    if (mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Ride rejected'),
                                          backgroundColor: AppTheme.errorColor,
                                          duration: Duration(seconds: 1),
                                        ),
                                      );
                                    }
                                  },
                                  child: const Text('Reject'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () async {
                                    final result = await context.push('/ride-request', extra: {
                                      'ride': ride,
                                    });

                                    // If ride was rejected, update the state
                                    if (result != null && result is Map<String, dynamic>) {
                                      if (result['rejected'] == true) {
                                        setState(() {
                                          _rejectedRideIds.add(result['rideId'] as String);
                                        });
                                      }
                                    }
                                  },
                                  child: const Text('Accept'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ] else ...[
            // Show message when offline
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Icon(
                      Icons.wifi_off,
                      size: 64,
                      color: AppTheme.textSecondary.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Go Online to See Ride Requests',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap "Go Online" button to start receiving ride requests',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 12),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}