import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'Side_bar.dart';
import 'package:game_match/theme_notifier.dart';
import 'package:provider/provider.dart';


class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String? _profileImageUrl;
  String _username = 'User';
  String _bio = "Bio.";
  String _favoriteGame1 = "Game 1";
  String _favoriteGame2 = "Game 2";
  String _favoriteGame3 = "Game 3";

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      setState(() {
        _username = userDoc['username'] ?? 'User';
        _bio = userDoc.data()?.containsKey('bio') == true ? userDoc['bio'] : '';
        _profileImageUrl = userDoc.data()?['profileImageUrl'] ?? ''; // Fetch profile image URL
        _favoriteGame1 = userDoc.data()?.containsKey('favoriteGames') == true ? userDoc['favoriteGames']['game1'] ?? '' : '';
        _favoriteGame2 = userDoc.data()?.containsKey('favoriteGames') == true ? userDoc['favoriteGames']['game2'] ?? '' : '';
        _favoriteGame3 = userDoc.data()?.containsKey('favoriteGames') == true ? userDoc['favoriteGames']['game3'] ?? '' : '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Profile',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
          ),
        ),
        //backgroundColor: const Color(0xFF74ACD5),
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.black),
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
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: 140,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        //Colors.grey[300]!
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 6,
                  right: 6,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.edit),
                    label: const Text("Edit Profile"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF41B1F1), // Background color
                      foregroundColor: Colors.white, // Text color
                    ),
                    onPressed: () {
                      // Navigate to Edit Profile Page
                      Navigator.pushNamed(context, '/Edit_profile');
                    },
                  ),
                ),
                Align(
                  alignment: Alignment.topCenter,
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      CircleAvatar(
                        radius: 40,
                        backgroundImage: _profileImageUrl != null &&
                                _profileImageUrl!.isNotEmpty
                            ? NetworkImage(_profileImageUrl!)
                            : null,
                        child: _profileImageUrl == null ||
                                _profileImageUrl!.isEmpty
                            ? const Icon(Icons.person, size: 40)
                            : null,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  _buildTextField(
                      "Username", _username, 1, Icons.person, false),
                  const SizedBox(height: 12),
                  _buildTextField("Bio", _bio, 4, Icons.info_outline, false),
                  const SizedBox(height: 12),
                  const Text("Favorite Games",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  _buildTextField("Favorite Game 1", _favoriteGame1, 1,
                      Icons.videogame_asset, false),
                  const SizedBox(height: 6),
                  _buildTextField("Favorite Game 2", _favoriteGame2, 1,
                      Icons.videogame_asset, false),
                  const SizedBox(height: 6),
                  _buildTextField("Favorite Game 3", _favoriteGame3, 1,
                      Icons.videogame_asset, false),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
      String label, String value, int maxLines, IconData icon, bool enabled) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        //style: const TextStyle(color: Colors.black),
        controller: TextEditingController(text: value),
        maxLines: maxLines,
        enabled: enabled,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: InputBorder.none,
        ),
        readOnly: true,
      ),
    );
  }
}