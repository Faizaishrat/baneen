import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_theme.dart';
import '../../services/storage/storage_service.dart';
import '../../services/location/location_service.dart';
import '../passenger/call_screen.dart';
import '../shared/chat_screen.dart';
import '../shared/cancel_ride_dialog.dart';
import 'safety_check_screen.dart';

class DriverActiveRideScreen extends StatefulWidget {
  const DriverActiveRideScreen({super.key});

  @override
  State<DriverActiveRideScreen> createState() =>
      _DriverActiveRideScreenState();
}

class _DriverActiveRideScreenState extends State<DriverActiveRideScreen> {
  String _rideStatus = 'accepted'; // accepted, in_progress, completed
  bool _isLoading = false;
  bool _isStartRideDisabled = false;
  bool _isEndRideDisabled = false;
  bool _showWhatsAppIcon = false;
  final LocationService _locationService = LocationService();

  Future<void> _startRide() async {
    // Navigate to safety check first
    final safetyPassed = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SafetyCheckScreen(),
      ),
    );

    if (safetyPassed == true) {
      setState(() {
        _rideStatus = 'in_progress';
        _isStartRideDisabled = true; // Disable Start Ride button
      });
      // TODO: Update ride status via API
    }
  }

  Future<void> _endRide() async {
    setState(() {
      _isEndRideDisabled = true; // Disable End Ride button
      _isStartRideDisabled = true; // Also disable Start Ride button
    });

    // Show feedback prompt
    _showFeedbackDialog();
  }

  void _showFeedbackDialog() {
    final _feedbackController = TextEditingController();
    final ValueNotifier<int> ratingNotifier = ValueNotifier<int>(0);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Rate Your Ride Experience'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('How was your ride experience?'),
              const SizedBox(height: 16),
              ValueListenableBuilder<int>(
                valueListenable: ratingNotifier,
                builder: (context, rating, _) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < rating ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 40,
                        ),
                        onPressed: () {
                          ratingNotifier.value = index + 1;
                        },
                      );
                    }),
                  );
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _feedbackController,
                decoration: const InputDecoration(
                  labelText: 'Additional Feedback (Optional)',
                  hintText: 'Share your experience...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              ratingNotifier.dispose();
              _feedbackController.dispose();
              Navigator.pop(context);
              // Complete the ride after feedback
              _completeRide();
            },
            child: const Text('Skip'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Submit feedback to API with ratingNotifier.value and _feedbackController.text
              ratingNotifier.dispose();
              _feedbackController.dispose();
              Navigator.pop(context);
              // Complete the ride after feedback
              _completeRide();
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  Future<void> _completeRide() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: Implement complete ride API call
      await Future.delayed(const Duration(seconds: 1)); // Simulate API call

      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ride completed successfully!'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to complete ride: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _callPassenger() {
    // Navigate to in-app call screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CallScreen(
          userId: 'passenger_123',
          userName: 'Passenger Name',
          userAvatar: null,
          phoneNumber: '+92 300 1234567',
        ),
      ),
    );
  }

  void _chatWithPassenger() {
    // Navigate to chat screen with passenger information
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ChatScreen(
          userId: 'passenger_123',
          userName: 'Passenger Name',
          userAvatar: null,
          isDriver: true, // Indicate this is driver's chat
        ),
      ),
    );
  }

  Future<void> _cancelRide() async {
    final cancellationReason = await showDialog<String>(
      context: context,
      builder: (context) => CancelRideDialog(
        isDriver: true,
        rideStatus: _rideStatus,
      ),
    );

    if (cancellationReason != null && mounted) {
      setState(() {
        _isLoading = true;
      });

      try {
        // TODO: Implement cancel ride API call with cancellationReason
        // Example: await rideService.cancelRide(rideId, cancellationReason, 'driver');
        await Future.delayed(const Duration(seconds: 1));

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Ride cancelled successfully'),
              backgroundColor: AppTheme.successColor,
            ),
          );
          context.pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to cancel ride: $e'),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
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

  Future<void> _shareViaWhatsApp() async {
    try {
      // Get current location
      final position = await _locationService.getCurrentPosition();

      // Create Google Maps location link
      final locationLink = 'https://www.google.com/maps?q=${position.latitude},${position.longitude}';

      // Create ride details message with location link
      final message = '''
🚗 Ride Details

Passenger: Passenger Name
Pickup: 123 Main Street, Islamabad
Destination: 456 Park Road, Rawalpindi
Status: ${_rideStatus == 'accepted' ? 'Accepted' : _rideStatus == 'in_progress' ? 'In Progress' : 'Completed'}

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
          // Container(
          //   height: double.infinity,
          //   color: AppTheme.backgroundColor,
          //   child: const Center(
          //     child: Icon(
          //       Icons.map,
          //       size: 100,
          //       color: AppTheme.textSecondary,
          //     ),
          //   ),
          // ),
          // Map Image at the top
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 550, // adjust height as needed
            child: ClipRRect(
              child: Image.asset(
                'assets/images/googlemap.jpeg', // <-- your map image path
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Passenger Info Card
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
                    child: Column(
                      children: [
                        // Passenger Details
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
                                    'Passenger Name',
                                    style:
                                    Theme.of(context).textTheme.titleLarge,
                                  ),
                                  Row(
                                    children: [
                                      const Icon(Icons.star,
                                          color: Colors.amber, size: 16),
                                      const SizedBox(width: 4),
                                      Text(
                                        '4.9',
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
                              onPressed: _callPassenger,
                              tooltip: 'Call Passenger',
                            ),
                            IconButton(
                              icon: const Icon(Icons.chat_bubble_outline),
                              color: AppTheme.primaryColor,
                              onPressed: _chatWithPassenger,
                              tooltip: 'Chat with Passenger',
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Location Info
                        if (_rideStatus == 'accepted')
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppTheme.backgroundColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.location_on,
                                    color: AppTheme.primaryColor),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Pickup Location',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall,
                                      ),
                                      Text(
                                        '123 Main Street, Islamabad',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppTheme.backgroundColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
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
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall,
                                      ),
                                      Text(
                                        '456 Park Road, Rawalpindi',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 16),
                        // Action Buttons - Start Ride, Cancel Ride, SOS Emergency
                        if (_rideStatus == 'accepted') ...[
                          // Start Ride and Cancel Ride buttons
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: _isStartRideDisabled || _isLoading ? null : _startRide,
                                  icon: const Icon(Icons.play_arrow),
                                  label: const Text('Start Ride'),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: _isLoading ? null : _cancelRide,
                                  icon: const Icon(Icons.cancel),
                                  label: const Text('Cancel Ride'),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    side: BorderSide(color: AppTheme.errorColor),
                                    foregroundColor: AppTheme.errorColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // SOS Emergency Button
                          SizedBox(
                            width: double.infinity,
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
                        ] else if (_rideStatus == 'in_progress') ...[
                          // For in_progress rides - SOS and End Ride
                          Row(
                            children: [
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
                          const SizedBox(height: 12),
                          // End Ride Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _isEndRideDisabled ? null : _endRide,
                              icon: const Icon(Icons.stop),
                              label: const Text('End Ride'),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                backgroundColor: AppTheme.errorColor,
                              ),
                            ),
                          ),
                        ],
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


