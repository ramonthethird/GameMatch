import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ViewProfile extends StatefulWidget {
  const ViewProfile({super.key});

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<ViewProfile> {
  String? _profileImageUrl;
  String _username = "User";
  String _bio = "Bio.";
  String _favoriteGame1 = "Game 1";
  String _favoriteGame2 = "Game 2";
  String _favoriteGame3 = "Game 3";

  bool _isLoading = true; // Loading state to show while fetching data

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = ModalRoute.of(context)!.settings.arguments as String;
      _loadUserDataForUser(userId);
    });
  }

  Future<void> _loadUserDataForUser(String userId) async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        setState(() {
          _username = userDoc.data()?['username'] ?? 'User';
          _bio = userDoc.data()?['bio'] ?? '';
          _favoriteGame1 = userDoc.data()?['favoriteGames']?['game1'] ?? '';
          _favoriteGame2 = userDoc.data()?['favoriteGames']?['game2'] ?? '';
          _favoriteGame3 = userDoc.data()?['favoriteGames']?['game3'] ?? '';
          _profileImageUrl = userDoc.data()?['profileImageUrl'];
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print("Error loading user data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.cancel, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        width: double.infinity,
                        height: 140,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFFF1F3F4), Color(0xFFF1F3F4)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
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
                        _buildTextField(
                            "Bio", _bio, 4, Icons.info_outline, false),
                        const SizedBox(height: 12),
                        const Text("Favorite Games",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
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
        color:  Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        style: const TextStyle(color: Colors.black),
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