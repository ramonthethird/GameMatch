
// still needs to edit for consolidation

import 'package:flutter/material.dart';
import 'package:game_match/pages/Side_bar.dart';
//import 'package:login_ui_1/recoverusername.dart';  // Import the recovery page

// void main() {
//   runApp(const MyApp());
// }

//class LoginPage extends StatelessWidget {
  //const LoginPage({super.key});

  //@override
  //Widget build(BuildContext context) {
  // return MaterialApp(
  //    title: 'Basic Login',
   //   theme: ThemeData(
  //     primarySwatch: Colors.grey,
   //   ),
   //   home: const MyLoginPage(title: 'My Main Login Page'),
    //);
 // }
//}

class MyLoginPage extends StatefulWidget {
  const MyLoginPage({super.key, required this.title});

  final String title;

  @override
  State<MyLoginPage> createState() => _MyLoginPageState();
}

class _MyLoginPageState extends State<MyLoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
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
                  height: 100,
                  width: 100,
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
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Enter your Username',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  ),
                ),
              ),
              
              const SizedBox(height: 2),

  
              GestureDetector(
                onTap: () {
                  // navigate to the RecoverUsernamePage
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(builder: (context) => const UsernameRecoveryPage()), // Ensure RecoverUsernamePage is imported and declared
                  // );
                },

                
                child: const Padding(
                  padding: EdgeInsets.only(left: 30),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Forgot your Username?',
                      style: TextStyle(
                        fontSize: 17,
                        color: Colors.blue, // blue color
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
                  decoration: const InputDecoration(
                    labelText: 'Enter your Password',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  ),
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

              // const SizedBox(height: 20),


                ElevatedButton(
                onPressed: () {
                      Navigator.pushNamed(context, "/Side_bar"); // Ensure SideBar is imported and declared
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlueAccent, // Button background color
                  shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(2.5), // Rounded corners
                  ),
                  fixedSize: const Size(140, 30), // Fixed width and height
                ),
                child: const Center(
                  child: Text(
                  'continue',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                  ),
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
                      color: Colors.black,
                      fontSize: 16,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, "/Sign_up"); // Ensure SignUpPage is imported and declared
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
