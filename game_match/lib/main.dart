import 'package:flutter/material.dart';
import 'firebase_options.dart'; // Auto-generated during Firebase setup
import 'pages/Home.dart'; // Import the home page

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(GameMatchApp());
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
      home: HomePage(), // This is the main screen of your app
    );
  }
}
