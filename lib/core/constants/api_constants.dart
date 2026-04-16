// class ApiConstants {
//   // Base URL - Backend
//   static const String baseUrl = 'https://baneen-fullbackend.onrender.com/api/v1';
//
//   // Authentication Endpoints
//   static const String register = '/auth/register';
//   static const String passengerRegister = '/auth/register-passenger';
//   static const String driverRegister = '/auth/register-driver';
//   static const String verifyDriverOtp = '/auth/verify-driver-otp';
//   static const String login = '/auth/login';
//   static const String verifyOtp = '/auth/verify-otp';
//   static const String resendOtp = '/auth/resend-otp';
//   static const String logout = '/auth/logout';
//   static const String refreshToken = '/auth/refresh-token';
//
//   // User Endpoints
//   static const String getUserProfile = '/users/profile';
//   static const String updateUserProfile = '/users/profile';
//   static const String uploadProfilePicture = '/users/profile-picture';
//
//   // Ride Endpoints (match backend)
//   static const String rides = '/rides';
//   static const String requestRide = '/rides/request';
//   static const String getFareEstimate = '/rides/fare-estimate';
//   static const String getActiveRide = '/rides/active';
//   static const String getRideHistory = '/rides/history';
//   static const String shareRideDetails = '/rides/share';
//
//   /// Paths for ride by id: use like rides + '/$rideId/accept'
//   static String rideAccept(String rideId) => '/rides/$rideId/accept';
//   static String rideCancel(String rideId) => '/rides/$rideId/cancel';
//   static String rideStart(String rideId) => '/rides/$rideId/start';
//   static String rideComplete(String rideId) => '/rides/$rideId/complete';
//   static String rideRate(String rideId) => '/rides/$rideId/rate';
//   static String rideDetails(String rideId) => '/rides/$rideId';
//
//   // Driver Endpoints (legacy; backend uses /rides/:id/accept etc.)
//   static const String updateAvailability = '/drivers/availability';
//   static const String getDriverEarnings = '/drivers/earnings';
//   static const String getRideRequests = '/drivers/rides/requests';
//
//   // Payment Endpoints
//   static const String processPayment = '/payments/process';
//   static const String getPaymentMethods = '/payments/methods';
//   static const String getPaymentHistory = '/payments/history';
//
//   // Subscription Endpoints
//   static const String getSubscriptionPlans = '/subscriptions/plans';
//   static const String subscribe = '/subscriptions/subscribe';
//   static const String getActiveSubscription = '/subscriptions/active';
//   static const String cancelSubscription = '/subscriptions/cancel';
//
//   // Emergency/SOS Endpoints
//   static const String triggerSos = '/emergency/sos';
//   static const String getEmergencyContacts = '/emergency/contacts';
//   static const String addEmergencyContact = '/emergency/contacts';
//
//   // Chat Endpoints
//   static const String sendMessage = '/chat/send';
//   static const String getMessages = '/chat/messages';
//   static const String getChatHistory = '/chat/history';
//
//   // AI Chatbot Endpoints
//   static const String chatbotMessage = '/chatbot/message';
//   static const String chatbotVoice = '/chatbot/voice';
//
//   // Safety Compliance Endpoints
//   static const String uploadSafetyCheck = '/safety/check';
//   static const String verifyHelmetSeatbelt = '/safety/verify';
//
//   // Rating & Review Endpoints
//   static const String submitRating = '/ratings/submit';
//   static const String getRatings = '/ratings';
//
//   // Notification Endpoints
//   static const String getNotifications = '/notifications';
//   static const String markNotificationRead = '/notifications/read';
//
//   // Admin Endpoints (if needed in mobile app)
//   static const String adminMonitorRides = '/admin/rides/monitor';
//   static const String adminSosAlerts = '/admin/emergency/alerts';
//
//   // Headers
//   static const String contentType = 'application/json';
//   static const String authorization = 'Authorization';
//   static const String bearer = 'Bearer';
//
//   // Timeouts
//   static const Duration connectTimeout = Duration(seconds: 30);
//   static const Duration receiveTimeout = Duration(seconds: 30);
// }
//


