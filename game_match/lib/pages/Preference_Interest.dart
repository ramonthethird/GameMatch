import 'package:flutter/material.dart';

class PreferenceInterestPage extends StatelessWidget {
  const PreferenceInterestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0), // Adjust height as needed
        child: AppBar(
          title: const Text(
            'Preferences & Interests',
        preferredSize: Size.fromHeight(60.0),
        child: AppBar(
          title: Text(
            'Preferences & Interests', // AppBar Title
            style: TextStyle(
              color: Colors.black,
            ),
          ),
          centerTitle: true,
          backgroundColor: const Color(0xFF74ACD5),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              //Scaffold.of(context).openDrawer();
              Navigator.pop(context,"/SideBar");
            },
          ),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
           const DrawerHeader(
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
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () {
                // Navigate to Home Page
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                // Navigate to Settings Page
              },
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('About'),
              onTap: () {
                // Navigate to About Page
              },
            ),
          ],
        ),
      ),
              Navigator.pop(context,"/SideBar"); // Open/Return to sidebar

            },
          ),
        ),
      ),
      
      body: Stack(
        children: [
          Container(
            height: 0, // Adjust height to better fit the new AppBar size
            decoration:const BoxDecoration(
              color: Colors.blue,
            height: 0,
            decoration: BoxDecoration(
              color: const Color(0xFF74ACD5),
              borderRadius: BorderRadius.only(
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(top: 20), // Adjust padding to control content position
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                 const  SizedBox(height: 15), // Space below AppBar

                  // Manage Preference button
                  CustomButton(
                    title: 'Manage preferences',
                    subtitle: 'Edit and Save genre preferences',
                    icon: Icons.tune, // Preference icon
                    onPressed: () {
                      // Navigate to Preference page (put code here)
                    },
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

  const CustomButton({super.key, 
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onPressed,
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
        style: ElevatedButton.styleFrom( // Effect when clicking button
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.all(25),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.black),
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
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    subtitle,
                    style: const TextStyle(
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