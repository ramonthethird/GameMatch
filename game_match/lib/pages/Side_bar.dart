import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:game_match/theme_notifier.dart';

class HomeScreen extends StatelessWidget {
  final ValueChanged<bool> onThemeChanged;
  final bool isDarkMode;

  const HomeScreen({
    super.key,
    required this.onThemeChanged,
    required this.isDarkMode,
  });

  Future<String> getUserName() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      return userDoc['username'] ?? 'Unknown';
    }
    return 'Unknown';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      appBar: AppBar(
        title: const Text("Home Screen"),
        backgroundColor:
            isDarkMode ? Colors.grey[900] : const Color(0xFF74ACD5),
      ),
      drawer: SideBar(
        onThemeChanged: onThemeChanged,
        isDarkMode: isDarkMode,
      ),
      body: Center(
        child: Text(
          "Main Content Area",
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class SideBar extends StatelessWidget {
  final ValueChanged<bool> onThemeChanged;
  final bool isDarkMode;

  const SideBar({
    super.key,
    required this.onThemeChanged,
    required this.isDarkMode,
  });

  Future<Map<String, String>> getUserInfo() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      String userName = userDoc['username'] ?? 'Unknown';

      DateTime? creationTime = user.metadata.creationTime;
      String memberSince = creationTime != null
          ? DateFormat('MMMM yyyy').format(creationTime)
          : 'Unknown';

      String profileImageUrl = userDoc['profileImageUrl'] ?? '';
      return {'username': userName, 'memberSince': memberSince, 'profileImageUrl': profileImageUrl};
    }
    return {'username': 'Unknown', 'memberSince': 'Unknown'};
  }

  Future<void> navigateToSubscription(BuildContext context) async {
  User? user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    // Ensure the document data is available and contains 'subscription'
    String subscriptionStatus = userDoc.data() != null && (userDoc.data() as Map<String, dynamic>).containsKey('subscription')
        ? userDoc['subscription'] as String
        : 'free';

    if (subscriptionStatus == 'free') {
      Navigator.pushNamed(context, '/Subscription'); // Free subscription page
    } else if (subscriptionStatus == 'paid') {
      Navigator.pushNamed(context, '/SubscriptionPremium'); // Paid subscription page
    }
  }
}


  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: MediaQuery.of(context).size.width *
          0.60, // Sidebar covers 60% of screen width
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            color: const Color(0xFF41B1F1),
            width: double.infinity,
            child: Row(
                children: [
                GestureDetector(
                  onTap: () {
                  Navigator.pushNamed(context, '/Profile');
                  },
                  child: Container(
                  width: 60,
                  height: 60,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey, // Background color for the icon
                  ),
                  child: FutureBuilder<Map<String, String>>(
                    future: getUserInfo(),
                    builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return const Icon(Icons.error, color: Colors.red);
                    } else {
                      final userInfo = snapshot.data ?? {'profileImageUrl': ''};
                      if (userInfo['profileImageUrl'] == null || userInfo['profileImageUrl']!.isEmpty) {
                      return const Icon(Icons.person, color: Colors.white, size: 40);
                      } else {
                      return Container(
                        decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: NetworkImage(userInfo['profileImageUrl']!),
                          fit: BoxFit.cover,
                        ),
                        ),
                      );
                      }
                    }
                    },
                  ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FutureBuilder<Map<String, String>>(
                        future: getUserInfo(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          } else if (snapshot.hasError) {
                            return const Text(
                              "Error",
                              style: TextStyle(fontSize: 16, color: Colors.red),
                            );
                          } else {
                            final userInfo = snapshot.data ??
                                {
                                  'username': 'Unknown',
                                  'memberSince': 'Unknown'
                                };
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    snapshot.data?['username'] ?? 'Unknown',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: isDarkMode
                                        ? Colors.white
                                        : Colors.black87,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Member Since: ${userInfo['memberSince']}",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDarkMode
                                        ? Colors.white70
                                        : Colors.black54,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Diamond Tier",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: isDarkMode
                                        ? Colors.white70
                                        : Colors.black54,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                buildMenuButton(context, Icons.home, "Home", () {
                  Navigator.pushNamed(context, '/Post_home');
                }),
                buildMenuButton(context, Icons.room_preferences, "Preferences",
                    () {
                  Navigator.pushNamed(context, '/Preference_&_Interest');
                }),
                buildMenuButton(context, Icons.subscriptions, "Subscription",
                    () {
                  navigateToSubscription(context); // Check subscription status
                }),
                buildMenuButton(context, Icons.interests, "Wishlist", () {
                  Navigator.pushNamed(context, '/Wishlist');
                }),
                buildMenuButton(
                    context, Icons.reviews, "My Reviews", () {
                  Navigator.pushNamed(context, '/Reviews');
                }),
                buildMenuButton(context, Icons.settings, "Settings", () {
                  Navigator.pushNamed(context, '/Settings');
                }),
                buildMenuButton(context, Icons.logout, "Log Out", () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        backgroundColor:
                            isDarkMode ? Colors.grey[850] : Colors.white,
                        content: Text(
                          "Are you sure you want to log out?",
                          style: TextStyle(
                              color: isDarkMode ? Colors.white : Colors.black),
                        ),
                        actions: [
                          TextButton(
                            child: Text(
                              "No",
                              style: TextStyle(
                                  color:
                                      isDarkMode ? Colors.white : Colors.black),
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          TextButton(
                            child: Text(
                              "Yes",
                              style: TextStyle(
                                  color:
                                      isDarkMode ? Colors.white : Colors.black),
                            ),
                            onPressed: () {
                              FirebaseAuth.instance.signOut();
                              Navigator.pushNamedAndRemoveUntil(
                                  context, "/Home", (route) => false);
                            },
                          ),
                        ],
                      );
                    },
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  ElevatedButton buildMenuButton(BuildContext context, IconData icon,
      String label, VoidCallback onPressed) {
    return ElevatedButton.icon(
      icon: Icon(icon, color: isDarkMode ? Colors.white : Colors.black),
      label: Text(
        label,
        style: TextStyle(
          fontSize: 16,
          color: isDarkMode ? Colors.white : Colors.black87,
          fontWeight: FontWeight.bold,
        ),
      ),
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
        backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
        alignment: Alignment.centerLeft,
        side: BorderSide(
          color: isDarkMode ? Colors.white70 : Colors.black45,
          width: 1.0,
        ),
        shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.zero, // Ensures the buttons are rectangular
        ),
      ),
    );
  }
}
