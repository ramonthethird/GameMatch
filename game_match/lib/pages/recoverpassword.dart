import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PasswordRecoveryPage extends StatefulWidget {
  const PasswordRecoveryPage({super.key});

  @override
  State<PasswordRecoveryPage> createState() => _PasswordRecoveryPageState();
}

class _PasswordRecoveryPageState extends State<PasswordRecoveryPage> {
  final TextEditingController _emailController = TextEditingController();

  // Method to send password reset email
  Future<void> _sendPasswordResetEmail() async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: _emailController.text);

      // Show a success message to the user
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password reset email sent!')),
      );
      // Optionally, navigate back or clear the text field
      _emailController.clear();
    } catch (e) {

      // Show an error message if there's an issue
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text(
          'Recover Password',
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
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
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
                alignment: Alignment.center,
                child: const Text(
                  'Recover your Password',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),


              const SizedBox(height: 5),


              const Text(
                'Please enter the email associated with your account. Your password will be emailed to you shortly.',
                style: TextStyle(
                  fontSize: 14,
                  //color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),



              const SizedBox(height: 20),


              SizedBox(
                height: 40,
                width: 325,
                child: TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Enter your Email',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _sendPasswordResetEmail, // Call the method to send email
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF41B1F1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),

                  ),
                  fixedSize: const Size(150, 30),
                ),

                child: const Center(
                  child: Text(
                    'Get Password',
                    style: TextStyle(
                      color: Colors.white,
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
