import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:game_match/pages/Preference_Interest.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'pages/Home.dart'; // Import the home page
import 'pages/Profile.dart'; // Import the profile page
import 'pages/Side_bar.dart'; // Import the side bar page
import 'pages/Interest.dart'; // Import the interest page
import 'pages/Settings.dart'; // Import the settings page

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const GameMatchApp());
}

class GameMatchApp extends StatelessWidget {
  const GameMatchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GameMatch', // The title of your app
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const SideBar(), // This is the side bar page
      routes: {
        '/side_bar': (context) => const SideBar(), // This is the side bar page
        '/Profile': (context) => const Profile(), // This is the profile page
        '/Preference_&_Interest': (context) => Preference_Interest_Page(), // This is the branch page for preference and interest page
        '/Interest': (context) => const InterestsPage(), // This is the interest page
        '/Settings': (context) => SettingsPage(),
      },
      //home: const HomePage(), // This is the main screen of your app
    );
  }
}