class ApiConstants {
  // Base URL - Backend
  static const String baseUrl = 'https://baneen-fullbackend.onrender.com/api/v1';

  // Authentication Endpoints
  static const String register = '/auth/register';
  static const String passengerRegister = '/auth/register-passenger';
  static const String driverRegister = '/auth/register-driver';
  static const String verifyDriverOtp = '/auth/verify-driver-otp';
  static const String login = '/auth/login';
  static const String verifyOtp = '/auth/verify-otp';
  static const String resendOtp = '/auth/resend-otp';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh-token';

  // User Endpoints
  static const String getUserProfile = '/users/profile';
  static const String updateUserProfile = '/users/profile';
  static const String uploadProfilePicture = '/users/profile-picture';

  // Ride Endpoints (match backend)
  static const String rides = '/rides';
  static const String requestRide = '/rides/request';
  static const String getFareEstimate = '/rides/fare-estimate';
  static const String getActiveRide = '/rides/active';
  static const String getRideHistory = '/rides/history';
  static const String shareRideDetails = '/rides/share';

  /// Paths for ride by id: use like rides + '/$rideId/accept'
  static String rideAccept(String rideId) => '/rides/$rideId/accept';
  static String rideCancel(String rideId) => '/rides/$rideId/cancel';
  static String rideStart(String rideId) => '/rides/$rideId/start';
  static String rideComplete(String rideId) => '/rides/$rideId/complete';
  static String rideRate(String rideId) => '/rides/$rideId/rate';
  static String rideDetails(String rideId) => '/rides/$rideId';

  // Driver Endpoints
  static const String driverGoOnline = '/drivers/online';
  static const String driverGoOffline = '/drivers/offline'; // ✅ confirmed exists
  static const String updateAvailability = '/drivers/availability';
  static const String getDriverEarnings = '/drivers/earnings';
  static const String getRideRequests = '/drivers/rides/requests';

  // Ride matching
  static const String rejectRide = '/matching/ride-response'; // POST /matching/ride-response/:rideId

  // Live location tracking
  // PUT /rides/:id/location
  static String rideLocation(String rideId) => '/rides/$rideId/location';

  // Payment Endpoints
  static const String processPayment = '/payments/process';
  static const String getPaymentMethods = '/payments/methods';
  static const String getPaymentHistory = '/payments/history';

  // Subscription Endpoints
  static const String getSubscriptionPlans = '/subscriptions/plans';
  static const String subscribe = '/subscriptions/subscribe';
  static const String getActiveSubscription = '/subscriptions/active';
  static const String cancelSubscription = '/subscriptions/cancel';

  // Emergency/SOS Endpoints
  static const String triggerSos = '/emergency/sos';
  static const String getEmergencyContacts = '/emergency/contacts';
  static const String addEmergencyContact = '/emergency/contacts';

  // Chat Endpoints
  static const String sendMessage = '/chat/send';
  static const String getMessages = '/chat/messages';
  static const String getChatHistory = '/chat/history';

  // AI Chatbot Endpoints
  static const String chatbotMessage = '/chatbot/message';
  static const String chatbotVoice = '/chatbot/voice';

  // Safety Compliance Endpoints
  static const String uploadSafetyCheck = '/safety/check';
  static const String verifyHelmetSeatbelt = '/safety/verify';

  // Rating & Review Endpoints
  static const String submitRating = '/ratings/submit';
  static const String getRatings = '/ratings';

  // Notification Endpoints
  static const String getNotifications = '/notifications';
  static const String markNotificationRead = '/notifications/read';

  // Admin Endpoints (if needed in mobile app)
  static const String adminMonitorRides = '/admin/rides/monitor';
  static const String adminSosAlerts = '/admin/emergency/alerts';

  // Headers
  static const String contentType = 'application/json';
  static const String authorization = 'Authorization';
  static const String bearer = 'Bearer';

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}