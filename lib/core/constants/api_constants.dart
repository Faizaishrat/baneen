class ApiConstants {
  // Base URL - Update with your backend URL
  static const String baseUrl = 'https://api.baneen.com/api';
  // For development, use: 'http://localhost:3000/api' or your local IP

  // Authentication Endpoints
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String verifyOtp = '/auth/verify-otp';
  static const String resendOtp = '/auth/resend-otp';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh-token';

  // User Endpoints
  static const String getUserProfile = '/users/profile';
  static const String updateUserProfile = '/users/profile';
  static const String uploadProfilePicture = '/users/profile-picture';

  // Ride Endpoints
  static const String requestRide = '/rides/request';
  static const String getFareEstimate = '/rides/fare-estimate';
  static const String cancelRide = '/rides/cancel';
  static const String getActiveRide = '/rides/active';
  static const String getRideHistory = '/rides/history';
  static const String getRideDetails = '/rides';
  static const String shareRideDetails = '/rides/share';

  // Driver Endpoints
  static const String updateAvailability = '/drivers/availability';
  static const String acceptRide = '/drivers/rides/accept';
  static const String rejectRide = '/drivers/rides/reject';
  static const String startRide = '/drivers/rides/start';
  static const String completeRide = '/drivers/rides/complete';
  static const String getDriverEarnings = '/drivers/earnings';
  static const String getRideRequests = '/drivers/rides/requests';

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

