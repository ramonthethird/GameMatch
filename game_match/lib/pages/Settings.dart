import 'package:flutter/material.dart';
import 'package:game_match/pages/Settings_Appearance.dart';
import 'package:game_match/pages/Settings_Notifications.dart';
import 'package:game_match/pages/Settings_Terms.dart';
import 'package:game_match/pages/Settings_Privacy.dart';
import 'package:game_match/pages/Side_bar.dart';

class SettingsPage extends StatefulWidget {
  final bool isDarkMode;
  final ValueChanged<bool> onThemeChanged;

  const SettingsPage({Key? key, required this.isDarkMode, required this.onThemeChanged}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late bool isDarkModeEnabled;

  @override
  void initState() {
    super.initState();
    isDarkModeEnabled = widget.isDarkMode; // Initialize with current theme state
  }

  void onThemeChanged(bool value) {
    setState(() {
      isDarkModeEnabled = value; // Update dark mode state
      widget.onThemeChanged(value); // Propagate theme change globally
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style: TextStyle(
            color: isDarkModeEnabled ? Colors.black : Colors.black, // Adjust title color based on mode
            fontSize: 24,
          ),
        ),
        centerTitle: true,
        backgroundColor: isDarkModeEnabled ? const Color(0xFF74ACD5) : const Color(0xFF74ACD5), // Adjust background color
        elevation: 1.0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(
              Icons.menu,
              color: isDarkModeEnabled ? Colors.black : Colors.black, // Adjust icon color
            ),
            onPressed: () {
              Navigator.pushNamed(context, '/side_bar');
            },
          ),
        ),
      ),
      body: Container(
        color: isDarkModeEnabled ? Colors.black : Colors.white, // Adjust body background color
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section: Content
            buildSectionHeader('Content'),
            buildSettingsOption(context, 'Notifications', SettingsNotificationsPage(
              isDarkMode: isDarkModeEnabled, // Pass the value
              onThemeChanged: onThemeChanged,
            )),

            // Section: Display
            buildSectionHeader('Display'),
            buildSettingsOption(
              context,
              'Appearance',
              SettingsAppearancePage(
                isDarkMode: isDarkModeEnabled, // Pass the value
                onThemeChanged: onThemeChanged, // Pass the callback
              ),
            ),

            // Section: Legal
            buildSectionHeader('Legal'),
            buildSettingsOption(context, 'Terms of Use', SettingsTermsPage()),
            buildSettingsOption(context, 'Privacy Policy', SettingsPrivacyPage()),
          ],
        ),
      ),
    );
  }

  // Settings Options
  Widget buildSettingsOption(BuildContext context, String title, Widget page) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 1.0, vertical: 0.1),
      decoration: BoxDecoration(
        border: Border.all(
          color: isDarkModeEnabled ? Colors.white : Colors.black, // Adjust border color
          width: 1.0,
        ),
      ),
      child: ListTile(
        title: Text(
          title,
          style: TextStyle(
            fontSize: 18.0,
            color: isDarkModeEnabled ? Colors.white : Colors.black, // Adjust text color
          ),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => page), // Navigate to the selected page
          );
        },
      ),
    );
  }

  Widget buildSectionHeader(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
      color: isDarkModeEnabled ? Colors.grey[800] : const Color.fromARGB(255, 210, 210, 210), // Adjust section header color
      width: double.infinity,
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18.0,
          fontWeight: FontWeight.bold,
          color: isDarkModeEnabled ? Colors.white : Colors.black, // Adjust text color in dark mode
        ),
      ),
    );
  }
}