import 'package:flutter/material.dart';

class UsernameRecoveryPage extends StatefulWidget {
  const UsernameRecoveryPage({super.key});

  @override
  State<UsernameRecoveryPage> createState() => _UsernameRecoveryPageState();
}

class _UsernameRecoveryPageState extends State<UsernameRecoveryPage> {
  // TextEditingController for email input field
  final TextEditingController _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Recover Username'),
      ),
      resizeToAvoidBottomInset: true,


      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              // Same logo as the login page

              Padding(
                padding: const EdgeInsets.only(top: 40.0),
                child: Image.asset(
                  'assets/images/gamematchlogoresize.png', // Same image as the login page
                  height: 260,
                  width: 260,
                ),
              ),

              const SizedBox(height: 16),

              Container(
                alignment: Alignment.center, // Center this bc its shifted
                child: const Text(
                  'Recover your Username',
                  style: TextStyle(
                    fontSize: 40, // same font size with login
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 10),

              // Put subtitle and description here
              const Text(
                'Please enter the email associated with your account. Your username will be emailed to you shortly.',
                style: TextStyle(
                  fontSize: 14, // Smaller
                  color: Colors.black87, // Slightly lighter color
                ),
                textAlign: TextAlign.center, // Shift it to center
              ),


              const SizedBox(height: 32),

              // Email input
              SizedBox(
                height: 40,
                width: 325, // Same width as login page?
                child: TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Enter your Email', // Email input label
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Continue button cohesiveness check
              Container(
                width: 140,
                height: 30,
                decoration: BoxDecoration(
                  color: Colors.lightBlueAccent, // same color as "continue" button
                  borderRadius: BorderRadius.all(Radius.circular(2.5)),
                ),
                child: const Center(
                  child: Text(
                    'Get Username',
                    style: TextStyle(
                      color: Colors.black, // same black color for text
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // put more backend logic here?
            ],
          ),
        ),
      ),
    );
  }
}
