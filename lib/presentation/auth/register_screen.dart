

import 'package:baneen/presentation/auth/passenger_register.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../controller/driver_register_provider.dart';
import '../../controller/passenger_register_provider.dart';
import '../../core/constants/app_constants.dart';
import 'driver_register.dart';


class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  String _selectedUserType = AppConstants.userTypePassenger;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Create Account'),
      ),
      body: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => PassengerRegisterProvider()),
          ChangeNotifierProvider(create: (_) => DriverRegisterProvider()),
        ],
        child: Column(
          children: [
            // User Type Selection
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'I am a:',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ChoiceChip(
                          label: const Center(child: Text('Passenger')),
                          selected: _selectedUserType == AppConstants.userTypePassenger,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() => _selectedUserType = AppConstants.userTypePassenger);
                            }
                          },
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ChoiceChip(
                          label: const Center(child: Text('Driver')),
                          selected: _selectedUserType == AppConstants.userTypeDriver,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() => _selectedUserType = AppConstants.userTypeDriver);
                            }
                          },
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Form content
            Expanded(
              child: _selectedUserType == AppConstants.userTypePassenger
                  ? const PassengerRegisterForm()
                  : const DriverRegisterForm(),
            ),
          ],
        ),
      ),
    );
  }
}