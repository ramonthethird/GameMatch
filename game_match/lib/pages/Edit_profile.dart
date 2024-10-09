import 'package:flutter/material.dart';

class EditProfile extends StatelessWidget {
  const EditProfile ({super.key});

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
                      alignment: Alignment.topLeft, // Correct alignment parameter
                      child: IconButton( // IconButton widget for the back button
                        icon: const Icon(Icons.cancel), // Icon widget for the back button
                        onPressed: () { // Function to execute when the back button is pressed
                          Navigator.pop(context); // Pop the current page off the navigation stack
                        },
                      ),
                    ),
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
                  ]
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}