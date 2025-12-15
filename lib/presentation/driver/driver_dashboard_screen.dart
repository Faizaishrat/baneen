import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/helpers.dart';
import 'ride_request_screen.dart';
import 'driver_active_ride_screen.dart';
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

  // Sample ride requests - in real app, this would come from API
  final List<Map<String, dynamic>> _allRideRequests = [
    {
      'id': '1',
      'passengerName': 'Sarah Ahmed',
      'passengerRating': 4.9,
      'pickup': '123 Main Street, Islamabad',
      'destination': '456 Park Road, Rawalpindi',
      'distance': '2.5 km',
      'fare': 250.0,
    },
    {
      'id': '2',
      'passengerName': 'Fatima Khan',
      'passengerRating': 4.7,
      'pickup': 'Gulshan-e-Iqbal, Karachi',
      'destination': 'Clifton Beach, Karachi',
      'distance': '5.2 km',
      'fare': 320.0,
    },
    {
      'id': '3',
      'passengerName': 'Ayesha Malik',
      'passengerRating': 5.0,
      'pickup': 'DHA Phase 5, Lahore',
      'destination': 'Lahore Fort, Lahore',
      'distance': '8.1 km',
      'fare': 450.0,
    },
    {
      'id': '4',
      'passengerName': 'Zainab Ali',
      'passengerRating': 4.8,
      'pickup': 'Bahadurabad, Karachi',
      'destination': 'Tariq Road, Karachi',
      'distance': '3.7 km',
      'fare': 280.0,
    },
  ];

  final Set<String> _rejectedRideIds = {};

  List<Map<String, dynamic>> get _availableRideRequests {
    return _allRideRequests
        .where((ride) => !_rejectedRideIds.contains(ride['id']))
        .toList();
  }

  // Get first 2-3 ride requests to display
  List<Map<String, dynamic>> get _displayRideRequests {
    final available = _availableRideRequests;
    return available.take(3).toList(); // Show up to 3 ride requests
  }

  Map<String, dynamic>? get _currentRideRequest {
    final available = _availableRideRequests;
    return available.isNotEmpty ? available[0] : null;
  }

  void _rejectRide(String rideId) {
    setState(() {
      _rejectedRideIds.add(rideId);
    });
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
        padding: const EdgeInsets.only(bottom: 16.0), // adjust as needed
        child: FloatingActionButton.extended(
          onPressed: () {
            setState(() {
              _isOnline = !_isOnline;
            });
            // TODO: Update availability status via API
          },
          label: Text(_isOnline ? 'Go Offline' : 'Go Online'),
          icon: Icon(_isOnline ? Icons.toggle_off : Icons.toggle_on),
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
          const SizedBox(height: 24),
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
            _displayRideRequests.isEmpty
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
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () {
                                    _rejectRide(ride['id']);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Ride rejected'),
                                        backgroundColor: AppTheme.successColor,
                                        duration: Duration(seconds: 1),
                                      ),
                                    );
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

