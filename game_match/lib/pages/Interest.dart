import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:game_match/firebase_options.dart';

class InterestsPage extends StatefulWidget {
  const InterestsPage({super.key});

  @override
  _InterestsPageState createState() => _InterestsPageState();
}

class _InterestsPageState extends State<InterestsPage> {
  // Variables to hold selected values for each dropdown
  String? dropdownValue1;
  String? dropdownValue2;
  String? dropdownValue3;
  String? dropdownValue4;
  
  // Loading state
  bool _isLoading = false;

  // List of items for each dropdown
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

  // Firestore instance
  final firestore = FirebaseFirestore.instance;

  // User ID (set dynamically)
  late String userId;

  @override
  void initState() {
    super.initState();
    _getCurrentUserId(); // Get current user ID
    _loadInterests(); // Load user's interests when the page initializes
  }

  // Get currently authenticated user's ID
  void _getCurrentUserId() {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      userId = currentUser.uid; // Set userId to the authenticated user's ID
    } else {
      // Error message in case user is not authenticated
      print('User not authenticated.');
    }
  }

  // Save user interests to Firestore
  void _saveInterests() async {
    setState(() {
      _isLoading = true; // Show loading indicator
    });

    try {
      await firestore.collection('users').doc(userId).set({
        'interests': {
          'gameMode': dropdownValue1 ?? '',
          'playerPerspective': dropdownValue2 ?? '',
          'platform': dropdownValue3 ?? '',
          'price': dropdownValue4 ?? '',
        }
      }, SetOptions(merge: true)); // Merge with existing data

      // Popup feedback for user
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Interests saved successfully!'), backgroundColor: Colors.green),
      );

      // Print for debugging purposes
      print('Interests saved successfully:');
      print({
        'gameMode': dropdownValue1,
        'playerPerspective': dropdownValue2,
        'platform': dropdownValue3,
        'price': dropdownValue4,
      });
    } catch (e) {
      print('Error saving interests: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error saving interests.'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() {
        _isLoading = false; // Hide loading indicator
      });
    }
  }

  // Load user interests from Firestore
  void _loadInterests() async {
    setState(() {
      _isLoading = true; // Show loading indicator
    });

    try {
      // Access firestore collection to get current user's data
      DocumentSnapshot doc = await firestore.collection('users').doc(userId).get();

      // If a user already has interests saved before, load them
      if (doc.exists && doc['interests'] != null) {
        Map<String, dynamic> interests = doc['interests'];
        setState(() {
          dropdownValue1 = interests['gameMode'];
          dropdownValue2 = interests['playerPerspective'];
          dropdownValue3 = interests['platform'];
          dropdownValue4 = interests['price'];
        });

        // Print for debugging purposes
        print('Interests loaded successfully:');
        print(interests);
      } else {
        print('No interests found for the user.');
      }
    } catch (e) {
      print('Error loading interests: $e');
    } finally {
      setState(() {
        _isLoading = false; // Hide loading indicator
      });
    }
  }

  // SideBar button
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Interests', style: TextStyle(color: Colors.black, fontSize: 24)), // AppBar title
        centerTitle: true,
        backgroundColor: const Color(0xFF74ACD5),
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.black), // Sidebar Icon
          onPressed: () {
            Navigator.pushNamed(context, "/Side_bar"); // Open/Return to sidebar
          },
        ),
      ),

      // Header Title
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading 
          ? const Center(child: CircularProgressIndicator()) // Show loading indicator
          : Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Align(
                  alignment: Alignment.topCenter,
                  child: Text(
                    'Manage Interests',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                // Dropdown 1: Game Mode
                const Text(
                  'Game Mode', // Dropdown Title
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                DropdownButton<String>(
                  value: dropdownValue1,
                  hint: const Text('Select Game Mode'), // Dropdown Hint
                  onChanged: (String? newValue) {
                    setState(() {
                      dropdownValue1 = newValue;
                    });
                  },
                  items: gameModes.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 30),

                // Dropdown 2: Player Perspective
                const Text(
                  'Player Perspective', // Dropdown Title
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                DropdownButton<String>(
                  value: dropdownValue2,
                  hint: const Text('Select Player Perspective'), //Dropdown Hint
                  onChanged: (String? newValue) {
                    setState(() {
                      dropdownValue2 = newValue;
                    });
                  },
                  items: playerPerspective.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 30),

                // Dropdown 3: Platform
                const Text(
                  'Platform', // Dropdown Title
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                DropdownButton<String>(
                  value: dropdownValue3,
                  hint: const Text('Select Platform'), // Dropdown Hint
                  onChanged: (String? newValue) {
                    setState(() {
                      dropdownValue3 = newValue;
                    });
                  },
                  items: platforms.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 30),

                // Dropdown 4: Price
                const Text(
                  'Price', // Dropdown Title
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                DropdownButton<String>(
                  value: dropdownValue4,
                  hint: const Text('Select Price'), // Dropdown Hint
                  onChanged: (String? newValue) {
                    setState(() {
                      dropdownValue4 = newValue;
                    });
                  },
                  items: price.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 30),

                // Save Button
                ElevatedButton(
                  onPressed: _saveInterests,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    textStyle: const TextStyle(fontSize: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Save',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                )
              ],
            ),
      ),
    );
  }
}
