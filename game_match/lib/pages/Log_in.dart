import 'package:flutter/material.dart';
import 'package:login_ui_1/recoverusername.dart';  // Import the recovery page for username
import 'package:login_ui_1/recoverpassword.dart';  // Import the recovery page for password

void main() {
  runApp(const MyApp());
}

// Root of the app
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Basic Login',  // Sets the app's title (seen when switching between apps)
      theme: ThemeData(
        primarySwatch: Colors.grey,  // Sets a grey color theme
      ),
      home: const MyLoginPage(title: 'My Main Login Page'),  // Opens the login page first
    );
  }
}

// Login page
class MyLoginPage extends StatefulWidget {
  const MyLoginPage({super.key, required this.title});

  final String title;

  @override
  State<MyLoginPage> createState() => _MyLoginPageState();
}

class _MyLoginPageState extends State<MyLoginPage> {
  // Controllers to keep track of the user's input in the text fields
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,  // Inherits the theme color
        title: Text(widget.title),  // Displays the title passed from above
      ),
      resizeToAvoidBottomInset: true,  // Prevents keyboard from overlapping the fields
      body: SingleChildScrollView(  // Allows the page to scroll when necessary
        child: Padding(
          padding: const EdgeInsets.all(16.0),  // Adds some space around the content
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,  // Aligns everything to the top
            children: <Widget>[
              // Insert logo right here
              
              Padding(
                padding: const EdgeInsets.only(top: 40.0),
                child: Image.asset(
                  'images/gamematchlogoresize.png',  // Make sure this image is in your assets
                  height: 260,
                  width: 260,
                ),
              ),

              // Big "Login" text for the heading
              const Text(
                'Login',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,  // Makes the text stand out
                ),
              ),

              const SizedBox(height: 32),  // Adds some space

              // Username input field
              SizedBox(
                height: 40,
                width: 325,
                child: TextField(
                  controller: _usernameController,  // Connects the controller to track username
                  decoration: const InputDecoration(
                    labelText: 'Enter your Username',
                    border: OutlineInputBorder(),  // Adds a visible border around the field
                    contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  ),
                ),
              ),

              const SizedBox(height: 2),  // Tiny space between the field and the "Forgot?" link

              // "Forgot your Username?" link
              GestureDetector(
                onTap: () {
                  // Navigate to the username recovery page
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const UsernameRecoveryPage()),
                  );
                },
                child: const Padding(
                  padding: EdgeInsets.only(left: 30),  // Moves the text a bit from the left edge
                  child: Align(
                    alignment: Alignment.centerLeft,  // Aligns the text to the left
                    child: Text(
                      'Forgot your Username?',
                      style: TextStyle(
                        fontSize: 17,
                        color: Colors.blue,  // Colors the text blue to make it look like a link
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),  // More space before the password field

              // Password input field
              SizedBox(
                height: 40,
                width: 325,
                child: TextField(
                  controller: _passwordController,  // Connects the controller to track password
                  obscureText: true,  // Hides the password when typed
                  decoration: const InputDecoration(
                    labelText: 'Enter your Password',
                    border: OutlineInputBorder(),  // Adds a border around the field
                    contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  ),
                ),
              ),

              const SizedBox(height: 2),  // Tiny space between the field and the "Forgot?" link

              // "Forgot your Password?" link
              GestureDetector(
                onTap: () {
                  // Navigate to the password recovery page
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const PasswordRecoveryPage()),
                  );
                },
                child: const Padding(
                  padding: EdgeInsets.only(left: 30),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Forgot your Password?',
                      style: TextStyle(
                        fontSize: 17,
                        color: Colors.blue,  // Colors the text blue to resemble a link
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),  // Adds space before the button

              // "Continue" button
              Container(
                width: 140,
                height: 30,
                decoration: BoxDecoration(
                  color: Colors.lightBlueAccent,  // Fills the button with a light blue color
                  borderRadius: BorderRadius.all(Radius.circular(2.5)),  // Slightly round corners
                ),
                child: const Center(
                  child: Text(
                    'continue',
                    style: TextStyle(
                      color: Colors.black,  // Black text inside the blue button
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),  // Some space before the "Sign up" link

              // "Don't have an account?" text with a "Sign up" link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,  // Aligns the content to the center
                children: [
                  const Text(
                    "Don't have an account? ",  // A subtle question for the user
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      // Placeholder for sign-up logic
                    },
                    child: const Text(
                      'Sign up',  // The clickable "Sign up" link
                      style: TextStyle(
                        color: Colors.blue,  // Blue text for emphasis
                        fontSize: 16,
                        fontWeight: FontWeight.bold,  // Bold to make it stand out and match 
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
