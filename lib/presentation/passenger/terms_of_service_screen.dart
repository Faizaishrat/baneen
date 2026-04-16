import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text('Terms of Service'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Last Updated: ${DateTime.now().toString().split(' ')[0]}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              title: '1. Acceptance of Terms',
              content:
              'By accessing and using the Baneen ride-sharing application, you accept and agree to be bound by the terms and provision of this agreement.',
            ),
            _buildSection(
              context,
              title: '2. Use License',
              content:
              'Permission is granted to temporarily use Baneen for personal, non-commercial transitory viewing only. This is the grant of a license, not a transfer of title, and under this license you may not:\n\n• Modify or copy the materials\n• Use the materials for any commercial purpose\n• Attempt to decompile or reverse engineer any software\n• Remove any copyright or other proprietary notations',
            ),
            _buildSection(
              context,
              title: '3. User Account',
              content:
              'You are responsible for maintaining the confidentiality of your account and password. You agree to accept responsibility for all activities that occur under your account.',
            ),
            _buildSection(
              context,
              title: '4. Payment Terms',
              content:
              'All payments must be made through the approved payment methods. Baneen reserves the right to change pricing at any time. Refunds are subject to our refund policy.',
            ),
            _buildSection(
              context,
              title: '5. Safety and Conduct',
              content:
              'Users must comply with all applicable laws and regulations. Any inappropriate behavior, harassment, or violation of safety guidelines will result in immediate account suspension.',
            ),
            _buildSection(
              context,
              title: '6. Limitation of Liability',
              content:
              'Baneen shall not be liable for any indirect, incidental, special, consequential, or punitive damages resulting from your use or inability to use the service.',
            ),
            _buildSection(
              context,
              title: '7. Changes to Terms',
              content:
              'Baneen reserves the right to revise these terms of service at any time. By continuing to use the service after changes are made, you agree to be bound by the revised terms.',
            ),
            const SizedBox(height: 32),
            Card(
              color: AppTheme.primaryColor.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.info, color: AppTheme.primaryColor),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'If you have any questions about these Terms of Service, please contact us at support@baneen.com',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, {required String title, required String content}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}


