import 'package:flutter/material.dart';

class Preference_Interest_Page extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.0), // Adjust height as needed
        child: AppBar(
          title: Text(
            'Preferences & Interests',
            style: TextStyle(
              //fontSize: 20, // Change font size to make it more compact
              color: Colors.black,
            ),
          ),
          centerTitle: true,
          backgroundColor: const Color(0xFF74ACD5),
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {
              //Scaffold.of(context).openDrawer();
            },
          ),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Home'),
              onTap: () {
                // Navigate to Home Page
              },
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
              onTap: () {
                // Navigate to Settings Page
              },
            ),
            ListTile(
              leading: Icon(Icons.info),
              title: Text('About'),
              onTap: () {
                // Navigate to About Page
              },
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          // Background Header (below AppBar)
          Container(
            height: 0, // Adjust height to better fit the new AppBar size
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.only(
                //bottomLeft: Radius.circular(30),
                //bottomRight: Radius.circular(30),
              ),
            ),
          ),

          // Page Content (Column shifted down to be under header)
          Padding(
            padding: const EdgeInsets.only(top: 20), // Adjust padding to control content position
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 15), // Space below AppBar

                  // First Button (Manage Preferences)
                  CustomButton(
                    title: 'Manage preferences',
                    subtitle: 'Edit and Save genre preferences',
                    icon: Icons.tune,
                    onPressed: () {
                      // Navigate or perform functionality
                    },
                  ),
                  SizedBox(height: 15),

                  // Second Button (Manage Interests & Other Options)
                  CustomButton(
                    title: 'Manage interests & other options',
                    subtitle: 'Edit and Save other filter options',
                    icon: Icons.filter_list,
                    onPressed: () {
                      // Navigate or perform functionality
                    },
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

// Custom Button Widget for consistency
class CustomButton extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onPressed;

  const CustomButton({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          padding: EdgeInsets.all(25),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.black),
            SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
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