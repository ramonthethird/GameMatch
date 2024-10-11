import 'package:flutter/material.dart';

class Settings_Notifications extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SettingsNotificationsPage(),
    );
  }
}

class SettingsNotificationsPage extends StatefulWidget {
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
          style: TextStyle(color: Colors.black, fontSize: 24),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF74ACD5),
        elevation: 1.0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.black,
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
              color: Colors.black,
              width: 1.0,
            ),
          ),
          child: ListTile(
            title: Text(
              'Enable Notifications',
              style: TextStyle(fontSize: 18.0),
            ),
            trailing: Switch(
              value: _notificationsEnabled,
              onChanged: (bool value) {
                setState(() {
                  _notificationsEnabled = value;
                });
              },
              activeColor: const Color(0xFF74ACD5), // Active color is blue
            ),
          ),
        ),
      ),
    );
  }
}