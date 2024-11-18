import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  // Create temporary wishlist for testing notifications page
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

  // Put some current non discounted titles and discounted titles to test the discount > 0 thing

  // Use a list to hold notification widgets
  List<Widget> notifications = [];

  // Put build method for ui stuff
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Have app bar be consistent with colors and font size
      appBar: AppBar(
        backgroundColor: const Color(0xFF41B1F1),
        title: const Text(
          'Notifications', // App bar title
          style: TextStyle(fontSize: 18),
        ),
      ),

      body: Column(
        mainAxisAlignment: MainAxisAlignment.start, // Align children to start
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0), // Padding around the title
            child: Text(
              'Notifications',
              style: TextStyle(
                fontSize: 30, // Title font size be consistent with others
                fontWeight: FontWeight.bold, // Make bold for consistency
              ),
            ),
          ),
          Expanded(
            child: notifications.isEmpty // Check if notifications list is empty

                // Question mark for if else shortcut
                ? const Center(
                    child: Text(
                        'No notifications available.')) // Display message if empty
                : ListView(
                    // Display notifications if available
                    children: notifications, // Show the list of notifications
                  ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Center(
              child: ElevatedButton(
                onPressed:
                    clearNotifications, // Press clear notifs button to clear list of notifications
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF41B1F1), // consistency
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(2.5),
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min, // Use minimum size for row
                  mainAxisAlignment:
                      MainAxisAlignment.center, // Center align button contents
                  children: [
                    Icon(
                      Icons.clear,
                      color: Colors.white,
                      size: 16, // Adjust size of icon for looks
                    ),
                    SizedBox(width: 8), // Space between icon and text
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

  // Initialize the state and fetch game notifications using method and define it
  @override
  void initState() {
    super.initState();
    fetchGameNotifications(); // Fetch notifications when the page is initialized
  }

  // Use set state here
  void clearNotifications() {
    setState(() {
      notifications.clear(); // Clear the notifications list
    });
  }

  // Function to recieve game notifications from the API
  Future<void> fetchGameNotifications() async {
    List<Widget> loadedNotifications =
        []; // Create list for loaded notifications

    // Load game notifications for each item in the wishlist, game is constantly changed interatively in for loop
    for (String game in wishlist) {
      final gameInfo = await fetchGameInfo(game); // Fetch game information

      // Check if salePrice and normalPrice are available
      // compare json data
      if (gameInfo['salePrice'] != null && gameInfo['normalPrice'] != null) {
        // Convert to double for safe calculation
        double salePrice = double.parse(gameInfo['salePrice']);
        double normalPrice = double.parse(gameInfo['normalPrice']);

        //calculate discount here
        double discount = ((normalPrice - salePrice) / normalPrice) *
            100; // Calculate discount percentage

        // If discount is found to be over 0, that means it should be added to the notifications
        if (discount > 0) {
          loadedNotifications.add(NotificationCard(
            // Notification card structure

            gameTitle: gameInfo['title'], // Title of the game
            discount: discount
                .toStringAsFixed(0), // Discount percentage formatted as string
            thumbnailUrl: gameInfo['thumb'], // Thumbnail image URL
            dealUrl:
                "https://www.cheapshark.com/redirect?dealID=${gameInfo['dealID']}", // URL for the deal
          ));
        }
      }
    }

    // Add a subscription warning notification just for testing since subscription can't be shown yet
    loadedNotifications.add(
      const WarningNotificationCard(
        message: "Warning: Your subscription ends in two weeks.",
      ),
    );

    // Update the state bc stateful class and need to combine notifs
    setState(() {
      notifications = loadedNotifications; // Set the notifications state
    });
  }

  // Figure out here how to get the cheapshark request in flutter
  // Function to fetch game information from the API
  Future<Map<String, dynamic>> fetchGameInfo(String gameTitle) async {
    final encodedTitle =
        Uri.encodeComponent(gameTitle); // Encode the game title for the URL
    final url = Uri.parse(
        'https://www.cheapshark.com/api/1.0/deals?title=$encodedTitle'); // Create the API URL
    final response = await http.get(url); // Make the GET request

    // Check if the response is successful
    if (response.statusCode == 200) {
      final List<dynamic> deals =
          json.decode(response.body); // Decode the JSON response
      if (deals.isNotEmpty) {
        return deals[0]; // Return the first deal if available
      } else {
        return {}; // Return an empty map if no deals are found
      }
    } else {
      throw Exception(
          "Failed to fetch deals for $gameTitle: ${response.statusCode}"); // Throw an error if the request fails
    }
  }
}

// Widget to display individual game notifications
class NotificationCard extends StatelessWidget {
  final String gameTitle;
  final String discount; // Discount percentage
  final String thumbnailUrl;
  final String dealUrl;

  const NotificationCard({
    super.key,
    required this.gameTitle,
    required this.discount,
    required this.thumbnailUrl,
    required this.dealUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
          vertical: 10, horizontal: 15), // Margin around the card
      child: ListTile(
        leading: Image.network(
          thumbnailUrl,
          width: 50,
          height: 50,
          fit: BoxFit.cover, // Fit the image within the bounds
        ),
        title: Text(
          '$gameTitle - Wishlist Item Discount for $discount%', // Title text
          style: const TextStyle(fontWeight: FontWeight.normal), // Text style
        ),
        trailing: IconButton(
          icon: const Icon(Icons.link), // Link icon
          onPressed: () async {
            // Launch the deal URL when the icon is pressed
            if (await canLaunchUrl(Uri.parse(dealUrl))) {
              await launchUrl(
                Uri.parse(dealUrl),
                mode:
                    LaunchMode.externalApplication, // Open in external browser
              );
            } else {
              throw 'Could not launch $dealUrl'; // Error if URL cannot be launched
            }
          },
        ),
      ),
    );
  }
}

// Widget to display a warning notification
class WarningNotificationCard extends StatelessWidget {
  final String message; // Warning message

  const WarningNotificationCard({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      child: ListTile(
        leading: const Icon(
          Icons
              .warning, // Warning icon on left of card where thumbnail on other notif type would be
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
