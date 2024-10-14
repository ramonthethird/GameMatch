import 'package:flutter/material.dart';

class Profile extends StatelessWidget {
  const Profile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(fontSize: 12),
        ), // Title of the page
        actions: [
          IconButton(
        icon: const Icon(Icons.settings),
        onPressed: () {
          // Navigate to Settings Page
          Navigator.pushNamed(context, '/Side_bar');
        },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                padding: const EdgeInsets.all(8), // Reduced padding
                color: const Color(0xFF74ACD5),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 50, // Reduced width
                      height: 50, // Reduced height
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/images/profile.png'),
                        ),
                      ),
                    ),
                    const Text(
                      'John Doe', // User's name extracted from the database
                      style: TextStyle(fontSize: 14), // Reduced font size
                    ),
                    const Text(
                      'Diamond Member', // User's membership level extracted from the database
                      style: TextStyle(fontSize: 14), // Reduced font size
                    ),
                    const SizedBox(height: 6),
                    Align(
                      alignment: Alignment.bottomRight, // Align the button to the bottom right
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.edit),
                        label: const Text("Edit Profile"),
                        onPressed: () {
                          // Navigate to Edit Profile Page
                          Navigator.pushNamed(context, '/Edit_profile');
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8), // Reduced padding
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Status:",
                    style: TextStyle(fontSize: 14), // Reduced font size
                  ),
                  Text(
                    'Game match member since: ', // User's membership level extracted from the database
                    style: TextStyle(fontSize: 14), // Reduced font size
                  ),
                  Text(
                    'date : ', // from the database
                    style: TextStyle(fontSize: 14), // Reduced font size
                  )
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8), // Reduced padding
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Bio:",
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: TextEditingController(text: 'I am .......'), // user bio from the database
                    maxLines: 4,
                    decoration: InputDecoration(
                      fillColor: Colors.grey[200],
                      filled: true,
                      border: const OutlineInputBorder(),
                      hintText: 'Enter your bio here',
                    ),
                    readOnly: true, // Make the TextField read-only
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8), // Reduced padding
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Favorite Games:",
                    style: TextStyle(fontSize: 14), // Reduced font size
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: TextEditingController(text: 'Game 1'), // user favorite games from the database
                    maxLines: 1,
                    decoration: InputDecoration(
                      fillColor: Colors.grey[200],
                      filled: true,
                      border: const OutlineInputBorder(),
                      hintText: 'Enter your favorite games here',
                    ),
                    readOnly: true, // Make the TextField read-only
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: TextEditingController(text: 'Game 2'), // user favorite games from the database
                    maxLines: 1,
                    decoration: InputDecoration(
                      fillColor: Colors.grey[200],
                      filled: true,
                      border: const OutlineInputBorder(),
                      hintText: 'Enter your favorite games here',
                    ),
                    readOnly: true, // Make the TextField read-only
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: TextEditingController(text: 'Game 3'), // user favorite games from the database
                    maxLines: 1,
                    decoration: InputDecoration(
                      fillColor: Colors.grey[200],
                      filled: true,
                      border: const OutlineInputBorder(),
                      hintText: 'Enter your favorite games here',
                    ),
                    readOnly: true, // Make the TextField read-only
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}