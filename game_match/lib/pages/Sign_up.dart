import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:game_match/pages/Post_home.dart'; 
import 'package:game_match/pages/Home.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(); // Initialize Firebase
//   runApp(const SignUp());
// }

// Main SignUp widget that sets up the MaterialApp
// class SignUp extends StatelessWidget {
//   const SignUp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return const MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: SignUpScreen(),
//     );
//   }
// }

// SignUpScreen StatefulWidget that handles user registration
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

// State class for SignUpScreen that contains the form and logic
class _SignUpScreenState extends State<SignUpScreen> {
  final GlobalKey<FormState> _formKey =GlobalKey<FormState>(); // Key to track form state
  final TextEditingController emailController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F3F4),
      appBar: AppBar(
        title: const Text('Create an Account', style: TextStyle(color: Colors.black, fontSize: 24,)),
        centerTitle: true,
        //backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              Navigator.pop(context);
          }, 
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Padding(
                padding: const EdgeInsets.only(top: 40.0),
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
                const SizedBox(height: 20),
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: passwordController,
                  obscureText: true, // Hide the text for password fields
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: confirmPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Confirm Password',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    // Validator to ensure passwords match
                    if (value != passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: (){
                    _trySubmit();
                    Navigator.pushNamed(context, '/Login');
                  }, // Button to trigger form submission
                  style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  ),
                  child: const Text('Sign Up'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Function to handle form submission
  Future<bool> _trySubmit() async {
    if (_formKey.currentState!.validate()) {
      // Check if the form is valid
      _formKey.currentState!.save(); // Save the form
      try {
        // Attempt to create a user with Firebase Auth
        UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );

        // Store additional user data in Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
          'username': usernameController.text,
          'email': emailController.text,
          'creationDate': FieldValue
              .serverTimestamp(), // Store the timestamp of account creation
        });

        // Show a success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Successfully signed up! Welcome, ${usernameController.text}!'),
            backgroundColor: Colors.green,
          ),
        );
        return true;
      } on FirebaseAuthException catch (e) {
        // Handle errors from Firebase
        var errorMessage = 'An error occurred, please check your credentials!';
        if (e.code == 'weak-password') {
          errorMessage =
              'The password provided is too weak. Must have at least 8 characters';
        } else if (e.code == 'email-already-in-use') {
          errorMessage = 'The account already exists for that email.';
        }

        // Show an error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
    return false;
  }

  // Function to fetch user data from Firestore
  Future<void> _fetchUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userData = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userData.exists) {
        setState(() {
          usernameController.text = userData['username'];
          emailController.text = userData['email'];
        });
      }
    }
  }

  @override
  void dispose() {
    // Clean up the controllers when the widget is disposed
    emailController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}
