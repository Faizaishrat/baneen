import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/helpers.dart';

class DriverPersonalInformationScreen extends StatelessWidget {
  const DriverPersonalInformationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text('Personal Information'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profile Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 50,
                    backgroundColor: AppTheme.primaryColor,
                    child: Icon(Icons.person, size: 50, color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Driver Name',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'driver@example.com',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        '4.8',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Information Cards
          _buildInfoCard(
            context,
            icon: Icons.person,
            title: 'Full Name',
            value: 'Driver Name',
          ),
          const SizedBox(height: 12),
          _buildInfoCard(
            context,
            icon: Icons.email,
            title: 'Email',
            value: 'driver@example.com',
          ),
          const SizedBox(height: 12),
          _buildInfoCard(
            context,
            icon: Icons.phone,
            title: 'Phone Number',
            value: '+92 300 1234567',
          ),
          const SizedBox(height: 12),
          _buildInfoCard(
            context,
            icon: Icons.badge,
            title: 'CNIC',
            value: '38201-6457287-0',
          ),
          const SizedBox(height: 12),
          _buildInfoCard(
            context,
            icon: Icons.calendar_today,
            title: 'Date of Birth',
            value: Helpers.formatDate(DateTime(1990, 3, 15)),
          ),
          const SizedBox(height: 12),
          _buildInfoCard(
            context,
            icon: Icons.verified,
            title: 'Verification Status',
            value: 'Verified',
            valueColor: AppTheme.successColor,
          ),
          const SizedBox(height: 12),
          _buildInfoCard(
            context,
            icon: Icons.directions_car,
            title: 'Vehicle Type',
            value: 'Car',
          ),
          const SizedBox(height: 12),
          _buildInfoCard(
            context,
            icon: Icons.confirmation_number,
            title: 'Vehicle Number',
            value: 'ABC-123',
          ),
          const SizedBox(height: 12),
          _buildInfoCard(
            context,
            icon: Icons.access_time,
            title: 'Member Since',
            value: Helpers.formatDate(DateTime.now().subtract(const Duration(days: 730))),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String value,
        Color? valueColor,
      }) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: AppTheme.primaryColor),
        title: Text(
          title,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
        subtitle: Text(
          value,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: valueColor ?? AppTheme.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}


