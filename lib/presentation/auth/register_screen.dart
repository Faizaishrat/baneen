import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/validators.dart';
import '../../core/constants/app_constants.dart';
import 'dart:io';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cnicController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Driver-specific fields
  final _vehicleNameController = TextEditingController();
  final _carOwnerNameController = TextEditingController();
  final _carOwnerDetailsController = TextEditingController();
  final _drivingLicenseController = TextEditingController();
  final _addressController = TextEditingController();
  final _alternateNumberController = TextEditingController();
  final _ownerNameController = TextEditingController();
  final _ownerCnicController = TextEditingController();
  final _ownerEmailController = TextEditingController();
  final _ownerPhoneController = TextEditingController();

  // Focus nodes for auto-focusing on errors
  final _nameFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _phoneFocusNode = FocusNode();
  final _cnicFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();
  final _vehicleNameFocusNode = FocusNode();
  final _carOwnerTypeFocusNode = FocusNode();
  final _ownerNameFocusNode = FocusNode();
  final _ownerCnicFocusNode = FocusNode();
  final _ownerEmailFocusNode = FocusNode();
  final _ownerPhoneFocusNode = FocusNode();
  final _drivingLicenseFocusNode = FocusNode();
  final _addressFocusNode = FocusNode();

  // GlobalKeys for form fields to scroll to them
  final Map<String, GlobalKey> _fieldKeys = {};

  String _selectedUserType = AppConstants.userTypePassenger;
  String? _selectedVehicleType; // 'car' or 'bike'
  String? _carOwnerType; // 'me' or 'not_me'
  File? _profilePicture;
  File? _cnicPicture;
  File? _drivingLicensePicture;
  File? _vehiclePermitPicture;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  final ImagePicker _picker = ImagePicker();
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
    _passwordController.addListener(_onPasswordChanged);
    // Initialize field keys
    _fieldKeys['name'] = GlobalKey();
    _fieldKeys['email'] = GlobalKey();
    _fieldKeys['phone'] = GlobalKey();
    _fieldKeys['cnic'] = GlobalKey();
    _fieldKeys['password'] = GlobalKey();
    _fieldKeys['confirmPassword'] = GlobalKey();
    _fieldKeys['vehicleName'] = GlobalKey();
    _fieldKeys['carOwnerType'] = GlobalKey();
    _fieldKeys['ownerName'] = GlobalKey();
    _fieldKeys['ownerEmail'] = GlobalKey();
    _fieldKeys['ownerPhone'] = GlobalKey();
    _fieldKeys['ownerCnic'] = GlobalKey();
    _fieldKeys['drivingLicense'] = GlobalKey();
    _fieldKeys['address'] = GlobalKey();
  }

  @override
  void dispose() {
    _passwordController.removeListener(_onPasswordChanged);
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _cnicController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _vehicleNameController.dispose();
    _carOwnerNameController.dispose();
    _carOwnerDetailsController.dispose();
    _drivingLicenseController.dispose();
    _addressController.dispose();
    _alternateNumberController.dispose();
    _ownerNameController.dispose();
    _ownerCnicController.dispose();
    _ownerEmailController.dispose();
    _ownerPhoneController.dispose();
    _scrollController.dispose();
    _nameFocusNode.dispose();
    _emailFocusNode.dispose();
    _phoneFocusNode.dispose();
    _cnicFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    _vehicleNameFocusNode.dispose();
    _carOwnerTypeFocusNode.dispose();
    _ownerNameFocusNode.dispose();
    _ownerCnicFocusNode.dispose();
    _ownerEmailFocusNode.dispose();
    _ownerPhoneFocusNode.dispose();
    _drivingLicenseFocusNode.dispose();
    _addressFocusNode.dispose();
    super.dispose();
  }

  void _onPasswordChanged() {
    setState(() {}); // Update UI when password changes
  }

  bool _hasMinLength(String password) => password.length >= 8;
  bool _hasUppercase(String password) => password.contains(RegExp(r'[A-Z]'));
  bool _hasLowercase(String password) => password.contains(RegExp(r'[a-z]'));
  bool _hasDigits(String password) => password.contains(RegExp(r'[0-9]'));
  bool _hasSpecialChars(String password) => password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _profilePicture = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
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

      if (image != null) {
        setState(() {
          _cnicPicture = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking CNIC image: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  Future<void> _pickDrivingLicenseImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 90,
      );

      if (image != null) {
        setState(() {
          _drivingLicensePicture = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking driving license image: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  Future<void> _pickVehiclePermitImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 90,
      );

      if (image != null) {
        setState(() {
          _vehiclePermitPicture = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking vehicle permit image: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  void _scrollToFirstError() {
    // Validate each field individually to find the first error
    String? firstErrorField;

    // Check each field in order
    if (Validators.validateName(_nameController.text) != null) {
      firstErrorField = 'name';
    } else if (Validators.validateEmail(_emailController.text) != null) {
      firstErrorField = 'email';
    } else if (Validators.validatePhone(_phoneController.text) != null) {
      firstErrorField = 'phone';
    } else if (Validators.validateCNIC(_cnicController.text) != null) {
      firstErrorField = 'cnic';
    } else if (_selectedUserType == AppConstants.userTypeDriver) {
      if (_vehicleNameController.text.isEmpty) {
        firstErrorField = 'vehicleName';
      } else if (_carOwnerType == null) {
        firstErrorField = 'carOwnerType';
      } else if (_carOwnerType == 'not_me') {
        if (_ownerNameController.text.isEmpty) {
          firstErrorField = 'ownerName';
        } else if (Validators.validateEmail(_ownerEmailController.text) != null) {
          firstErrorField = 'ownerEmail';
        } else if (Validators.validatePhone(_ownerPhoneController.text) != null) {
          firstErrorField = 'ownerPhone';
        } else if (_ownerCnicController.text.isEmpty || Validators.validateCNIC(_ownerCnicController.text) != null) {
          firstErrorField = 'ownerCnic';
        } else if (_drivingLicenseController.text.isEmpty) {
          firstErrorField = 'drivingLicense';
        } else if (_addressController.text.isEmpty) {
          firstErrorField = 'address';
        }
      } else if (_drivingLicenseController.text.isEmpty) {
        firstErrorField = 'drivingLicense';
      } else if (_addressController.text.isEmpty) {
        firstErrorField = 'address';
      }
    }

    if (firstErrorField == null) {
      // Check password fields
      if (Validators.validatePassword(_passwordController.text) != null) {
        firstErrorField = 'password';
      } else if (_validateConfirmPassword(_confirmPasswordController.text) != null) {
        firstErrorField = 'confirmPassword';
      }
    }

    // Scroll to and focus the first error field
    if (firstErrorField != null) {
      final key = _fieldKeys[firstErrorField];
      FocusNode? focusNode;

      switch (firstErrorField) {
        case 'name':
          focusNode = _nameFocusNode;
          break;
        case 'email':
          focusNode = _emailFocusNode;
          break;
        case 'phone':
          focusNode = _phoneFocusNode;
          break;
        case 'cnic':
          focusNode = _cnicFocusNode;
          break;
        case 'vehicleName':
          focusNode = _vehicleNameFocusNode;
          break;
        case 'carOwnerType':
          focusNode = _carOwnerTypeFocusNode;
          break;
        case 'ownerName':
          focusNode = _ownerNameFocusNode;
          break;
        case 'ownerEmail':
          focusNode = _ownerEmailFocusNode;
          break;
        case 'ownerPhone':
          focusNode = _ownerPhoneFocusNode;
          break;
        case 'ownerCnic':
          focusNode = _ownerCnicFocusNode;
          break;
        case 'drivingLicense':
          focusNode = _drivingLicenseFocusNode;
          break;
        case 'address':
          focusNode = _addressFocusNode;
          break;
        case 'password':
          focusNode = _passwordFocusNode;
          break;
        case 'confirmPassword':
          focusNode = _confirmPasswordFocusNode;
          break;
      }

      if (key?.currentContext != null && focusNode != null) {
        final RenderObject? renderObject = key!.currentContext!.findRenderObject();
        if (renderObject != null) {
          final RenderBox renderBox = renderObject as RenderBox;
          final position = renderBox.localToGlobal(Offset.zero);

          // Scroll to the field
          final targetScroll = position.dy - 150; // Offset by 150px from top
          _scrollController.animateTo(
            targetScroll > 0 ? targetScroll : 0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );

          // Focus the field after scrolling
          Future.delayed(const Duration(milliseconds: 350), () {
            if (mounted) {
              focusNode!.requestFocus();
            }
          });
        }
      }
    }
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) {
      // Wait for the next frame to ensure error messages are rendered
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToFirstError();
      });
      return;
    }

    if (_cnicPicture == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please upload your CNIC picture'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    // Driver-specific validations
    if (_selectedUserType == AppConstants.userTypeDriver) {
      if (_selectedVehicleType == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select vehicle type'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
        return;
      }
      if (_carOwnerType == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select car owner type'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
        return;
      }
      if (_carOwnerType == 'not_me') {
        if (_ownerNameController.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please enter owner name'),
              backgroundColor: AppTheme.errorColor,
            ),
          );
          return;
        }
        if (_ownerEmailController.text.isEmpty || Validators.validateEmail(_ownerEmailController.text) != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please enter valid owner email'),
              backgroundColor: AppTheme.errorColor,
            ),
          );
          return;
        }
        if (_ownerPhoneController.text.isEmpty || Validators.validatePhone(_ownerPhoneController.text) != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please enter valid owner phone number'),
              backgroundColor: AppTheme.errorColor,
            ),
          );
          return;
        }
        if (_ownerCnicController.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please enter owner CNIC'),
              backgroundColor: AppTheme.errorColor,
            ),
          );
          return;
        }
      }
      if (_drivingLicensePicture == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please upload your driving license'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
        return;
      }
      if (_vehiclePermitPicture == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please upload your vehicle permit picture'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
        return;
      }
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: Implement actual registration API call
      await Future.delayed(const Duration(seconds: 1)); // Simulate API call

      if (mounted) {
        // Navigate to OTP verification
        context.push(
          '/otp-verification',
          extra: {
            'phone': _phoneController.text,
            'email': _emailController.text,
            'userType': _selectedUserType,
          },
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Registration failed: $e'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text('Create Account'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
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
                        backgroundImage: _profilePicture != null
                            ? FileImage(_profilePicture!)
                            : null,
                        child: _profilePicture == null
                            ? const Icon(
                          Icons.person,
                          size: 60,
                          color: AppTheme.primaryColor,
                        )
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
                              icon: Icon(Icons.camera_alt, size: 20),
                              color: _isHoveringCamera ? Colors.grey : Colors.white,
                              onPressed: _pickImage,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // User Type Selection
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
                            setState(() {
                              _selectedUserType = AppConstants.userTypePassenger;
                            });
                          }
                        },
                        padding: const EdgeInsets.symmetric(vertical: 12), // 👈 height control
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
                            setState(() {
                              _selectedUserType = AppConstants.userTypeDriver;
                            });
                          }
                        },
                        padding: const EdgeInsets.symmetric(vertical: 12), // 👈 SAME
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),
                // Name
                MouseRegion(
                  onEnter: (_) => setState(() => _isHoveringName = true),
                  onExit: (_) => setState(() => _isHoveringName = false),
                  child: Builder(
                    builder: (context) {
                      return Container(
                        key: _fieldKeys['name'],
                        child: TextFormField(
                          controller: _nameController,
                          focusNode: _nameFocusNode,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Full Name',
                            hintText: 'Enter your full name',
                            prefixIcon: const Icon(Icons.person),
                            labelStyle: const TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                            hintStyle: const TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: _isHoveringName ? Colors.grey : Colors.grey.shade300,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: AppTheme.primaryColor,
                                width: 2,
                              ),
                            ),
                          ),
                          validator: Validators.validateName,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                // Email
                MouseRegion(
                  onEnter: (_) => setState(() => _isHoveringEmail = true),
                  onExit: (_) => setState(() => _isHoveringEmail = false),
                  child: Container(
                    key: _fieldKeys['email'],
                    child: TextFormField(
                      controller: _emailController,
                      focusNode: _emailFocusNode,
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Email',
                        hintText: 'example@gmail.com',
                        prefixIcon: const Icon(Icons.email),
                        labelStyle: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                        hintStyle: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: _isHoveringEmail ? Colors.grey : Colors.grey.shade300,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: AppTheme.primaryColor,
                            width: 2,
                          ),
                        ),
                      ),
                      validator: Validators.validateEmail,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Phone
                MouseRegion(
                  onEnter: (_) => setState(() => _isHoveringPhone = true),
                  onExit: (_) => setState(() => _isHoveringPhone = false),
                  child: Container(
                    key: _fieldKeys['phone'],
                    child: TextFormField(
                      controller: _phoneController,
                      focusNode: _phoneFocusNode,
                      keyboardType: TextInputType.phone,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Phone Number',
                        hintText: '03XXXXXXXXX',
                        prefixIcon: const Icon(Icons.phone),
                        labelStyle: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                        hintStyle: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: _isHoveringPhone ? Colors.grey : Colors.grey.shade300,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: AppTheme.primaryColor,
                            width: 2,
                          ),
                        ),
                      ),
                      validator: Validators.validatePhone,
                    ),
                  ),
                ),
                // Driver-specific: Alternate Phone Number (optional, just below phone)
                if (_selectedUserType == AppConstants.userTypeDriver) ...[
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _alternateNumberController,
                    keyboardType: TextInputType.phone,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Alternate Phone Number (Optional)',
                      hintText: '03XXXXXXXXX',
                      prefixIcon: const Icon(Icons.phone_android),
                      labelStyle: const TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                      hintStyle: const TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: Colors.grey.shade300,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: AppTheme.primaryColor,
                          width: 2,
                        ),
                      ),
                    ),
                    // Optional field - only validate if not empty
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        return Validators.validatePhone(value);
                      }
                      return null;
                    },
                  ),
                ],
                const SizedBox(height: 16),
                // CNIC
                MouseRegion(
                  onEnter: (_) => setState(() => _isHoveringCnic = true),
                  onExit: (_) => setState(() => _isHoveringCnic = false),
                  child: Container(
                    key: _fieldKeys['cnic'],
                    child: TextFormField(
                      controller: _cnicController,
                      focusNode: _cnicFocusNode,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                      ),
                      decoration: InputDecoration(
                        labelText: 'CNIC',
                        hintText: '12345-1234567-1',
                        prefixIcon: const Icon(Icons.badge),
                        labelStyle: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                        hintStyle: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: _isHoveringCnic ? Colors.grey : Colors.grey.shade300,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: AppTheme.primaryColor,
                            width: 2,
                          ),
                        ),
                      ),
                      validator: Validators.validateCNIC,
                    ),
                  ),
                ),
                // Driver-specific fields
                if (_selectedUserType == AppConstants.userTypeDriver) ...[
                  const SizedBox(height: 16),
                  // Driving License Number
                  Container(
                    key: _fieldKeys['drivingLicense'],
                    child: TextFormField(
                      controller: _drivingLicenseController,
                      focusNode: _drivingLicenseFocusNode,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Driving License Number',
                        hintText: 'Enter driving license number',
                        prefixIcon: const Icon(Icons.credit_card),
                        labelStyle: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                        hintStyle: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: Colors.grey.shade300,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: AppTheme.primaryColor,
                            width: 2,
                          ),
                        ),
                      ),
                      validator: _selectedUserType == AppConstants.userTypeDriver
                          ? (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter driving license number';
                        }
                        return null;
                      }
                          : null,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Address
                  Container(
                    key: _fieldKeys['address'],
                    child: TextFormField(
                      controller: _addressController,
                      focusNode: _addressFocusNode,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Address',
                        hintText: 'Enter your complete address',
                        prefixIcon: const Icon(Icons.location_on),
                        labelStyle: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                        hintStyle: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: Colors.grey.shade300,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: AppTheme.primaryColor,
                            width: 2,
                          ),
                        ),
                      ),
                      validator: _selectedUserType == AppConstants.userTypeDriver
                          ? (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your address';
                        }
                        return null;
                      }
                          : null,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Driving License Picture
                  Text(
                    'Driving License Picture',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: _isLoading ? null : _pickDrivingLicenseImage,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _drivingLicensePicture != null
                              ? AppTheme.primaryColor
                              : Colors.grey.shade300,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.08),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 64,
                            height: 48,
                            decoration: BoxDecoration(
                              color: AppTheme.backgroundColor,
                              borderRadius: BorderRadius.circular(8),
                              image: _drivingLicensePicture != null
                                  ? DecorationImage(
                                image: FileImage(_drivingLicensePicture!),
                                fit: BoxFit.cover,
                              )
                                  : null,
                            ),
                            child: _drivingLicensePicture == null
                                ? const Icon(
                              Icons.credit_card,
                              color: AppTheme.textSecondary,
                            )
                                : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _drivingLicensePicture != null
                                      ? 'Driving license image selected'
                                      : 'Tap to upload driving license picture',
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                                const SizedBox(height: 4),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.upload,
                            color: AppTheme.primaryColor,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Vehicle Permit Picture
                  Text(
                    'Vehicle Permit Picture',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: _isLoading ? null : _pickVehiclePermitImage,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _vehiclePermitPicture != null
                              ? AppTheme.primaryColor
                              : Colors.grey.shade300,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.08),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 64,
                            height: 48,
                            decoration: BoxDecoration(
                              color: AppTheme.backgroundColor,
                              borderRadius: BorderRadius.circular(8),
                              image: _vehiclePermitPicture != null
                                  ? DecorationImage(
                                image: FileImage(_vehiclePermitPicture!),
                                fit: BoxFit.cover,
                              )
                                  : null,
                            ),
                            child: _vehiclePermitPicture == null
                                ? const Icon(
                              Icons.description,
                              color: AppTheme.textSecondary,
                            )
                                : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _vehiclePermitPicture != null
                                      ? 'Vehicle permit image selected'
                                      : 'Tap to upload vehicle permit picture',
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                                const SizedBox(height: 4),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.upload,
                            color: AppTheme.primaryColor,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                // CNIC Picture
                Text(
                  'CNIC Picture',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _isLoading ? null : _pickCnicImage,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _cnicPicture != null
                            ? AppTheme.primaryColor
                            : Colors.grey.shade300,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.08),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 64,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppTheme.backgroundColor,
                            borderRadius: BorderRadius.circular(8),
                            image: _cnicPicture != null
                                ? DecorationImage(
                              image: FileImage(_cnicPicture!),
                              fit: BoxFit.cover,
                            )
                                : null,
                          ),
                          child: _cnicPicture == null
                              ? const Icon(
                            Icons.badge,
                            color: AppTheme.textSecondary,
                          )
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _cnicPicture != null
                                    ? 'CNIC image selected'
                                    : 'Tap to upload CNIC picture',
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              const SizedBox(height: 4),
                            ],
                          ),
                        ),
                        MouseRegion(
                          onEnter: (_) => setState(() => _isHoveringUpload = true),
                          onExit: (_) => setState(() => _isHoveringUpload = false),
                          child: Icon(
                            Icons.upload,
                            color: _isHoveringUpload ? Colors.grey : AppTheme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Vehicle Type and Car Owner Details (for drivers only - after CNIC Picture, before Password)
                if (_selectedUserType == AppConstants.userTypeDriver) ...[
                  // Vehicle Type
                  Text(
                    'Vehicle Type',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ChoiceChip(
                          label: const Text('Car'),
                          selected: _selectedVehicleType == 'car',
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _selectedVehicleType = 'car';
                              });
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ChoiceChip(
                          label: const Text('Bike'),
                          selected: _selectedVehicleType == 'bike',
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _selectedVehicleType = 'bike';
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Vehicle Name
                  Container(
                    key: _fieldKeys['vehicleName'],
                    child: TextFormField(
                      controller: _vehicleNameController,
                      focusNode: _vehicleNameFocusNode,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Vehicle Name',
                        hintText: 'e.g., Toyota Corolla',
                        prefixIcon: const Icon(Icons.directions_car),
                        labelStyle: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                        hintStyle: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: Colors.grey.shade300,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: AppTheme.primaryColor,
                            width: 2,
                          ),
                        ),
                      ),
                      validator: _selectedUserType == AppConstants.userTypeDriver
                          ? (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter vehicle name';
                        }
                        return null;
                      }
                          : null,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Car Owner Type Dropdown
                  Text(
                    'Car Owner',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    key: _fieldKeys['carOwnerType'],
                    child: DropdownButtonFormField<String>(
                      value: _carOwnerType,
                      focusNode: _carOwnerTypeFocusNode,
                      decoration: InputDecoration(
                        labelText: 'Select Car Owner',
                        hintText: 'Select an option',
                        prefixIcon: const Icon(Icons.person),
                        labelStyle: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: Colors.grey.shade300,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: AppTheme.primaryColor,
                            width: 2,
                          ),
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'me',
                          child: Text('It\'s me'),
                        ),
                        DropdownMenuItem(
                          value: 'not_me',
                          child: Text('It\'s not me'),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _carOwnerType = value;
                          // Clear fields when switching
                          if (value == 'me') {
                            _ownerNameController.clear();
                            _ownerCnicController.clear();
                            _ownerEmailController.clear();
                            _ownerPhoneController.clear();
                          }
                        });
                      },
                      validator: _selectedUserType == AppConstants.userTypeDriver
                          ? (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select car owner type';
                        }
                        return null;
                      }
                          : null,
                    ),
                  ),
                  // Show owner details fields only when "It's not me" is selected
                  if (_carOwnerType == 'not_me') ...[
                    const SizedBox(height: 16),
                    // Owner Name
                    Container(
                      key: _fieldKeys['ownerName'],
                      child: TextFormField(
                        controller: _ownerNameController,
                        focusNode: _ownerNameFocusNode,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Owner Name',
                          hintText: 'Enter owner\'s full name',
                          prefixIcon: const Icon(Icons.person_outline),
                          labelStyle: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                          hintStyle: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: Colors.grey.shade300,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: AppTheme.primaryColor,
                              width: 2,
                            ),
                          ),
                        ),
                        validator: _carOwnerType == 'not_me'
                            ? (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter owner name';
                          }
                          return null;
                        }
                            : null,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Owner Email
                    Container(
                      key: _fieldKeys['ownerEmail'],
                      child: TextFormField(
                        controller: _ownerEmailController,
                        focusNode: _ownerEmailFocusNode,
                        keyboardType: TextInputType.emailAddress,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Owner Email',
                          hintText: 'Enter owner\'s email',
                          prefixIcon: const Icon(Icons.email),
                          labelStyle: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                          hintStyle: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: Colors.grey.shade300,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: AppTheme.primaryColor,
                              width: 2,
                            ),
                          ),
                        ),
                        validator: _carOwnerType == 'not_me'
                            ? (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter owner email';
                          }
                          return Validators.validateEmail(value);
                        }
                            : null,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Owner Phone Number
                    Container(
                      key: _fieldKeys['ownerPhone'],
                      child: TextFormField(
                        controller: _ownerPhoneController,
                        focusNode: _ownerPhoneFocusNode,
                        keyboardType: TextInputType.phone,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Owner Phone Number',
                          hintText: 'Enter owner\'s phone number',
                          prefixIcon: const Icon(Icons.phone),
                          labelStyle: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                          hintStyle: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: Colors.grey.shade300,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: AppTheme.primaryColor,
                              width: 2,
                            ),
                          ),
                        ),
                        validator: _carOwnerType == 'not_me'
                            ? (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter owner phone number';
                          }
                          return Validators.validatePhone(value);
                        }
                            : null,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Owner CNIC
                    Container(
                      key: _fieldKeys['ownerCnic'],
                      child: TextFormField(
                        controller: _ownerCnicController,
                        focusNode: _ownerCnicFocusNode,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Owner CNIC',
                          hintText: '12345-1234567-1',
                          prefixIcon: const Icon(Icons.badge),
                          labelStyle: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                          hintStyle: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: Colors.grey.shade300,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: AppTheme.primaryColor,
                              width: 2,
                            ),
                          ),
                        ),
                        validator: _carOwnerType == 'not_me'
                            ? (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter owner CNIC';
                          }
                          return Validators.validateCNIC(value);
                        }
                            : null,
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                ],
                // Password
                MouseRegion(
                  onEnter: (_) => setState(() => _isHoveringPassword = true),
                  onExit: (_) => setState(() => _isHoveringPassword = false),
                  child: Container(
                    key: _fieldKeys['password'],
                    child: TextFormField(
                      controller: _passwordController,
                      focusNode: _passwordFocusNode,
                      obscureText: _obscurePassword,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Password',
                        hintText: 'Enter password',
                        prefixIcon: const Icon(Icons.lock),
                        labelStyle: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                        hintStyle: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: _isHoveringPassword ? Colors.grey : Colors.grey.shade300,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: AppTheme.primaryColor,
                            width: 2,
                          ),
                        ),
                        suffixIcon: MouseRegion(
                          onEnter: (_) => setState(() => _isHoveringPasswordVisibility = true),
                          onExit: (_) => setState(() => _isHoveringPasswordVisibility = false),
                          child: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: _isHoveringPasswordVisibility ? Colors.grey : null,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                      ),
                      validator: Validators.validatePassword,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // Password Requirements
                Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'add 8 characters,digits,uppercase,lowercase and special characters',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildRequirementItem('8 characters', _hasMinLength(_passwordController.text)),
                      _buildRequirementItem('Uppercase', _hasUppercase(_passwordController.text)),
                      _buildRequirementItem('Lowercase', _hasLowercase(_passwordController.text)),
                      _buildRequirementItem('Digits', _hasDigits(_passwordController.text)),
                      _buildRequirementItem('Special characters', _hasSpecialChars(_passwordController.text)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Confirm Password
                MouseRegion(
                  onEnter: (_) => setState(() => _isHoveringConfirmPassword = true),
                  onExit: (_) => setState(() => _isHoveringConfirmPassword = false),
                  child: Container(
                    key: _fieldKeys['confirmPassword'],
                    child: TextFormField(
                      controller: _confirmPasswordController,
                      focusNode: _confirmPasswordFocusNode,
                      obscureText: _obscureConfirmPassword,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Confirm Password',
                        hintText: 'Enter password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        labelStyle: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                        hintStyle: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: _isHoveringConfirmPassword ? Colors.grey : Colors.grey.shade300,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: AppTheme.primaryColor,
                            width: 2,
                          ),
                        ),
                        suffixIcon: MouseRegion(
                          onEnter: (_) => setState(() => _isHoveringConfirmPasswordVisibility = true),
                          onExit: (_) => setState(() => _isHoveringConfirmPasswordVisibility = false),
                          child: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: _isHoveringConfirmPasswordVisibility ? Colors.grey : null,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureConfirmPassword = !_obscureConfirmPassword;
                              });
                            },
                          ),
                        ),
                      ),
                      validator: _validateConfirmPassword,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                // Register Button
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleRegister,
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
                      : const Text('Register'),
                ),
                const SizedBox(height: 16),
                // Login Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Already have an account? '),
                    TextButton(
                      onPressed: () {
                        context.pop();
                      },
                      child: const Text('Login'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
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

