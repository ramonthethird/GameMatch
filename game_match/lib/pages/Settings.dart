import 'package:flutter/material.dart';
import 'package:game_match/pages/Side_bar.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1.0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(
              Icons.menu,
              color: Colors.black,
            ),
            onPressed: () {
              //Scaffold.of(context).openDrawer();
              Navigator.pop(context,"/SideBar"); // Open/Return to sidebar
            },
          ),
        ),
        titleTextStyle: TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Create Section Titles and Buttons
          // Section Title: Content
          buildSectionHeader('Content'),
          buildSettingsOption(context, 'Notifications'),

          // Section Title: Display
          buildSectionHeader('Display'),
          buildSettingsOption(context, 'Appearance'),

          // Section Title: Legal
          buildSectionHeader('Legal'),
          buildSettingsOption(context, 'Terms of Use'),
          buildSettingsOption(context, 'Privacy Policy'),
        ],
      ),
    );
  }

  // Settings Options
  Widget buildSettingsOption(BuildContext context, String title) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 1.0, vertical: 0.1),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 1.0),
      ),
      child: ListTile(
        title: Text(
          title,
          style: TextStyle(
            fontSize: 18.0,
          ),
        ),
        onTap: () {
        },
      ),
    );
  }

  // Section Headers
  Widget buildSectionHeader(String title) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
      color: const Color.fromARGB(255, 210, 210, 210),
      width: double.infinity,
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18.0,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}