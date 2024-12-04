import 'dart:async';
import 'dart:math';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  NotificationService(this.flutterLocalNotificationsPlugin);
  // Initialize timer
  Timer? _randomNotificationTimer;

  // Starts the timer to trigger random notifications, set at whatever time will jumpscare you with a sale
  void startRandomNotifications(List<Map<String, dynamic>> notificationData) {
    _randomNotificationTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      _triggerRandomNotification(notificationData);
    });
  }

  // Function to stop timer
  void stopRandomNotifications() {
    _randomNotificationTimer?.cancel();
  }

  /// Triggers a random notification
  Future<void> _triggerRandomNotification(List<Map<String, dynamic>> notificationData) async {
    if (notificationData.isNotEmpty) {
      // check if sales are not empty then choose a random sale on wishlist to notify user about during runtime
      final randomIndex = Random().nextInt(notificationData.length);
      final selectedNotification = notificationData[randomIndex];

      // Shows the push notification itself here triggers show function from below
      await _showNotification(
        selectedNotification['title'] ?? 'Game Deal',
        selectedNotification['message'] ?? 'Check out the latest deal!',
      );
    }
  }

  // Display notification function defined here
  Future<void> _showNotification(String title, String body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'notification_channel',
      'General Notifications',
      importance: Importance.max,
      priority: Priority.high,
    );

    
    const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
    // trigger the flutter local notifications function here with random id for game.
    await flutterLocalNotificationsPlugin.show(
      Random().nextInt(100000), // Unique ID for each notification
      title,
      body,
      platformChannelSpecifics,
    );
  }
}
