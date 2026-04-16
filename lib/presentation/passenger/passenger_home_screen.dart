import 'dart:async';
import 'package:flutter/material.dart';
import '../widgets/baneen_map_widget.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../controller/places_controller.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../shared/voice_command_service.dart';
import 'trip_history_screen.dart';
import 'passenger_profile_screen.dart';
import 'subscription_plans_screen.dart';

class PassengerHomeScreen extends StatefulWidget {
  const PassengerHomeScreen({super.key});

  @override
  State<PassengerHomeScreen> createState() => _PassengerHomeScreenState();
}

class _PassengerHomeScreenState extends State<PassengerHomeScreen> {
  int _currentIndex = 0;
  String? _pickupLocation;
  String? _destinationLocation;
  String? _selectedPaymentMethod = AppConstants.paymentMethodCash;
  bool _isListeningPickup = false;
  bool _isListeningDestination = false;
  final VoiceCommandService _voiceService = VoiceCommandService();
  final TextEditingController _pickupController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  Timer? _pickupDebounce;
  Timer? _destinationDebounce;





// ===== Payment methods config =====
  final List<Map<String, dynamic>> _paymentMethods = [
    {
      'type': AppConstants.paymentMethodCash,
      'title': 'Cash',
      'subtitle': 'Pay directly to driver',
      'isDefault': true,
    },
    {
      'type': AppConstants.paymentMethodEasyPaisa,
      'title': 'EasyPaisa',
      'subtitle': 'Pay via EasyPaisa',
      'isDefault': false,
    },
    {
      'type': AppConstants.paymentMethodJazzCash,
      'title': 'JazzCash',
      'subtitle': 'Pay via JazzCash',
      'isDefault': false,
    },
  ];

  bool _showAdditionalMethods = false;

