import 'package:flutter/material.dart';
class EditProfile extends StatelessWidget {
  const EditProfile({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                      Align(
                        alignment:
                            Alignment.topLeft, // Correct alignment parameter
                        child: IconButton(
                          // IconButton widget for the back button
                          icon: const Icon(
                              Icons.cancel), // Icon widget for the back button
                          onPressed: () {
                            // Function to execute when the back button is pressed
                            Navigator.pop(
                                context); // Pop the current page off the navigation stack
                          },
                        ),
                      ),
                      GestureDetector(
                        onTap: () async {
                          // Allow to change the picture from local computer file
                          //final pickedFile = await ImagePicker().getImage(source: ImageSource.gallery);
                          //if (pickedFile != null) {
                          // Update the profile picture
                          // setState(() {
                          //image = File(pickedFile.path);
                          //});
                          //}
                        },
                        onLongPress: () {
                          // Show robot choice to select
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Select Robot Avatar'),
                                content: SingleChildScrollView(
                                  child: ListBody(
                                    children: <Widget>[
                                      GestureDetector(
                                        child: const Text('Robot 1'),
                                        onTap: () {
                                          // Handle Robot 1 selection
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                      const SizedBox(height: 10),
                                      GestureDetector(
                                        child: const Text('Robot 2'),
                                        onTap: () {
                                          // Handle Robot 2 selection
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                        child: Container(
                          width: 80, // Reduced width
                          height: 80, // Reduced height
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage('assets/images/profile.png'),
                            ),
                          ),
                        ),
                      ),
                    ]),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8), // Reduced padding
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "User name:",
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: TextEditingController(
                        text: 'John Doe'), // user name from the database
                    maxLines: 1,
                    decoration: InputDecoration(
                      fillColor: Colors.grey[200],
                      filled: true,
                      border: const OutlineInputBorder(),
                      hintText: 'Enter your username here',
                    ),
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
                    "Bio:",
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: TextEditingController(
                        text: 'I am .......'), // user bio from the database
                    maxLines: 4,
                    decoration: InputDecoration(
                      fillColor: Colors.grey[200],
                      filled: true,
                      border: const OutlineInputBorder(),
                      hintText: 'Enter your bio here',
                    ),
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
                    controller: TextEditingController(
                        text:
                            'Game 1'), // user favorite games from the database
                    maxLines: 1,
                    decoration: InputDecoration(
                      fillColor: Colors.grey[200],
                      filled: true,
                      border: const OutlineInputBorder(),
                      hintText: 'Enter your favorite games here',
                    ),
                    style: const TextStyle(fontSize: 12),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: TextEditingController(
                        text:
                            'Game 2'), // user favorite games from the database
                    maxLines: 1,
                    decoration: InputDecoration(
                      fillColor: Colors.grey[200],
                      filled: true,
                      border: const OutlineInputBorder(),
                      hintText: 'Enter your favorite games here',
                    ),
                    style: const TextStyle(fontSize: 12),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: TextEditingController(
                        text:
                            'Game 3'), // user favorite games from the database
                    maxLines: 1,
                    decoration: InputDecoration(
                      fillColor: Colors.grey[200],
                      filled: true,
                      border: const OutlineInputBorder(),
                      hintText: 'Enter your favorite games here',
                    ),
                    style: const TextStyle(fontSize: 12), // Reduced font size
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // Respond to button press
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Profile updated successfully'),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF74ACD5),
              ),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
class ImagePicker {
  Future<ImagePicker> getImage({required ImageSource gallery}) {
    throw UnimplementedError();
  }
}
class ImageSource {
  static ImageSource gallery = ImageSource();
}