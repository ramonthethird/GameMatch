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
    'Single Player',
    'Multiplayer',
    'Co-op',
    'Online PvP'
  ];

  final List<String> playerPerspective = [
    'First Person',
    'Third Person',
    'Top-Down',
    'Side-Scrolling'
  ];

  final List<String> platforms = [
    'PC',
    'PlayStation',
    'Xbox',
    'Nintendo Switch'
  ];

  final List<String> price = [
    'Free',
    '\$0 - \$20',
    '\$20 - \$50',
    '\$50 - \$80'
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
      userId = currentUser.uid;
    } else {
      print('User not authenticated.');
    }
  }

  void _saveInterests() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await firestore.collection('users').doc(userId).set({
        'interests': {
          'gameMode': dropdownValue1 ?? '',
          'playerPerspective': dropdownValue2 ?? '',
          'platform': dropdownValue3 ?? '',
          'price': dropdownValue4 ?? '',
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
      DocumentSnapshot doc =
          await firestore.collection('users').doc(userId).get();

      if (doc.exists && doc['interests'] != null) {
        Map<String, dynamic> interests = doc['interests'];
        setState(() {
          dropdownValue1 = interests['gameMode'];
          dropdownValue2 = interests['playerPerspective'];
          dropdownValue3 = interests['platform'];
          dropdownValue4 = interests['price'];
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
          style: TextStyle(color: Colors.black, fontSize: 24),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF74ACD5),
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.black),
          onPressed: () {
            Navigator.pushNamed(context, "/Side_bar");
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
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                      height: 30), // Space between title and dropdowns
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
                  const SizedBox(height: 20),
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
                  const SizedBox(height: 20),
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
                  const SizedBox(height: 20),
                  _buildDropdownCard(
                    icon: Icons.attach_money,
                    label: 'Price',
                    value: dropdownValue4,
                    items: price,
                    onChanged: (String? newValue) {
                      setState(() {
                        dropdownValue4 = newValue;
                      });
                    },
                  ),
                  const SizedBox(height: 40),
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
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            DropdownButton<String>(
              value: value,
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
        backgroundColor: const Color(0xFF74ACD5),
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
          fontSize: 18,
        ),
      ),
    );
  }
}
