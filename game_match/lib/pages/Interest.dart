import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

  // Customized list of items for each dropdown
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

  // Dummy user ID for testing purposes
  final String userId = 'user123';

  @override
  void initState() {
    super.initState();
    _loadInterests(); // Load the user's interests when the page initializes
  }

  // Method to save user's interests to Firestore
  void _saveInterests() async {
    await firestore.collection('users').doc(userId).set({
      'interests': {
        'gameMode': dropdownValue1 ?? '',
        'playerPerspective': dropdownValue2 ?? '',
        'platform': dropdownValue3 ?? '',
        'price': dropdownValue4 ?? '',
      }
    }, SetOptions(merge: true)); // Merge the interests with existing data

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Interests saved successfully!')),
    );

    // Print for debugging
    print('Interests saved successfully:');
    print({
      'gameMode': dropdownValue1,
      'playerPerspective': dropdownValue2,
      'platform': dropdownValue3,
      'price': dropdownValue4,
    });
  }

  // Method to load user's interests from Firestore
  void _loadInterests() async {
    DocumentSnapshot doc = await firestore.collection('users').doc(userId).get();

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
  }

  // SideBar button
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Interests'),
        centerTitle: true,
        backgroundColor: const Color(0xFF74ACD5),
        leading: IconButton(
          icon: Icon(Icons.menu),
          onPressed: () {
            //Scaffold.of(context).openDrawer();
            Navigator.pushNamed(context,"/side_bar");
          },
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: const Color(0xFF74ACD5),
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
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
              onTap: () {},
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: Text(
                'Manage Interests',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 40),

            // Dropdown 1: Game Mode
            Text(
              'Game Mode',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            DropdownButton<String>(
              value: dropdownValue1,
              hint: Text('Select Game Mode'),
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
            SizedBox(height: 30),

            // Dropdown 2: Player Perspective
            Text(
              'Player Perspective',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            DropdownButton<String>(
              value: dropdownValue2,
              hint: Text('Select Player Perspective'),
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
            SizedBox(height: 30),

            // Dropdown 3: Platform
            Text(
              'Platform',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            DropdownButton<String>(
              value: dropdownValue3,
              hint: Text('Select Platform'),
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
            SizedBox(height: 30),

            // Dropdown 4: Price
            Text(
              'Price',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            DropdownButton<String>(
              value: dropdownValue4,
              hint: Text('Select Price'),
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
            SizedBox(height: 30),

            // Save Button
            ElevatedButton(
              onPressed: _saveInterests,
              child: Text(
                'Save',
                style: TextStyle(
                  color: Colors.white, // Set the text color here
                  fontSize: 18,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
