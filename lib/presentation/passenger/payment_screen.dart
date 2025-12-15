import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/helpers.dart';
import 'rating_screen.dart';

class PaymentScreen extends StatefulWidget {
  final double amount;
  final bool isSubscription;
  final String? rideId;

  const PaymentScreen({
    super.key,
    required this.amount,
    this.isSubscription = false,
    this.rideId,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String _selectedPaymentMethod = AppConstants.paymentMethodCash;
  final _easyPaisaController = TextEditingController();
  final _jazzCashController = TextEditingController();
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    // For subscriptions, default to EasyPaisa
    if (widget.isSubscription) {
      _selectedPaymentMethod = AppConstants.paymentMethodEasyPaisa;
    }
  }

  @override
  void dispose() {
    _easyPaisaController.dispose();
    _jazzCashController.dispose();
    super.dispose();
  }

  Future<void> _processPayment() async {
    if (_selectedPaymentMethod == AppConstants.paymentMethodEasyPaisa) {
      // Validate EasyPaisa phone number
      if (_easyPaisaController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter your EasyPaisa phone number'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
        return;
      }
    } else if (_selectedPaymentMethod == AppConstants.paymentMethodJazzCash) {
      // Validate JazzCash phone number
      if (_jazzCashController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter your JazzCash phone number'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
        return;
      }
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      // TODO: Implement actual payment processing
      await Future.delayed(const Duration(seconds: 2)); // Simulate API call

      if (mounted) {
        if (widget.isSubscription) {
          // Navigate back on subscription
          context.pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Subscription activated successfully!'),
              backgroundColor: AppTheme.successColor,
            ),
          );
        } else {
          // Navigate to rating screen after ride payment
          context.push('/rating', extra: {'rideId': widget.rideId});
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment failed: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
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
        title: Text(widget.isSubscription ? 'Subscribe' : 'Payment'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Amount Display
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Text(
                      widget.isSubscription
                          ? 'Subscription Amount'
                          : 'Total Amount',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      Helpers.formatCurrency(widget.amount),
                      style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Payment Method Selection
            Text(
              'Select Payment Method',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            // Cash Option (only for non-subscription)
            if (!widget.isSubscription)
              RadioListTile<String>(
                title: const Text('Cash'),
                subtitle: const Text('Pay directly to driver'),
                value: AppConstants.paymentMethodCash,
                groupValue: _selectedPaymentMethod,
                onChanged: (value) {
                  setState(() {
                    _selectedPaymentMethod = value!;
                  });
                },
              ),
            // EasyPaisa Option (only for subscription)
            if (widget.isSubscription)
              RadioListTile<String>(
                title: const Text('EasyPaisa'),
                subtitle: const Text('Pay via EasyPaisa'),
                value: AppConstants.paymentMethodEasyPaisa,
                groupValue: _selectedPaymentMethod,
                onChanged: (value) {
                  setState(() {
                    _selectedPaymentMethod = value!;
                  });
                },
              ),
            // JazzCash Option (only for subscription)
            if (widget.isSubscription)
              RadioListTile<String>(
                title: const Text('JazzCash'),
                subtitle: const Text('Pay via JazzCash'),
                value: AppConstants.paymentMethodJazzCash,
                groupValue: _selectedPaymentMethod,
                onChanged: (value) {
                  setState(() {
                    _selectedPaymentMethod = value!;
                  });
                },
              ),
            // EasyPaisa Details (if EasyPaisa selected)
            if (_selectedPaymentMethod == AppConstants.paymentMethodEasyPaisa) ...[
              const SizedBox(height: 16),
              TextFormField(
                controller: _easyPaisaController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'EasyPaisa Phone Number',
                  hintText: '03XXXXXXXXX',
                  prefixIcon: Icon(Icons.phone),
                ),
              ),
            ],
            // JazzCash Details (if JazzCash selected)
            if (_selectedPaymentMethod == AppConstants.paymentMethodJazzCash) ...[
              const SizedBox(height: 16),
              TextFormField(
                controller: _jazzCashController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'JazzCash Phone Number',
                  hintText: '03XXXXXXXXX',
                  prefixIcon: Icon(Icons.phone),
                ),
              ),
            ],
            const SizedBox(height: 32),
            // Pay Button
            ElevatedButton(
              onPressed: _isProcessing ? null : _processPayment,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isProcessing
                  ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
                  : Text(widget.isSubscription ? 'Subscribe' : 'Pay Now'),
            ),
          ],
        ),
      ),
    );
  }
}

