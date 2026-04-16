



import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../controller/storage_services.dart' as auth_storage;
import '../../../core/constants/api_constants.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../services/cookie_manager.dart';
import 'http_client_otp.dart';

class DriverOtpVerificationScreen extends StatefulWidget {
  final String? phone;
  final String? email;
  final String userType;

  const DriverOtpVerificationScreen({
    super.key,
    this.phone,
    this.email,
    required this.userType,
  });

  @override
  State<DriverOtpVerificationScreen> createState() => _DriverOtpVerificationScreenState();
}

class _DriverOtpVerificationScreenState extends State<DriverOtpVerificationScreen> {
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  bool _isLoading = false;
  bool _isResending = false;
  int _resendCountdown = 0;

  @override
  void initState() {
    super.initState();
    _startResendCountdown();
    WidgetsBinding.instance.addPostFrameCallback((_) => _focusNodes[0].requestFocus());
  }

  void _startResendCountdown() {
    setState(() => _resendCountdown = 60);
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        setState(() => _resendCountdown--);
        return _resendCountdown > 0;
      }
      return false;
    });
  }

  String _getOtp() => _controllers.map((c) => c.text.trim()).join();

  Future<void> _verifyOtp(String otp) async {
    if (otp.length != 6) {
      _showSnackBar('Enter 6-digit OTP', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.verifyDriverOtp}');

      final body = {
        'otp': otp,
        if (widget.phone != null) 'phone': widget.phone,
        if (widget.email != null) 'email': widget.email,
      };

      final response = await http.post(
        uri,
        headers: SimpleDriverCookieManager.attachCookie({
          'Content-Type': 'application/json',
        }),
        body: jsonEncode(body),
      );

      print('VERIFY (driver) → Status: ${response.statusCode}');
      print('VERIFY (driver) → Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        if (json['success'] == true) {
          // Save tokens to same storage as login (same as passenger OTP)
          final data = json['data'] as Map<String, dynamic>? ?? json;
          final accessToken = json['accessToken'] ?? json['token'] ?? json['access_token'] ??
              data['accessToken'] ?? data['token'] ?? data['access_token'];
          final refreshToken = json['refreshToken'] ?? json['refresh_token'] ??
              data['refreshToken'] ?? data['refresh_token'];
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool(AppConstants.prefIsLoggedIn, true);
          if (accessToken != null && accessToken.toString().isNotEmpty) {
            await prefs.setString(AppConstants.storageToken, accessToken.toString());
            await prefs.setString('access_token', accessToken.toString());
            final storage = await auth_storage.getStorageService();
            await storage.saveAccessToken(accessToken.toString());
            await storage.saveUserType(widget.userType);
            if (refreshToken != null && refreshToken.toString().isNotEmpty) {
              await prefs.setString('refresh_token', refreshToken.toString());
              await storage.saveRefreshToken(refreshToken.toString());
            }
            SimpleDriverCookieManager.saveCookieFromTokens(accessToken.toString(), refreshToken?.toString());
          } else {
            final storage = await auth_storage.getStorageService();
            await storage.saveUserType(widget.userType);
          }

          if (context.mounted) {
            context.go(widget.userType == AppConstants.userTypePassenger ? '/home' : '/driver');
          }
          setState(() => _isLoading = false);
          return;
        }
      }

      // Incorrect OTP or API error – do not navigate (same as passenger)
      String message = 'Incorrect OTP';
      try {
        final errJson = jsonDecode(response.body) as Map<String, dynamic>?;
        message = errJson?['message']?.toString() ?? message;
      } catch (_) {}
      _showSnackBar(message, isError: true);
    } catch (e) {
      _showSnackBar('Network error', isError: true);
    }

    setState(() => _isLoading = false);
  }

  Future<void> _resendOtp() async {
    if (_resendCountdown > 0 || _isResending) return;
    setState(() => _isResending = true);

    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.resendOtp}');

      final body = <String, dynamic>{};
      if (widget.phone != null) body['phone'] = widget.phone;
      if (widget.email != null) body['email'] = widget.email;

      final headers = {'Content-Type': 'application/json'};

      final response = await PersistentHttpClient.instance.post(
        uri,
        headers: headers,
        body: jsonEncode(body),
      );

      print('RESEND (driver) → Status: ${response.statusCode}');
      print('RESEND (driver) → Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        _showSnackBar('OTP resent', isError: false);
        _startResendCountdown();
      } else {
        String msg = 'Resend failed';
        try {
          final json = jsonDecode(response.body);
          msg = json['message'] ?? msg;
        } catch (_) {}
        _showSnackBar(msg, isError: true);
      }
    } catch (e) {
      _showSnackBar('Network error', isError: true);
    } finally {
      if (mounted) setState(() => _isResending = false);
    }
  }

  void _showSnackBar(String message, {required bool isError}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppTheme.errorColor : AppTheme.successColor,
      ),
    );
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.maybePop(context)),
        title: const Text('Verify OTP'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              const Icon(Icons.verified_user, size: 80, color: AppTheme.primaryColor),
              const SizedBox(height: 24),
              Text('Enter Verification Code', style: Theme.of(context).textTheme.displaySmall, textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text(
                widget.phone != null ? 'Code sent to ${widget.phone}' : 'Code sent to ${widget.email ?? "your email"}',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(6, (index) {
                  return SizedBox(
                    width: 50,
                    child: TextField(
                      controller: _controllers[index],
                      focusNode: _focusNodes[index],
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      maxLength: 1,
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        counterText: '',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
                        ),
                      ),
                      onChanged: (value) {
                        if (value.length == 1 && index < 5) _focusNodes[index + 1].requestFocus();
                        if (value.isEmpty && index > 0) _focusNodes[index - 1].requestFocus();
                        if (index == 5 && _getOtp().length == 6) _verifyOtp(_getOtp());
                      },
                    ),
                  );
                }),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _isLoading ? null : () => _verifyOtp(_getOtp()),
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                child: _isLoading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Verify OTP'),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Didn't receive code? "),
                  TextButton(
                    onPressed: _resendCountdown > 0 || _isResending ? null : _resendOtp,
                    child: Text(_resendCountdown > 0 ? 'Resend in ${_resendCountdown}s' : 'Resend OTP'),
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