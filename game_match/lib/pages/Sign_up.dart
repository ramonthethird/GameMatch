import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create an Account', style: TextStyle(color: Colors.black, fontSize: 24,)),
        centerTitle: true,
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
                            Colors.white,
                            BlendMode.srcATop,
                          )
                        : const ColorFilter.mode(
                            Colors.transparent,
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
                  obscureText: true,
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
                    if (value != passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 40),
ElevatedButton(
  onPressed: () {
    _trySubmit();
  },
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.blue,
  ),
  child: const Text(
    'Sign Up',
    style: TextStyle(color: Colors.white), // Set text color to white
  ),
),

              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _trySubmit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try {
        // Check if the username is already taken
        final querySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('username', isEqualTo: usernameController.text)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          // Username is already taken
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Username already exists. Please choose another one.'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        // Attempt to create a user with Firebase Auth
        UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );

        // Store additional user data in Firestore
        await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
          'username': usernameController.text,
          'email': emailController.text,
          'creationDate': FieldValue.serverTimestamp(),
        });

        // Show a success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully signed up! Welcome, ${usernameController.text}!'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pushNamed(context, '/Login'); // Navigate to the login page

      } on FirebaseAuthException catch (e) {
        var errorMessage = 'An error occurred, please check your credentials!';
        if (e.code == 'weak-password') {
          errorMessage = 'The password provided is too weak. Must have at least 8 characters';
        } else if (e.code == 'email-already-in-use') {
          errorMessage = 'The account already exists for that email.';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}
