import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:game_match/theme_notifier.dart';
import 'package:game_match/pages/Settings_Terms.dart';
import 'package:game_match/pages/Settings_Privacy.dart';
import 'Side_bar.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String? fetchedUsername;
  String? profilePictureUrl; // Store profile picture URL
  bool notificationsEnabled = false;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          setState(() {
            fetchedUsername = userDoc['username'] ?? 'No username found';
            profilePictureUrl = userDoc['profileImageUrl'] ?? ''; // Fetch profile picture URL
          });
        } else {
          setState(() {
            fetchedUsername = 'No username found';
          });
        }
      } else {
        setState(() {
          fetchedUsername = 'User not logged in';
        });
      }
    } catch (e) {
      print('Error fetching user profile: $e');
      setState(() {
        fetchedUsername = 'Error fetching user profile';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return Scaffold(
      key: _scaffoldKey, // Key for the scaffold
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
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
      drawer: Drawer(
        child: SideBar(
          onThemeChanged: (isDarkMode) {
            // Handle theme change here
            themeNotifier.toggleTheme(isDarkMode);
          },
          isDarkMode: themeNotifier.isDarkMode,
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          color: themeNotifier.isDarkMode ? Colors.black : Colors.grey[200],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              CircleAvatar(
                radius: 50,
                backgroundImage: profilePictureUrl != null && profilePictureUrl!.isNotEmpty
                    ? NetworkImage(profilePictureUrl!) // Use the URL if available
                    : const AssetImage('assets/images/profile_picture.png') as ImageProvider, // Fallback to placeholder
              ),
              const SizedBox(height: 10),
              Text(
                fetchedUsername ?? 'Loading...',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: themeNotifier.isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 20),
              buildSectionHeader('Appearance'),
              buildSwitchOption(
                'Dark Mode',
                themeNotifier.isDarkMode,
                Icons.dark_mode,
                (value) {
                  themeNotifier.toggleTheme(value);
                },
              ),
              const SizedBox(height: 20),
              buildSectionHeader('Notifications'),
              buildSwitchOption(
                'Enable Notifications',
                notificationsEnabled,
                Icons.notifications_active,
                (value) {
                  setState(() {
                    notificationsEnabled = value;
                  });
                },
              ),
              const SizedBox(height: 20),
              buildSectionHeader('Legal'),
              buildSettingsOption(
                context,
                'Terms of Service',
                const SettingsTermsPage(),
                Icons.description,
              ),
              buildSettingsOption(
                context,
                'Privacy Policy',
                const SettingsPrivacyPage(),
                Icons.privacy_tip,
              ),
              const SizedBox(height: 200),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildSettingsOption(
      BuildContext context, String title, dynamic action, IconData icon) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
      decoration: BoxDecoration(
        color: themeNotifier.isDarkMode ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: themeNotifier.isDarkMode ? Colors.white : Colors.black,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 14.0,
            color: themeNotifier.isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: () {
          if (action is Function) {
            action();
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => action),
            );
          }
        },
      ),
    );
  }

  Widget buildSectionHeader(String title) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18.0,
          fontWeight: FontWeight.bold,
          color: themeNotifier.isDarkMode ? Colors.white : Colors.black,
        ),
      ),
    );
  }

  Widget buildSwitchOption(
      String title, bool value, IconData icon, ValueChanged<bool> onChanged) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
      decoration: BoxDecoration(
        color: themeNotifier.isDarkMode ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child: SwitchListTile(
        title: Row(
          children: [
            Icon(
              icon,
              color: themeNotifier.isDarkMode ? Colors.white : Colors.black,
            ),
            const SizedBox(width: 10),
            Text(
              title,
              style: TextStyle(
                fontSize: 14.0,
                color: themeNotifier.isDarkMode ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
        value: value,
        inactiveThumbColor: Colors.grey[400],
        inactiveTrackColor: Colors.grey[600],
        activeColor: const Color(0xFF74ACD5),
        onChanged: onChanged,
      ),
    );
  }
}
