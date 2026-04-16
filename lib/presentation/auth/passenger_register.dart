


import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'dart:io';

import '../../controller/passenger_register_provider.dart';
import '../../core/theme/app_theme.dart';


class PassengerRegisterForm extends StatefulWidget {
  const PassengerRegisterForm({super.key});

  @override
  State<PassengerRegisterForm> createState() => _PassengerRegisterFormState();
}

class _PassengerRegisterFormState extends State<PassengerRegisterForm> {
  final _scrollController = ScrollController();

  // Controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cnicController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  File? _profilePicturePreview;
  File? _cnicPicturePreview;

  final ImagePicker _picker = ImagePicker();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // Hover states
  bool _isHoveringCamera = false;
  bool _isHoveringUpload = false;
  bool _isHoveringPasswordVisibility = false;
  bool _isHoveringConfirmPasswordVisibility = false;
  bool _isHoveringName = false;
  bool _isHoveringEmail = false;
  bool _isHoveringPhone = false;
  bool _isHoveringCnic = false;
  bool _isHoveringPassword = false;
  bool _isHoveringConfirmPassword = false;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<PassengerRegisterProvider>(context, listen: false);

    _nameController.text = provider.fullName;
    _emailController.text = provider.email;
    _phoneController.text = provider.phone;
    _cnicController.text = provider.cnic;
    _passwordController.text = provider.password;
    _confirmPasswordController.text = provider.confirmPassword;

    _profilePicturePreview = provider.profilePicture;
    _cnicPicturePreview = provider.cnicPicture;

