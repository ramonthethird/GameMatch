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

// Initialize here
class _MyLoginPageState extends State<MyLoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String _errorMessage = '';

  // Function to handle user login
  Future<void> _login() async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
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
        backgroundColor: const Color(0xFFF1F3F4),
        //backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 40.0),
                child: Image.asset(
                  'assets/images/gamematchlogoresize.png',
                  height: 260,
                  width: 260,
                ),
              ),
              const Text(
                'Login',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                height: 40,
                width: 325,
                child: TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Enter your Email',
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  ),
                  keyboardType:
                      TextInputType.emailAddress, // Use email keyboard
                ),
              ),
              const SizedBox(height: 2),
              TextButton(
                onPressed: () {
                  // Navigate to username recovery page
                },
                child: const Padding(
                  padding: EdgeInsets.only(left: 33),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Forgot your Email?',
                      style: TextStyle(
                        fontSize: 17,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                height: 40,
                width: 325,
                child: TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Enter your Password',
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  ),
                  obscureText: true, // Hide password input
                ),
              ),
              const SizedBox(height: 2),
              const Padding(
                padding: EdgeInsets.only(left: 30),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Forgot your Password?',
                    style: TextStyle(
                      fontSize: 17,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlueAccent,
                  backgroundColor: Colors.lightBlueAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(2.5),
                    borderRadius: BorderRadius.circular(2.5),
                  ),
                  fixedSize: const Size(140, 30),
                  fixedSize: const Size(140, 30),
                ),
                child: const Center(
                  child: Text(
                    'Continue',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                    ),
                    'Continue',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
              ),
              if (_errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Text(
                    _errorMessage,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 16,
                    ),
                  ),
                ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Don't have an account? ",
                    style: TextStyle(
                      //color: Colors.black,
                      fontSize: 16,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, "/Sign_up");
                    },
                    child: const Text(
                      'Sign up',
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
