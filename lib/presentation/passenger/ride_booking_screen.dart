
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../shared/voice_command_service.dart';
import 'active_ride_screen.dart';

class RideBookingScreen extends StatefulWidget {
  final String? pickup;
  final String? destination;
  final String? paymentMethod;

  const RideBookingScreen({
    super.key,
    this.pickup,
    this.destination,
    this.paymentMethod,
  });

  @override
  State<RideBookingScreen> createState() => _RideBookingScreenState();
}

class _RideBookingScreenState extends State<RideBookingScreen> {
  String? _selectedVehicleType = AppConstants.vehicleTypeCar;
  DateTime? _scheduledTime;
  bool _isScheduled = false;
  bool _isLoading = false;
  bool _isListeningPickup = false;
  bool _isListeningDestination = false;
  final VoiceCommandService _voiceService = VoiceCommandService();
  final TextEditingController _pickupController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _pickupController.text = widget.pickup ?? '';
    _destinationController.text = widget.destination ?? '';
  }

  @override
  void dispose() {
    _pickupController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  Future<void> _bookRide() async {
    if (_pickupController.text.isEmpty || _destinationController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select pickup and destination'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Show searching for driver dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 24),
              Text(
                'Searching for driver...',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Please wait while we find the nearest available driver',
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );

    try {
      // Simulate searching for driver
      await Future.delayed(const Duration(seconds: 3));

      if (mounted) {
        Navigator.of(context).pop();
        context.push('/active-ride');
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to book ride: $e'),
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

  Future<void> _selectScheduleTime() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 7)),
    );

    if (picked != null) {
      final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (time != null) {
        setState(() {
          _scheduledTime = DateTime(
            picked.year,
            picked.month,
            picked.day,
            time.hour,
            time.minute,
          );
          _isScheduled = true;
        });
      }
    }
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
            _isListeningPickup = false;
          } else {
            _destinationController.text = result;
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

  String _getEstimatedFare() {
    if (_selectedVehicleType == AppConstants.vehicleTypeCar) {
      return 'PKR 250';
    } else if (_selectedVehicleType == AppConstants.vehicleTypeBike) {
      return 'PKR 150';
    }
    return 'PKR 250';
  }

  String _getPaymentMethodName() {
    switch (widget.paymentMethod) {
      case AppConstants.paymentMethodCash:
        return 'Cash';
      case AppConstants.paymentMethodEasyPaisa:
        return 'EasyPaisa';
      case AppConstants.paymentMethodJazzCash:
        return 'JazzCash';
      default:
        return 'Cash';
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
        title: const Text('Book Ride'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Simple Map Image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                height: 300,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Image.asset(
                  'assets/images/googlemap.jpeg', // <-- your map image path
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Location Summary
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
                          child: TextField(
                            controller: _pickupController,
                            decoration: InputDecoration(
                              hintText: 'Pickup Location',
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
                          child: TextField(
                            controller: _destinationController,
                            decoration: InputDecoration(
                              hintText: 'Destination',
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
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Vehicle Type Selection
            Text(
              'Select Vehicle Type',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildVehicleTypeCard(
                    AppConstants.vehicleTypeCar,
                    Icons.directions_car,
                    'Car',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildVehicleTypeCard(
                    AppConstants.vehicleTypeBike,
                    Icons.two_wheeler,
                    'Bike',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Schedule Ride Option
            Card(
              child: SwitchListTile(
                title: const Text('Schedule Ride'),
                subtitle: _isScheduled && _scheduledTime != null
                    ? Text(
                  'Scheduled for ${_scheduledTime!.toString().substring(0, 16)}',
                )
                    : null,
                value: _isScheduled,
                onChanged: (value) {
                  if (value) {
                    _selectScheduleTime();
                  } else {
                    setState(() {
                      _isScheduled = false;
                      _scheduledTime = null;
                    });
                  }
                },
              ),
            ),
            const SizedBox(height: 24),
            // Estimated Fare
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Estimated Fare',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getEstimatedFare(),
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium
                          ?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Payment Method: ${_getPaymentMethodName()}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            // Book Ride Button
            ElevatedButton(
              onPressed: _isLoading ? null : _bookRide,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor:
                  AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
                  : const Text('Confirm Booking'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleTypeCard(String type, IconData icon, String label) {
    final isSelected = _selectedVehicleType == type;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedVehicleType = type;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryLight.withOpacity(0.3)
              : Colors.white,
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 40,
              color: isSelected ? AppTheme.primaryColor : AppTheme.textSecondary,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? AppTheme.primaryColor : AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

