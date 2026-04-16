//
//
// import 'dart:convert';
// import 'dart:io';
//
// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:http/http.dart' as http;
// import 'package:http_parser/http_parser.dart';
// import 'package:path/path.dart' as path;
//
// import '../../core/utils/validators.dart';
// import '../../core/constants/app_constants.dart';
// import '../core/constants/api_constants.dart';
//
// class PassengerRegisterProvider extends ChangeNotifier {
//   String fullName = '';
//   String email = '';
//   String phone = '';
//   String cnic = '';
//   String password = '';
//   String confirmPassword = '';
//
//   File? profilePicture;
//   File? cnicPicture;
//
//   bool isLoading = false;
//
//   // Errors
//   String? fullNameError;
//   String? emailError;
//   String? phoneError;
//   String? cnicError;
//   String? passwordError;
//   String? confirmPasswordError;
//   String? profilePictureError;
//   String? cnicPictureError;
//   String? generalError;
//
//   void updateField(String field, String value) {
//     switch (field) {
//       case 'fullName':
//         fullName = value.trim();
//         fullNameError = null;
//         break;
//       case 'email':
//         email = value.trim();
//         emailError = null;
//         break;
//       case 'phone':
//         phone = value.trim();
//         phoneError = null;
//         break;
//       case 'cnic':
//         cnic = value.trim();
//         cnicError = null;
//         break;
//       case 'password':
//         password = value;
//         passwordError = null;
//         break;
//       case 'confirmPassword':
//         confirmPassword = value;
//         confirmPasswordError = null;
//         break;
//     }
//     notifyListeners();
//   }
//
//   void setImage(String type, File? file) {
//     if (type == 'profile') {
//       if (file != null) {
//         final ext = path.extension(file.path).toLowerCase();
//         final allowed = ['.jpg', '.jpeg', '.png', '.webp', '.heic', '.heif'];
//         if (!allowed.contains(ext)) {
//           profilePictureError = 'Allowed formats: JPG, JPEG, PNG, WEBP, HEIC/HEIF';
//           profilePicture = null;
//           notifyListeners();
//           return;
//         }
//       }
//       profilePicture = file;
//       profilePictureError = null;
//     } else if (type == 'cnic') {
//       if (file != null) {
//         final ext = path.extension(file.path).toLowerCase();
//         final allowed = ['.jpg', '.jpeg', '.png', '.webp', '.heic', '.heif'];
//         if (!allowed.contains(ext)) {
//           cnicPictureError = 'Allowed formats: JPG, JPEG, PNG, WEBP, HEIC/HEIF';
//           cnicPicture = null;
//           notifyListeners();
//           return;
//         }
//       }
//       cnicPicture = file;
//       cnicPictureError = null;
//     }
//     notifyListeners();
//   }
//
//   void setLoading(bool loading) {
//     isLoading = loading;
//     notifyListeners();
//   }
//
//   void clearAllErrors() {
//     fullNameError = emailError = phoneError = cnicError = null;
//     passwordError = confirmPasswordError = profilePictureError = cnicPictureError = generalError = null;
//     notifyListeners();
//   }
//
//   bool validateAll() {
//     clearAllErrors();
//
//     fullNameError     = Validators.validateName(fullName);
//     emailError        = Validators.validateEmail(email);
//     phoneError        = Validators.validatePhone(phone);
//     cnicError         = Validators.validateCNIC(cnic);
//     passwordError     = Validators.validatePassword(password);
//
//     confirmPasswordError = confirmPassword.isEmpty
//         ? 'Please confirm your password'
//         : (confirmPassword != password ? 'Passwords do not match' : null);
//
//     // Optional: if profile picture is required → uncomment next line
//     // if (profilePicture == null) profilePictureError = 'Please upload profile picture';
//
//     if (cnicPicture == null) {
//       cnicPictureError = 'Please upload CNIC picture';
//     }
//
//     notifyListeners();
//
//     return fullNameError == null &&
//         emailError == null &&
//         phoneError == null &&
//         cnicError == null &&
//         passwordError == null &&
//         confirmPasswordError == null &&
//         // profilePictureError == null &&   // ← optional
//         cnicPictureError == null;
//   }
//
//   Future<bool> tryRegister(BuildContext context) async {
//     if (!validateAll()) {
//       return false;
//     }
//
//     setLoading(true);
//     generalError = null;
//     notifyListeners();
//
//     try {
//       var uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.passengerRegister}');
//
//       var request = http.MultipartRequest('POST', uri);
//
//       // ── Form fields ───────────────────────────────────────
//       request.fields['name']            = fullName.trim();
//       request.fields['email']           = email.trim();
//       request.fields['phone']           = phone.trim();
//       request.fields['cnic']            = cnic.trim();
//       request.fields['password']        = password;
//       request.fields['confirmPassword'] = confirmPassword;     // ← REQUIRED by your backend
//
//       // ── Profile Image (optional but recommended) ─────────
//       if (profilePicture != null) {
//         final originalFilename = path.basename(profilePicture!.path);
//         var ext = path.extension(originalFilename).toLowerCase();
//
//         var sendFilename = originalFilename;
//         // Normalize .jpg → .jpeg (very common backend expectation)
//         if (ext == '.jpg') {
//           sendFilename = '${path.withoutExtension(originalFilename)}.jpeg';
//         }
//
//         MediaType contentType;
//         switch (ext) {
//           case '.png':
//             contentType = MediaType('image', 'png');
//             break;
//           case '.webp':
//             contentType = MediaType('image', 'webp');
//             break;
//           case '.heic':
//           case '.heif':
//             contentType = MediaType('image', 'heic');
//             break;
//           default:
//             contentType = MediaType('image', 'jpeg');
//         }
//
//         request.files.add(
//           await http.MultipartFile.fromPath(
//             'profileImage',           // ← change to correct field name if different (profilePic, avatar, etc.)
//             profilePicture!.path,
//             filename: sendFilename,
//             contentType: contentType,
//           ),
//         );
//       }
//
//       // ── CNIC Image (required) ─────────────────────────────
//       if (cnicPicture != null) {
//         final originalFilename = path.basename(cnicPicture!.path);
//         var ext = path.extension(originalFilename).toLowerCase();
//
//         var sendFilename = originalFilename;
//         if (ext == '.jpg') {
//           sendFilename = '${path.withoutExtension(originalFilename)}.jpeg';
//         }
//
//         MediaType contentType;
//         switch (ext) {
//           case '.png':
//             contentType = MediaType('image', 'png');
//             break;
//           case '.webp':
//             contentType = MediaType('image', 'webp');
//             break;
//           case '.heic':
//           case '.heif':
//             contentType = MediaType('image', 'heic');
//             break;
//           default:
//             contentType = MediaType('image', 'jpeg');
//         }
//
//         request.files.add(
//           await http.MultipartFile.fromPath(
//             'cnicImage',
//             cnicPicture!.path,
//             filename: sendFilename,
//             contentType: contentType,
//           ),
//         );
//       }
//
//       final streamedResponse = await request.send().timeout(const Duration(seconds: 50));
//       final response = await http.Response.fromStream(streamedResponse);
//
//       print('→ Status: ${response.statusCode}');
//       print('→ Body: ${response.body}');
//
//       if (response.statusCode == 200 || response.statusCode == 201) {
//         Map<String, dynamic> json;
//         try {
//           json = jsonDecode(response.body);
//         } catch (_) {
//           generalError = 'Invalid response format from server';
//           notifyListeners();
//           return false;
//         }
//
//         if (json['success'] == true) {
//           // TODO: save tokens here if returned in body
//           // final data = json['data'] ?? {};
//           // final access = data['accessToken'];
//           // final refresh = data['refreshToken'];
//           // if (access != null || refresh != null) {
//           //   final storage = await getStorageService();
//           //   if (access != null) await storage.saveAccessToken(access);
//           //   if (refresh != null) await storage.saveRefreshToken(refresh);
//           // }
//
//           if (context.mounted) {
//             context.push(
//               '/otp-verification',
//               extra: {
//                 'phone': phone,
//                 'email': email,
//                 'userType': AppConstants.userTypePassenger,
//               },
//             );
//           }
//           return true;
//         } else {
//           generalError = json['message'] ?? 'Registration failed';
//         }
//       } else {
//         String errorMsg = 'Error ${response.statusCode}';
//
//         try {
//           final json = jsonDecode(response.body);
//           errorMsg = json['message'] ??
//               json['error'] ??
//               json['msg'] ??
//               (json['errors'] is List
//                   ? (json['errors'] as List).join('\n')
//                   : (json['errors'] is Map ? (json['errors'] as Map).values.join('\n') : errorMsg));
//         } catch (_) {
//           errorMsg = response.body.isNotEmpty ? response.body : errorMsg;
//         }
//
//         generalError = errorMsg.trim();
//       }
//     } catch (e) {
//       generalError = 'Network/connection error: $e';
//     } finally {
//       setLoading(false);
//     }
//
//     notifyListeners();
//     return false;
//   }
// }



