import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';


class NotificationsPage extends StatefulWidget {
  NotificationsPage({Key? key}) : super(key: key);

  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}


class _NotificationsPageState extends State<NotificationsPage> {
  final List<String> wishlist = [
    "Injustice 2",
    "Neon Arena",
    "Call of Duty: Black Ops 6",
    "Elden Ring Shadow of the Erdtree",
    "Universe Sandbox",
    "F.E.A.R. 2",
    "Figment",
    "Metro 2033 Redux",
    "BioShock Infinite"
  ];

  List<Widget> notifications = [];
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    fetchNotifications();
  }

  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    final InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _showNotification(String title, String body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'notification_channel',
      'General Notifications',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF41B1F1),
        title: const Text(
          'Notifications',
          style: TextStyle(fontSize: 24),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Notifications',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: notifications.isEmpty
                ? const Center(child: Text('No notifications available.'))
                : ListView(
              children: notifications,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Center(
              child: ElevatedButton(
                onPressed: clearNotifications,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF41B1F1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(2.5),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(
                      Icons.clear,
                      color: Colors.white,
                      size: 16,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Clear Notifications',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void clearNotifications() {
    setState(() {
      notifications.clear();
    });
  }

  Future<void> fetchNotifications() async {
    List<Widget> loadedNotifications = [];

    // Subscription expiration fetcher
    final subscriptionNotification = await fetchSubscriptionExpirationDate();
    if (subscriptionNotification != null) {
      loadedNotifications.add(subscriptionNotification);
    }

    // Sale notifications for wishlist games
    for (String game in wishlist) {
      final gameInfo = await fetchGameInfo(game);

      if (gameInfo['salePrice'] != null && gameInfo['normalPrice'] != null) {
        double salePrice = double.parse(gameInfo['salePrice']);
        double normalPrice = double.parse(gameInfo['normalPrice']);
        double discount = ((normalPrice - salePrice) / normalPrice) * 100;

        if (discount > 0) {
          // Convert discount to whole number with toStringAsFixed(0)
          String discountStr = discount.toStringAsFixed(0);

          loadedNotifications.add(NotificationCard(
            gameTitle: gameInfo['title'],
            discount: discountStr,  // Using the whole number version
            thumbnailUrl: gameInfo['thumb'],
            dealUrl: "https://www.cheapshark.com/redirect?dealID=${gameInfo['dealID']}",
          ));

          // Schedule notification for this game with formatted discount
          _showNotification(gameInfo['title'], '$discountStr% off on your wishlist item!');
        }

      }
    }

    // Add new release notification for Call of Duty: Black Ops 6
    // loadedNotifications.add(ReleaseNotificationCard(
    //   gameTitle: "Call of Duty: Black Ops 6",
    //   releaseDate: "Available Now!",
    //   thumbnailUrl: "https://example.com/cod_black_ops_6_thumbnail.jpg",
    //   storeUrl: "https://store.steampowered.com/app/123456/Call_of_Duty_Black_Ops_6",
    // ));
    // _showNotification("Call of Duty: Black Ops 6", "New Release Available Now!");

    setState(() {
      notifications = loadedNotifications;
    });
  }

  Future<Widget?> fetchSubscriptionExpirationDate() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

      if (userDoc.exists) {
        final subscriptionExpirationDate = userDoc.get('subscriptionExpirationDate') as String?;

        if (subscriptionExpirationDate != null) {
          return WarningNotificationCard(
            message: "Warning: Your subscription expires on $subscriptionExpirationDate",
          );
        }
      }
    }
    return null;
  }

  Future<Map<String, dynamic>> fetchGameInfo(String gameTitle) async {
    final encodedTitle = Uri.encodeComponent(gameTitle);
    final url = Uri.parse('https://www.cheapshark.com/api/1.0/deals?title=$encodedTitle');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> deals = json.decode(response.body);
      if (deals.isNotEmpty) {
        return deals[0];
      } else {
        return {};
      }
    } else {
      throw Exception("Failed to fetch deals for $gameTitle: ${response.statusCode}");
    }
  }
}

class NotificationCard extends StatelessWidget {
  final String gameTitle;
  final String discount;
  final String thumbnailUrl;
  final String dealUrl;

  const NotificationCard({
    Key? key,
    required this.gameTitle,
    required this.discount,
    required this.thumbnailUrl,
    required this.dealUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      child: ListTile(
        leading: Image.network(
          thumbnailUrl,
          width: 50,
          height: 50,
          fit: BoxFit.cover,
        ),
        title: Text(
          '$gameTitle - Wishlist Item Discount for $discount%',
          style: const TextStyle(fontWeight: FontWeight.normal),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.link),
          onPressed: () async {
            if (await canLaunchUrl(Uri.parse(dealUrl))) {
              await launchUrl(
                Uri.parse(dealUrl),
                mode: LaunchMode.externalApplication,
              );
            } else {
              throw 'Could not launch $dealUrl';
            }
          },
        ),
      ),
    );
  }
}

class ReleaseNotificationCard extends StatelessWidget {
  final String gameTitle;
  final String releaseDate;
  final String thumbnailUrl;
  final String storeUrl;

  const ReleaseNotificationCard({
    Key? key,
    required this.gameTitle,
    required this.releaseDate,
    required this.thumbnailUrl,
    required this.storeUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      child: ListTile(
        leading: Image.network(
          thumbnailUrl,
          width: 50,
          height: 50,
          fit: BoxFit.cover,
        ),
        title: Text(
          '$gameTitle - Released on $releaseDate!',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.link),
          onPressed: () async {
            if (await canLaunchUrl(Uri.parse(storeUrl))) {
              await launchUrl(
                Uri.parse(storeUrl),
                mode: LaunchMode.externalApplication,
              );
            } else {
              throw 'Could not launch $storeUrl';
            }
          },
        ),
      ),
    );
  }
}

class WarningNotificationCard extends StatelessWidget {
  final String message;

  const WarningNotificationCard({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      child: ListTile(
        leading: const Icon(
          Icons.warning,
          color: Colors.amber,
          size: 50,
        ),
        title: Text(
          message,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
