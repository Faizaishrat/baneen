import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_theme.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (!await canLaunchUrl(uri)) {
      throw 'Could not launch $url';
    }
    await launchUrl(uri);
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final uri = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _sendEmail(String email) async {
    final uri = Uri.parse('mailto:$email');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text('Help & Support'),
      ),
      body: ListView(
        children: [
          // Contact Support Section
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Contact Support',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.phone, color: AppTheme.primaryColor),
                  title: const Text('Call Support'),
                  subtitle: const Text('+92 300 1234567'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => _makePhoneCall('+923001234567'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.email, color: AppTheme.primaryColor),
                  title: const Text('Email Support'),
                  subtitle: const Text('support@baneen.com'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => _sendEmail('support@baneen.com'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.chat, color: AppTheme.primaryColor),
                  title: const Text('Live Chat'),
                  subtitle: const Text('Chat with our support team'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    context.push('/live-chat');
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // FAQ Section
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Frequently Asked Questions',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          _buildFAQItem(
            context,
            question: 'How do I book a ride?',
            answer:
            'Open the app, enter your pickup and destination locations, select your vehicle type, and tap "Book Ride".',
          ),
          _buildFAQItem(
            context,
            question: 'How do I pay for a ride?',
            answer:
            'You can pay using cash, EasyPaisa, or JazzCash. Payment methods can be managed in your profile settings.',
          ),
          _buildFAQItem(
            context,
            question: 'What if I need to cancel a ride?',
            answer:
            'You can cancel a ride from the active ride screen. Please note that cancellation fees may apply depending on the timing.',
          ),
          _buildFAQItem(
            context,
            question: 'How do I add emergency contacts?',
            answer:
            'Go to your profile, tap on "Emergency Contacts", and add your emergency contacts for your safety.',
          ),
          _buildFAQItem(
            context,
            question: 'Is my data safe?',
            answer:
            'Yes, we take your privacy seriously. All your data is encrypted and stored securely. Check our Privacy Policy for more details.',
          ),
          const SizedBox(height: 16),
          // Resources Section
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Resources',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.description, color: AppTheme.primaryColor),
            title: const Text('Terms of Service'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              context.push('/terms-of-service');
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.privacy_tip, color: AppTheme.primaryColor),
            title: const Text('Privacy Policy'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              context.push('/privacy-policy');
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info, color: AppTheme.primaryColor),
            title: const Text('About Baneen'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'Baneen',
                applicationVersion: '1.0.0',
                applicationIcon: const Icon(Icons.directions_car, size: 48),
                children: [
                  const Text(
                    'Baneen is a safe and reliable ride-sharing app designed for women.',
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFAQItem(BuildContext context, {required String question, required String answer}) {
    return ExpansionTile(
      title: Text(question),
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            answer,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}

