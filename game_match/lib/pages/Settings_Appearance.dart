import 'package:flutter/material.dart';

class Settings_Appearance extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SettingsAppearancePage(),
    );
  }
}

class SettingsAppearancePage extends StatefulWidget {
  @override
  _AppearanceSettingsPageState createState() => _AppearanceSettingsPageState();
}

class _AppearanceSettingsPageState extends State<SettingsAppearancePage> {
  // Variable to hold the switch value
  bool isDarkModeEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Appearance',
          style: TextStyle(color: Colors.black, fontSize: 24),
        ),
        backgroundColor: const Color(0xFF74ACD5),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context); // Go back to Settings Page
          },
        ),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(0.1),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 1.0, vertical: 0.1),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 1.0),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Dark Mode',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                    Switch(
                      value: isDarkModeEnabled,
                      onChanged: (value) {
                        setState(() {
                          isDarkModeEnabled = value;
                        });
                      },
                      activeColor: const Color(0xFF74ACD5), // Active color is blue
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