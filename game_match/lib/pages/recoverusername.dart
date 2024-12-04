import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UsernameRecoveryPage extends StatefulWidget {
  const UsernameRecoveryPage({super.key});

  @override
  State<UsernameRecoveryPage> createState() => _UsernameRecoveryPageState();
}

// State management 
// Add text controllers here to use for auth
class _UsernameRecoveryPageState extends State<UsernameRecoveryPage> {
  // Controllers to manage text input for email and password
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance; // Instance of FirebaseAuth for authentication

  // Method to update user's email address
  Future<void> _updateEmail() async {
    String newEmail = _emailController.text.trim(); // Get the new email from the controller
    String currentPassword = _passwordController.text.trim(); // Get the current password from the controller

    // Check the fields and display snackbar error
    if (newEmail.isEmpty || currentPassword.isEmpty) {
      _showErrorSnackBar("Please enter both your current password and new email.");
      return; // Exit if validation fails
    }

    try {
      User? user = _auth.currentUser; // Get the currently signed-in user using firebase class

      if (user != null) {
        // Re-authenticate the user (needed password for this email change)
        AuthCredential credential = EmailAuthProvider.credential(
          email: user.email!,
          password: currentPassword,
        );
        
        // Firebase method for reauthentication
        await user.reauthenticateWithCredential(credential); // Re-authenticate the user with their current credentials

        // Update the user's email
        await user.updateEmail(newEmail);
        await user.sendEmailVerification(); // Send a verification email after updating

        // Show success message using Snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Your email has been updated successfully. A verification email has been sent to $newEmail.")),
        );

      } else {
        _showErrorSnackBar("No user is currently signed in."); // Handle case where no user is signed in
      }
    } on FirebaseAuthException catch (e) { // Handle authentication errors
      if (e.code == 'invalid-email') {
        _showErrorSnackBar("The email address is badly formatted.");
      } else if (e.code == 'email-already-in-use') {
        _showErrorSnackBar("The email address is already in use by another account.");
      } else if (e.code == 'wrong-password') {
        _showErrorSnackBar("The password entered is incorrect.");
      } else {
        _showErrorSnackBar("An error occurred: ${e.message}"); // Show a generic error message
      }
    }
  }
  
  // Define snackbar method here to make it ez for errors in the if else statements
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

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
      resizeToAvoidBottomInset: true, // prevents keyboard conflicting with other elements on screen
      body: SingleChildScrollView( 
        child: Padding(
          padding: const EdgeInsets.all(16.0), // Padding around the main content
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              // Logo image at the top of the email change page
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

              const SizedBox(height: 16),
              
              
              Container(
                alignment: Alignment.center,
                child: const Text(
                  'Change your Email', // Header text
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              
              
              const SizedBox(height: 5),
              
              
              const Text(
                'Please enter your current password and the new email you would like to use for your account.', // Instruction text
                style: TextStyle(
                  fontSize: 14, // Smaller font size for the subtitle
                  //color: Colors.black87, // Lighter color for the subtitle
                ),
                textAlign: TextAlign.center,
              ),
              
              
              const SizedBox(height: 32),

              // Input field for the current password
              SizedBox(
                height: 40,
                width: 325,
                child: TextField(
                  controller: _passwordController, // Controller for password input
                  obscureText: true, // Hide password input
                  decoration: const InputDecoration(
                    labelText: 'Enter your current password', // Label for password input
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Input field for the new email address
              SizedBox(
                height: 40,
                width: 325,
                child: TextField(
                  controller: _emailController, // Controller for new email input
                  decoration: const InputDecoration(
                    labelText: 'Enter your new Email', // Label for new email input
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Button to update the email
              Container(
                width: 180,
                height: 40,
                child: ElevatedButton(
                  onPressed: _updateEmail, // Call the method to update email on press
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF41B1F1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(
                        Icons.email, // Always use email icon for recovery pages or reset pages
                        color: Colors.white,
                        size: 16,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Update Email', // Button text
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ],
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