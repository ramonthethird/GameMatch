import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF1F3F4), Color(0xFFE0E0E0)], // New background gradient colors
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 40), // For spacing

            // Game Match logo
              Padding(
                padding: const EdgeInsets.only(top: 40.0),
                child: Image.asset(
                  'assets/images/gamematchlogoresize.png',
                  height: 100,
                  width: 100,
                ),
              ),
            const SizedBox(height: 30), // For spacing

            // Interesting feature text
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                'Find your perfect game match based on genre, price, and platform. '
                'Swipe, wishlist, and explore games personalized just for you!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
            ),

            const SizedBox(height: 40), // For spacing

            // Login Button
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/Log_in'); // Navigate to login page
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 5,
                //shadowColor: Colors.black45,
              ),
              child: const Text(
                'Login',
                style: TextStyle(fontSize: 16, color: Color(0xFF448AFF)),
              ),
            ),

            const SizedBox(height: 20), // For spacing

            // Sign Up Button
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/Sign_up'); // Navigate to sign up page
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF448AFF),
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 5,
                shadowColor: Colors.black45,
              ),
              child: const Text(
                'Sign Up',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),

            const SizedBox(height: 40), // For spacing

            // Features or Taglines section
            const Column(
              children: [
                Text(
                  '🎮 Discover New Games',
                  style: TextStyle(color: Colors.black, fontSize: 18, shadows: [
                  ]),
                ),
                SizedBox(height: 10),
                Text(
                    '📰 Stay Updated with Trends',
                  style: TextStyle(color: Colors.black, fontSize: 18, shadows: [
                  ]),
                ),
                SizedBox(height: 10),
                Text(
                  '⭐ Add to Wishlist & Review',
                  style: TextStyle(color: Colors.black, fontSize: 18, shadows: [
                  ]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
