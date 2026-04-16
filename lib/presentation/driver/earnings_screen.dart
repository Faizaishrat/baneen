import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/helpers.dart';

class EarningsScreen extends StatefulWidget {
  const EarningsScreen({super.key});

  @override
  State<EarningsScreen> createState() => _EarningsScreenState();
}

class _EarningsScreenState extends State<EarningsScreen> {
  String _selectedPeriod = 'today'; // today, week, month

  // Sample earnings data - in real app, this would come from API
  final List<Map<String, dynamic>> _allEarnings = [
    {
      'id': '1',
      'rideId': 'R12345',
      'date': DateTime.now().subtract(const Duration(hours: 2)),
      'fare': 250.0,
    },
    {
      'id': '2',
      'rideId': 'R12346',
      'date': DateTime.now().subtract(const Duration(hours: 5)),
      'fare': 320.0,
    },
    {
      'id': '3',
      'rideId': 'R12347',
      'date': DateTime.now().subtract(const Duration(days: 1)),
      'fare': 180.0,
    },
    {
      'id': '4',
      'rideId': 'R12348',
      'date': DateTime.now().subtract(const Duration(days: 1, hours: 3)),
      'fare': 450.0,
    },
    {
      'id': '5',
      'rideId': 'R12349',
      'date': DateTime.now().subtract(const Duration(days: 2)),
      'fare': 280.0,
    },
    {
      'id': '6',
      'rideId': 'R12350',
      'date': DateTime.now().subtract(const Duration(days: 2, hours: 5)),
      'fare': 350.0,
    },
    {
      'id': '7',
      'rideId': 'R12351',
      'date': DateTime.now().subtract(const Duration(days: 3)),
      'fare': 220.0,
    },
    {
      'id': '8',
      'rideId': 'R12352',
      'date': DateTime.now().subtract(const Duration(days: 4)),
      'fare': 400.0,
    },
    {
      'id': '9',
      'rideId': 'R12353',
      'date': DateTime.now().subtract(const Duration(days: 5)),
      'fare': 290.0,
    },
    {
      'id': '10',
      'rideId': 'R12354',
      'date': DateTime.now().subtract(const Duration(days: 6)),
      'fare': 310.0,
    },
    {
      'id': '11',
      'rideId': 'R12355',
      'date': DateTime.now().subtract(const Duration(days: 8)),
      'fare': 380.0,
    },
    {
      'id': '12',
      'rideId': 'R12356',
      'date': DateTime.now().subtract(const Duration(days: 10)),
      'fare': 270.0,
    },
    {
      'id': '13',
      'rideId': 'R12357',
      'date': DateTime.now().subtract(const Duration(days: 12)),
      'fare': 420.0,
    },
    {
      'id': '14',
      'rideId': 'R12358',
      'date': DateTime.now().subtract(const Duration(days: 15)),
      'fare': 330.0,
    },
    {
      'id': '15',
      'rideId': 'R12359',
      'date': DateTime.now().subtract(const Duration(days: 18)),
      'fare': 360.0,
    },
    {
      'id': '16',
      'rideId': 'R12360',
      'date': DateTime.now().subtract(const Duration(days: 20)),
      'fare': 240.0,
    },
    {
      'id': '17',
      'rideId': 'R12361',
      'date': DateTime.now().subtract(const Duration(days: 25)),
      'fare': 390.0,
    },
    {
      'id': '18',
      'rideId': 'R12362',
      'date': DateTime.now().subtract(const Duration(days: 28)),
      'fare': 410.0,
    },
  ];

  List<Map<String, dynamic>> get _filteredEarnings {
    final now = DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day);
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final startOfMonth = DateTime(now.year, now.month, 1);

    switch (_selectedPeriod) {
      case 'today':
        return _allEarnings.where((earning) {
          final earningDate = earning['date'] as DateTime;
          return earningDate.isAfter(startOfToday.subtract(const Duration(seconds: 1))) &&
              earningDate.isBefore(now.add(const Duration(days: 1)));
        }).toList();
      case 'week':
        return _allEarnings.where((earning) {
          final earningDate = earning['date'] as DateTime;
          return earningDate.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
              earningDate.isBefore(now.add(const Duration(days: 1)));
        }).toList();
      case 'month':
        return _allEarnings.where((earning) {
          final earningDate = earning['date'] as DateTime;
          return earningDate.isAfter(startOfMonth.subtract(const Duration(days: 1))) &&
              earningDate.isBefore(now.add(const Duration(days: 1)));
        }).toList();
      default:
        return _allEarnings;
    }
  }

  double get _totalEarnings {
    return _filteredEarnings.fold(0.0, (sum, earning) => sum + (earning['fare'] as double));
  }

  int get _rideCount {
    return _filteredEarnings.length;
  }

  @override
  Widget build(BuildContext context) {
    final filteredEarnings = _filteredEarnings;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text('Earnings'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _selectedPeriod = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'today', child: Text('Today')),
              const PopupMenuItem(value: 'week', child: Text('This Week')),
              const PopupMenuItem(value: 'month', child: Text('This Month')),
            ],
            child: const Icon(Icons.more_vert),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Total Earnings Card
            Card(
              color: AppTheme.primaryColor,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Text(
                      _getPeriodLabel(),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      Helpers.formatCurrency(_totalEarnings),
                      style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Stats Cards
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Rides',
                    '$_rideCount',
                    Icons.directions_car,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Bonus',
                    Helpers.formatCurrency(_getBonus()),
                    Icons.card_giftcard,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Earnings Breakdown
            Text(
              'Earnings Breakdown',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            // Earnings List
            filteredEarnings.isEmpty
                ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  children: [
                    Icon(
                      Icons.account_balance_wallet_outlined,
                      size: 64,
                      color: AppTheme.textSecondary.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No earnings found',
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
              ),
            )
                : Column(
              children: filteredEarnings.map((earning) {
                return _buildEarningItem(earning);
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  String _getPeriodLabel() {
    switch (_selectedPeriod) {
      case 'today':
        return 'Today\'s Earnings';
      case 'week':
        return 'This Week\'s Earnings';
      case 'month':
        return 'This Month\'s Earnings';
      default:
        return 'Total Earnings';
    }
  }

  double _getBonus() {
    // Bonus is 10% of total earnings
    return _totalEarnings * 0.1;
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, color: AppTheme.primaryColor, size: 32),
            const SizedBox(height: 12),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
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

  Widget _buildEarningItem(Map<String, dynamic> earning) {
    final rideId = earning['rideId'] as String;
    final date = earning['date'] as DateTime;
    final fare = earning['fare'] as double;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: AppTheme.primaryLight,
          child: Icon(Icons.directions_car, color: AppTheme.primaryColor),
        ),
        title: Text('Ride $rideId'),
        subtitle: Text(Helpers.formatDateTime(date)),
        trailing: Text(
          Helpers.formatCurrency(fare),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
      ),
    );
  }
}