import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

import '../../core/constants/api_constants.dart';
import '../../core/constants/app_constants.dart';
import '../services/cookie_manager.dart';

class PassengerRegisterProvider extends ChangeNotifier {
  String fullName = '';
  String email = '';
  String phone = '';
  String cnic = '';
  String password = '';
  String confirmPassword = '';

  File? profilePicture;
  File? cnicPicture;

  bool isLoading = false;
  String? generalError;

  // ✅ FIELD ERRORS (UI ke liye required)
  String? fullNameError;
  String? emailError;
  String? phoneError;
  String? cnicError;
  String? passwordError;
  String? confirmPasswordError;

  // ===============================
  // Update Fields
  // ===============================

  void updateField(String field, String value) {
    switch (field) {
      case 'fullName':
        fullName = value.trim();
        fullNameError = null;
        break;
      case 'email':
        email = value.trim();
        emailError = null;
        break;
      case 'phone':
        phone = value.trim();
        phoneError = null;
        break;
      case 'cnic':
        cnic = value.trim();
        cnicError = null;
        break;
      case 'password':
        password = value;
        passwordError = null;
        break;
      case 'confirmPassword':
        confirmPassword = value;
        confirmPasswordError = null;
        break;
    }
    notifyListeners();
  }

  void setImage(String type, File? file) {
    if (type == 'profile') {
      profilePicture = file;
    } else if (type == 'cnic') {
      cnicPicture = file;
    }
    notifyListeners();
  }

