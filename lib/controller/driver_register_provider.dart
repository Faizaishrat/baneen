
import 'dart:developer';
import 'dart:io';

import 'package:baneen/core/constants/api_constants.dart';
import 'package:baneen/core/constants/app_constants.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../presentation/auth/verify_driver_otp.dart';
import '../services/cookie_manager.dart';


class DriverRegisterProvider extends ChangeNotifier {
  // ────────────────────────────────────────────────
  //  Form fields
  // ────────────────────────────────────────────────
  String fullName = '';
  String email = '';
  String phone = '';
  String alternatePhone = '';
  String cnic = '';
  String password = '';
  String confirmPassword = '';

  String vehicleName = '';
  String drivingLicenseNumber = '';
  String address = '';

  String? vehicleType;       // 'car' | 'bike'
  String? carOwnerType;      // 'me' | 'not_me'

  String ownerName = '';
  String ownerCnic = '';
  String ownerEmail = '';
  String ownerPhone = '';

  // Images
  File? profilePicture;
  File? cnicPicture;
  File? drivingLicensePicture;
  File? vehiclePermitPicture;

  // ────────────────────────────────────────────────
  //  Errors (shown under fields when API returns 400)
  // ────────────────────────────────────────────────
  String? fullNameError;
  String? emailError;
  String? phoneError;
  String? cnicError;
  String? passwordError;
  String? confirmPasswordError;
  String? vehicleTypeError;
  String? vehicleNameError;
  String? carOwnerTypeError;
  String? drivingLicenseNumberError;
  String? addressError;
  String? ownerNameError;
  String? ownerEmailError;
  String? ownerPhoneError;
  String? ownerCnicError;

  String? profilePictureError;
  String? cnicPictureError;
  String? drivingLicensePictureError;
  String? vehiclePermitPictureError;

