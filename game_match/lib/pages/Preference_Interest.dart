import 'package:flutter/material.dart';
import 'package:game_match/pages/Side_bar.dart';

class PreferenceInterestPage extends StatelessWidget {
  final bool isDarkMode; // Accept current theme mode
  final ValueChanged<bool> onThemeChanged; // Theme change callback

  const PreferenceInterestPage({
    Key? key,
    required this.isDarkMode, // Add dark mode parameter
    required this.onThemeChanged, // Add theme change callback
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0),
        child: AppBar(
          title: const Text(
            'Preferences & Interests',
            style: TextStyle(
              color: Colors.black, 
              fontSize: 24,
            ),
          ),
          centerTitle: true,
          backgroundColor: const Color(0xFF74ACD5), // Use fixed app bar color
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.menu, color: Colors.black),
            onPressed: () {
              Navigator.pop(context, "/SideBar"); // Open/Return to sidebar
            },
          ),
        ),
      ),
      body: Stack(
        children: [
          Container(
            height: 0,
            decoration: const BoxDecoration(
              color: Color(0xFF74ACD5),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 15),
                  // Manage Preference button
                  CustomButton(
                    title: 'Manage preferences',
                    subtitle: 'Edit and Save genre preferences',
                    icon: Icons.tune, // Preference icon
                    onPressed: () {
                      // Add navigation logic here
                    },
                    isDarkMode: isDarkMode, // Pass dark mode status
                  ),
                  const SizedBox(height: 15),

                  // Manage Interest button
                  CustomButton(
                    title: 'Manage interests & other options',
                    subtitle: 'Edit and Save other filter options',
                    icon: Icons.filter_list, // Interest icon
                    onPressed: () {
                      Navigator.pushNamed(context, '/Interest'); // Navigate to Interest page
                    },
                    isDarkMode: isDarkMode, // Pass dark mode status
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Customize buttons for effects
class CustomButton extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onPressed;
  final bool isDarkMode; // Add dark mode flag

  const CustomButton({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onPressed,
    required this.isDarkMode, // Receive dark mode flag
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: [ // Add shadows
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isDarkMode ? const Color.fromARGB(255, 50, 50, 50) : Colors.white, // Adapt background color
          foregroundColor: isDarkMode ? Colors.white : Colors.black, // Adapt text color
          padding: const EdgeInsets.all(25),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 40,
              color: isDarkMode ? Colors.white : Colors.black, // Adapt icon color
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black, // Adapt text color
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      color: isDarkMode ? Colors.grey[300] : Colors.black54, // Adapt subtitle color
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
