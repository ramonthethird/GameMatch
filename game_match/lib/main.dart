import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'pages/Preference_Interest.dart';
import 'pages/game_info.dart';
import 'pages/Profile.dart';
import 'pages/Side_bar.dart';
import 'pages/Interest.dart';
import 'pages/Edit_profile.dart';
import 'pages/Sign_up.dart';
import 'pages/Settings.dart';
import 'pages/Settings_Appearance.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(GameMatchApp());
}

class GameMatchApp extends StatefulWidget {
  @override
  _GameMatchAppState createState() => _GameMatchAppState();
}

class _GameMatchAppState extends State<GameMatchApp> {
  bool isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadThemePreference(); // Load theme when the app starts
  }

  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkMode = prefs.getBool('isDarkMode') ?? false;
    });
  }

  void _toggleTheme(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkMode = isDark; // Update theme mode in state
    });
    await prefs.setBool('isDarkMode', isDark); // Save theme mode to SharedPreferences
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GameMatch',
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData.light(), // Light theme
      darkTheme: ThemeData.dark(), // Dark theme
      home: SideBar(
        isDarkMode: isDarkMode, // Pass the current theme state
        onThemeChanged: _toggleTheme, // Pass the theme toggle function
      ),
      //home: GameListScreen(), // This is to test that games are loading from API
      routes: {
        '/Sign_in': (context) => const SignUp(),
        '/side_bar': (context) => SideBar(
              onThemeChanged: _toggleTheme,
              isDarkMode: isDarkMode,
            ),
        '/Profile': (context) => Profile(),
        '/Interest': (context) => InterestsPage(),
        '/Edit_profile': (context) => EditProfile(),
        '/Preference_&_Interest': (context) => PreferenceInterestPage(
              onThemeChanged: _toggleTheme,
              isDarkMode: isDarkMode,
        ),
        '/Settings': (context) => SettingsPage(
              isDarkMode: isDarkMode,
              onThemeChanged: _toggleTheme,
            ),
        '/Appearance': (context) => SettingsAppearancePage(
              isDarkMode: isDarkMode,
              onThemeChanged: _toggleTheme,
            ),
      },
    );
  }
}
