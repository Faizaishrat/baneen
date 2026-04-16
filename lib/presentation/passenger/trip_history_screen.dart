import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/helpers.dart';

class TripHistoryScreen extends StatefulWidget {
  const TripHistoryScreen({super.key});

  @override
  State<TripHistoryScreen> createState() => _TripHistoryScreenState();
}

class _TripHistoryScreenState extends State<TripHistoryScreen> {
  String _selectedFilter = 'all'; // all, week, month

  // Sample trip data - in a real app, this would come from a service/API
  final List<Map<String, dynamic>> _allTrips = [
    {
      'date': DateTime.now().subtract(const Duration(days: 1)),
      'pickup': 'Airport Road, Karachi',
      'destination': 'Clifton Beach, Karachi',
      'fare': 250.0,
      'rating': 4.8,
      'status': 'Completed',
    },
    {
      'date': DateTime.now().subtract(const Duration(days: 3)),
      'pickup': 'Gulshan-e-Iqbal, Karachi',
      'destination': 'Saddar, Karachi',
      'fare': 180.0,
      'rating': 4.5,
      'status': 'Completed',
    },
    {
      'date': DateTime.now().subtract(const Duration(days: 5)),
      'pickup': 'DHA Phase 5, Karachi',
      'destination': 'Port Grand, Karachi',
      'fare': 320.0,
      'rating': 5.0,
      'status': 'Completed',
    },
    {
      'date': DateTime.now().subtract(const Duration(days: 8)),
      'pickup': 'Bahadurabad, Karachi',
      'destination': 'Tariq Road, Karachi',
      'fare': 150.0,
      'rating': 4.2,
      'status': 'Completed',
    },
    {
      'date': DateTime.now().subtract(const Duration(days: 12)),
      'pickup': 'Karachi University, Karachi',
      'destination': 'Gulistan-e-Johar, Karachi',
      'fare': 280.0,
      'rating': 4.7,
      'status': 'Completed',
    },
    {
      'date': DateTime.now().subtract(const Duration(days: 20)),
      'pickup': 'Korangi, Karachi',
      'destination': 'Malir, Karachi',
      'fare': 200.0,
      'rating': 4.3,
      'status': 'Completed',
    },
    {
      'date': DateTime.now().subtract(const Duration(days: 35)),
      'pickup': 'North Nazimabad, Karachi',
      'destination': 'Shahrah-e-Faisal, Karachi',
      'fare': 220.0,
      'rating': 4.6,
      'status': 'Completed',
    },
  ];

  List<Map<String, dynamic>> get _filteredTrips {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final startOfMonth = DateTime(now.year, now.month, 1);

    switch (_selectedFilter) {
      case 'week':
        return _allTrips.where((trip) {
          final tripDate = trip['date'] as DateTime;
          return tripDate.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
              tripDate.isBefore(now.add(const Duration(days: 1)));
        }).toList();
      case 'month':
        return _allTrips.where((trip) {
          final tripDate = trip['date'] as DateTime;
          return tripDate.isAfter(startOfMonth.subtract(const Duration(days: 1))) &&
              tripDate.isBefore(now.add(const Duration(days: 1)));
        }).toList();
      default:
        return _allTrips;
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredTrips = _filteredTrips;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text('Trip History'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _selectedFilter = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'all', child: Text('All')),
              const PopupMenuItem(value: 'week', child: Text('This Week')),
              const PopupMenuItem(value: 'month', child: Text('This Month')),
            ],
            child: const Icon(Icons.more_vert),
          ),
        ],
      ),
      body: filteredTrips.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 64,
              color: AppTheme.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No trips found',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try selecting a different time period',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filteredTrips.length,
        itemBuilder: (context, index) {
          return _buildTripCard(filteredTrips[index]);
        },
      ),
    );
  }

  Widget _buildTripCard(Map<String, dynamic> trip) {
    final date = trip['date'] as DateTime;
    final pickup = trip['pickup'] as String;
    final destination = trip['destination'] as String;
    final fare = trip['fare'] as double;
    final rating = trip['rating'] as double;
    final status = trip['status'] as String;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          // TODO: Navigate to trip details
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    Helpers.formatDate(date),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.successColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        color: AppTheme.successColor,
                        fontSize: 12,
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
                      pickup,
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
                      destination,
                      style: Theme.of(context).textTheme.bodyMedium,
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
                        'Fare',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        Helpers.formatCurrency(fare),
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        rating.toStringAsFixed(1),
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

