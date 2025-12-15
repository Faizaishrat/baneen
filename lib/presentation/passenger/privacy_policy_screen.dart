import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text('Privacy Policy'),
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
              title: '1. Information We Collect',
              content:
              'We collect information that you provide directly to us, including:\n\n• Name, email address, phone number\n• Payment information\n• Location data\n• Profile information\n• Emergency contact details',
            ),
            _buildSection(
              context,
              title: '2. How We Use Your Information',
              content:
              'We use the information we collect to:\n\n• Provide, maintain, and improve our services\n• Process transactions and send related information\n• Send you technical notices and support messages\n• Respond to your comments and questions\n• Monitor and analyze trends and usage',
            ),
            _buildSection(
              context,
              title: '3. Information Sharing',
              content:
              'We do not sell, trade, or rent your personal information to third parties. We may share your information only in the following circumstances:\n\n• With your consent\n• To comply with legal obligations\n• To protect and defend our rights\n• With service providers who assist us in operating our service',
            ),
            _buildSection(
              context,
              title: '4. Data Security',
              content:
              'We implement appropriate technical and organizational security measures to protect your personal information. However, no method of transmission over the Internet is 100% secure.',
            ),
            _buildSection(
              context,
              title: '5. Your Rights',
              content:
              'You have the right to:\n\n• Access your personal information\n• Correct inaccurate data\n• Request deletion of your data\n• Object to processing of your data\n• Data portability',
            ),
            _buildSection(
              context,
              title: '6. Location Data',
              content:
              'We collect location data to provide ride-sharing services. You can control location sharing through your device settings, but this may limit app functionality.',
            ),
            _buildSection(
              context,
              title: '7. Children\'s Privacy',
              content:
              'Our service is not intended for children under 18. We do not knowingly collect personal information from children under 18.',
            ),
            _buildSection(
              context,
              title: '8. Changes to This Policy',
              content:
              'We may update our Privacy Policy from time to time. We will notify you of any changes by posting the new Privacy Policy on this page.',
            ),
            const SizedBox(height: 32),
            Card(
              color: AppTheme.primaryColor.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.privacy_tip, color: AppTheme.primaryColor),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'If you have any questions about this Privacy Policy, please contact us at support@baneen.com',
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


