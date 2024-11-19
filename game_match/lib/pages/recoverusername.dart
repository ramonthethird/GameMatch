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
        //backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text(
          'Recover Username',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context); // Navigate back to the previous screen
          },
        ),
      ),
      resizeToAvoidBottomInset: true, // Add same function for keyboard pop up error


      body: SingleChildScrollView( // Wrap with singlechildscrollview
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              // Same logo as the login page

              Padding(
                padding: const EdgeInsets.only(top: 0.0),
                child: ColorFiltered(
                  colorFilter: Theme.of(context).brightness == Brightness.dark
                      ? const ColorFilter.mode(
                          Colors.white, // Makes the logo white in dark mode
                          BlendMode.srcATop,
                        )
                      : const ColorFilter.mode(
                          Colors.transparent, // No change in light mode
                          BlendMode.srcOver,
                        ),
                  child: Image.asset(
                    'assets/images/gamematchlogoresize.png',
                    height: 260,
                    width: 260,
                  ),
                ),
              ),  

              //const SizedBox(height: 16),

              Container(
                alignment: Alignment.center, // Center the text within the container
                child: const Text(
                  'Recover your Username',
                  style: TextStyle(
                    fontSize: 22, // same font size as the "Login" text
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 5),

              // Subtitle text
              const Text(
                'Please enter the email associated with your account. Your password will be emailed to you shortly.',
                style: TextStyle(
                  fontSize: 14, // Smaller font size for the subtitle
                  //color: Colors.black87, // Lighter color for the subtitle
                ),
                textAlign: TextAlign.center, // Center align the subtitle
              ),


              const SizedBox(height: 20),

              // TextField for email input
              SizedBox(
                height: 40,
                width: 325, // same width as login page
                child: TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Enter your Email', // email input label
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // "Get Username" button, same style as "Continue" button from main page
              Container(
                width: 140,
                height: 40,
                decoration: BoxDecoration(
                  
                  color: const Color(0xFF41B1F1), // same color as "continue" button
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                child: const Center(
                  child: Text(
                    'Get Username',
                    style: TextStyle(
                      color: Colors.white, // same black color for text
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