    _passwordController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _cnicController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _pickProfileImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      if (image != null && mounted) {
        final file = File(image.path);
        setState(() => _profilePicturePreview = file);
        Provider.of<PassengerRegisterProvider>(context, listen: false).setImage('profile', file);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e'), backgroundColor: AppTheme.errorColor),
        );
      }
    }
  }

  Future<void> _pickCnicImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 90,
      );
      if (image != null && mounted) {
        final file = File(image.path);
        setState(() => _cnicPicturePreview = file);
        Provider.of<PassengerRegisterProvider>(context, listen: false).setImage('cnic', file);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking CNIC: $e'), backgroundColor: AppTheme.errorColor),
        );
      }
    }
  }

  bool _hasMinLength() => _passwordController.text.length >= 8;
  bool _hasUppercase() => _passwordController.text.contains(RegExp(r'[A-Z]'));
  bool _hasLowercase() => _passwordController.text.contains(RegExp(r'[a-z]'));
  bool _hasDigits() => _passwordController.text.contains(RegExp(r'[0-9]'));
  bool _hasSpecial() => _passwordController.text.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

  @override
  Widget build(BuildContext context) {
    return Consumer<PassengerRegisterProvider>(
      builder: (context, provider, _) {
        return SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Profile Picture
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: AppTheme.primaryLight,
                      backgroundImage: _profilePicturePreview != null ? FileImage(_profilePicturePreview!) : null,
                      child: _profilePicturePreview == null
                          ? const Icon(Icons.person, size: 60, color: AppTheme.primaryColor)
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: CircleAvatar(
                        radius: 20,
                        backgroundColor: AppTheme.primaryColor,
                        child: MouseRegion(
                          onEnter: (_) => setState(() => _isHoveringCamera = true),
                          onExit: (_) => setState(() => _isHoveringCamera = false),
                          child: IconButton(
                            icon: const Icon(Icons.camera_alt, size: 20),
                            color: _isHoveringCamera ? Colors.grey : Colors.white,
                            onPressed: provider.isLoading ? null : _pickProfileImage,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Full Name
              MouseRegion(
                onEnter: (_) => setState(() => _isHoveringName = true),
                onExit: (_) => setState(() => _isHoveringName = false),
                child: TextFormField(
                  controller: _nameController,
                  decoration: _inputDecoration('Full Name', 'Enter your full name', Icons.person, _isHoveringName),
                  onChanged: (v) => provider.updateField('fullName', v),
                ),
              ),
              if (provider.fullNameError != null) ...[
                const SizedBox(height: 4),
                Text(
                  provider.fullNameError!,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ],
              const SizedBox(height: 16),

              // Email
              MouseRegion(
                onEnter: (_) => setState(() => _isHoveringEmail = true),
                onExit: (_) => setState(() => _isHoveringEmail = false),
                child: TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: _inputDecoration('Email', 'example@gmail.com', Icons.email, _isHoveringEmail),
                  onChanged: (v) => provider.updateField('email', v),
                ),
              ),
              if (provider.emailError != null) ...[
                const SizedBox(height: 4),
                Text(
                  provider.emailError!,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ],
              const SizedBox(height: 16),

              // Phone
              MouseRegion(
                onEnter: (_) => setState(() => _isHoveringPhone = true),
                onExit: (_) => setState(() => _isHoveringPhone = false),
                child: TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: _inputDecoration('Phone Number', '03XXXXXXXXX', Icons.phone, _isHoveringPhone),
                  onChanged: (v) => provider.updateField('phone', v),
                ),
              ),
              if (provider.phoneError != null) ...[
                const SizedBox(height: 4),
                Text(
                  provider.phoneError!,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ],
              const SizedBox(height: 16),

              // CNIC
              MouseRegion(
                onEnter: (_) => setState(() => _isHoveringCnic = true),
                onExit: (_) => setState(() => _isHoveringCnic = false),
                child: TextFormField(
                  controller: _cnicController,
                  keyboardType: TextInputType.number,
                  decoration: _inputDecoration('CNIC', '12345-1234567-1', Icons.badge, _isHoveringCnic),
                  onChanged: (v) => provider.updateField('cnic', v),
                ),
              ),
              if (provider.cnicError != null) ...[
                const SizedBox(height: 4),
                Text(
                  provider.cnicError!,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ],
              const SizedBox(height: 16),

              // CNIC Picture
              Text('CNIC Picture', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: provider.isLoading ? null : _pickCnicImage,
                child: _buildUploadContainer(
                  image: _cnicPicturePreview,
                  placeholder: Icons.badge,
                  text: _cnicPicturePreview != null ? 'CNIC image selected' : 'Tap to upload CNIC picture',
                ),
              ),
              if (provider.generalError != null && provider.generalError!.contains('CNIC')) ...[
                const SizedBox(height: 4),
                Text(
                  provider.generalError!,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ],
              const SizedBox(height: 24),

              // Password
              MouseRegion(
                onEnter: (_) => setState(() => _isHoveringPassword = true),
                onExit: (_) => setState(() => _isHoveringPassword = false),
                child: TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    hintText: 'Enter password',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: MouseRegion(
                      onEnter: (_) => setState(() => _isHoveringPasswordVisibility = true),
                      onExit: (_) => setState(() => _isHoveringPasswordVisibility = false),
                      child: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off : Icons.visibility,
                          color: _isHoveringPasswordVisibility ? Colors.grey : null,
                        ),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                    labelStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                    hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: _isHoveringPassword ? Colors.grey : Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
                    ),
                  ),
                  onChanged: (v) => provider.updateField('password', v),
                ),
              ),
              if (provider.passwordError != null) ...[
                const SizedBox(height: 4),
                Text(
                  provider.passwordError!,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ],
              const SizedBox(height: 8),

              // Password strength indicators
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'add 8 characters,digits,uppercase,lowercase and special characters',
                      style: TextStyle(color: Colors.red, fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    _buildRequirementItem('8 characters', _hasMinLength()),
                    _buildRequirementItem('Uppercase', _hasUppercase()),
                    _buildRequirementItem('Lowercase', _hasLowercase()),
                    _buildRequirementItem('Digits', _hasDigits()),
                    _buildRequirementItem('Special characters', _hasSpecial()),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Confirm Password
              MouseRegion(
                onEnter: (_) => setState(() => _isHoveringConfirmPassword = true),
                onExit: (_) => setState(() => _isHoveringConfirmPassword = false),
                child: TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    hintText: 'Enter password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: MouseRegion(
                      onEnter: (_) => setState(() => _isHoveringConfirmPasswordVisibility = true),
                      onExit: (_) => setState(() => _isHoveringConfirmPasswordVisibility = false),
                      child: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                          color: _isHoveringConfirmPasswordVisibility ? Colors.grey : null,
                        ),
                        onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                      ),
                    ),
                    labelStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                    hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: _isHoveringConfirmPassword ? Colors.grey : Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
                    ),
                  ),
                  onChanged: (v) => provider.updateField('confirmPassword', v),
                ),
              ),
              if (provider.confirmPasswordError != null) ...[
                const SizedBox(height: 4),
                Text(
                  provider.confirmPasswordError!,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ],
              const SizedBox(height: 32),

              // General error (images wala)
              if (provider.generalError != null) ...[
                Text(
                  provider.generalError!,
                  style: const TextStyle(color: Colors.red, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
              ],

              ElevatedButton(
                onPressed: provider.isLoading
                    ? null
                    : () async {
                  final success = await provider.tryRegister(context);
                  if (!success) {
                    // Scroll to top ya error field pe le ja sakte ho
                    _scrollController.animateTo(
                      0,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                },
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                child: provider.isLoading
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Colors.white)),
                )
                    : const Text('Register'),
              ),
              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Already have an account? "),
                  TextButton(
                    onPressed: () => context.pop(),
                    child: const Text('Login'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  InputDecoration _inputDecoration(String label, String hint, IconData icon, bool hovering) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon),
      labelStyle: const TextStyle(color: Colors.grey, fontSize: 14),
      hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: hovering ? Colors.grey : Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
      ),
    );
  }

  Widget _buildUploadContainer({
    required File? image,
    required IconData placeholder,
    required String text,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: image != null ? AppTheme.primaryColor : Colors.grey.shade300),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.08), blurRadius: 6, offset: const Offset(0, 3))],
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.backgroundColor,
              borderRadius: BorderRadius.circular(8),
              image: image != null ? DecorationImage(image: FileImage(image), fit: BoxFit.cover) : null,
            ),
            child: image == null ? Icon(placeholder, color: AppTheme.textSecondary) : null,
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: Theme.of(context).textTheme.bodyLarge)),
          MouseRegion(
            onEnter: (_) => setState(() => _isHoveringUpload = true),
            onExit: (_) => setState(() => _isHoveringUpload = false),
            child: Icon(Icons.upload, color: _isHoveringUpload ? Colors.grey : AppTheme.primaryColor),
          ),
        ],
      ),
    );
  }

  Widget _buildRequirementItem(String text, bool isMet) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle : Icons.circle_outlined,
            size: 16,
            color: isMet ? Colors.grey : Colors.red,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: isMet ? Colors.grey : Colors.red,
              fontSize: 12,
              decoration: isMet ? TextDecoration.lineThrough : null,
            ),
          ),
        ],
      ),
    );
  }
}