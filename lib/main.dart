import 'package:baneen/presentation/splash/splash2.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'presentation/splash/splash_screen.dart';
import 'presentation/splash/splash2.dart';
import 'presentation/auth/login_screen.dart';
import 'presentation/auth/register_screen.dart';
import 'presentation/auth/otp_verification_screen.dart';
import 'presentation/auth/forgot_password_screen.dart';
import 'presentation/auth/forgot_password_otp_screen.dart';
import 'presentation/auth/reset_password_screen.dart';
import 'presentation/passenger/passenger_home_screen.dart';
import 'presentation/passenger/ride_booking_screen.dart';
import 'presentation/passenger/active_ride_screen.dart';
import 'presentation/passenger/rating_screen.dart';
import 'presentation/passenger/subscription_plans_screen.dart';
import 'presentation/passenger/settings_screen.dart';
import 'presentation/passenger/edit_profile_screen.dart';
import 'presentation/passenger/personal_information_screen.dart';
import 'presentation/passenger/emergency_contacts_screen.dart';
import 'presentation/passenger/payment_methods_screen.dart';
import 'presentation/passenger/help_support_screen.dart';
import 'presentation/passenger/live_chat_screen.dart';
import 'presentation/passenger/terms_of_service_screen.dart';
import 'presentation/passenger/privacy_policy_screen.dart';
import 'presentation/passenger/app_complaints_screen.dart';
import 'presentation/passenger/feedback_screen.dart';
import 'presentation/passenger/delete_account_screen.dart';
import 'presentation/passenger/change_password_screen.dart';
import 'presentation/driver/driver_dashboard_screen.dart';
import 'presentation/driver/ride_request_screen.dart';
import 'presentation/driver/driver_active_ride_screen.dart';

void main() {
  runApp(const BaneenApp());
}

class BaneenApp extends StatelessWidget {
  const BaneenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Baneen',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: _router,
    );
  }
}

final GoRouter _router = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/splash2',
      builder: (context, state) => const Splash2Screen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/otp-verification',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        final userType =
            (extra?['userType'] as String?) ?? AppConstants.userTypePassenger;
        return OtpVerificationScreen(
          phone: extra?['phone'],
          email: extra?['email'],
          userType: userType,
        );
      },
    ),
    GoRoute(
      path: '/forgot-password',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      path: '/forgot-password-otp',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return ForgotPasswordOtpScreen(
          phone: extra?['phone'],
          email: extra?['email'],
        );
      },
    ),
    GoRoute(
      path: '/reset-password',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return ResetPasswordScreen(
          phone: extra?['phone'],
          email: extra?['email'],
        );
      },
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) {
        // TODO: Determine user type and route accordingly
        // For now, defaulting to passenger
        return const PassengerHomeScreen();
      },
    ),
    GoRoute(
      path: '/ride-booking',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return RideBookingScreen(
          pickup: extra?['pickup'],
          destination: extra?['destination'],
          paymentMethod: extra?['paymentMethod'],
        );
      },
    ),
    GoRoute(
      path: '/active-ride',
      builder: (context, state) => const ActiveRideScreen(),
    ),
    GoRoute(
      path: '/rating',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return RatingScreen(rideId: extra?['rideId']);
      },
    ),
    GoRoute(
      path: '/subscription',
      builder: (context, state) => const SubscriptionPlansScreen(),
    ),
    GoRoute(
      path: '/driver',
      builder: (context, state) => const DriverDashboardScreen(),
    ),
    GoRoute(
      path: '/ride-request',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return RideRequestScreen(ride: extra?['ride']);
      },
    ),
    GoRoute(
      path: '/driver-active-ride',
      builder: (context, state) => const DriverActiveRideScreen(),
    ),
    // Profile & Settings Routes
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/edit-profile',
      builder: (context, state) => const EditProfileScreen(),
    ),
    GoRoute(
      path: '/personal-information',
      builder: (context, state) => const PersonalInformationScreen(),
    ),
    GoRoute(
      path: '/emergency-contacts',
      builder: (context, state) => const EmergencyContactsScreen(),
    ),
    GoRoute(
      path: '/payment-methods',
      builder: (context, state) => const PaymentMethodsScreen(),
    ),
    GoRoute(
      path: '/help-support',
      builder: (context, state) => const HelpSupportScreen(),
    ),
    GoRoute(
      path: '/live-chat',
      builder: (context, state) => const LiveChatScreen(),
    ),
    GoRoute(
      path: '/terms-of-service',
      builder: (context, state) => const TermsOfServiceScreen(),
    ),
    GoRoute(
      path: '/privacy-policy',
      builder: (context, state) => const PrivacyPolicyScreen(),
    ),
    GoRoute(
      path: '/app-complaints',
      builder: (context, state) => const AppComplaintsScreen(),
    ),
    GoRoute(
      path: '/feedback',
      builder: (context, state) => const FeedbackScreen(),
    ),
    GoRoute(
      path: '/delete-account',
      builder: (context, state) => const DeleteAccountScreen(),
    ),
    GoRoute(
      path: '/change-password',
      builder: (context, state) => const ChangePasswordScreen(),
    ),
  ],
);
