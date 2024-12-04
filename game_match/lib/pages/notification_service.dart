import 'dart:async';
import 'dart:math';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  NotificationService(this.flutterLocalNotificationsPlugin);

  Timer? _randomNotificationTimer;

  /// Starts the timer to trigger random notifications
  void startRandomNotifications(List<Map<String, dynamic>> notificationData) {
    _randomNotificationTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      _triggerRandomNotification(notificationData);
    });
  }

  /// Stops the timer
  void stopRandomNotifications() {
    _randomNotificationTimer?.cancel();
  }

  /// Triggers a random notification
  Future<void> _triggerRandomNotification(List<Map<String, dynamic>> notificationData) async {
    if (notificationData.isNotEmpty) {
      // Pick a random card
      final randomIndex = Random().nextInt(notificationData.length);
      final selectedNotification = notificationData[randomIndex];

      // Show the push notification
      await _showNotification(
        selectedNotification['title'] ?? 'Game Deal',
        selectedNotification['message'] ?? 'Check out the latest deal!',
      );
    }
  }

  /// Displays the notification
  Future<void> _showNotification(String title, String body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'notification_channel',
      'General Notifications',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      Random().nextInt(100000), // Unique ID for each notification
      title,
      body,
      platformChannelSpecifics,
    );
  }
}