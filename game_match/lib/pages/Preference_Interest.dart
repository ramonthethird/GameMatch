import 'package:flutter/material.dart';
import 'package:game_match/pages/Side_bar.dart';
import 'package:game_match/theme_notifier.dart';
import 'package:provider/provider.dart';

class PreferenceInterestPage extends StatefulWidget {
  final bool isDarkMode; // Accept current theme mode
  final ValueChanged<bool> onThemeChanged; // Theme change callback

  const PreferenceInterestPage({
    super.key,
    required this.isDarkMode, // Add dark mode parameter
    required this.onThemeChanged, // Add theme change callback
  });

  @override
  _PreferenceInterestPageState createState() => _PreferenceInterestPageState();
}

class _PreferenceInterestPageState extends State<PreferenceInterestPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    return Scaffold(
      key: _scaffoldKey, // Key for the scaffold
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
          backgroundColor: const Color(0xFF41B1F1),
          elevation: 0,
          leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.black), // Sidebar Icon
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        ),
      ),
      drawer: Drawer(
        child: SideBar(
          onThemeChanged: (isDarkMode) {
            // Handle theme change here
            themeNotifier.toggleTheme(isDarkMode);
          },
          isDarkMode: themeNotifier.isDarkMode,
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
                    icon: Icons.tune,
                    onPressed: () {
                      // Add navigation here
                      Navigator.pushNamed(context, '/preference_page');
                    },
                    isDarkMode: widget.isDarkMode, // Pass dark mode status
                  ),
                  const SizedBox(height: 15),

                  // Manage Interest button
                  CustomButton(
                    title: 'Manage interests & other options',
                    subtitle: 'Edit and Save other filter options',
                    icon: Icons.filter_list,
                    onPressed: () {
                      Navigator.pushNamed(context, '/Interest'); // Navigate to Interest page
                    },
                    isDarkMode: widget.isDarkMode, // Pass dark mode status
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

class CustomButton extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onPressed;
  final bool isDarkMode;

  const CustomButton({
    super.key, 
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onPressed,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
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
          backgroundColor: isDarkMode ? const Color.fromARGB(255, 50, 50, 50) : Colors.white,
          foregroundColor: isDarkMode ? Colors.white : Colors.black,
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
              color: isDarkMode ? Colors.white : Colors.black,
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
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
