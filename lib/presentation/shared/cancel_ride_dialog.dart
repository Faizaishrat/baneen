import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';

class CancelRideDialog extends StatefulWidget {
  final bool isDriver;
  final String? rideStatus; // To determine if cancellation fee applies

  const CancelRideDialog({
    super.key,
    this.isDriver = false,
    this.rideStatus,
  });

  @override
  State<CancelRideDialog> createState() => _CancelRideDialogState();
}

class _CancelRideDialogState extends State<CancelRideDialog> {
  String? _selectedReason;
  final TextEditingController _otherReasonController = TextEditingController();
  bool _showOtherField = false;

  List<String> get _cancellationReasons {
    return widget.isDriver
        ? AppConstants.driverCancellationReasons
        : AppConstants.passengerCancellationReasons;
  }

  bool get _hasCancellationFee {
    // Cancellation fee applies if driver has accepted the ride
    return widget.rideStatus == AppConstants.rideStatusAccepted ||
        widget.rideStatus == AppConstants.rideStatusInProgress;
  }

  @override
  void dispose() {
    _otherReasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Cancel Ride'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Please select a reason for cancellation:',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            ..._cancellationReasons.map((reason) {
              return RadioListTile<String>(
                title: Text(reason),
                value: reason,
                groupValue: _selectedReason,
                onChanged: (value) {
                  setState(() {
                    _selectedReason = value;
                    _showOtherField = value == 'Other';
                    if (!_showOtherField) {
                      _otherReasonController.clear();
                    }
                  });
                },
                dense: true,
                contentPadding: EdgeInsets.zero,
              );
            }),
            if (_showOtherField) ...[
              const SizedBox(height: 8),
              TextField(
                controller: _otherReasonController,
                decoration: const InputDecoration(
                  hintText: 'Please specify...',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                maxLines: 2,
                autofocus: true,
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Back'),
        ),
        ElevatedButton(
          onPressed: _selectedReason == null ||
              (_showOtherField && _otherReasonController.text.trim().isEmpty)
              ? null
              : () {
            final reason = _showOtherField
                ? _otherReasonController.text.trim()
                : _selectedReason!;
            Navigator.of(context).pop(reason);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.errorColor,
          ),
          child: const Text('Cancel Ride'),
        ),
      ],
    );
  }
}

