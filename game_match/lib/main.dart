import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:game_match/pages/game_info.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'pages/Profile.dart'; // Import the profile page
import 'pages/Side_bar.dart'; // Import the side bar page
import 'pages/Interest.dart'; // Import the interest page
import 'pages/Edit_profile.dart'; // Import the edit profile page
import 'pages/Preference_Interest.dart';
import 'pages/Sign_up.dart';
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
      home:
          const SideBar(), // This is the side bar page this is the main screen of your app for now
      //home: GameListScreen(), // This is to test that games are loading from API
      routes: {
        '/Sign_in': (context) => const SignUp(), // This is the sign in page
        '/side_bar': (context) => const SideBar(), // This is the side bar page
        '/Profile': (context) => const Profile(), // This is the profile page
        '/Interest': (context) =>
            const InterestsPage(), // This is the interest page
        '/Edit_profile': (context) =>
            const EditProfile(), // This is the edit profile page
        '/Preference_&_Interest': (context) =>
            const PreferenceInterestPage(), // This is the interest page
        '/Settings': (context) =>
            const SettingsPage(), // This is the settings page
      },
    );
  }
}
