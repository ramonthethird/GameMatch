import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:game_match/pages/Sign_up.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const MyLoginPage(title: 'Login'),
      routes: {
        '/Post_home': (context) => const MyLoginPage(
            title: 'WelcomePage'), // Define the route for Post_home
        '/Sign_up': (context) =>
            const SignUpScreen(), // Ensure SignUpPage is imported and declared
      },
    );
  }
}

class MyLoginPage extends StatefulWidget {
  const MyLoginPage({super.key, required this.title});
  final String title;

  @override
  State<MyLoginPage> createState() => _MyLoginPageState();
}

// State management for MyLoginPage
class _MyLoginPageState extends State<MyLoginPage> {
  // Controllers to manage text input for username and password
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance; // Instance of FirebaseAuth for authentication

  // Method to handle user sign-in
  Future<void> _signIn() async {
    String username = _usernameController.text.trim(); // Get username from controller
    String password = _passwordController.text.trim(); // Get password from controller

  // Function to handle user login
  Future<void> _login() async {
    try {
      // Sign in with email and password
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: username, // Treat username as an email
        password: password,
      );
      // Navigate to notifications page on successful sign-in
      Navigator.pushNamed(context, "/Notif");
    } on FirebaseAuthException catch (e) {
      // Handle authentication errors and show messages
      String message = 'An error occurred. Please try again.';
      if (e.code == 'user-not-found') {
        message = 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        message = 'Wrong password provided for that user.';
      }
      // Display error message in a snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),

      );
      // On successful login, navigate to the post-home page
      Navigator.pushNamed(context, "/Post_home");
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F3F4),
      appBar: AppBar(
        backgroundColor: Color(0xFF41B1F1), // AppBar background color
        title: Text(widget.title, // Display title
          style: const TextStyle(
            fontSize: 24,
          ),
        ),
      ),

      resizeToAvoidBottomInset: true, // Prevent content from being hidden by the keyboard

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0), // Padding for the main content

          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              // Logo image at the top of the login page
              Padding(
                padding: const EdgeInsets.only(top: 40.0),
                child: Image.asset(
                  'assets/images/gamematchlogoresize.png',
                  height: 260,
                  width: 260,
                ),
              ),

              const SizedBox(height: 16),

              const Text(
                'Login', // Login header
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 32),

              // TextField for email input
              SizedBox(
                height: 40,
                width: 325,
                child: TextField(
                  controller: _usernameController, // Email Controller even tho it says username
                  decoration: const InputDecoration(
                    labelText: 'Enter your Email', // Label for email input
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  ),
                  keyboardType: TextInputType.emailAddress, // Specify input type for email
                ),
              ),

              const SizedBox(height: 2),

              // Link for email change page 
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const UsernameRecoveryPage()),
                  );
                },
                child: const Padding(
                  padding: EdgeInsets.only(left: 33),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Want to change your Email?', // Text for email recovery
                      style: TextStyle(
                        fontSize: 17,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // TextField for password input
              SizedBox(
                height: 40,
                width: 325,
                child: TextField(
                  controller: _passwordController, // Password input controller
                  decoration: const InputDecoration(
                    labelText: 'Enter your Password', // Label for password input
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  ),
                  obscureText: true, // Hide password text
                ),
              ),
              const SizedBox(height: 2),

              // Link for password recovery
              GestureDetector(
                onTap: () {
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
                      'Forgot your Password?', // Text for password recovery
                      style: TextStyle(
                        fontSize: 17,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Button for sign-in action
              ElevatedButton(
                onPressed: _signIn, // Call sign-in method on press
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF41B1F1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(2.5),
                    borderRadius: BorderRadius.circular(2.5),
                  ),
                  fixedSize: const Size(140, 30),
                  fixedSize: const Size(140, 30),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(
                      Icons.arrow_forward, // Arrow icon on the left
                      color: Colors.white,
                      size: 16,
                    ),
                    SizedBox(width: 8), // Space between icon and text
                    Text(
                      'Continue', // Button text
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Sign-up prompt text
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Don't have an account? ", // Prompt for new users
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, "/Sign_up"); // Navigate to sign-up page
                    },
                    child: const Text(
                      'Sign up', // Sign-up link text
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
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
