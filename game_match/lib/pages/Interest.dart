import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class InterestsPage extends StatefulWidget {
  const InterestsPage({super.key});

  @override
  _InterestsPageState createState() => _InterestsPageState();
}

class _InterestsPageState extends State<InterestsPage> {
  String? dropdownValue1;
  String? dropdownValue2;
  String? dropdownValue3;
  String? dropdownValue4;
  
  // Loading state
  bool _isLoading = false;

  final List<String> gameModes = [
    'Select',
    'Single Player',
    'Multiplayer',
    'Co-operative',
    'Online PvP'
  ];

  final List<String> playerPerspective = [
    'Select',
    'First Person',
    'Third Person',
    'Top-Down',
    'Side-Scrolling'
  ];

  final List<String> platforms = [
    'Select',
    'PC',
    'PlayStation',
    'Xbox',
    'Nintendo Switch'
  ];

  final List<String> ratings = [
    'Select',
    '0 - 20',
    '21 - 40',
    '41 - 60',
    '61 - 80',
    '81 - 100',
  ];


  final firestore = FirebaseFirestore.instance;

  // User ID (set dynamically)
  late String userId;

  @override
  void initState() {
    super.initState();
    _getCurrentUserId();
    _loadInterests();
  }

  void _getCurrentUserId() {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      setState(() {
        userId = currentUser.uid;
      });
    } else {
      print('User not authenticated.');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User not authenticated. Please log in again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }


  void _saveInterests() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await firestore.collection('users').doc(userId).set({
        'interests': {
        'gameMode': dropdownValue1 == 'None' ? '' : dropdownValue1 ?? '',
        'playerPerspective': dropdownValue2 == 'None' ? '' : dropdownValue2 ?? '',
        'platform': dropdownValue3 == 'None' ? '' : dropdownValue3 ?? '',
        'rating': dropdownValue4 == 'None' ? '' : dropdownValue4 ?? '',
        }
      }, SetOptions(merge: true));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Interests saved successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('Error saving interests: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error saving interests.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _loadInterests() async {
    setState(() {
      _isLoading = true;
    });

    try {
      DocumentSnapshot doc = await firestore.collection('users').doc(userId).get();

      if (doc.exists && doc['interests'] != null) {
        Map<String, dynamic> interests = doc['interests'];
      setState(() {
        dropdownValue1 = gameModes.contains(interests['gameMode']) ? interests['gameMode'] : null;
        dropdownValue2 = playerPerspective.contains(interests['playerPerspective']) ? interests['playerPerspective'] : null;
        dropdownValue3 = platforms.contains(interests['platform']) ? interests['platform'] : null;
        dropdownValue4 = ratings.contains(interests['rating']) ? interests['rating'] : null;
      });
      } else {
        print('No interests found for the user.');
      }
    } catch (e) {
      print('Error loading interests: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Interests',
          style: TextStyle(color: Colors.black, fontSize: 16),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF41B1F1),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pushNamed(context, "/Preference_&_Interest");
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  const Text(
                    'Manage Interests',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20), // Space between title and dropdowns
                  _buildDropdownCard(
                    icon: Icons.videogame_asset,
                    label: 'Game Mode',
                    value: dropdownValue1,
                    items: gameModes,
                    onChanged: (String? newValue) {
                      setState(() {
                        dropdownValue1 = newValue;
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  _buildDropdownCard(
                    icon: Icons.visibility,
                    label: 'Player Perspective',
                    value: dropdownValue2,
                    items: playerPerspective,
                    onChanged: (String? newValue) {
                      setState(() {
                        dropdownValue2 = newValue;
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  _buildDropdownCard(
                    icon: Icons.devices,
                    label: 'Platform',
                    value: dropdownValue3,
                    items: platforms,
                    onChanged: (String? newValue) {
                      setState(() {
                        dropdownValue3 = newValue;
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  _buildDropdownCard(
                    icon: Icons.star,
                    label: 'Rating',
                    value: dropdownValue4,
                    items: ratings,
                    onChanged: (String? newValue) {
                      setState(() {
                        dropdownValue4 = newValue;
                      });
                    },
                  ),
                  const SizedBox(height: 30),
                  _buildSaveButton(),
                ],
              ),
      ),
    );
  }

  Widget _buildDropdownCard({
    required IconData icon,
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: const Color(0xFF74ACD5)),
                const SizedBox(width: 10),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            DropdownButton<String>(
            value: value == null || value == '' ? 'Select' : value, // Handle unselected state
            hint: Text('Select $label'),
            isExpanded: true,
            onChanged: onChanged,
              items: items.map<DropdownMenuItem<String>>((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(item),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return ElevatedButton(
      onPressed: _saveInterests,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF41B1F1),
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
        textStyle: const TextStyle(fontSize: 18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: const Text(
        'Save',
        style: TextStyle(
          color: Colors.white,
          fontSize: 14,
        ),
      ),
    );
  }
}