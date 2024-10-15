import 'package:flutter/material.dart';

class SettingsAppearancePage extends StatefulWidget {
  final bool isDarkMode; // Pass the current dark mode state
  final ValueChanged<bool> onThemeChanged; // Pass the callback to toggle the theme globally

  const SettingsAppearancePage({
    super.key,
    required this.isDarkMode,
    required this.onThemeChanged,
  });

  @override
  _SettingsAppearancePageState createState() => _SettingsAppearancePageState();
}

class _SettingsAppearancePageState extends State<SettingsAppearancePage> {
  late bool isDarkModeEnabled;

  @override
  void initState() {
    super.initState();
    isDarkModeEnabled = widget.isDarkMode; // Initialize with current theme state
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Appearance',
          style: TextStyle(
            color: isDarkModeEnabled ? Colors.black : Colors.black, // White text in dark mode
            fontSize: 24,
          ),
        ),
        backgroundColor: isDarkModeEnabled ? const Color(0xFF74ACD5) : const Color(0xFF74ACD5), // Black background in dark mode
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDarkModeEnabled ? Colors.black : Colors.black, // White icon in dark mode
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        color: isDarkModeEnabled ? Colors.black : Colors.white, // Black background in dark mode
        padding: const EdgeInsets.all(0.1),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 1.0, vertical: 0.1),
              decoration: BoxDecoration(
                border: Border.all(
                  color: isDarkModeEnabled ? Colors.white : Colors.black, // White border in dark mode
                  width: 1.0,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Dark Mode',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: isDarkModeEnabled ? Colors.white : Colors.black, // White text in dark mode
                      ),
                    ),
                    Switch(
                      value: isDarkModeEnabled,
                      onChanged: (value) {
                        setState(() {
                          isDarkModeEnabled = value; // Update local state
                          widget.onThemeChanged(isDarkModeEnabled); // Update global theme state
                        });
                      },
                      activeColor: Colors.blue,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