  void setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  // ===============================
  // VALIDATION
  // ===============================

  bool validateAll() {
    generalError = null;

    fullNameError =
    fullName.isEmpty ? "Full name is required" : null;
    emailError =
    email.isEmpty ? "Email is required" : null;
    phoneError =
    phone.isEmpty ? "Phone is required" : null;
    cnicError =
    cnic.isEmpty ? "CNIC is required" : null;
    passwordError =
    password.isEmpty ? "Password is required" : null;
    confirmPasswordError =
    confirmPassword.isEmpty
        ? "Confirm password is required"
        : null;

    if (password.isNotEmpty &&
        confirmPassword.isNotEmpty &&
        password != confirmPassword) {
      confirmPasswordError = "Passwords do not match";
    }

    if (cnicPicture == null) {
      generalError = "CNIC image is required";
    }

    notifyListeners();

    return fullNameError == null &&
        emailError == null &&
        phoneError == null &&
        cnicError == null &&
        passwordError == null &&
        confirmPasswordError == null &&
        cnicPicture != null;
  }

  // ===============================
  // REGISTER API
  // ===============================

  Future<bool> tryRegister(BuildContext context) async {
    if (!validateAll()) return false;

    setLoading(true);

    try {
      final uri = Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.passengerRegister}',
      );

      final request = http.MultipartRequest('POST', uri);

      request.fields['name'] = fullName;
      request.fields['email'] = email;
      request.fields['phone'] = phone;
      request.fields['cnic'] = cnic;
      request.fields['password'] = password;
      request.fields['confirmPassword'] = confirmPassword;

      if (profilePicture != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'profileImage',
          profilePicture!.path,
          filename: path.basename(profilePicture!.path),
        ));
      }

      if (cnicPicture != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'cnicImage',
          cnicPicture!.path,
          filename: path.basename(cnicPicture!.path),
        ));
      }

      final streamedResponse =
      await request.send().timeout(const Duration(seconds: 60));

      final response =
      await http.Response.fromStream(streamedResponse);

      SimpleDriverCookieManager.saveCookie(response);

      if (response.statusCode == 200 ||
          response.statusCode == 201) {
        final json = jsonDecode(response.body);

        if (json['success'] == true) {
          if (context.mounted) {
            context.push(
              '/otp-verification',
              extra: {
                'phone': phone,
                'email': email,
                'userType': AppConstants.userTypePassenger,
              },
            );
          }
          setLoading(false);
          return true;
        } else {
          generalError =
              json['message'] ?? "Registration failed";
        }
      } else {
        try {
          final json = jsonDecode(response.body);
          generalError =
              json['message'] ?? "Error ${response.statusCode}";
        } catch (_) {
          generalError = response.body;
        }
      }
    } catch (e) {
      generalError = "Network error: $e";
    }

    setLoading(false);
    notifyListeners();
    return false;
  }
}