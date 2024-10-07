import 'package:flutter/material.dart';

class Profile extends StatelessWidget {
  const Profile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('Profile'),
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: Container(
          padding: const EdgeInsets.all(10),
          color: const Color(0xFF74ACD5),
          height: 220,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/profile.png'),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'John Doe', // User's name extracted from the database
                style: TextStyle(fontSize: 16),
              ),
              const Text(
                'Diamond Member', // User's membership level extracted from the database
                style: TextStyle(fontSize: 16),
              ),
              const Spacer(),
              Align(
                alignment: Alignment
                    .bottomRight, // Align the button to the bottom right
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.edit),
                  label: const Text("Edit Profile"),
                  onPressed: () {},
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
