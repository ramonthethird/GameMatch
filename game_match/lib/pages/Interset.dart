import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: InterestsPage(),
    );
  }
}

class InterestsPage extends StatefulWidget {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Interests'),
        centerTitle: true,
        backgroundColor: Colors.blue,
        // Sidebar button
        leading: IconButton(
          icon: Icon(Icons.menu), // Three-lines icon
          onPressed: () {
            // Action to open a drawer or sidebar
            // Scaffold.of(context).openDrawer();
          },
        ),
      ),
      // Sidebar Nav (in dev)
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
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
              leading: Icon(Icons.home),
              title: Text('Swipe Page'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to Swipe Page
              },
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to Settings Page
              },
            ),
            ListTile(
              leading: Icon(Icons.info),
              title: Text('Preferences'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to Preferences / Interests Page
              },
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

            // First Dropdown (Game Mode)
            Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
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
            ),
            SizedBox(height: 50),

            // Second Dropdown (Player Perspective)
            Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
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
            ),
            SizedBox(height: 50),

            // Third Dropdown (Platform)
            Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
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
            ),
            SizedBox(height: 50),

            // Fourth Dropdown Price
            Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
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
                ],
              ),
            ),
            SizedBox(height: 50),

            // Save Button
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Notify user that changes has been saved
                  print('User preferences saved!');
                },
                child: Text('Save'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  textStyle: TextStyle(fontSize: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
