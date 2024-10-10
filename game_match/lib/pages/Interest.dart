import 'package:flutter/material.dart';
import 'package:game_match/pages/Side_bar.dart'; // Import the side bar page

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: InterestsPage(),
    );
  }
}

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

  // Dummy user ID for testing purposes
  final String userId = 'user123';

  @override
  void initState() {
    super.initState();
    _loadInterests(); // Load the user's interests when the page initializes
  }

  // Save user's interests to Firestore
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
  }

  // Load user's interests from Firestore
  void _loadInterests() async {
    DocumentSnapshot doc = await firestore.collection('users').doc(userId).get();

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
  }

  // SideBar button
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Interests'), // AppBar title
        centerTitle: true,
        backgroundColor:const Color(0xFF74ACD5),
        // Sidebar button
        leading: IconButton(
          icon: const Icon(Icons.menu), // Three-lines icon
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SideBar()),
            );
          },
        ),
        ),
      // Sidebar Nav (in dev)
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color:  Color(0xFF74ACD5),
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
              title: const Text('Swipe Page'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to Swipe Page
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to Settings Page
              },
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('Preferences'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to Preferences / Interests Page
              },
            ),
          ],
        ),
      ),
          icon: const Icon(Icons.menu), // Sidebar Icon
          onPressed: () {
            //Scaffold.of(context).openDrawer();
            Navigator.pushNamed(context,"/side_bar"); // Open/Return to sidebar
          },
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

            // First Dropdown (Game Mode)
            Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Game Mode',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  DropdownButton<String>(
                    value: dropdownValue1,
                    hint: const Text('Select Game Mode'),
                    onChanged: (String? newValue) {
                      setState(() {
                        dropdownValue1 = newValue;
                      });
                    },
                    items:
                        gameModes.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ],
              ),
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
            const SizedBox(height: 40),


            // Second Dropdown (Player Perspective)
            Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Player Perspective',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  DropdownButton<String>(
                    value: dropdownValue2,
                    hint: const Text('Select Player Perspective'),
                    onChanged: (String? newValue) {
                      setState(() {
                        dropdownValue2 = newValue;
                      });
                    },
                    items: playerPerspective
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ],
              ),
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
            const SizedBox(height: 40),

            // Third Dropdown (Platform)
            Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Platform',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  DropdownButton<String>(
                    value: dropdownValue3,
                    hint: const Text('Select Platform'),
                    onChanged: (String? newValue) {
                      setState(() {
                        dropdownValue3 = newValue;
                      });
                    },
                    items:
                        platforms.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ],
              ),
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
            const SizedBox(height: 40),


            // Fourth Dropdown Price
            Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Price',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  DropdownButton<String>(
                    value: dropdownValue4,
                    hint: const Text('Select Price'),
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
                ],
              ),
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
            const SizedBox(height: 40),

            // Save Button
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Notify user that changes has been saved
                  print('User preferences saved!');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  textStyle: const TextStyle(fontSize: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
            ElevatedButton(
              onPressed: _saveInterests,
              child: Text(
                'Save',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                textStyle: const TextStyle(fontSize: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
