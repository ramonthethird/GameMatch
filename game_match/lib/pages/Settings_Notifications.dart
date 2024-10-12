import 'package:flutter/material.dart';

class Settings_Notifications extends StatelessWidget {
  final bool isDarkMode;
  final ValueChanged<bool> onThemeChanged;

  const Settings_Notifications({
    Key? key,
    required this.isDarkMode,
    required this.onThemeChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: isDarkMode ? ThemeData.dark() : ThemeData.light(),
      home: SettingsNotificationsPage(
        isDarkMode: isDarkMode,
        onThemeChanged: onThemeChanged,
      ),
    );
  }
}

class SettingsNotificationsPage extends StatefulWidget {
  final bool isDarkMode;
  final ValueChanged<bool> onThemeChanged;

  const SettingsNotificationsPage({
    Key? key,
    required this.isDarkMode,
    required this.onThemeChanged,
  }) : super(key: key);

  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<SettingsNotificationsPage> {
  bool _notificationsEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Notifications',
          style: TextStyle(
            color: widget.isDarkMode ? Colors.black : Colors.black, // Adapt text color
            fontSize: 24,
          ),
        ),
        centerTitle: true,
        backgroundColor:
            widget.isDarkMode ? const Color(0xFF74ACD5) : const Color(0xFF74ACD5), // Adapt background color
        elevation: 1.0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: widget.isDarkMode ? Colors.black : Colors.black, // Adapt icon color
          ),
          onPressed: () {
            Navigator.pop(context); // Go back to Settings Page
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(0.1),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 1.0, vertical: 0.1),
          decoration: BoxDecoration(
            border: Border.all(
              color: widget.isDarkMode ? Colors.white : Colors.black, // Adapt border color
              width: 1.0,
            ),
          ),
          child: ListTile(
            title: Text(
              'Enable Notifications',
              style: TextStyle(
                fontSize: 18.0,
                color: widget.isDarkMode ? Colors.white : Colors.black, // Adapt text color
              ),
            ),
            trailing: Switch(
              value: _notificationsEnabled,
              onChanged: (bool value) {
                setState(() {
                  _notificationsEnabled = value;
                });
              },
              activeColor: const Color(0xFF74ACD5), // Active color remains blue
            ),
          ),
        ),
      ),
    );
  }
}
