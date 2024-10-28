import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:game_match/pages/Side_bar.dart';

class InterestsPage extends StatefulWidget {
  const InterestsPage({super.key});
  
  @override
   _InterestsPageState createState() => _InterestsPageState();
}

class _InterestsPageState extends State<InterestsPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  // Variables to hold selected values for each dropdown
  String? dropdownValue1;
  String? dropdownValue2;
  String? dropdownValue3;
  String? dropdownValue4;

  // List of items for each dropdown
  final List<String> gameModes = [
    'Single Player', 
    'Multiplayer', 
    'Co-op', 
    'Online Pvp'
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

  // FirebaseAuth instance
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _loadInterests(); // Load the user's interests when the page initializes
  }

  // Save user's interests to Firestore
  void _saveInterests() async {
    User? user = _auth.currentUser;
    if (user != null) {
      await firestore.collection('users').doc(user.uid).set({
        'interests': {
          'gameMode': dropdownValue1 ?? '',
          'playerPerspective': dropdownValue2 ?? '',
          'platform': dropdownValue3 ?? '',
          'price': dropdownValue4 ?? '',
        }
      }, SetOptions(merge: true)); // Merge the interests with existing data

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Interests saved successfully!')),
      );

      // Print for debugging
      print('Interests saved successfully:');
      print({
        'gameMode': dropdownValue1,
        'playerPerspective': dropdownValue2,
        'platform': dropdownValue3,
        'price': dropdownValue4,
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No user is signed in.')),
      );
    }
  }

  // Load user's interests from Firestore
  void _loadInterests() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot doc = await firestore.collection('users').doc(user.uid).get();

      // If a user already have interests saved before, load them
      if (doc.exists && doc['interests'] != null) {
        Map<String, dynamic> interests = doc['interests'];
        setState(() {
          dropdownValue1 = interests['gameMode'];
          dropdownValue2 = interests['playerPerspective'];
          dropdownValue3 = interests['platform'];
          dropdownValue4 = interests['price'];
        });

        // Print for debugging
        print('Interests loaded successfully:');
        print(interests);
      } else {
        print('No interests found for the user.');
      }
    } else {
      print('No user is signed in.');
    }
  }

  // SideBar button
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey, 
      appBar: AppBar(
        title: const Text('Interests', style: TextStyle(color: Colors.black, fontSize: 24)), // AppBar title
        centerTitle: true,
        backgroundColor: const Color(0xFF74ACD5),
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
          },
          isDarkMode: false, // Replace with actual theme state if implemented
        ),
      ),
      // Header Title
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
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
              onChanged: (String? newValue) { // Change state of dropdown, show selected item
                setState(() {
                  dropdownValue1 = newValue;
                });
              },
              items: gameModes.map<DropdownMenuItem<String>>((String value) { // Use gameModes string values as dropdown items
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
              onChanged: (String? newValue) { // Change state of dropdown, show selected item
                setState(() {
                  dropdownValue2 = newValue;
                });
              },
              items: playerPerspective.map<DropdownMenuItem<String>>((String value) { // Use playerPerspective string values as dropdown items
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
              onChanged: (String? newValue) { // Change state of dropdown, show selected item
                setState(() {
                  dropdownValue3 = newValue;
                });
              },
              items: platforms.map<DropdownMenuItem<String>>((String value) { // Use platforms string values as dropdown items
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
              onChanged: (String? newValue) { // Change state of dropdown item, show selected item
                setState(() {
                  dropdownValue4 = newValue;
                });
              },
              items: price.map<DropdownMenuItem<String>>((String value) { // Use price string values as dropdown items
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
              child: const Text(
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