  @override
  void dispose() {
    _pickupDebounce?.cancel();
    _destinationDebounce?.cancel();
    _pickupController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  void _onPickupChanged(BuildContext context, String value) {
    _pickupLocation = value.isEmpty ? null : value;
    _pickupDebounce?.cancel();
    if (value.trim().length < 2) {
      if (mounted) Provider.of<PlacesProvider>(context, listen: false).clearPickupSuggestions();
      return;
    }
    _pickupDebounce = Timer(const Duration(milliseconds: 400), () {
      if (mounted) {
        Provider.of<PlacesProvider>(context, listen: false).fetchPickupSuggestions(value);
      }
    });
  }

  void _onDestinationChanged(BuildContext context, String value) {
    _destinationLocation = value.isEmpty ? null : value;
    _destinationDebounce?.cancel();
    if (value.trim().length < 2) {
      if (mounted) Provider.of<PlacesProvider>(context, listen: false).clearDestinationSuggestions();
      return;
    }
    _destinationDebounce = Timer(const Duration(milliseconds: 400), () {
      if (mounted) {
        Provider.of<PlacesProvider>(context, listen: false).fetchDestinationSuggestions(value);
      }
    });
  }

  void _selectPickupSuggestion(BuildContext context, PlaceSuggestion s) {
    _pickupController.text = s.description;
    _pickupLocation = s.description;
    Provider.of<PlacesProvider>(context, listen: false).clearPickupSuggestions();
  }

  void _selectDestinationSuggestion(BuildContext context, PlaceSuggestion s) {
    _destinationController.text = s.description;
    _destinationLocation = s.description;
    Provider.of<PlacesProvider>(context, listen: false).clearDestinationSuggestions();
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
            _pickupLocation = result;
            _isListeningPickup = false;
          } else {
            _destinationController.text = result;
            _destinationLocation = result;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildHomeTab(),
          const TripHistoryScreen(),
          const SubscriptionPlansScreen(),
          const PassengerProfileScreen(),
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
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.subscriptions),
            label: 'Subscription',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildHomeTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // // Map placeholder
          // Container(
          //   height: 300,
          //   color: AppTheme.backgroundColor,
          //   child: const Center(
          //     child: Icon(
          //       Icons.map,
          //       size: 80,
          //       color: AppTheme.textSecondary,
          //     ),
          //   ),
          // ),
          // Real OpenStreetMap
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: BaneenMapWidget(
              height: 280,
              showMyLocation: true,
              showRoute: false,
            ),
          ),
          // Location Inputs
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Consumer<PlacesProvider>(
              builder: (context, places, _) => Column(
                children: [
                  // Location Summary Card (matching book ride screen)
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
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    TextField(
                                      controller: _pickupController,
                                      decoration: InputDecoration(
                                        hintText: 'Selected Pickup',
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
                                      onChanged: (v) => _onPickupChanged(context, v),
                                    ),
                                    if (places.pickupSuggestions.isNotEmpty)
                                      Container(
                                        constraints: const BoxConstraints(maxHeight: 180),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          border: Border.all(color: Colors.grey.shade300),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: ListView.builder(
                                          shrinkWrap: true,
                                          padding: EdgeInsets.zero,
                                          itemCount: places.pickupSuggestions.length,
                                          itemBuilder: (_, i) {
                                            final s = places.pickupSuggestions[i];
                                            return ListTile(
                                              dense: true,
                                              leading: const Icon(Icons.place, size: 20, color: AppTheme.primaryColor),
                                              title: Text(s.description, style: const TextStyle(fontSize: 14)),
                                              onTap: () => _selectPickupSuggestion(context, s),
                                            );
                                          },
                                        ),
                                      ),
                                  ],
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
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    TextField(
                                      controller: _destinationController,
                                      decoration: InputDecoration(
                                        hintText: 'Selected Destination',
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
                                      onChanged: (v) => _onDestinationChanged(context, v),
                                    ),
                                    if (places.destinationSuggestions.isNotEmpty)
                                      Container(
                                        constraints: const BoxConstraints(maxHeight: 180),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          border: Border.all(color: Colors.grey.shade300),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: ListView.builder(
                                          shrinkWrap: true,
                                          padding: EdgeInsets.zero,
                                          itemCount: places.destinationSuggestions.length,
                                          itemBuilder: (_, i) {
                                            final s = places.destinationSuggestions[i];
                                            return ListTile(
                                              dense: true,
                                              leading: const Icon(Icons.place, size: 20, color: AppTheme.primaryColor),
                                              title: Text(s.description, style: const TextStyle(fontSize: 14)),
                                              onTap: () => _selectDestinationSuggestion(context, s),
                                            );
                                          },
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Payment Method Selection (if both locations selected)
                  if (_pickupLocation != null && _destinationLocation != null) ...[
                    Text(
                      'Select Payment Method',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),



                    Card(
                      child: Column(
                        children: [
                          ..._paymentMethods
                              .where((m) => _showAdditionalMethods || m['isDefault'] == true)
                              .map((method) {
                            return Column(
                              children: [

                                RadioListTile<String>(
                                  value: method['type'],
                                  groupValue: _selectedPaymentMethod,
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedPaymentMethod = value;
                                    });
                                  },
                                  title: Text(method['title']),
                                  subtitle: Text(method['subtitle']),
                                  // Use the image directly as secondary
                                  secondary: SizedBox(
                                    width: 40,
                                    height: 40,
                                    child: Image.asset(
                                      method['type'] == AppConstants.paymentMethodCash
                                          ? 'assets/images/cash.png'
                                          : method['type'] == AppConstants.paymentMethodEasyPaisa
                                          ? 'assets/images/img.png'
                                          : 'assets/images/jz.png',
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),




                                // RadioListTile<String>(
                                //   value: method['type'],
                                //   groupValue: _selectedPaymentMethod,
                                //   onChanged: (value) {
                                //     setState(() {
                                //       _selectedPaymentMethod = value;
                                //     });
                                //   },
                                //   title: Text(method['title']),
                                //   subtitle: Text(method['subtitle']),
                                //   // secondary: CircleAvatar(
                                //   //   backgroundColor:
                                //   //   // _getPaymentColor(method['type']).withOpacity(0.15),
                                //   //
                                //   // ),
                                // ),
                                const Divider(height: 1),
                              ],
                            );
                          }),

                          TextButton.icon(
                            onPressed: () {
                              setState(() {
                                _showAdditionalMethods = !_showAdditionalMethods;
                              });
                            },
                            icon: Icon(
                              _showAdditionalMethods
                                  ? Icons.expand_less
                                  : Icons.expand_more,
                            ),
                            label: Text(
                              _showAdditionalMethods
                                  ? 'Hide payment methods'
                                  : 'Show other payment methods',
                            ),
                          ),
                        ],
                      ),
                    ),










                    // Card(
                    //   child: Column(
                    //     children: [
                    //       RadioListTile<String>(
                    //         title: const Text('Cash'),
                    //         subtitle: const Text('Pay directly to driver'),
                    //         value: AppConstants.paymentMethodCash,
                    //         groupValue: _selectedPaymentMethod,
                    //         onChanged: (value) {
                    //           setState(() {
                    //             _selectedPaymentMethod = value;
                    //           });
                    //         },
                    //       ),
                    //       const Divider(height: 1),
                    //       RadioListTile<String>(
                    //         title: const Text('EasyPaisa'),
                    //         subtitle: const Text('Pay via EasyPaisa'),
                    //         value: AppConstants.paymentMethodEasyPaisa,
                    //         groupValue: _selectedPaymentMethod,
                    //         onChanged: (value) {
                    //           setState(() {
                    //             _selectedPaymentMethod = value;
                    //           });
                    //         },
                    //       ),
                    //       const Divider(height: 1),
                    //       RadioListTile<String>(
                    //         title: const Text('JazzCash'),
                    //         subtitle: const Text('Pay via JazzCash'),
                    //         value: AppConstants.paymentMethodJazzCash,
                    //         groupValue: _selectedPaymentMethod,
                    //         onChanged: (value) {
                    //           setState(() {
                    //             _selectedPaymentMethod = value;
                    //           });
                    //         },
                    //       ),
                    //     ],
                    //   ),
                    // ),
                    const SizedBox(height: 12),
                  ],
                  const SizedBox(height: 24),
                  // Ride Options
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _pickupLocation != null &&
                              _destinationLocation != null
                              ? () {
                            context.push('/ride-booking', extra: {
                              'pickup': _pickupLocation,
                              'destination': _destinationLocation,
                              'paymentMethod': _selectedPaymentMethod,
                            });
                          }
                              : null,
                          icon: const Icon(Icons.directions_car),
                          label: const Text('Book Ride'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            context.push('/subscription');
                          },
                          icon: const Icon(Icons.subscriptions),
                          label: const Text('Subscribe'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                    ],
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
// import '../../controller/places_controller.dart';
// import '../../core/theme/app_theme.dart';
// import '../../core/constants/app_constants.dart';
// import '../shared/voice_command_service.dart';
// import 'trip_history_screen.dart';
// import 'passenger_profile_screen.dart';
// import 'subscription_plans_screen.dart';
//
// class PassengerHomeScreen extends StatefulWidget {
//   const PassengerHomeScreen({super.key});
//
//   @override
//   State<PassengerHomeScreen> createState() => _PassengerHomeScreenState();
// }
//
// class _PassengerHomeScreenState extends State<PassengerHomeScreen> {
//   int _currentIndex = 0;
//   String? _pickupLocation;
//   String? _destinationLocation;
//   String? _selectedPaymentMethod = AppConstants.paymentMethodCash;
//   bool _isListeningPickup = false;
//   bool _isListeningDestination = false;
//   final VoiceCommandService _voiceService = VoiceCommandService();
//   final TextEditingController _pickupController = TextEditingController();
//   final TextEditingController _destinationController = TextEditingController();
//   Timer? _pickupDebounce;
//   Timer? _destinationDebounce;
//
//
//
//
//
// // ===== Payment methods config =====
//   final List<Map<String, dynamic>> _paymentMethods = [
//     {
//       'type': AppConstants.paymentMethodCash,
//       'title': 'Cash',
//       'subtitle': 'Pay directly to driver',
//       'isDefault': true,
//     },
//     {
//       'type': AppConstants.paymentMethodEasyPaisa,
//       'title': 'EasyPaisa',
//       'subtitle': 'Pay via EasyPaisa',
//       'isDefault': false,
//     },
//     {
//       'type': AppConstants.paymentMethodJazzCash,
//       'title': 'JazzCash',
//       'subtitle': 'Pay via JazzCash',
//       'isDefault': false,
//     },
//   ];
//
//   bool _showAdditionalMethods = false;
//
//   @override
//   void dispose() {
//     _pickupDebounce?.cancel();
//     _destinationDebounce?.cancel();
//     _pickupController.dispose();
//     _destinationController.dispose();
//     super.dispose();
//   }
//
//   void _onPickupChanged(BuildContext context, String value) {
//     _pickupLocation = value.isEmpty ? null : value;
//     _pickupDebounce?.cancel();
//     if (value.trim().length < 2) {
//       if (mounted) Provider.of<PlacesProvider>(context, listen: false).clearPickupSuggestions();
//       return;
//     }
//     _pickupDebounce = Timer(const Duration(milliseconds: 400), () {
//       if (mounted) {
//         Provider.of<PlacesProvider>(context, listen: false).fetchPickupSuggestions(value);
//       }
//     });
//   }
//
//   void _onDestinationChanged(BuildContext context, String value) {
//     _destinationLocation = value.isEmpty ? null : value;
//     _destinationDebounce?.cancel();
//     if (value.trim().length < 2) {
//       if (mounted) Provider.of<PlacesProvider>(context, listen: false).clearDestinationSuggestions();
//       return;
//     }
//     _destinationDebounce = Timer(const Duration(milliseconds: 400), () {
//       if (mounted) {
//         Provider.of<PlacesProvider>(context, listen: false).fetchDestinationSuggestions(value);
//       }
//     });
//   }
//
//   void _selectPickupSuggestion(BuildContext context, PlaceSuggestion s) {
//     _pickupController.text = s.description;
//     _pickupLocation = s.description;
//     Provider.of<PlacesProvider>(context, listen: false).clearPickupSuggestions();
//   }
//
//   void _selectDestinationSuggestion(BuildContext context, PlaceSuggestion s) {
//     _destinationController.text = s.description;
//     _destinationLocation = s.description;
//     Provider.of<PlacesProvider>(context, listen: false).clearDestinationSuggestions();
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
//             _pickupLocation = result;
//             _isListeningPickup = false;
//           } else {
//             _destinationController.text = result;
//             _destinationLocation = result;
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
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: IndexedStack(
//         index: _currentIndex,
//         children: [
//           _buildHomeTab(),
//           const TripHistoryScreen(),
//           const SubscriptionPlansScreen(),
//           const PassengerProfileScreen(),
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
//             icon: Icon(Icons.home),
//             label: 'Home',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.history),
//             label: 'History',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.subscriptions),
//             label: 'Subscription',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.person),
//             label: 'Profile',
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildHomeTab() {
//     return SingleChildScrollView(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: [
//           // // Map placeholder
//           // Container(
//           //   height: 300,
//           //   color: AppTheme.backgroundColor,
//           //   child: const Center(
//           //     child: Icon(
//           //       Icons.map,
//           //       size: 80,
//           //       color: AppTheme.textSecondary,
//           //     ),
//           //   ),
//           // ),
//           // Map image
//           Container(
//             height: 300,
//             width: double.infinity,
//             color: AppTheme.backgroundColor,
//             child: Image.asset(
//               'assets/images/googlemap.jpeg', // <-- replace with your image path
//               fit: BoxFit.cover, // makes it fill the container nicely
//             ),
//           ),
//           // Location Inputs
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Consumer<PlacesProvider>(
//               builder: (context, places, _) => Column(
//                 children: [
//                   // Location Summary Card (matching book ride screen)
//                   Card(
//                     child: Padding(
//                       padding: const EdgeInsets.all(16.0),
//                       child: Column(
//                         children: [
//                           Row(
//                             children: [
//                               const Icon(Icons.radio_button_checked,
//                                   color: AppTheme.successColor),
//                               const SizedBox(width: 12),
//                               Expanded(
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.stretch,
//                                   children: [
//                                     TextField(
//                                       controller: _pickupController,
//                                       decoration: InputDecoration(
//                                         hintText: 'Selected Pickup',
//                                         border: InputBorder.none,
//                                         suffixIcon: IconButton(
//                                           icon: Icon(
//                                             _isListeningPickup
//                                                 ? Icons.mic
//                                                 : Icons.mic_none,
//                                             color: _isListeningPickup
//                                                 ? AppTheme.errorColor
//                                                 : AppTheme.primaryColor,
//                                           ),
//                                           onPressed: () => _startVoiceInput('pickup'),
//                                           tooltip: 'Voice input for pickup',
//                                         ),
//                                       ),
//                                       onChanged: (v) => _onPickupChanged(context, v),
//                                     ),
//                                     if (places.pickupSuggestions.isNotEmpty)
//                                       Container(
//                                         constraints: const BoxConstraints(maxHeight: 180),
//                                         decoration: BoxDecoration(
//                                           color: Colors.white,
//                                           border: Border.all(color: Colors.grey.shade300),
//                                           borderRadius: BorderRadius.circular(8),
//                                         ),
//                                         child: ListView.builder(
//                                           shrinkWrap: true,
//                                           padding: EdgeInsets.zero,
//                                           itemCount: places.pickupSuggestions.length,
//                                           itemBuilder: (_, i) {
//                                             final s = places.pickupSuggestions[i];
//                                             return ListTile(
//                                               dense: true,
//                                               leading: const Icon(Icons.place, size: 20, color: AppTheme.primaryColor),
//                                               title: Text(s.description, style: const TextStyle(fontSize: 14)),
//                                               onTap: () => _selectPickupSuggestion(context, s),
//                                             );
//                                           },
//                                         ),
//                                       ),
//                                   ],
//                                 ),
//                               ),
//                             ],
//                           ),
//                           const SizedBox(height: 16),
//                           const Divider(),
//                           const SizedBox(height: 16),
//                           Row(
//                             children: [
//                               const Icon(Icons.location_on,
//                                   color: AppTheme.primaryColor),
//                               const SizedBox(width: 12),
//                               Expanded(
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.stretch,
//                                   children: [
//                                     TextField(
//                                       controller: _destinationController,
//                                       decoration: InputDecoration(
//                                         hintText: 'Selected Destination',
//                                         border: InputBorder.none,
//                                         suffixIcon: IconButton(
//                                           icon: Icon(
//                                             _isListeningDestination
//                                                 ? Icons.mic
//                                                 : Icons.mic_none,
//                                             color: _isListeningDestination
//                                                 ? AppTheme.errorColor
//                                                 : AppTheme.primaryColor,
//                                           ),
//                                           onPressed: () => _startVoiceInput('destination'),
//                                           tooltip: 'Voice input for destination',
//                                         ),
//                                       ),
//                                       onChanged: (v) => _onDestinationChanged(context, v),
//                                     ),
//                                     if (places.destinationSuggestions.isNotEmpty)
//                                       Container(
//                                         constraints: const BoxConstraints(maxHeight: 180),
//                                         decoration: BoxDecoration(
//                                           color: Colors.white,
//                                           border: Border.all(color: Colors.grey.shade300),
//                                           borderRadius: BorderRadius.circular(8),
//                                         ),
//                                         child: ListView.builder(
//                                           shrinkWrap: true,
//                                           padding: EdgeInsets.zero,
//                                           itemCount: places.destinationSuggestions.length,
//                                           itemBuilder: (_, i) {
//                                             final s = places.destinationSuggestions[i];
//                                             return ListTile(
//                                               dense: true,
//                                               leading: const Icon(Icons.place, size: 20, color: AppTheme.primaryColor),
//                                               title: Text(s.description, style: const TextStyle(fontSize: 14)),
//                                               onTap: () => _selectDestinationSuggestion(context, s),
//                                             );
//                                           },
//                                         ),
//                                       ),
//                                   ],
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 const SizedBox(height: 24),
//                 // Payment Method Selection (if both locations selected)
//                 if (_pickupLocation != null && _destinationLocation != null) ...[
//                   Text(
//                     'Select Payment Method',
//                     style: Theme.of(context).textTheme.titleLarge,
//                   ),
//                   const SizedBox(height: 12),
//
//
//
//                   Card(
//                     child: Column(
//                       children: [
//                         ..._paymentMethods
//                             .where((m) => _showAdditionalMethods || m['isDefault'] == true)
//                             .map((method) {
//                           return Column(
//                             children: [
//
//                               RadioListTile<String>(
//                                 value: method['type'],
//                                 groupValue: _selectedPaymentMethod,
//                                 onChanged: (value) {
//                                   setState(() {
//                                     _selectedPaymentMethod = value;
//                                   });
//                                 },
//                                 title: Text(method['title']),
//                                 subtitle: Text(method['subtitle']),
//                                 // Use the image directly as secondary
//                                 secondary: SizedBox(
//                                   width: 40,
//                                   height: 40,
//                                   child: Image.asset(
//                                     method['type'] == AppConstants.paymentMethodCash
//                                         ? 'assets/images/cash.png'
//                                         : method['type'] == AppConstants.paymentMethodEasyPaisa
//                                         ? 'assets/images/img.png'
//                                         : 'assets/images/jz.png',
//                                     fit: BoxFit.contain,
//                                   ),
//                                 ),
//                               ),
//
//
//
//
//                               // RadioListTile<String>(
//                               //   value: method['type'],
//                               //   groupValue: _selectedPaymentMethod,
//                               //   onChanged: (value) {
//                               //     setState(() {
//                               //       _selectedPaymentMethod = value;
//                               //     });
//                               //   },
//                               //   title: Text(method['title']),
//                               //   subtitle: Text(method['subtitle']),
//                               //   // secondary: CircleAvatar(
//                               //   //   backgroundColor:
//                               //   //   // _getPaymentColor(method['type']).withOpacity(0.15),
//                               //   //
//                               //   // ),
//                               // ),
//                               const Divider(height: 1),
//                             ],
//                           );
//                         }),
//
//                         TextButton.icon(
//                           onPressed: () {
//                             setState(() {
//                               _showAdditionalMethods = !_showAdditionalMethods;
//                             });
//                           },
//                           icon: Icon(
//                             _showAdditionalMethods
//                                 ? Icons.expand_less
//                                 : Icons.expand_more,
//                           ),
//                           label: Text(
//                             _showAdditionalMethods
//                                 ? 'Hide payment methods'
//                                 : 'Show other payment methods',
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//
//
//
//
//
//
//
//
//
//
//                   // Card(
//                   //   child: Column(
//                   //     children: [
//                   //       RadioListTile<String>(
//                   //         title: const Text('Cash'),
//                   //         subtitle: const Text('Pay directly to driver'),
//                   //         value: AppConstants.paymentMethodCash,
//                   //         groupValue: _selectedPaymentMethod,
//                   //         onChanged: (value) {
//                   //           setState(() {
//                   //             _selectedPaymentMethod = value;
//                   //           });
//                   //         },
//                   //       ),
//                   //       const Divider(height: 1),
//                   //       RadioListTile<String>(
//                   //         title: const Text('EasyPaisa'),
//                   //         subtitle: const Text('Pay via EasyPaisa'),
//                   //         value: AppConstants.paymentMethodEasyPaisa,
//                   //         groupValue: _selectedPaymentMethod,
//                   //         onChanged: (value) {
//                   //           setState(() {
//                   //             _selectedPaymentMethod = value;
//                   //           });
//                   //         },
//                   //       ),
//                   //       const Divider(height: 1),
//                   //       RadioListTile<String>(
//                   //         title: const Text('JazzCash'),
//                   //         subtitle: const Text('Pay via JazzCash'),
//                   //         value: AppConstants.paymentMethodJazzCash,
//                   //         groupValue: _selectedPaymentMethod,
//                   //         onChanged: (value) {
//                   //           setState(() {
//                   //             _selectedPaymentMethod = value;
//                   //           });
//                   //         },
//                   //       ),
//                   //     ],
//                   //   ),
//                   // ),
//                   const SizedBox(height: 12),
//                 ],
//                 const SizedBox(height: 24),
//                 // Ride Options
//                 Row(
//                   children: [
//                     Expanded(
//                       child: ElevatedButton.icon(
//                         onPressed: _pickupLocation != null &&
//                             _destinationLocation != null
//                             ? () {
//                           context.push('/ride-booking', extra: {
//                             'pickup': _pickupLocation,
//                             'destination': _destinationLocation,
//                             'paymentMethod': _selectedPaymentMethod,
//                           });
//                         }
//                             : null,
//                         icon: const Icon(Icons.directions_car),
//                         label: const Text('Book Ride'),
//                         style: ElevatedButton.styleFrom(
//                           padding: const EdgeInsets.symmetric(vertical: 16),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 12),
//                     Expanded(
//                       child: OutlinedButton.icon(
//                         onPressed: () {
//                           context.push('/subscription');
//                         },
//                         icon: const Icon(Icons.subscriptions),
//                         label: const Text('Subscribe'),
//                         style: OutlinedButton.styleFrom(
//                           padding: const EdgeInsets.symmetric(vertical: 16),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//         ],
//       ),
//     );
//   }
//
// }
//
