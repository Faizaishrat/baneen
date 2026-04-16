// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:provider/provider.dart';
// import 'dart:io';
//
// import '../../controller/driver_register_provider.dart';
// import '../../core/theme/app_theme.dart';
//
//
// class DriverRegisterForm extends StatefulWidget {
//   const DriverRegisterForm({super.key});
//
//   @override
//   State<DriverRegisterForm> createState() => _DriverRegisterFormState();
// }
//
// class _DriverRegisterFormState extends State<DriverRegisterForm> {
//   final _scrollController = ScrollController();
//
//   // Controllers
//   final _nameController = TextEditingController();
//   final _emailController = TextEditingController();
//   final _phoneController = TextEditingController();
//   final _cnicController = TextEditingController();
//   final _passwordController = TextEditingController();
//   final _confirmPasswordController = TextEditingController();
//
//   final _vehicleNameController = TextEditingController();
//   final _alternateNumberController = TextEditingController();
//   final _drivingLicenseController = TextEditingController();
//   final _addressController = TextEditingController();
//   final _ownerNameController = TextEditingController();
//   final _ownerCnicController = TextEditingController();
//   final _ownerEmailController = TextEditingController();
//   final _ownerPhoneController = TextEditingController();
//
//   // Previews
//   File? _profilePicturePreview;
//   File? _cnicPicturePreview;
//   File? _drivingLicensePreview;
//   File? _vehiclePermitPreview;
//
//   final ImagePicker _picker = ImagePicker();
//
//   String? _localVehicleType;
//   String? _localCarOwnerType;
//
//   bool _obscurePassword = true;
//   bool _obscureConfirmPassword = true;
//
//   // Hover states (kept as they were)
//   bool _isHoveringCamera = false;
//   bool _isHoveringUpload = false;
//   bool _isHoveringPasswordVisibility = false;
//   bool _isHoveringConfirmPasswordVisibility = false;
//   bool _isHoveringName = false;
//   bool _isHoveringEmail = false;
//   bool _isHoveringPhone = false;
//   bool _isHoveringCnic = false;
//   bool _isHoveringPassword = false;
//   bool _isHoveringConfirmPassword = false;
//
//   @override
//   void initState() {
//     super.initState();
//     final p = Provider.of<DriverRegisterProvider>(context, listen: false);
//
//     _nameController.text = p.fullName;
//     _emailController.text = p.email;
//     _phoneController.text = p.phone;
//     _cnicController.text = p.cnic;
//     _passwordController.text = p.password;
//     _confirmPasswordController.text = p.confirmPassword;
//
//     _vehicleNameController.text = p.vehicleName;
//     _alternateNumberController.text = p.alternatePhone;
//     _drivingLicenseController.text = p.drivingLicenseNumber;
//     _addressController.text = p.address;
//
//     _ownerNameController.text = p.ownerName;
//     _ownerCnicController.text = p.ownerCnic;
//     _ownerEmailController.text = p.ownerEmail;
//     _ownerPhoneController.text = p.ownerPhone;
//
//     _profilePicturePreview = p.profilePicture;
//     _cnicPicturePreview = p.cnicPicture;
//     _drivingLicensePreview = p.drivingLicensePicture;
//     _vehiclePermitPreview = p.vehiclePermitPicture;
//
//     _localVehicleType = p.vehicleType;
//     _localCarOwnerType = p.carOwnerType;
//
//     _passwordController.addListener(() => setState(() {}));
//   }
//
//   @override
//   void dispose() {
//     _nameController.dispose();
//     _emailController.dispose();
//     _phoneController.dispose();
//     _cnicController.dispose();
//     _passwordController.dispose();
//     _confirmPasswordController.dispose();
//     _vehicleNameController.dispose();
//     _alternateNumberController.dispose();
//     _drivingLicenseController.dispose();
//     _addressController.dispose();
//     _ownerNameController.dispose();
//     _ownerCnicController.dispose();
//     _ownerEmailController.dispose();
//     _ownerPhoneController.dispose();
//     _scrollController.dispose();
//     super.dispose();
//   }
//
//   Future<void> _pickProfile() async => _pickAndSet('profile', max: 800);
//   Future<void> _pickCnic() async => _pickAndSet('cnic', max: 1200);
//   Future<void> _pickDrivingLicense() async => _pickAndSet('drivingLicense', max: 1200);
//   Future<void> _pickVehiclePermit() async => _pickAndSet('vehiclePermit', max: 1200);
//
//   Future<void> _pickAndSet(String type, {int max = 800}) async {
//     try {
//       final XFile? xfile = await _picker.pickImage(
//         source: ImageSource.gallery,
//         maxWidth: max.toDouble(),
//         maxHeight: max.toDouble(),
//         imageQuality: 85,
//       );
//       if (xfile != null && mounted) {
//         final file = File(xfile.path);
//         setState(() {
//           switch (type) {
//             case 'profile':
//               _profilePicturePreview = file;
//               break;
//             case 'cnic':
//               _cnicPicturePreview = file;
//               break;
//             case 'drivingLicense':
//               _drivingLicensePreview = file;
//               break;
//             case 'vehiclePermit':
//               _vehiclePermitPreview = file;
//               break;
//           }
//         });
//         Provider.of<DriverRegisterProvider>(context, listen: false).setImage(type, file);
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error picking image: $e'), backgroundColor: AppTheme.errorColor),
//         );
//       }
//     }
//   }
//
//   bool _hasMinLength() => _passwordController.text.length >= 8;
//   bool _hasUppercase() => _passwordController.text.contains(RegExp(r'[A-Z]'));
//   bool _hasLowercase() => _passwordController.text.contains(RegExp(r'[a-z]'));
//   bool _hasDigits() => _passwordController.text.contains(RegExp(r'[0-9]'));
//   bool _hasSpecial() => _passwordController.text.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
//
//   @override
//   Widget build(BuildContext context) {
//     return Consumer<DriverRegisterProvider>(
//       builder: (context, provider, _) {
//         final isLoading = provider.isLoading;
//
//         Widget wrapIfLoading(Widget child) {
//           return IgnorePointer(
//             ignoring: isLoading,
//             child: Opacity(
//               opacity: isLoading ? 0.6 : 1.0,
//               child: child,
//             ),
//           );
//         }
//
//         return SingleChildScrollView(
//           controller: _scrollController,
//           padding: const EdgeInsets.all(24.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               // Profile picture + error below
//               Center(
//                 child: Stack(
//                   children: [
//                     CircleAvatar(
//                       radius: 60,
//                       backgroundColor: AppTheme.primaryLight,
//                       backgroundImage: _profilePicturePreview != null ? FileImage(_profilePicturePreview!) : null,
//                       child: _profilePicturePreview == null
//                           ? const Icon(Icons.person, size: 60, color: AppTheme.primaryColor)
//                           : null,
//                     ),
//                     Positioned(
//                       bottom: 0,
//                       right: 0,
//                       child: CircleAvatar(
//                         radius: 20,
//                         backgroundColor: AppTheme.primaryColor,
//                         child: MouseRegion(
//                           onEnter: (_) => setState(() => _isHoveringCamera = true),
//                           onExit: (_) => setState(() => _isHoveringCamera = false),
//                           child: IconButton(
//                             icon: const Icon(Icons.camera_alt, size: 20),
//                             color: _isHoveringCamera ? Colors.grey : Colors.white,
//                             onPressed: isLoading ? null : _pickProfile,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               if (provider.profilePictureError != null) ...[
//                 const SizedBox(height: 8),
//                 Text(
//                   provider.profilePictureError!,
//                   style: const TextStyle(color: Colors.red, fontSize: 12),
//                   textAlign: TextAlign.center,
//                 ),
//               ],
//               const SizedBox(height: 24),
//
//               // Full Name + error below
//               wrapIfLoading(
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     MouseRegion(
//                       onEnter: (_) => setState(() => _isHoveringName = true),
//                       onExit: (_) => setState(() => _isHoveringName = false),
//                       child: TextFormField(
//                         controller: _nameController,
//                         decoration: _decoration('Full Name', Icons.person, _isHoveringName),
//                         onChanged: (v) {
//                           provider.updateField('fullName', v);
//                           provider.validateField('fullName');
//                         },
//                       ),
//                     ),
//                     if (provider.fullNameError != null) ...[
//                       const SizedBox(height: 4),
//                       Text(
//                         provider.fullNameError!,
//                         style: const TextStyle(color: Colors.red, fontSize: 12),
//                       ),
//                     ],
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 16),
//
//               // Email + error
//               wrapIfLoading(
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     MouseRegion(
//                       onEnter: (_) => setState(() => _isHoveringEmail = true),
//                       onExit: (_) => setState(() => _isHoveringEmail = false),
//                       child: TextFormField(
//                         controller: _emailController,
//                         keyboardType: TextInputType.emailAddress,
//                         decoration: _decoration('Email', Icons.email, _isHoveringEmail),
//                         onChanged: (v) {
//                           provider.updateField('email', v);
//                           provider.validateField('email');
//                         },
//                       ),
//                     ),
//                     if (provider.emailError != null) ...[
//                       const SizedBox(height: 4),
//                       Text(
//                         provider.emailError!,
//                         style: const TextStyle(color: Colors.red, fontSize: 12),
//                       ),
//                     ],
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 16),
//
//               // Phone + error
//               wrapIfLoading(
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     MouseRegion(
//                       onEnter: (_) => setState(() => _isHoveringPhone = true),
//                       onExit: (_) => setState(() => _isHoveringPhone = false),
//                       child: TextFormField(
//                         controller: _phoneController,
//                         keyboardType: TextInputType.phone,
//                         decoration: _decoration('Phone Number', Icons.phone, _isHoveringPhone),
//                         onChanged: (v) {
//                           provider.updateField('phone', v);
//                           provider.validateField('phone');
//                         },
//                       ),
//                     ),
//                     if (provider.phoneError != null) ...[
//                       const SizedBox(height: 4),
//                       Text(
//                         provider.phoneError!,
//                         style: const TextStyle(color: Colors.red, fontSize: 12),
//                       ),
//                     ],
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 16),
//
//               // Alternate Phone (optional - no error)
//               wrapIfLoading(
//                 TextFormField(
//                   controller: _alternateNumberController,
//                   keyboardType: TextInputType.phone,
//                   decoration: InputDecoration(
//                     labelText: 'Alternate Phone (Optional)',
//                     hintText: '03XXXXXXXXX',
//                     prefixIcon: const Icon(Icons.phone_android),
//                     border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//                   ),
//                   onChanged: (v) => provider.updateField('alternatePhone', v),
//                 ),
//               ),
//               const SizedBox(height: 16),
//
//               // CNIC + error
//               wrapIfLoading(
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     MouseRegion(
//                       onEnter: (_) => setState(() => _isHoveringCnic = true),
//                       onExit: (_) => setState(() => _isHoveringCnic = false),
//                       child: TextFormField(
//                         controller: _cnicController,
//                         keyboardType: TextInputType.number,
//                         decoration: _decoration('CNIC', Icons.badge, _isHoveringCnic),
//                         onChanged: (v) {
//                           provider.updateField('cnic', v);
//                           provider.validateField('cnic');
//                         },
//                       ),
//                     ),
//                     if (provider.cnicError != null) ...[
//                       const SizedBox(height: 4),
//                       Text(
//                         provider.cnicError!,
//                         style: const TextStyle(color: Colors.red, fontSize: 12),
//                       ),
//                     ],
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 16),
//
//               // CNIC Picture + error
//               Text('CNIC Picture', style: Theme.of(context).textTheme.titleLarge),
//               const SizedBox(height: 8),
//               GestureDetector(
//                 onTap: isLoading ? null : _pickCnic,
//                 child: _uploadBox(_cnicPicturePreview, Icons.badge, 'Tap to upload CNIC picture'),
//               ),
//               if (provider.cnicPictureError != null) ...[
//                 const SizedBox(height: 4),
//                 Text(
//                   provider.cnicPictureError!,
//                   style: const TextStyle(color: Colors.red, fontSize: 12),
//                 ),
//               ],
//               const SizedBox(height: 24),
//
//               // Driving License Number + error
//               wrapIfLoading(
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     TextFormField(
//                       controller: _drivingLicenseController,
//                       decoration: InputDecoration(
//                         labelText: 'Driving License Number',
//                         prefixIcon: const Icon(Icons.credit_card),
//                         border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//                       ),
//                       onChanged: (v) {
//                         provider.updateField('drivingLicenseNumber', v);
//                         provider.validateField('drivingLicenseNumber');
//                       },
//                     ),
//                     if (provider.drivingLicenseNumberError != null) ...[
//                       const SizedBox(height: 4),
//                       Text(
//                         provider.drivingLicenseNumberError!,
//                         style: const TextStyle(color: Colors.red, fontSize: 12),
//                       ),
//                     ],
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 16),
//
//               // Address + error
//               wrapIfLoading(
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     TextFormField(
//                       controller: _addressController,
//                       decoration: InputDecoration(
//                         labelText: 'Address',
//                         prefixIcon: const Icon(Icons.location_on),
//                         border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//                       ),
//                       onChanged: (v) {
//                         provider.updateField('address', v);
//                         provider.validateField('address');
//                       },
//                     ),
//                     if (provider.addressError != null) ...[
//                       const SizedBox(height: 4),
//                       Text(
//                         provider.addressError!,
//                         style: const TextStyle(color: Colors.red, fontSize: 12),
//                       ),
//                     ],
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 16),
//
//               // Driving License Picture + error
//               Text('Driving License Picture', style: Theme.of(context).textTheme.titleMedium),
//               const SizedBox(height: 8),
//               GestureDetector(
//                 onTap: isLoading ? null : _pickDrivingLicense,
//                 child: _uploadBox(_drivingLicensePreview, Icons.credit_card, 'Tap to upload driving license'),
//               ),
//               if (provider.drivingLicensePictureError != null) ...[
//                 const SizedBox(height: 4),
//                 Text(
//                   provider.drivingLicensePictureError!,
//                   style: const TextStyle(color: Colors.red, fontSize: 12),
//                 ),
//               ],
//               const SizedBox(height: 16),
//
//               // Vehicle Permit Picture + error
//               Text('Vehicle Permit Picture', style: Theme.of(context).textTheme.titleMedium),
//               const SizedBox(height: 8),
//               GestureDetector(
//                 onTap: isLoading ? null : _pickVehiclePermit,
//                 child: _uploadBox(_vehiclePermitPreview, Icons.description, 'Tap to upload vehicle permit'),
//               ),
//               if (provider.vehiclePermitPictureError != null) ...[
//                 const SizedBox(height: 4),
//                 Text(
//                   provider.vehiclePermitPictureError!,
//                   style: const TextStyle(color: Colors.red, fontSize: 12),
//                 ),
//               ],
//               const SizedBox(height: 24),
//
//               // Vehicle Type + error
//               Text('Vehicle Type', style: Theme.of(context).textTheme.titleMedium),
//               const SizedBox(height: 8),
//               Row(
//                 children: [
//                   Expanded(
//                     child: ChoiceChip(
//                       label: const Text('Car'),
//                       selected: _localVehicleType == 'car',
//                       onSelected: isLoading
//                           ? null
//                           : (sel) {
//                         if (sel) {
//                           setState(() => _localVehicleType = 'car');
//                           provider.updateField('vehicleType', 'car');
//                           provider.validateField('vehicleType');
//                         }
//                       },
//                     ),
//                   ),
//                   const SizedBox(width: 16),
//                   Expanded(
//                     child: ChoiceChip(
//                       label: const Text('Bike'),
//                       selected: _localVehicleType == 'bike',
//                       onSelected: isLoading
//                           ? null
//                           : (sel) {
//                         if (sel) {
//                           setState(() => _localVehicleType = 'bike');
//                           provider.updateField('vehicleType', 'bike');
//                           provider.validateField('vehicleType');
//                         }
//                       },
//                     ),
//                   ),
//                 ],
//               ),
//               if (provider.vehicleTypeError != null) ...[
//                 const SizedBox(height: 4),
//                 Text(
//                   provider.vehicleTypeError!,
//                   style: const TextStyle(color: Colors.red, fontSize: 12),
//                 ),
//               ],
//               const SizedBox(height: 16),
//
//               // Vehicle Name + error
//               wrapIfLoading(
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     TextFormField(
//                       controller: _vehicleNameController,
//                       decoration: InputDecoration(
//                         labelText: 'Vehicle Name',
//                         prefixIcon: const Icon(Icons.directions_car),
//                         border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//                       ),
//                       onChanged: (v) {
//                         provider.updateField('vehicleName', v);
//                         provider.validateField('vehicleName');
//                       },
//                     ),
//                     if (provider.vehicleNameError != null) ...[
//                       const SizedBox(height: 4),
//                       Text(
//                         provider.vehicleNameError!,
//                         style: const TextStyle(color: Colors.red, fontSize: 12),
//                       ),
//                     ],
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 16),
//
//               // Car Owner Type + error
//               Text('Car Owner', style: Theme.of(context).textTheme.titleMedium),
//               const SizedBox(height: 8),
//               wrapIfLoading(
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     DropdownButtonFormField<String>(
//                       value: _localCarOwnerType,
//                       decoration: InputDecoration(
//                         labelText: 'Select Car Owner',
//                         border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//                       ),
//                       items: const [
//                         DropdownMenuItem(value: 'me', child: Text("It's me")),
//                         DropdownMenuItem(value: 'not_me', child: Text("It's not me")),
//                       ],
//                       onChanged: isLoading
//                           ? null
//                           : (v) {
//                         setState(() => _localCarOwnerType = v);
//                         provider.updateField('carOwnerType', v);
//                         provider.validateField('carOwnerType');
//                       },
//                     ),
//                     if (provider.carOwnerTypeError != null) ...[
//                       const SizedBox(height: 4),
//                       Text(
//                         provider.carOwnerTypeError!,
//                         style: const TextStyle(color: Colors.red, fontSize: 12),
//                       ),
//                     ],
//                   ],
//                 ),
//               ),
//
//               if (_localCarOwnerType == 'not_me') ...[
//                 const SizedBox(height: 16),
//                 wrapIfLoading(
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       TextFormField(
//                         controller: _ownerNameController,
//                         decoration: InputDecoration(
//                           labelText: 'Owner Name',
//                           prefixIcon: const Icon(Icons.person_outline),
//                           border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//                         ),
//                         onChanged: (v) {
//                           provider.updateField('ownerName', v);
//                           provider.validateField('ownerName');
//                         },
//                       ),
//                       if (provider.ownerNameError != null) ...[
//                         const SizedBox(height: 4),
//                         Text(
//                           provider.ownerNameError!,
//                           style: const TextStyle(color: Colors.red, fontSize: 12),
//                         ),
//                       ],
//                     ],
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 wrapIfLoading(
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       TextFormField(
//                         controller: _ownerEmailController,
//                         keyboardType: TextInputType.emailAddress,
//                         decoration: InputDecoration(
//                           labelText: 'Owner Email',
//                           prefixIcon: const Icon(Icons.email),
//                           border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//                         ),
//                         onChanged: (v) {
//                           provider.updateField('ownerEmail', v);
//                           provider.validateField('ownerEmail');
//                         },
//                       ),
//                       if (provider.ownerEmailError != null) ...[
//                         const SizedBox(height: 4),
//                         Text(
//                           provider.ownerEmailError!,
//                           style: const TextStyle(color: Colors.red, fontSize: 12),
//                         ),
//                       ],
//                     ],
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 wrapIfLoading(
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       TextFormField(
//                         controller: _ownerPhoneController,
//                         keyboardType: TextInputType.phone,
//                         decoration: InputDecoration(
//                           labelText: 'Owner Phone Number',
//                           prefixIcon: const Icon(Icons.phone),
//                           border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//                         ),
//                         onChanged: (v) {
//                           provider.updateField('ownerPhone', v);
//                           provider.validateField('ownerPhone');
//                         },
//                       ),
//                       if (provider.ownerPhoneError != null) ...[
//                         const SizedBox(height: 4),
//                         Text(
//                           provider.ownerPhoneError!,
//                           style: const TextStyle(color: Colors.red, fontSize: 12),
//                         ),
//                       ],
//                     ],
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 wrapIfLoading(
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       TextFormField(
//                         controller: _ownerCnicController,
//                         keyboardType: TextInputType.number,
//                         decoration: InputDecoration(
//                           labelText: 'Owner CNIC',
//                           prefixIcon: const Icon(Icons.badge),
//                           border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//                         ),
//                         onChanged: (v) {
//                           provider.updateField('ownerCnic', v);
//                           provider.validateField('ownerCnic');
//                         },
//                       ),
//                       if (provider.ownerCnicError != null) ...[
//                         const SizedBox(height: 4),
//                         Text(
//                           provider.ownerCnicError!,
//                           style: const TextStyle(color: Colors.red, fontSize: 12),
//                         ),
//                       ],
//                     ],
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//               ],
//
//               // Password + error
//               wrapIfLoading(
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     MouseRegion(
//                       onEnter: (_) => setState(() => _isHoveringPassword = true),
//                       onExit: (_) => setState(() => _isHoveringPassword = false),
//                       child: Padding(
//                         padding: const EdgeInsets.only(top: 8),
//                         child: TextFormField(
//                           controller: _passwordController,
//                           obscureText: _obscurePassword,
//                           decoration: InputDecoration(
//                             labelText: 'Password',
//                             prefixIcon: const Icon(Icons.lock),
//                             suffixIcon: MouseRegion(
//                               onEnter: (_) => setState(() => _isHoveringPasswordVisibility = true),
//                               onExit: (_) => setState(() => _isHoveringPasswordVisibility = false),
//                               child: IconButton(
//                                 icon: Icon(
//                                   _obscurePassword ? Icons.visibility_off : Icons.visibility,
//                                   color: _isHoveringPasswordVisibility ? Colors.grey : null,
//                                 ),
//                                 onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
//                               ),
//                             ),
//                             border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//                           ),
//                           onChanged: (v) {
//                             provider.updateField('password', v);
//                             provider.validateField('password');
//                           },
//                         ),
//                       ),
//                     ),
//                     if (provider.passwordError != null) ...[
//                       const SizedBox(height: 4),
//                       Text(
//                         provider.passwordError!,
//                         style: const TextStyle(color: Colors.red, fontSize: 12),
//                       ),
//                     ],
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 8),
//
//               // Password strength indicators (unchanged)
//               Padding(
//                 padding: const EdgeInsets.only(left: 16),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text(
//                       'add 8 characters,digits,uppercase,lowercase and special characters',
//                       style: TextStyle(color: Colors.red, fontSize: 12),
//                     ),
//                     const SizedBox(height: 8),
//                     _reqItem('8 characters', _hasMinLength()),
//                     _reqItem('Uppercase', _hasUppercase()),
//                     _reqItem('Lowercase', _hasLowercase()),
//                     _reqItem('Digits', _hasDigits()),
//                     _reqItem('Special characters', _hasSpecial()),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 16),
//
//               // Confirm Password + error
//               wrapIfLoading(
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     MouseRegion(
//                       onEnter: (_) => setState(() => _isHoveringConfirmPassword = true),
//                       onExit: (_) => setState(() => _isHoveringConfirmPassword = false),
//                       child: TextFormField(
//                         controller: _confirmPasswordController,
//                         obscureText: _obscureConfirmPassword,
//                         decoration: InputDecoration(
//                           labelText: 'Confirm Password',
//                           prefixIcon: const Icon(Icons.lock_outline),
//                           suffixIcon: MouseRegion(
//                             onEnter: (_) => setState(() => _isHoveringConfirmPasswordVisibility = true),
//                             onExit: (_) => setState(() => _isHoveringConfirmPasswordVisibility = false),
//                             child: IconButton(
//                               icon: Icon(
//                                 _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
//                                 color: _isHoveringConfirmPasswordVisibility ? Colors.grey : null,
//                               ),
//                               onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
//                             ),
//                           ),
//                           border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//                         ),
//                         onChanged: (v) {
//                           provider.updateField('confirmPassword', v);
//                           provider.validateField('confirmPassword');
//                         },
//                       ),
//                     ),
//                     if (provider.confirmPasswordError != null) ...[
//                       const SizedBox(height: 4),
//                       Text(
//                         provider.confirmPasswordError!,
//                         style: const TextStyle(color: Colors.red, fontSize: 12),
//                       ),
//                     ],
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 32),
//
//               ElevatedButton(
//                 onPressed: isLoading
//                     ? null
//                     : () async {
//                   final success = await provider.tryRegister(context);
//                   if (!success && mounted) {
//                     // Scroll to top to make errors visible
//                     _scrollController.animateTo(
//                       0,
//                       duration: const Duration(milliseconds: 300),
//                       curve: Curves.easeInOut,
//                     );
//                   }
//                 },
//                 style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
//                 child: isLoading
//                     ? const SizedBox(
//                   height: 20,
//                   width: 20,
//                   child: CircularProgressIndicator(
//                     strokeWidth: 2,
//                     valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                   ),
//                 )
//                     : const Text('Register'),
//               ),
//               const SizedBox(height: 16),
//
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   const Text('Already have an account? '),
//                   TextButton(
//                     onPressed: () => context.pop(),
//                     child: const Text('Login'),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
//
//   InputDecoration _decoration(String label, IconData icon, bool hover) {
//     return InputDecoration(
//       labelText: label,
//       prefixIcon: Icon(icon),
//       border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//       enabledBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(8),
//         borderSide: BorderSide(color: hover ? Colors.grey : Colors.grey.shade300),
//       ),
//       focusedBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(8),
//         borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
//       ),
//     );
//   }
//
//   Widget _uploadBox(File? img, IconData icon, String txt) {
//     return Container(
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: img != null ? AppTheme.primaryColor : Colors.grey.shade300),
//         boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.08), blurRadius: 6)],
//       ),
//       child: Row(
//         children: [
//           Container(
//             width: 64,
//             height: 48,
//             decoration: BoxDecoration(
//               color: AppTheme.backgroundColor,
//               borderRadius: BorderRadius.circular(8),
//               image: img != null ? DecorationImage(image: FileImage(img), fit: BoxFit.cover) : null,
//             ),
//             child: img == null ? Icon(icon, color: AppTheme.textSecondary) : null,
//           ),
//           const SizedBox(width: 12),
//           Expanded(child: Text(txt, style: Theme.of(context).textTheme.bodyLarge)),
//           MouseRegion(
//             onEnter: (_) => setState(() => _isHoveringUpload = true),
//             onExit: (_) => setState(() => _isHoveringUpload = false),
//             child: Icon(Icons.upload, color: _isHoveringUpload ? Colors.grey : AppTheme.primaryColor),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _reqItem(String label, bool met) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 4),
//       child: Row(
//         children: [
//           Icon(met ? Icons.check_circle : Icons.circle_outlined, size: 16, color: met ? Colors.grey : Colors.red),
//           const SizedBox(width: 8),
//           Text(
//             label,
//             style: TextStyle(
//               color: met ? Colors.grey : Colors.red,
//               fontSize: 12,
//               decoration: met ? TextDecoration.lineThrough : null,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }




import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'dart:io';

import '../../controller/driver_register_provider.dart';
import '../../core/theme/app_theme.dart';

class DriverRegisterForm extends StatefulWidget {
  const DriverRegisterForm({super.key});

  @override
  State<DriverRegisterForm> createState() => _DriverRegisterFormState();
}

class _DriverRegisterFormState extends State<DriverRegisterForm> {
  final _scrollController = ScrollController();

  // Controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cnicController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _vehicleNameController = TextEditingController();
  final _alternateNumberController = TextEditingController();
  final _drivingLicenseController = TextEditingController();
  final _addressController = TextEditingController();
  final _ownerNameController = TextEditingController();
  final _ownerCnicController = TextEditingController();
  final _ownerEmailController = TextEditingController();
  final _ownerPhoneController = TextEditingController();

  // Previews
  File? _profilePicturePreview;
  File? _cnicPicturePreview;
  File? _drivingLicensePreview;
  File? _vehiclePermitPreview;

  final ImagePicker _picker = ImagePicker();

  String? _localVehicleType;
  String? _localCarOwnerType;

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
    final p = Provider.of<DriverRegisterProvider>(context, listen: false);

    _nameController.text = p.fullName;
    _emailController.text = p.email;
    _phoneController.text = p.phone;
    _cnicController.text = p.cnic;
    _passwordController.text = p.password;
    _confirmPasswordController.text = p.confirmPassword;

    _vehicleNameController.text = p.vehicleName;
    _alternateNumberController.text = p.alternatePhone;
    _drivingLicenseController.text = p.drivingLicenseNumber;
    _addressController.text = p.address;

    _ownerNameController.text = p.ownerName;
    _ownerCnicController.text = p.ownerCnic;
    _ownerEmailController.text = p.ownerEmail;
    _ownerPhoneController.text = p.ownerPhone;

    _profilePicturePreview = p.profilePicture;
    _cnicPicturePreview = p.cnicPicture;
    _drivingLicensePreview = p.drivingLicensePicture;
    _vehiclePermitPreview = p.vehiclePermitPicture;

    _localVehicleType = p.vehicleType;
    _localCarOwnerType = p.carOwnerType;

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
    _vehicleNameController.dispose();
    _alternateNumberController.dispose();
    _drivingLicenseController.dispose();
    _addressController.dispose();
    _ownerNameController.dispose();
    _ownerCnicController.dispose();
    _ownerEmailController.dispose();
    _ownerPhoneController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _pickProfile() async => _pickAndSet('profile', max: 800);
  Future<void> _pickCnic() async => _pickAndSet('cnic', max: 1200);
  Future<void> _pickDrivingLicense() async => _pickAndSet('drivingLicense', max: 1200);
  Future<void> _pickVehiclePermit() async => _pickAndSet('vehiclePermit', max: 1200);

  Future<void> _pickAndSet(String type, {int max = 800}) async {
    try {
      final XFile? xfile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: max.toDouble(),
        maxHeight: max.toDouble(),
        imageQuality: 85,
      );
      if (xfile != null && mounted) {
        final file = File(xfile.path);
        setState(() {
          switch (type) {
            case 'profile':
              _profilePicturePreview = file;
              break;
            case 'cnic':
              _cnicPicturePreview = file;
              break;
            case 'drivingLicense':
              _drivingLicensePreview = file;
              break;
            case 'vehiclePermit':
              _vehiclePermitPreview = file;
              break;
          }
        });
        Provider.of<DriverRegisterProvider>(context, listen: false).setImage(type, file);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e'), backgroundColor: AppTheme.errorColor),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DriverRegisterProvider>(
      builder: (context, provider, _) {
        final isLoading = provider.isLoading;

        Widget wrapIfLoading(Widget child) {
          return IgnorePointer(
            ignoring: isLoading,
            child: Opacity(
              opacity: isLoading ? 0.6 : 1.0,
              child: child,
            ),
          );
        }

        return SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Profile picture + error
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
                            onPressed: isLoading ? null : _pickProfile,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (provider.profilePictureError != null) ...[
                const SizedBox(height: 8),
                Text(
                  provider.profilePictureError!,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 24),

              // Full Name + error
              wrapIfLoading(
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MouseRegion(
                      onEnter: (_) => setState(() => _isHoveringName = true),
                      onExit: (_) => setState(() => _isHoveringName = false),
                      child: TextFormField(
                        controller: _nameController,
                        decoration: _decoration('Full Name', Icons.person, _isHoveringName),
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
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Email + error
              wrapIfLoading(
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MouseRegion(
                      onEnter: (_) => setState(() => _isHoveringEmail = true),
                      onExit: (_) => setState(() => _isHoveringEmail = false),
                      child: TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: _decoration('Email', Icons.email, _isHoveringEmail),
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
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Phone + error
              wrapIfLoading(
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MouseRegion(
                      onEnter: (_) => setState(() => _isHoveringPhone = true),
                      onExit: (_) => setState(() => _isHoveringPhone = false),
                      child: TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: _decoration('Phone Number', Icons.phone, _isHoveringPhone),
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
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Alternate Phone
              wrapIfLoading(
                TextFormField(
                  controller: _alternateNumberController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Alternate Phone (Optional)',
                    hintText: '03XXXXXXXXX',
                    prefixIcon: const Icon(Icons.phone_android),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onChanged: (v) => provider.updateField('alternatePhone', v),
                ),
              ),
              const SizedBox(height: 16),

              // CNIC + error
              wrapIfLoading(
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MouseRegion(
                      onEnter: (_) => setState(() => _isHoveringCnic = true),
                      onExit: (_) => setState(() => _isHoveringCnic = false),
                      child: TextFormField(
                        controller: _cnicController,
                        keyboardType: TextInputType.number,
                        decoration: _decoration('CNIC', Icons.badge, _isHoveringCnic),
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
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // CNIC Picture + error
              Text('CNIC Picture', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: isLoading ? null : _pickCnic,
                child: _uploadBox(_cnicPicturePreview, Icons.badge, 'Tap to upload CNIC picture'),
              ),
              if (provider.cnicPictureError != null) ...[
                const SizedBox(height: 4),
                Text(
                  provider.cnicPictureError!,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ],
              const SizedBox(height: 24),

              // Driving License Number + error
              wrapIfLoading(
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _drivingLicenseController,
                      decoration: InputDecoration(
                        labelText: 'Driving License Number',
                        prefixIcon: const Icon(Icons.credit_card),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onChanged: (v) => provider.updateField('drivingLicenseNumber', v),
                    ),
                    if (provider.drivingLicenseNumberError != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        provider.drivingLicenseNumberError!,
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Address + error
              wrapIfLoading(
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _addressController,
                      decoration: InputDecoration(
                        labelText: 'Address',
                        prefixIcon: const Icon(Icons.location_on),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onChanged: (v) => provider.updateField('address', v),
                    ),
                    if (provider.addressError != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        provider.addressError!,
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Driving License Picture + error
              Text('Driving License Picture', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: isLoading ? null : _pickDrivingLicense,
                child: _uploadBox(_drivingLicensePreview, Icons.credit_card, 'Tap to upload driving license'),
              ),
              if (provider.drivingLicensePictureError != null) ...[
                const SizedBox(height: 4),
                Text(
                  provider.drivingLicensePictureError!,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ],
              const SizedBox(height: 16),

              // Vehicle Permit Picture + error
              Text('Vehicle Permit Picture', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: isLoading ? null : _pickVehiclePermit,
                child: _uploadBox(_vehiclePermitPreview, Icons.description, 'Tap to upload vehicle permit'),
              ),
              if (provider.vehiclePermitPictureError != null) ...[
                const SizedBox(height: 4),
                Text(
                  provider.vehiclePermitPictureError!,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ],
              const SizedBox(height: 24),

              // Vehicle Type + error
              Text('Vehicle Type', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: const Text('Car'),
                      selected: _localVehicleType == 'car',
                      onSelected: isLoading
                          ? null
                          : (sel) {
                        if (sel) {
                          setState(() => _localVehicleType = 'car');
                          provider.updateField('vehicleType', 'car');
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ChoiceChip(
                      label: const Text('Bike'),
                      selected: _localVehicleType == 'bike',
                      onSelected: isLoading
                          ? null
                          : (sel) {
                        if (sel) {
                          setState(() => _localVehicleType = 'bike');
                          provider.updateField('vehicleType', 'bike');
                        }
                      },
                    ),
                  ),
                ],
              ),
              if (provider.vehicleTypeError != null) ...[
                const SizedBox(height: 4),
                Text(
                  provider.vehicleTypeError!,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ],
              const SizedBox(height: 16),

              // Vehicle Name + error
              wrapIfLoading(
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _vehicleNameController,
                      decoration: InputDecoration(
                        labelText: 'Vehicle Name',
                        prefixIcon: const Icon(Icons.directions_car),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onChanged: (v) => provider.updateField('vehicleName', v),
                    ),
                    if (provider.vehicleNameError != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        provider.vehicleNameError!,
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Car Owner Type + error
              Text('Car Owner', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              wrapIfLoading(
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: _localCarOwnerType,
                      decoration: InputDecoration(
                        labelText: 'Select Car Owner',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'me', child: Text("It's me")),
                        DropdownMenuItem(value: 'not_me', child: Text("It's not me")),
                      ],
                      onChanged: isLoading
                          ? null
                          : (v) {
                        setState(() => _localCarOwnerType = v);
                        provider.updateField('carOwnerType', v);
                      },
                    ),
                    if (provider.carOwnerTypeError != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        provider.carOwnerTypeError!,
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ],
                  ],
                ),
              ),

              if (_localCarOwnerType == 'not_me') ...[
                const SizedBox(height: 16),
                wrapIfLoading(
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _ownerNameController,
                        decoration: InputDecoration(
                          labelText: 'Owner Name',
                          prefixIcon: const Icon(Icons.person_outline),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onChanged: (v) => provider.updateField('ownerName', v),
                      ),
                      if (provider.ownerNameError != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          provider.ownerNameError!,
                          style: const TextStyle(color: Colors.red, fontSize: 12),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                wrapIfLoading(
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _ownerEmailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: 'Owner Email',
                          prefixIcon: const Icon(Icons.email),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onChanged: (v) => provider.updateField('ownerEmail', v),
                      ),
                      if (provider.ownerEmailError != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          provider.ownerEmailError!,
                          style: const TextStyle(color: Colors.red, fontSize: 12),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                wrapIfLoading(
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _ownerPhoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: 'Owner Phone Number',
                          prefixIcon: const Icon(Icons.phone),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onChanged: (v) => provider.updateField('ownerPhone', v),
                      ),
                      if (provider.ownerPhoneError != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          provider.ownerPhoneError!,
                          style: const TextStyle(color: Colors.red, fontSize: 12),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                wrapIfLoading(
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _ownerCnicController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Owner CNIC',
                          prefixIcon: const Icon(Icons.badge),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onChanged: (v) => provider.updateField('ownerCnic', v),
                      ),
                      if (provider.ownerCnicError != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          provider.ownerCnicError!,
                          style: const TextStyle(color: Colors.red, fontSize: 12),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Password + error
              wrapIfLoading(
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MouseRegion(
                      onEnter: (_) => setState(() => _isHoveringPassword = true),
                      onExit: (_) => setState(() => _isHoveringPassword = false),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: 'Password',
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
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onChanged: (v) => provider.updateField('password', v),
                        ),
                      ),
                    ),
                    if (provider.passwordError != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        provider.passwordError!,
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Confirm Password + error
              wrapIfLoading(
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MouseRegion(
                      onEnter: (_) => setState(() => _isHoveringConfirmPassword = true),
                      onExit: (_) => setState(() => _isHoveringConfirmPassword = false),
                      child: TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirmPassword,
                        decoration: InputDecoration(
                          labelText: 'Confirm Password',
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
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
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
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Register Button
              ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () async {
                  final success = await provider.tryRegister(context);
                  if (!success && mounted) {
                    _scrollController.animateTo(
                      0,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                },
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                child: isLoading
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
                    : const Text('Register'),
              ),
              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Already have an account? '),
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

  InputDecoration _decoration(String label, IconData icon, bool hover) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: hover ? Colors.grey : Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
      ),
    );
  }

  Widget _uploadBox(File? img, IconData icon, String txt) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: img != null ? AppTheme.primaryColor : Colors.grey.shade300),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.08), blurRadius: 6)],
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.backgroundColor,
              borderRadius: BorderRadius.circular(8),
              image: img != null ? DecorationImage(image: FileImage(img), fit: BoxFit.cover) : null,
            ),
            child: img == null ? Icon(icon, color: AppTheme.textSecondary) : null,
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(txt, style: Theme.of(context).textTheme.bodyLarge)),
          MouseRegion(
            onEnter: (_) => setState(() => _isHoveringUpload = true),
            onExit: (_) => setState(() => _isHoveringUpload = false),
            child: Icon(Icons.upload, color: _isHoveringUpload ? Colors.grey : AppTheme.primaryColor),
          ),
        ],
      ),
    );
  }
}