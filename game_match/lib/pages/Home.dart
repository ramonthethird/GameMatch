import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    // Check if the current theme is dark mode
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          // gradient: LinearGradient(
          //   colors: isDarkMode
          //       ? [Color(0xFF303030), Color(0xFF424242)] // Dark mode gradient colors
          //       : [Color(0xFFF1F3F4), Color(0xFFE0E0E0)], // Light mode gradient colors
          //   begin: Alignment.topCenter,
          //   end: Alignment.bottomCenter,
          // ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 0), // For spacing

            // Game Match logo
            Padding(
              padding: const EdgeInsets.only(top: 40.0),
              child: Image.asset(
                'assets/images/gamematchlogoresize.png',
                height: 260,
                width: 260,
                color: isDarkMode ? Colors.white : null, // Make logo white in dark mode
              ),
            ),
            const SizedBox(height: 20), // For spacing

            // Interesting feature text
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                'Find your perfect game match based on genre, price, and platform. '
                'Swipe, wishlist, and explore games personalized just for you!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: isDarkMode ? Colors.white : Colors.black, // Text color based on theme
                ),
              ),
            ),

            const SizedBox(height: 20), // For spacing

            // Login Button
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/Login'); // Navigate to login page
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isDarkMode ? Colors.grey[700] : Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 5,
                shadowColor: isDarkMode ? Colors.black45 : Colors.grey, // Adjust shadow color
              ),
              child: Text(
                'Login',
                style: TextStyle(
                  fontSize: 14,
                  color: isDarkMode ? Colors.white : Color(0xFF41B1F1), // Button text color based on theme
                ),
              ),
            ),

            const SizedBox(height: 20), // For spacing

            // Sign Up Button
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/Sign_up'); // Navigate to sign up page
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isDarkMode ? Color(0xFF41B1F1) : Color(0xFF41B1F1),
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 5,
                shadowColor: isDarkMode ? Colors.black45 : Colors.grey,
              ),
              child: Text(
                'Sign Up',
                style: TextStyle(
                  fontSize: 14,
                  color: isDarkMode ? Colors.white : Colors.white, // Invert text color for dark mode
                ),
              ),
            ),

            const SizedBox(height: 20), // For spacing

            // Features or Taglines section
            Column(
              children: [
                Text(
                  '🎮 Discover New Games',
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black, // Text color based on theme
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '📰 Stay Updated with Trends',
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black, // Text color based on theme
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '⭐ Add to Wishlist & Review',
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black, // Text color based on theme
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