  bool isLoading = false;

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 45),
      receiveTimeout: const Duration(seconds: 45),
    ),
  );

  void updateField(String field, dynamic value) {
    switch (field) {
      case 'fullName':
        fullName = (value ?? '').trim();
        break;
      case 'email':
        email = (value ?? '').trim();
        break;
      case 'phone':
        phone = (value ?? '').trim();
        break;
      case 'alternatePhone':
        alternatePhone = (value ?? '').trim();
        break;
      case 'cnic':
        cnic = (value ?? '').trim();
        break;
      case 'password':
        password = value ?? '';
        break;
      case 'confirmPassword':
        confirmPassword = value ?? '';
        break;
      case 'vehicleType':
        vehicleType = value;
        break;
      case 'vehicleName':
        vehicleName = (value ?? '').trim();
        break;
      case 'carOwnerType':
        carOwnerType = value;
        if (value == 'me') {
          ownerName = ownerCnic = ownerEmail = ownerPhone = '';
        }
        break;
      case 'drivingLicenseNumber':
        drivingLicenseNumber = (value ?? '').trim();
        break;
      case 'address':
        address = (value ?? '').trim();
        break;
      case 'ownerName':
        ownerName = (value ?? '').trim();
        break;
      case 'ownerCnic':
        ownerCnic = (value ?? '').trim();
        break;
      case 'ownerEmail':
        ownerEmail = (value ?? '').trim();
        break;
      case 'ownerPhone':
        ownerPhone = (value ?? '').trim();
        break;
    }
    notifyListeners();
  }

  void setImage(String type, File? file) {
    switch (type) {
      case 'profile':
        profilePicture = file;
        profilePictureError = null;
        break;
      case 'cnic':
        cnicPicture = file;
        cnicPictureError = null;
        break;
      case 'drivingLicense':
        drivingLicensePicture = file;
        drivingLicensePictureError = null;
        break;
      case 'vehiclePermit':
        vehiclePermitPicture = file;
        vehiclePermitPictureError = null;
        break;
    }
    notifyListeners();
  }

  void _clearErrors() {
    fullNameError = emailError = phoneError = cnicError = passwordError = confirmPasswordError = null;
    vehicleTypeError = vehicleNameError = carOwnerTypeError = drivingLicenseNumberError = addressError = null;
    ownerNameError = ownerEmailError = ownerPhoneError = ownerCnicError = null;
    profilePictureError = cnicPictureError = drivingLicensePictureError = vehiclePermitPictureError = null;
    notifyListeners();
  }

  Future<bool> tryRegister(BuildContext context) async {
    _clearErrors();
    isLoading = true;
    notifyListeners();

    try {
      final formData = FormData.fromMap({
        'name': fullName.trim(),
        'email': email.trim(),
        'phone': phone.trim(),
        if (alternatePhone.trim().isNotEmpty) 'alternatePhone': alternatePhone.trim(),
        'cnic': cnic.replaceAll(RegExp(r'[- ]'), ''),
        'password': password,
        'confirmPassword': confirmPassword,
        'licenseNumber': drivingLicenseNumber.trim(),
        'vehicleType': vehicleType,
        'vehicleName': vehicleName.trim(),
        'owner': carOwnerType == 'me' ? 'yes' : 'no',
        'address': address.trim(),

        if (carOwnerType == 'not_me') ...{
          'ownerName': ownerName.trim(),
          'ownerCnic': ownerCnic.replaceAll(RegExp(r'[- ]'), ''),
          'ownerEmail': ownerEmail.trim(),
          'ownerPhone': ownerPhone.trim(),
        },

        if (profilePicture != null)
          'profilePic': await MultipartFile.fromFile(
            profilePicture!.path,
            filename: 'profile.jpg',
          ),

        if (cnicPicture != null)
          'cnicImage': await MultipartFile.fromFile(
            cnicPicture!.path,
            filename: 'cnic.jpg',
          ),

        if (drivingLicensePicture != null)
          'licensePic': await MultipartFile.fromFile(
            drivingLicensePicture!.path,
            filename: 'license.jpg',
          ),

        if (vehiclePermitPicture != null)
          'vehiclePermitPic': await MultipartFile.fromFile(
            vehiclePermitPicture!.path,
            filename: 'permit.jpg',
          ),
      });

      log('Sending registration data:');
      for (var f in formData.fields) {
        log('  ${f.key}: ${f.value}');
      }

      final response = await _dio.post(
        ApiConstants.driverRegister,
        data: formData,
      );

      isLoading = false;
      notifyListeners();

      log('Status Code: ${response.statusCode}');
      log('Response Body: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Save cookie from response (same as passenger) - required for OTP verification
        final setCookie = response.headers.map['set-cookie']?.first ??
            response.headers.map['Set-Cookie']?.first;
        if (setCookie != null && setCookie.isNotEmpty) {
          SimpleDriverCookieManager.saveCookieFromString(setCookie);
        }
        // Do NOT overwrite with refreshToken — verify OTP needs verificationToken from registration

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registration successful! OTP sent.'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate to OTP screen
        if (context.mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DriverOtpVerificationScreen(
                phone: phone.isNotEmpty ? phone : null,
                email: email.isNotEmpty ? email : null,
                userType: AppConstants.userTypeDriver,
              ),
            ),
          );
        }

        return true;
      }

      // ─── Handle 400 Validation Errors ───
      if (response.statusCode == 400) {
        final data = response.data;

        if (data is Map) {
          final errorBody = data['errors'] ?? data['error'] ?? data['validationErrors'] ?? data;

          if (errorBody is Map) {
            errorBody.forEach((key, value) {
              String msg = '';
              if (value is List && value.isNotEmpty) {
                msg = value.join(', ');
              } else if (value is String) {
                msg = value;
              } else {
                msg = value.toString();
              }
              _mapErrorToField(key.toString().toLowerCase(), msg);
            });
          } else if (errorBody is List && errorBody.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(errorBody.first.toString()), backgroundColor: Colors.red),
            );
          } else if (errorBody is String) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(errorBody), backgroundColor: Colors.red),
            );
          }
        }

        notifyListeners();
        return false;
      }

      // Other status codes
      final msg = (response.data is Map && response.data['message'] != null)
          ? response.data['message'].toString()
          : 'Registration failed (status ${response.statusCode})';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: Colors.red),
      );
      return false;
    } on DioException catch (e) {
      isLoading = false;
      notifyListeners();

      String msg = 'Registration failed';

      if (e.response != null) {
        final data = e.response?.data;
        log('Error response data: $data');

        if (e.response?.statusCode == 400 && data is Map) {
          final errorBody = data['errors'] ?? data['error'] ?? data;

          if (errorBody is Map) {
            errorBody.forEach((key, value) {
              String errMsg = '';
              if (value is List && value.isNotEmpty) {
                errMsg = value.join(', ');
              } else if (value is String) {
                errMsg = value;
              } else {
                errMsg = value.toString();
              }
              _mapErrorToField(key.toString().toLowerCase(), errMsg);
            });
            notifyListeners();
          } else if (errorBody is List && errorBody.isNotEmpty) {
            msg = errorBody.join('\n');
          } else if (errorBody is String) {
            msg = errorBody;
          } else {
            msg = data.toString();
          }
        } else {
          msg = (data is Map && data['message'] != null)
              ? data['message'].toString()
              : 'Server error (${e.response?.statusCode})';
        }
      } else {
        msg = e.type == DioExceptionType.connectionTimeout
            ? 'Connection timeout – check internet'
            : e.message ?? 'Network error';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: Colors.red),
      );
      return false;
    } catch (e, stack) {
      isLoading = false;
      notifyListeners();
      log('Unexpected error: $e\n$stack');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unexpected error: $e'), backgroundColor: Colors.red),
      );
      return false;
    }
  }

  void _mapErrorToField(String key, String msg) {
    final lowerKey = key.toLowerCase().replaceAll('_', '');
    switch (lowerKey) {
      case 'name':
      case 'fullname':
        fullNameError = msg;
        break;
      case 'email':
        emailError = msg;
        break;
      case 'phone':
      case 'phonenumber':
        phoneError = msg;
        break;
      case 'cnic':
      case 'cnicnumber':
        cnicError = msg;
        break;
      case 'password':
        passwordError = msg;
        break;
      case 'confirmpassword':
      case 'confirm_password':
        confirmPasswordError = msg;
        break;
      case 'vehicletype':
      case 'vehicle_type':
        vehicleTypeError = msg;
        break;
      case 'vehiclename':
      case 'vehicle_name':
        vehicleNameError = msg;
        break;
      case 'owner':
      case 'carownertype':
        carOwnerTypeError = msg;
        break;
      case 'licensenumber':
      case 'license_number':
      case 'drivinglicensenumber':
        drivingLicenseNumberError = msg;
        break;
      case 'address':
        addressError = msg;
        break;
      case 'ownername':
        ownerNameError = msg;
        break;
      case 'owneremail':
        ownerEmailError = msg;
        break;
      case 'ownerphone':
        ownerPhoneError = msg;
        break;
      case 'ownercnic':
        ownerCnicError = msg;
        break;
      case 'profilepic':
      case 'profilepicture':
        profilePictureError = msg;
        break;
      case 'cnicimage':
        cnicPictureError = msg;
        break;
      case 'licensepic':
        drivingLicensePictureError = msg;
        break;
      case 'vehiclepermitpic':
        vehiclePermitPictureError = msg;
        break;
      default:
        log('Unhandled validation field: $key → $msg');
        break;
    }
  }
}