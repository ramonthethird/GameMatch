import 'dart:async';
import 'dart:math';
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
  List<String> wishlist = [];
  List<Widget> notifications = [];
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  Timer? _randomNotificationTimer;

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    fetchNotifications();
  }

  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    final InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid);

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
      Random().nextInt(100000), // Unique ID for each notification
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
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context); // Navigate back to the previous screen
          },
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            // child: Text(
            //   'Notifications',
            //   style: TextStyle(
            //     fontSize: 30,
            //     fontWeight: FontWeight.bold,
            //   ),
            // ),
          ),
          Expanded(
            child: notifications.isEmpty
                ? const Center(child: Text('No notifications available.'))
                : ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                return notifications[index];
              },
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
                    borderRadius: BorderRadius.circular(10),
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

    // Subscription expiration fetcher should be the first notification
    final subscriptionNotification = await fetchSubscriptionExpirationDate();
    if (subscriptionNotification != null) {
      loadedNotifications.add(subscriptionNotification);
    }

    // Fetch games from wishlist and the sale notifs
    await fetchWishlist();
    // check only if wishlist is populated then iterate through the wishlist and do fetch game info function
    if (wishlist.isNotEmpty) {
      // Sale notifications for wishlist games
      for (String game in wishlist) {
        final gameInfo = await fetchGameInfo(game);

        if (gameInfo['salePrice'] != null && gameInfo['normalPrice'] != null) {
          double salePrice = double.parse(gameInfo['salePrice']);
          double normalPrice = double.parse(gameInfo['normalPrice']);
          double discount = ((normalPrice - salePrice) / normalPrice) * 100;

          if (discount > 0) {
            String discountStr = discount.toStringAsFixed(0);

            loadedNotifications.add(NotificationCard(
              gameTitle: gameInfo['title'],
              discount: discountStr,
              thumbnailUrl: gameInfo['thumb'],
              dealUrl: "https://www.cheapshark.com/redirect?dealID=${gameInfo['dealID']}",
            ));
          }
        }
      }
    } else {
      loadedNotifications.add(const Center(
        child: Text(
          'Your wishlist is empty.',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ));
    }

    setState(() {
      notifications = loadedNotifications;
    });

    // trigger function for random notifs here
    _startRandomNotifications(loadedNotifications);
  }
  
  Future<void> fetchWishlist() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final wishlistSnapshot =
      await FirebaseFirestore.instance.collection('users').doc(user.uid).collection('wishlist').get();

      setState(() {
        wishlist = wishlistSnapshot.docs.map((doc) => doc['name'] as String).toList();
      });
    }
  }
  
  Future<Widget?> fetchSubscriptionExpirationDate() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

      if (userDoc.exists) {
        final subscriptionStatus = userDoc.data()?['subscription'] as String?; // Check subscription status
        final subscriptionExpirationDate = userDoc.data()?['subscriptionExpirationDate'] as String?;

        if (
          subscriptionStatus == 'paid' &&
          subscriptionExpirationDate != null) {
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
  // Random Notification Logic
  void _startRandomNotifications(List<Widget> notifications) {
    // Cancel any existing timer before starting a new one
    _randomNotificationTimer?.cancel();

    _randomNotificationTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      if (notifications.isNotEmpty) {
        // Pick a random notification
        final randomIndex = Random().nextInt(notifications.length);
        final selectedNotification = notifications[randomIndex];

        // If it's a sale notification, trigger a push notification
        if (selectedNotification is NotificationCard) {
          _showNotification(
            selectedNotification.gameTitle,
            '${selectedNotification.discount}% off on your wishlist item!',
          );
        }
      }
    });
  }

  @override
  void dispose() {
    // Make sure to cancel the random notification timer when disposing
    _randomNotificationTimer?.cancel();
    super.dispose();
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
          style: const TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
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

class WarningNotificationCard extends StatelessWidget {
  final String message;

  const WarningNotificationCard({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Add navigation here
        Navigator.pushNamed(context, '/SubscriptionPremium');
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        child: ListTile(
          leading: const Icon(
            Icons.warning,
            color: Colors.amber,
            size: 50,
          ),
          title: Text(
            message,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ),
      ),
    );
  }
}
