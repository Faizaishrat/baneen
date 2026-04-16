// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:provider/provider.dart';
// import '../../controller/ride_controller.dart';
// import '../../core/theme/app_theme.dart';
// import '../../core/utils/helpers.dart';
// import '../shared/cancel_ride_dialog.dart';
//
// class RideRequestScreen extends StatefulWidget {
//   final Map<String, dynamic>? ride;
//
//   const RideRequestScreen({
//     super.key,
//     this.ride,
//   });
//
//   @override
//   State<RideRequestScreen> createState() => _RideRequestScreenState();
// }
//
// class _RideRequestScreenState extends State<RideRequestScreen> {
//   bool _isLoading = false;
//
//   String? get _rideId {
//     final r = widget.ride;
//     if (r == null) return null;
//     return r['_id']?.toString() ?? r['id']?.toString();
//   }
//
//   Map<String, dynamic> get _rideData {
//     final r = widget.ride;
//     if (r == null) {
//       return {
//         'id': '1',
//         'passengerName': 'Passenger Name',
//         'passengerRating': 4.9,
//         'pickup': '123 Main Street, Islamabad',
//         'destination': '456 Park Road, Rawalpindi',
//         'distance': '5.2 km',
//         'fare': 250.0,
//       };
//     }
//     return {
//       ...r,
//       'passengerName': r['passenger']?['name'] ?? r['passengerName'] ?? 'Passenger',
//       'pickup': r['pickupLocation'] ?? r['pickup'] ?? '—',
//       'destination': r['dropoffLocation'] ?? r['destination'] ?? '—',
//       'distance': r['distance']?.toString() ?? '—',
//       'fare': r['fare'] ?? r['estimatedFare'] ?? 0,
//     };
//   }
//
//   Future<void> _acceptRide() async {
//     final rideId = _rideId;
//     if (rideId == null || rideId.isEmpty) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Invalid ride. Missing ride ID.'),
//             backgroundColor: AppTheme.errorColor,
//           ),
//         );
//       }
//       return;
//     }
//     setState(() => _isLoading = true);
//     try {
//       final provider = Provider.of<RideProvider>(context, listen: false);
//       final ok = await provider.acceptRide(rideId);
//       if (!mounted) return;
//       if (ok) {
//         context.push('/driver-active-ride', extra: {
//           'rideId': rideId,
//           'ride': widget.ride,
//         });
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(provider.errorMessage ?? 'Failed to accept ride'),
//             backgroundColor: AppTheme.errorColor,
//           ),
//         );
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Failed to accept ride: $e'),
//             backgroundColor: AppTheme.errorColor,
//           ),
//         );
//       }
//     } finally {
//       if (mounted) setState(() => _isLoading = false);
//     }
//   }
//
//   Future<void> _rejectRide() async {
//     final cancellationReason = await showDialog<String>(
//       context: context,
//       builder: (context) => CancelRideDialog(
//         isDriver: true,
//         rideStatus: null,
//       ),
//     );
//
//     if (cancellationReason == null) return;
//
//     final rideId = _rideId;
//     if (rideId == null || rideId.isEmpty) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Invalid ride. Missing ride ID.'),
//             backgroundColor: AppTheme.errorColor,
//           ),
//         );
//       }
//       return;
//     }
//
//     setState(() => _isLoading = true);
//     try {
//       final provider = Provider.of<RideProvider>(context, listen: false);
//       final ok = await provider.cancelRide(rideId, reason: cancellationReason);
//       if (!mounted) return;
//       if (ok) {
//         context.pop({'rejected': true, 'rideId': rideId});
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(provider.errorMessage ?? 'Failed to cancel ride'),
//             backgroundColor: AppTheme.errorColor,
//           ),
//         );
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Failed to reject ride: $e'),
//             backgroundColor: AppTheme.errorColor,
//           ),
//         );
//       }
//     } finally {
//       if (mounted) setState(() => _isLoading = false);
//     }
//   }
//
//   void _triggerSOS() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Emergency SOS'),
//         content: const Text(
//           'Are you sure you want to trigger an emergency alert?',
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel'),
//           ),
//           ElevatedButton(
//             onPressed: () async {
//               Navigator.pop(context);
//               // TODO: Implement SOS functionality
//               if (mounted) {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(
//                     content: Text('SOS alert sent'),
//                     backgroundColor: AppTheme.sosColor,
//                     duration: Duration(seconds: 3),
//                   ),
//                 );
//               }
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: AppTheme.sosColor,
//             ),
//             child: const Text('Send SOS'),
//           ),
//         ],
//       ),
//     );
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
//         title: const Text('Ride Request'),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             Positioned(
//               top: 0,
//               left: 0,
//               right: 0,
//               height: 300, // adjust height as needed
//               child: ClipRRect(
//                 child: Image.asset(
//                   'assets/images/googlemap.jpeg', // <-- your map image path
//                   fit: BoxFit.cover,
//                 ),
//               ),
//             ),
//
//             const SizedBox(height: 24),
//             // Passenger Info Card
//             Card(
//               child: Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Column(
//                   children: [
//                     const CircleAvatar(
//                       radius: 40,
//                       backgroundColor: AppTheme.primaryLight,
//                       child: Icon(Icons.person, size: 40),
//                     ),
//                     const SizedBox(height: 12),
//                     Text(
//                       _rideData['passengerName'],
//                       style: Theme.of(context).textTheme.titleLarge,
//                     ),
//                     const SizedBox(height: 4),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         const Icon(Icons.star, color: Colors.amber, size: 20),
//                         const SizedBox(width: 4),
//                         Text(
//                           _rideData['passengerRating'].toString(),
//                           style: Theme.of(context).textTheme.bodyLarge,
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             const SizedBox(height: 24),
//             // Ride Details
//             Card(
//               child: Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'Ride Details',
//                       style: Theme.of(context).textTheme.titleLarge,
//                     ),
//                     const SizedBox(height: 16),
//                     Row(
//                       children: [
//                         const Icon(Icons.radio_button_checked,
//                             color: AppTheme.successColor),
//                         const SizedBox(width: 12),
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 'Pickup Location',
//                                 style: Theme.of(context).textTheme.bodySmall,
//                               ),
//                               Text(
//                                 _rideData['pickup'],
//                                 style: Theme.of(context).textTheme.bodyLarge,
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 16),
//                     Row(
//                       children: [
//                         const Icon(Icons.location_on,
//                             color: AppTheme.primaryColor),
//                         const SizedBox(width: 12),
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 'Destination',
//                                 style: Theme.of(context).textTheme.bodySmall,
//                               ),
//                               Text(
//                                 _rideData['destination'],
//                                 style: Theme.of(context).textTheme.bodyLarge,
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                     const Divider(height: 24),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               'Distance',
//                               style: Theme.of(context).textTheme.bodySmall,
//                             ),
//                             Text(
//                               _rideData['distance'],
//                               style: Theme.of(context).textTheme.bodyLarge,
//                             ),
//                           ],
//                         ),
//                         Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               'Estimated Fare',
//                               style: Theme.of(context).textTheme.bodySmall,
//                             ),
//                             Text(
//                               Helpers.formatCurrency(_rideData['fare']),
//                               style: Theme.of(context)
//                                   .textTheme
//                                   .bodyLarge
//                                   ?.copyWith(
//                                 fontWeight: FontWeight.bold,
//                                 color: AppTheme.primaryColor,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             const SizedBox(height: 32),
//             // Reject Button
//             SizedBox(
//               width: double.infinity,
//               child: OutlinedButton(
//                 onPressed: _isLoading ? null : _rejectRide,
//                 style: OutlinedButton.styleFrom(
//                   padding: const EdgeInsets.symmetric(vertical: 16),
//                 ),
//                 child: const Text('Reject'),
//               ),
//             ),
//             const SizedBox(height: 12),
//             // Accept Ride and SOS Emergency in same line
//             Row(
//               children: [
//                 Expanded(
//                   child: ElevatedButton(
//                     onPressed: _isLoading ? null : _acceptRide,
//                     style: ElevatedButton.styleFrom(
//                       padding: const EdgeInsets.symmetric(vertical: 16),
//                     ),
//                     child: _isLoading
//                         ? const SizedBox(
//                       height: 20,
//                       width: 20,
//                       child: CircularProgressIndicator(
//                         strokeWidth: 2,
//                         valueColor:
//                         AlwaysStoppedAnimation<Color>(Colors.white),
//                       ),
//                     )
//                         : const Text('Accept Ride'),
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: ElevatedButton.icon(
//                     onPressed: _triggerSOS,
//                     icon: const Icon(Icons.warning),
//                     label: const Text('SOS Emergency'),
//                     style: ElevatedButton.styleFrom(
//                       padding: const EdgeInsets.symmetric(vertical: 16),
//                       backgroundColor: AppTheme.sosColor,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//


import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../controller/ride_controller.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/helpers.dart';
import '../../services/driver/driver_service.dart';
import '../shared/cancel_ride_dialog.dart';

class RideRequestScreen extends StatefulWidget {
  final Map<String, dynamic>? ride;

  const RideRequestScreen({
    super.key,
    this.ride,
  });

  @override
  State<RideRequestScreen> createState() => _RideRequestScreenState();
}

class _RideRequestScreenState extends State<RideRequestScreen> {
  bool _isLoading = false;

  String? get _rideId {
    final r = widget.ride;
    if (r == null) return null;
    // Backend returns rideId in pendingRides list
    return r['rideId']?.toString()
        ?? r['_id']?.toString()
        ?? r['id']?.toString();
  }

  Map<String, dynamic> get _rideData {
    final r = widget.ride;
    if (r == null) {
      return {
        'id': '1',
        'passengerName': 'Passenger Name',
        'passengerRating': 4.9,
        'pickup': '123 Main Street, Islamabad',
        'destination': '456 Park Road, Rawalpindi',
        'distance': '5.2 km',
        'fare': 250.0,
      };
    }
    // Parse fare safely as double (backend returns int)
    double parseFare(dynamic val) {
      if (val == null) return 0.0;
      if (val is double) return val;
      if (val is int) return val.toDouble();
      return double.tryParse(val.toString()) ?? 0.0;
    }

    // Get pickup/destination from nested or flat structure
    final pickup = r['pickupLocation'] as String?
        ?? r['pickup']?['address'] as String?
        ?? r['pickup'] as String?
        ?? '—';
    final destination = r['dropoffLocation'] as String?
        ?? r['dropoff']?['address'] as String?
        ?? r['destination'] as String?
        ?? '—';
    final fare = parseFare(r['fare'] ?? r['estimatedFare']);
    final passengerRating = parseFare(r['passenger']?['rating'] ?? r['passengerRating'] ?? 0);

    // Don't spread ...r — backend has nested Maps that cause type errors
    // Only include the fields we actually need
    return {
      '_id': r['_id']?.toString() ?? r['id']?.toString() ?? r['rideId']?.toString() ?? '',
      'id': r['rideId']?.toString() ?? r['_id']?.toString() ?? r['id']?.toString() ?? '',
      'rideId': r['rideId']?.toString() ?? r['_id']?.toString() ?? r['id']?.toString() ?? '',
      'passengerName': r['passenger']?['name'] ?? r['passengerName'] ?? 'Passenger',
      'passengerRating': passengerRating,
      'pickup': pickup,
      'destination': destination,
      'distance': r['distanceText'] ?? r['driverDistance']?['text'] ?? r['distance']?.toString() ?? '—',
      'fare': fare,
      'paymentMethod': r['paymentMethod']?.toString() ?? 'cash',
      'duration': r['driverETA']?['text'] ?? r['durationText'] ?? r['duration']?.toString() ?? '—',
    };
  }

  Future<void> _acceptRide() async {
    final rideId = _rideId;
    if (rideId == null || rideId.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid ride. Missing ride ID.'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
      return;
    }
    setState(() => _isLoading = true);
    try {
      final provider = Provider.of<RideProvider>(context, listen: false);
      final ok = await provider.acceptRide(rideId);
      if (!mounted) return;
      if (ok) {
        context.push('/driver-active-ride', extra: {
          'rideId': rideId,
          'ride': widget.ride,
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.errorMessage ?? 'Failed to accept ride'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to accept ride: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _rejectRide() async {
    final cancellationReason = await showDialog<String>(
      context: context,
      builder: (context) => CancelRideDialog(
        isDriver: true,
        rideStatus: null,
      ),
    );

    if (cancellationReason == null) return;

    final rideId = _rideId;
    if (rideId == null || rideId.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid ride. Missing ride ID.'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
      return;
    }

    setState(() => _isLoading = true);
    try {
      // Use DriverService for reject — POST /matching/ride-response/:rideId
      final driverService = DriverService();
      final ok = await driverService.rejectRide(rideId);
      if (!mounted) return;
      if (ok) {
        context.pop({'rejected': true, 'rideId': rideId});
      } else {
        // Even if API fails, still pop (local rejection)
        context.pop({'rejected': true, 'rideId': rideId});
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to reject ride'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to reject ride: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _triggerSOS() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Emergency SOS'),
        content: const Text(
          'Are you sure you want to trigger an emergency alert?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              // TODO: Implement SOS functionality
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('SOS alert sent'),
                    backgroundColor: AppTheme.sosColor,
                    duration: Duration(seconds: 3),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.sosColor,
            ),
            child: const Text('Send SOS'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text('Ride Request'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 300, // adjust height as needed
              child: ClipRRect(
                child: Image.asset(
                  'assets/images/googlemap.jpeg', // <-- your map image path
                  fit: BoxFit.cover,
                ),
              ),
            ),

            const SizedBox(height: 24),
            // Passenger Info Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 40,
                      backgroundColor: AppTheme.primaryLight,
                      child: Icon(Icons.person, size: 40),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _rideData['passengerName'],
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 20),
                        const SizedBox(width: 4),
                        Text(
                          _rideData['passengerRating'].toString(),
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Ride Details
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ride Details',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Icon(Icons.radio_button_checked,
                            color: AppTheme.successColor),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Pickup Location',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              Text(
                                _rideData['pickup'],
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Icon(Icons.location_on,
                            color: AppTheme.primaryColor),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Destination',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              Text(
                                _rideData['destination'],
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Distance',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            Text(
                              _rideData['distance'],
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Estimated Fare',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            Text(
                              Helpers.formatCurrency(_rideData['fare']),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            // Reject Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _isLoading ? null : _rejectRide,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Reject'),
              ),
            ),
            const SizedBox(height: 12),
            // Accept Ride and SOS Emergency in same line
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _acceptRide,
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
                        : const Text('Accept Ride'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _triggerSOS,
                    icon: const Icon(Icons.warning),
                    label: const Text('SOS Emergency'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: AppTheme.sosColor,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
