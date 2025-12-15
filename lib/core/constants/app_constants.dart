class AppConstants {
  // App Information
  static const String appName = 'Baneen';
  static const String appVersion = '1.0.0';

  // User Types
  static const String userTypePassenger = 'passenger';
  static const String userTypeDriver = 'driver';

  // Ride Status
  static const String rideStatusPending = 'pending';
  static const String rideStatusAccepted = 'accepted';
  static const String rideStatusInProgress = 'in_progress';
  static const String rideStatusCompleted = 'completed';
  static const String rideStatusCancelled = 'cancelled';

  // Payment Methods
  static const String paymentMethodCash = 'cash';
  static const String paymentMethodCard = 'card';
  static const String paymentMethodWallet = 'wallet';
  static const String paymentMethodEasyPaisa = 'easypaisa';
  static const String paymentMethodJazzCash = 'jazzcash';

  // Vehicle Types
  static const String vehicleTypeCar = 'car';
  static const String vehicleTypeBike = 'bike';
  static const String vehicleTypeRickshaw = 'rickshaw';

  // CNIC Validation
  static const int cnicLength = 13;
  static const String cnicPattern = r'^\d{5}-\d{7}-\d{1}$';

  // Phone Number Validation (Pakistan)
  static const String phonePattern = r'^03\d{9}$';
  static const int phoneLength = 11;

  // OTP
  static const int otpLength = 6;
  static const int otpExpiryMinutes = 5;

  // Location
  static const double defaultLatitude = 33.6844; // Islamabad
  static const double defaultLongitude = 73.0479;
  static const double defaultZoom = 13.0;

  // Map Settings
  static const int mapUpdateInterval = 5; // seconds
  static const double nearbyRadiusKm = 5.0; // km

  // Safety
  static const int sosTimeoutSeconds = 10;
  static const String emergencyNumber = '15'; // Pakistan emergency

  // File Upload
  static const int maxImageSizeMB = 5;
  static const int maxFileSizeMB = 10;
  static const List<String> allowedImageFormats = ['jpg', 'jpeg', 'png'];

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Cache Duration
  static const Duration cacheDuration = Duration(minutes: 5);

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 400);
  static const Duration longAnimation = Duration(milliseconds: 600);

  // Storage Keys
  static const String storageToken = 'auth_token';
  static const String storageRefreshToken = 'refresh_token';
  static const String storageUserData = 'user_data';
  static const String storageUserType = 'user_type';
  static const String storageOnboardingComplete = 'onboarding_complete';
  static const String storageLanguage = 'language';
  static const String storageTheme = 'theme';
  static const String storageFavoriteContactName = 'favorite_contact_name';

  // Cancellation Reasons
  static const List<String> passengerCancellationReasons = [
    'Driver is taking too long',
    'Found another ride',
    'Change of plans',
    'Wrong pickup location',
    'Driver not responding',
    'Emergency situation',
    'Other',
  ];

  static const List<String> driverCancellationReasons = [
    'Passenger not responding',
    'Passenger location too far',
    'Vehicle issue',
    'Emergency situation',
    'Passenger requested cancellation',
    'Other',
  ];
}

