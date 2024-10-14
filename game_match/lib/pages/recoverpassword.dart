import 'package:flutter/material.dart';

class PasswordRecoveryPage extends StatefulWidget {
  const PasswordRecoveryPage({super.key});

  @override
  State<PasswordRecoveryPage> createState() => _PasswordRecoveryPageState();
}

class _PasswordRecoveryPageState extends State<PasswordRecoveryPage> {
  // TextEditingController for email input field
  final TextEditingController _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Recover Password'),
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
                  'images/gamematchlogoresize.png', // Same image as the login page
                  height: 260,
                  width: 260,
                ),
              ),

              const SizedBox(height: 16),

              Container(
                alignment: Alignment.center, // Center the text within the container
                child: const Text(
                  'Recover your Password',
                  style: TextStyle(
                    fontSize: 40, // Same font size as the "Login" text
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 10),

              // Subtitle text
              const Text(
                'Please enter the email associated with your account. Your password will be emailed to you shortly.',
                style: TextStyle(
                  fontSize: 14, // Smaller font size for the subtitle
                  color: Colors.black87, // Lighter color for the subtitle
                ),
                textAlign: TextAlign.center, // Center align the subtitle
              ),

              const SizedBox(height: 32),

              // TextField for email input
              SizedBox(
                height: 40,
                width: 325, // Same width as the login page
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

              // "Get Password" button, same style as "Continue" button from the main page
              Container(
                width: 140,
                height: 30,
                decoration: BoxDecoration(
                  color: Colors.lightBlueAccent, // Same color as "continue" button
                  borderRadius: BorderRadius.all(Radius.circular(2.5)),
                ),
                child: const Center(
                  child: Text(
                    'Get Password',
                    style: TextStyle(
                      color: Colors.black, // Same black color for text
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

  
            ],
          ),
        ),
      ),
    );
  }
}
