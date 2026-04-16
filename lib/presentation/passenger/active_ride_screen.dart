import 'dart:async';
import 'package:flutter/material.dart';
import '../widgets/baneen_map_widget.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../controller/ride_controller.dart';
import '../../core/theme/app_theme.dart';
import '../../services/location/location_service.dart';
import '../../services/storage/storage_service.dart';
import '../shared/chat_screen.dart';
import '../shared/cancel_ride_dialog.dart';
import 'call_screen.dart';

class ActiveRideScreen extends StatefulWidget {
  final String? rideId;
  final Map<String, dynamic>? ride;

  const ActiveRideScreen({super.key, this.rideId, this.ride});

  @override
  State<ActiveRideScreen> createState() => _ActiveRideScreenState();
}

class _ActiveRideScreenState extends State<ActiveRideScreen> {
  Map<String, dynamic>? _ride;
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    _ride = widget.ride;
    if (_isWaitingForDriver && widget.rideId != null) _startPolling();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  String get _rideStatus {
    final r = _ride ?? widget.ride;
    if (r == null) return 'accepted';
    final s = r['status'] ?? r['ride']?['status'];
    return s?.toString() ?? 'accepted';
  }

  bool get _isWaitingForDriver =>
      _rideStatus == 'pending' || _rideStatus == 'requested';

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 2), (_) async {
      if (!mounted || widget.rideId == null) return;
      final provider = Provider.of<RideProvider>(context, listen: false);
      final details = await provider.getRideDetails(widget.rideId!);
      if (!mounted) return;
      final status = details?['status'] ?? details?['ride']?['status']?.toString();
      if (status == 'cancelled') {
        _pollTimer?.cancel();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Ride was cancelled'),
              backgroundColor: AppTheme.errorColor,
            ),
          );
          context.pop();
        }
        return;
      }
      if (status == 'accepted' || status == 'in_progress' || status == 'completed') {
        _pollTimer?.cancel();
        setState(() {
          _ride = details?['ride'] ?? details;
        });
      }
    });
  }

  bool _showWhatsAppIcon = false;
  final LocationService _locationService = LocationService();

  void _triggerSOS() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Emergency SOS'),
        content: const Text(
          'Are you sure you want to trigger an emergency alert? This will notify emergency contacts and admin.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              // Get favorite contact name
              final storageService = await getStorageService();
              final favoriteContactName = storageService.getFavoriteContactName() ?? 'Emergency Contact';

              // TODO: Implement SOS functionality (send to backend, call emergency number, etc.)

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Message sent to $favoriteContactName'),
                    backgroundColor: AppTheme.sosColor,
                    duration: const Duration(seconds: 3),
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

  Future<void> _cancelRide() async {
    final cancellationReason = await showDialog<String>(
      context: context,
      builder: (context) => CancelRideDialog(
        isDriver: false,
        rideStatus: _rideStatus,
      ),
    );

    if (cancellationReason != null && mounted) {
      if (widget.rideId != null) {
        await Provider.of<RideProvider>(context, listen: false)
            .cancelRide(widget.rideId!, reason: cancellationReason);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ride cancelled successfully'),
            backgroundColor: AppTheme.successColor,
          ),
        );
        context.pop();
      }
    }
  }

  void _callDriver() {
    // Navigate to in-app call screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CallScreen(
          userId: 'driver_123',
          userName: 'Driver Name',
          userAvatar: null,
          phoneNumber: '+92 300 1234567',
        ),
      ),
    );
  }

  void _chatWithDriver() {
    // Navigate to chat screen with driver information
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ChatScreen(
          userId: 'driver_123',
          userName: 'Driver Name',
          userAvatar: null,
        ),
      ),
    );
  }

  Future<void> _shareViaWhatsApp() async {
    try {
      // Get current location
      final position = await _locationService.getCurrentPosition();

      // Create Google Maps location link
      final locationLink = 'https://www.google.com/maps?q=${position.latitude},${position.longitude}';

      // Create ride details message with location link
      final message = '''
🚗 Ride Details

Driver: Driver Name
Vehicle: Toyota Corolla (ABC-123)
Pickup: Current Location
Destination: Destination Location
ETA: 5 minutes

📍 My Location: $locationLink

Track my ride in real-time.
''';

      // Encode the message for URL
      final encodedMessage = Uri.encodeComponent(message);

      // WhatsApp URL format: whatsapp://send?text=message
      // Using wa.me without phone number opens contact picker
      final whatsappUrl = Uri.parse('https://wa.me/?text=$encodedMessage');

      if (await canLaunchUrl(whatsappUrl)) {
        await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('WhatsApp is not installed'),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Map View
          Container(
            height: double.infinity,
            color: AppTheme.backgroundColor,
            child: const Center(
              child: Icon(
                Icons.map,
                size: 100,
                color: AppTheme.textSecondary,
              ),
            ),
          ),

          // Real Live Map
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 520,
            child: BaneenMapWidget(
              height: 520,
              showMyLocation: true,
              showRoute: true,
              pickupLat: widget.ride?['pickupLat'] as double?,
              pickupLng: widget.ride?['pickupLng'] as double?,
              dropoffLat: widget.ride?['dropoffLat'] as double?,
              dropoffLng: widget.ride?['dropoffLng'] as double?,
            ),
          ),
          // Bottom card: Waiting for driver OR Driver info
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: _isWaitingForDriver
                        ? Column(
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: 16),
                        Text(
                          'Finding a driver',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Your request is visible to nearby drivers. You will see their location when one accepts.',
                          style: Theme.of(context).textTheme.bodySmall,
                          textAlign: TextAlign.center,
                        ),
                        if (widget.rideId != null) ...[
                          const SizedBox(height: 12),
                          Text(
                            'Ride ID: ${widget.rideId}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                        const SizedBox(height: 16),
                        OutlinedButton(
                          onPressed: _cancelRide,
                          child: const Text('Cancel request'),
                        ),
                      ],
                    )
                        : Column(
                      children: [
                        // Driver Details
                        Row(
                          children: [
                            const CircleAvatar(
                              radius: 30,
                              backgroundColor: AppTheme.primaryLight,
                              child: Icon(Icons.person, size: 30),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Driver Name',
                                    style: Theme.of(context).textTheme.titleLarge,
                                  ),
                                  Row(
                                    children: [
                                      const Icon(Icons.star,
                                          color: Colors.amber, size: 16),
                                      const SizedBox(width: 4),
                                      Text(
                                        '4.8',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.phone),
                              color: AppTheme.primaryColor,
                              onPressed: _callDriver,
                              tooltip: 'Call Driver',
                            ),
                            IconButton(
                              icon: const Icon(Icons.chat_bubble_outline),
                              color: AppTheme.primaryColor,
                              onPressed: _chatWithDriver,
                              tooltip: 'Chat with Driver',
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Vehicle Info
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.backgroundColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.directions_car,
                                  color: AppTheme.primaryColor),
                              const SizedBox(width: 12),
                              const Text('Toyota Corolla'),
                              const Spacer(),
                              const Text('ABC-123'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        // ETA
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.access_time,
                                color: AppTheme.primaryColor),
                            const SizedBox(width: 8),
                            Text(
                              'ETA: 5 minutes',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Action Buttons
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _cancelRide,
                                icon: const Icon(Icons.cancel),
                                label: const Text('Cancel'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _triggerSOS,
                                icon: const Icon(Icons.warning),
                                label: const Text('SOS'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.sosColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Share Ride Button
                        TextButton.icon(
                          onPressed: () {
                            setState(() {
                              _showWhatsAppIcon = !_showWhatsAppIcon;
                            });
                          },
                          icon: const Icon(Icons.share),
                          label: const Text('Share Ride Details'),
                        ),
                        // WhatsApp Icon (shown when share is clicked)
                        if (_showWhatsAppIcon)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                InkWell(
                                  onTap: _shareViaWhatsApp,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF25D366), // WhatsApp green
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: const [
                                        Icon(
                                          Icons.chat,
                                          color: Colors.white,
                                          size: 24,
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          'Share via WhatsApp',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}





// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:provider/provider.dart';
// import 'package:url_launcher/url_launcher.dart';
// import '../../controller/ride_controller.dart';
// import '../../core/theme/app_theme.dart';
// import '../../services/location/location_service.dart';
// import '../../services/storage/storage_service.dart';
// import '../shared/chat_screen.dart';
// import '../shared/cancel_ride_dialog.dart';
// import 'call_screen.dart';
//
// class ActiveRideScreen extends StatefulWidget {
//   final String? rideId;
//   final Map<String, dynamic>? ride;
//
//   const ActiveRideScreen({super.key, this.rideId, this.ride});
//
//   @override
//   State<ActiveRideScreen> createState() => _ActiveRideScreenState();
// }
//
// class _ActiveRideScreenState extends State<ActiveRideScreen> {
//   Map<String, dynamic>? _ride;
//   Timer? _pollTimer;
//
//   @override
//   void initState() {
//     super.initState();
//     _ride = widget.ride;
//     if (_isWaitingForDriver && widget.rideId != null) _startPolling();
//   }
//
//   @override
//   void dispose() {
//     _pollTimer?.cancel();
//     super.dispose();
//   }
//
//   String get _rideStatus {
//     final r = _ride ?? widget.ride;
//     if (r == null) return 'accepted';
//     final s = r['status'] ?? r['ride']?['status'];
//     return s?.toString() ?? 'accepted';
//   }
//
//   bool get _isWaitingForDriver =>
//       _rideStatus == 'pending' || _rideStatus == 'requested';
//
//   void _startPolling() {
//     _pollTimer?.cancel();
//     _pollTimer = Timer.periodic(const Duration(seconds: 2), (_) async {
//       if (!mounted || widget.rideId == null) return;
//       final provider = Provider.of<RideProvider>(context, listen: false);
//       final details = await provider.getRideDetails(widget.rideId!);
//       if (!mounted) return;
//       final status = details?['status'] ?? details?['ride']?['status']?.toString();
//       if (status == 'cancelled') {
//         _pollTimer?.cancel();
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               content: Text('Ride was cancelled'),
//               backgroundColor: AppTheme.errorColor,
//             ),
//           );
//           context.pop();
//         }
//         return;
//       }
//       if (status == 'accepted' || status == 'in_progress' || status == 'completed') {
//         _pollTimer?.cancel();
//         setState(() {
//           _ride = details?['ride'] ?? details;
//         });
//       }
//     });
//   }
//
//   bool _showWhatsAppIcon = false;
//   final LocationService _locationService = LocationService();
//
//   void _triggerSOS() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Emergency SOS'),
//         content: const Text(
//           'Are you sure you want to trigger an emergency alert? This will notify emergency contacts and admin.',
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel'),
//           ),
//           ElevatedButton(
//             onPressed: () async {
//               Navigator.pop(context);
//               // Get favorite contact name
//               final storageService = await getStorageService();
//               final favoriteContactName = storageService.getFavoriteContactName() ?? 'Emergency Contact';
//
//               // TODO: Implement SOS functionality (send to backend, call emergency number, etc.)
//
//               if (mounted) {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   SnackBar(
//                     content: Text('Message sent to $favoriteContactName'),
//                     backgroundColor: AppTheme.sosColor,
//                     duration: const Duration(seconds: 3),
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
//   Future<void> _cancelRide() async {
//     final cancellationReason = await showDialog<String>(
//       context: context,
//       builder: (context) => CancelRideDialog(
//         isDriver: false,
//         rideStatus: _rideStatus,
//       ),
//     );
//
//     if (cancellationReason != null && mounted) {
//       if (widget.rideId != null) {
//         await Provider.of<RideProvider>(context, listen: false)
//             .cancelRide(widget.rideId!, reason: cancellationReason);
//       }
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Ride cancelled successfully'),
//             backgroundColor: AppTheme.successColor,
//           ),
//         );
//         context.pop();
//       }
//     }
//   }
//
//   void _callDriver() {
//     // Navigate to in-app call screen
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => const CallScreen(
//           userId: 'driver_123',
//           userName: 'Driver Name',
//           userAvatar: null,
//           phoneNumber: '+92 300 1234567',
//         ),
//       ),
//     );
//   }
//
//   void _chatWithDriver() {
//     // Navigate to chat screen with driver information
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => const ChatScreen(
//           userId: 'driver_123',
//           userName: 'Driver Name',
//           userAvatar: null,
//         ),
//       ),
//     );
//   }
//
//   Future<void> _shareViaWhatsApp() async {
//     try {
//       // Get current location
//       final position = await _locationService.getCurrentPosition();
//
//       // Create Google Maps location link
//       final locationLink = 'https://www.google.com/maps?q=${position.latitude},${position.longitude}';
//
//       // Create ride details message with location link
//       final message = '''
// 🚗 Ride Details
//
// Driver: Driver Name
// Vehicle: Toyota Corolla (ABC-123)
// Pickup: Current Location
// Destination: Destination Location
// ETA: 5 minutes
//
// 📍 My Location: $locationLink
//
// Track my ride in real-time.
// ''';
//
//       // Encode the message for URL
//       final encodedMessage = Uri.encodeComponent(message);
//
//       // WhatsApp URL format: whatsapp://send?text=message
//       // Using wa.me without phone number opens contact picker
//       final whatsappUrl = Uri.parse('https://wa.me/?text=$encodedMessage');
//
//       if (await canLaunchUrl(whatsappUrl)) {
//         await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
//       } else {
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               content: Text('WhatsApp is not installed'),
//               backgroundColor: AppTheme.errorColor,
//             ),
//           );
//         }
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Error: ${e.toString()}'),
//             backgroundColor: AppTheme.errorColor,
//           ),
//         );
//       }
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         children: [
//           // Map View
//           Container(
//             height: double.infinity,
//             color: AppTheme.backgroundColor,
//             child: const Center(
//               child: Icon(
//                 Icons.map,
//                 size: 100,
//                 color: AppTheme.textSecondary,
//               ),
//             ),
//           ),
//
//           // Map Image at the top
//           Positioned(
//             top: 0,
//             left: 0,
//             right: 0,
//             height: 600, // adjust height as needed
//             child: ClipRRect(
//               child: Image.asset(
//                 'assets/images/googlemap.jpeg', // <-- your map image path
//                 fit: BoxFit.cover,
//               ),
//             ),
//           ),
//           // Bottom card: Waiting for driver OR Driver info
//           Positioned(
//             bottom: 0,
//             left: 0,
//             right: 0,
//             child: Container(
//               decoration: const BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black12,
//                     blurRadius: 10,
//                     offset: Offset(0, -2),
//                   ),
//                 ],
//               ),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Container(
//                     margin: const EdgeInsets.only(top: 12),
//                     width: 40,
//                     height: 4,
//                     decoration: BoxDecoration(
//                       color: Colors.grey.shade300,
//                       borderRadius: BorderRadius.circular(2),
//                     ),
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.all(16.0),
//                     child: _isWaitingForDriver
//                         ? Column(
//                             children: [
//                               const CircularProgressIndicator(),
//                               const SizedBox(height: 16),
//                               Text(
//                                 'Finding a driver',
//                                 style: Theme.of(context).textTheme.titleLarge,
//                               ),
//                               const SizedBox(height: 8),
//                               Text(
//                                 'Your request is visible to nearby drivers. You will see their location when one accepts.',
//                                 style: Theme.of(context).textTheme.bodySmall,
//                                 textAlign: TextAlign.center,
//                               ),
//                               if (widget.rideId != null) ...[
//                                 const SizedBox(height: 12),
//                                 Text(
//                                   'Ride ID: ${widget.rideId}',
//                                   style: Theme.of(context).textTheme.bodySmall,
//                                 ),
//                               ],
//                               const SizedBox(height: 16),
//                               OutlinedButton(
//                                 onPressed: _cancelRide,
//                                 child: const Text('Cancel request'),
//                               ),
//                             ],
//                           )
//                         : Column(
//                       children: [
//                         // Driver Details
//                         Row(
//                           children: [
//                             const CircleAvatar(
//                               radius: 30,
//                               backgroundColor: AppTheme.primaryLight,
//                               child: Icon(Icons.person, size: 30),
//                             ),
//                             const SizedBox(width: 12),
//                             Expanded(
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     'Driver Name',
//                                     style: Theme.of(context).textTheme.titleLarge,
//                                   ),
//                                   Row(
//                                     children: [
//                                       const Icon(Icons.star,
//                                           color: Colors.amber, size: 16),
//                                       const SizedBox(width: 4),
//                                       Text(
//                                         '4.8',
//                                         style: Theme.of(context)
//                                             .textTheme
//                                             .bodyMedium,
//                                       ),
//                                     ],
//                                   ),
//                                 ],
//                               ),
//                             ),
//                             IconButton(
//                               icon: const Icon(Icons.phone),
//                               color: AppTheme.primaryColor,
//                               onPressed: _callDriver,
//                               tooltip: 'Call Driver',
//                             ),
//                             IconButton(
//                               icon: const Icon(Icons.chat_bubble_outline),
//                               color: AppTheme.primaryColor,
//                               onPressed: _chatWithDriver,
//                               tooltip: 'Chat with Driver',
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 16),
//                         // Vehicle Info
//                         Container(
//                           padding: const EdgeInsets.all(12),
//                           decoration: BoxDecoration(
//                             color: AppTheme.backgroundColor,
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                           child: Row(
//                             children: [
//                               const Icon(Icons.directions_car,
//                                   color: AppTheme.primaryColor),
//                               const SizedBox(width: 12),
//                               const Text('Toyota Corolla'),
//                               const Spacer(),
//                               const Text('ABC-123'),
//                             ],
//                           ),
//                         ),
//                         const SizedBox(height: 16),
//                         // ETA
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             const Icon(Icons.access_time,
//                                 color: AppTheme.primaryColor),
//                             const SizedBox(width: 8),
//                             Text(
//                               'ETA: 5 minutes',
//                               style: Theme.of(context).textTheme.titleLarge,
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 16),
//                         // Action Buttons
//                         Row(
//                           children: [
//                             Expanded(
//                               child: OutlinedButton.icon(
//                                 onPressed: _cancelRide,
//                                 icon: const Icon(Icons.cancel),
//                                 label: const Text('Cancel'),
//                               ),
//                             ),
//                             const SizedBox(width: 12),
//                             Expanded(
//                               child: ElevatedButton.icon(
//                                 onPressed: _triggerSOS,
//                                 icon: const Icon(Icons.warning),
//                                 label: const Text('SOS'),
//                                 style: ElevatedButton.styleFrom(
//                                   backgroundColor: AppTheme.sosColor,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 8),
//                         // Share Ride Button
//                         TextButton.icon(
//                           onPressed: () {
//                             setState(() {
//                               _showWhatsAppIcon = !_showWhatsAppIcon;
//                             });
//                           },
//                           icon: const Icon(Icons.share),
//                           label: const Text('Share Ride Details'),
//                         ),
//                         // WhatsApp Icon (shown when share is clicked)
//                         if (_showWhatsAppIcon)
//                           Padding(
//                             padding: const EdgeInsets.only(top: 8.0),
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 InkWell(
//                                   onTap: _shareViaWhatsApp,
//                                   child: Container(
//                                     padding: const EdgeInsets.symmetric(
//                                       horizontal: 16,
//                                       vertical: 12,
//                                     ),
//                                     decoration: BoxDecoration(
//                                       color: const Color(0xFF25D366), // WhatsApp green
//                                       borderRadius: BorderRadius.circular(8),
//                                     ),
//                                     child: Row(
//                                       mainAxisSize: MainAxisSize.min,
//                                       children: const [
//                                         Icon(
//                                           Icons.chat,
//                                           color: Colors.white,
//                                           size: 24,
//                                         ),
//                                         SizedBox(width: 8),
//                                         Text(
//                                           'Share via WhatsApp',
//                                           style: TextStyle(
//                                             color: Colors.white,
//                                             fontWeight: FontWeight.bold,
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
