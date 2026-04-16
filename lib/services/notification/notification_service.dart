import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _notifications =
  FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
    DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Request permissions
    await _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap
    // TODO: Navigate to appropriate screen based on notification payload
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidDetails =
    AndroidNotificationDetails(
      'baneen_channel',
      'Baneen Notifications',
      channelDescription: 'Notifications for ride updates and alerts',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      id,
      title,
      body,
      details,
      payload: payload,
    );
  }

  Future<void> showRideRequestNotification({
    required String passengerName,
    required String pickupLocation,
  }) async {
    await showNotification(
      id: 1,
      title: 'New Ride Request',
      body: '$passengerName requested a ride from $pickupLocation',
      payload: 'ride_request',
    );
  }

  Future<void> showRideAcceptedNotification({
    required String driverName,
  }) async {
    await showNotification(
      id: 2,
      title: 'Ride Accepted',
      body: '$driverName has accepted your ride request',
      payload: 'ride_accepted',
    );
  }

  Future<void> showDriverArrivedNotification() async {
    await showNotification(
      id: 3,
      title: 'Driver Arrived',
      body: 'Your driver has arrived at the pickup location',
      payload: 'driver_arrived',
    );
  }

  Future<void> showRideCompletedNotification({
    required double fare,
  }) async {
    await showNotification(
      id: 4,
      title: 'Ride Completed',
      body: 'Your ride has been completed. Fare: PKR $fare',
      payload: 'ride_completed',
    );
  }

  Future<void> showSOSNotification() async {
    await showNotification(
      id: 5,
      title: 'SOS Alert',
      body: 'Emergency alert has been sent to your contacts',
      payload: 'sos_alert',
    );
  }

  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }
}

