import 'package:flutter/material.dart';


class SideBar extends StatelessWidget {
  final ValueChanged<bool> onThemeChanged; // Callback to change the theme
  final bool isDarkMode; // Pass the current theme mode

  const SideBar({
    super.key,
    required this.onThemeChanged, // Accept the callback
    required this.isDarkMode, // Accept the current mode
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white, // Background color based on theme
      body: Align(
        alignment: Alignment.topLeft,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              color: isDarkMode ? const Color(0xFF74ACD5) : const Color(0xFF74ACD5), // Adjust the header color based on theme
              width: 200,
          child: Row(
            children: [
                  ElevatedButton(
                    onPressed: () {
                      // navigate to the profile page
                      Navigator.pushNamed(context, '/Profile');
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(10),
                      backgroundColor: isDarkMode ? const Color(0xFF74ACD5) : const Color(0xFF74ACD5), // Adjust background color
                      fixedSize: const Size(80, 80),
                      alignment: Alignment.centerLeft,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/images/profile.png'),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(left: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "John Doe",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black54, // Keep username in white for visibility
                            ),
                          ),
                          Text(
                            "Diamond Tier",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black54, // Light grey for tier in dark mode
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            buildMenuButton(context, Icons.favorite, "Swipe page", () {}),
            buildMenuButton(context, Icons.room_preferences, "Preference", () {
              Navigator.pushNamed(context, '/Preference_&_Interest');
            }),
            buildMenuButton(context, Icons.subscriptions, "Subscription", () {}),
            buildMenuButton(context, Icons.newspaper_rounded, "News", () {}),
            buildMenuButton(context, Icons.interests, "Wishlist", () {}),
            buildMenuButton(context, Icons.settings, "Settings", () {
              Navigator.pushNamed(context, '/Settings');
            }),
            buildMenuButton(context, Icons.logout, "Log out", () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    backgroundColor: isDarkMode ? Colors.grey[850] : Colors.white,
                    content: Text(
                      "Are you sure you want to log out?",
                      style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                    ),
                    actions: [
                      TextButton(
                        child: Text(
                          "No",
                          style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),

                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      TextButton(
                        child: Text(
                          "Yes",
                          style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                        ),
                        onPressed: () {
                          Navigator.pushNamed(context, "/Log_in"); 
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
    );
  }

  ElevatedButton buildMenuButton(BuildContext context, IconData icon, String label, VoidCallback onPressed) {
    return ElevatedButton.icon(
      icon: Icon(
        icon,
        color: isDarkMode ? Colors.white : Colors.black, // Icon color based on theme
      ),
      label: Text(
        label,
        style: TextStyle(
          fontSize: 16,
          color: isDarkMode ? Colors.white : Colors.black, // Text color based on theme
          fontWeight: FontWeight.bold,
        ),
      ),
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.all(10),
        backgroundColor: isDarkMode ? Colors.black : Colors.white, // Button background based on theme
        fixedSize: const Size(200, 50),
        alignment: Alignment.centerLeft, // Align the text to the left
        side: BorderSide(
          color: isDarkMode ? Colors.white : Colors.black, // Border color based on theme
          width: 1.0,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0), // Keep buttons rectangular
        ),
      ),
    );
  }
}
