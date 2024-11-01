//Subscription.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'billing_info.dart';
import 'Sign_up.dart';
import 'Side_bar.dart';
import 'package:game_match/theme_notifier.dart';
import 'package:provider/provider.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(); // Initialize Firebase
//   runApp(const GameMatchApp());
// }

// class GameMatchApp extends StatelessWidget {
//   const GameMatchApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       initialRoute: '/',
//       routes: {
//         '/': (context) => const SignUpScreen(),
//         '/Subscription': (context) => SubscriptionManagementScreen(),
//         '/billing_info': (context) => const PremiumSubscriptionPage(),
//       },
//     );
//   }
// }

// // SignUpScreen StatefulWidget that handles user registration
// class SignUpScreen extends StatefulWidget {
//   const SignUpScreen({super.key});

//   @override
//   _SignUpScreenState createState() => _SignUpScreenState();
// }

// // State class for SignUpScreen that contains the form and logic
// class _SignUpScreenState extends State<SignUpScreen> {
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
//   final TextEditingController emailController = TextEditingController();
//   final TextEditingController usernameController = TextEditingController();
//   final TextEditingController passwordController = TextEditingController();
//   final TextEditingController confirmPasswordController = TextEditingController();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Create an Account', style: TextStyle(color: Colors.black)),
//         backgroundColor: Colors.white,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.black),
//           onPressed: () {
//             Navigator.pop(context);
//           },
//         ),
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(20),
//           child: Form(
//             key: _formKey,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: <Widget>[
//                 Image.asset(
//                   'assets/images/gamematchlogoresize.png',
//                   height: 100,
//                 ),
//                 const SizedBox(height: 20),
//                 TextFormField(
//                   controller: emailController,
//                   decoration: const InputDecoration(
//                     labelText: 'Email',
//                     border: OutlineInputBorder(),
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//                 TextFormField(
//                   controller: usernameController,
//                   decoration: const InputDecoration(
//                     labelText: 'Username',
//                     border: OutlineInputBorder(),
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//                 TextFormField(
//                   controller: passwordController,
//                   obscureText: true,
//                   decoration: const InputDecoration(
//                     labelText: 'Password',
//                     border: OutlineInputBorder(),
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//                 TextFormField(
//                   controller: confirmPasswordController,
//                   obscureText: true,
//                   decoration: const InputDecoration(
//                     labelText: 'Confirm Password',
//                     border: OutlineInputBorder(),
//                   ),
//                   validator: (value) {
//                     if (value != passwordController.text) {
//                       return 'Passwords do not match';
//                     }
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 40),
//                 ElevatedButton(
//                   onPressed: _trySubmit,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.blue,
//                   ),
//                   child: const Text('Sign Up'),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   // Function to handle form submission
//   Future<void> _trySubmit() async {
//     if (_formKey.currentState!.validate()) {
//       _formKey.currentState!.save();
//       try {
//         UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
//           email: emailController.text,
//           password: passwordController.text,
//         );

//         await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
//           'username': usernameController.text,
//           'email': emailController.text,
//           'creationDate': FieldValue.serverTimestamp(),
//         });

//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Successfully signed up! Welcome, ${usernameController.text}!'),
//             backgroundColor: Colors.green,
//           ),
//         );

//         // Navigate to SubscriptionManagementScreen
//         Navigator.pushNamed(context, '/Subscription');
//       } on FirebaseAuthException catch (e) {
//         var errorMessage = 'An error occurred, please check your credentials!';
//         if (e.code == 'weak-password') {
//           errorMessage = 'The password provided is too weak. Must have at least 8 characters';
//         } else if (e.code == 'email-already-in-use') {
//           errorMessage = 'The account already exists for that email.';
//         }

//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(errorMessage),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     }
//   }

//   @override
//   void dispose() {
//     emailController.dispose();
//     usernameController.dispose();
//     passwordController.dispose();
//     confirmPasswordController.dispose();
//     super.dispose();
//   }
// }

// SubscriptionManagementScreen implementation
class SubscriptionManagementScreen extends StatelessWidget {
  SubscriptionManagementScreen({super.key});
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    return Scaffold(
      key: _scaffoldKey, // Key for the scaffold
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Subscription Management',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
          ),
        ),
        //backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.black), // Sidebar Icon
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
      ),
      drawer: Drawer(
        child: SideBar(
          onThemeChanged: (isDarkMode) {
            // Handle theme change here
            themeNotifier.toggleTheme(isDarkMode);
          },
          isDarkMode: themeNotifier.isDarkMode,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Current Plan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Free Member'),
              trailing: Radio(value: 'free', groupValue: 'free', onChanged: (value) {}),
            ),
            ListTile(
              leading: const Icon(Icons.star_border),
              title: const Text('Premium Member'),
              trailing: Radio(value: 'premium', groupValue: 'free', onChanged: (value) {}),
            ),
            const SizedBox(height: 20),
            const Text('Subscription Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ListTile(
              leading: const Icon(Icons.description),
              title: const Text('Plan Name'),
              subtitle: const Text('Free'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.credit_card),
              title: const Text('Billing Status'),
              subtitle: const Text('Active'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {},
            ),
            const SizedBox(height: 20),
            const Text('Why Upgrade?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const ListTile(
              leading: Icon(Icons.check_circle_outline),
              title: Text('Access exclusive content and discounts'),
            ),
            const ListTile(
              leading: Icon(Icons.check_circle_outline),
              title: Text('Ad-free experience'),
            ),
            const ListTile(
              leading: Icon(Icons.check_circle_outline),
              title: Text('Priority customer support'),
            ),
            const Spacer(),
            Card(
              elevation: 2,
              child: ListTile(
                title: const Text('Monthly Plan'),
                subtitle: const Text('\$5'),
                trailing: ElevatedButton(
                  onPressed: () {
Navigator.pushNamed(context, '/Billing_info');

                  },
                  child: const Text('Upgrade'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
