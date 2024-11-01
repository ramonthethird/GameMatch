import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
//import 'package:game_match/pages/game_info.dart'; // Import the GameListScreen widget
//import 'pages/preference_page.dart'; // Import the PreferencePage widget
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:game_match/pages/New_Releases.dart'; // Import the TopRatedGames widget
import 'package:game_match/pages/Post_home.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_options.dart';
import 'package:provider/provider.dart';
import 'theme_notifier.dart';

// Import all your pages
import 'pages/Preference_Interest.dart';
import 'pages/Profile.dart';
import 'pages/Side_bar.dart';
import 'pages/Interest.dart';
import 'pages/Edit_profile.dart';
import 'pages/Sign_up.dart';
import 'pages/Settings.dart';
import 'pages/Settings_Appearance.dart';
import 'pages/Side_bar.dart';
import 'pages/Sign_up.dart';
import 'pages/Log_in.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Ensure dotenv is loaded before app runs
  await dotenv.load(fileName: ".env");
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Load the theme preference before the app starts
  final prefs = await SharedPreferences.getInstance();
  bool isDarkMode = prefs.getBool('isDarkMode') ?? false;
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ThemeNotifier(isDarkMode),
        ),
      ],
      child: const GameMatchApp(),
    ),
  );
}

class GameMatchApp extends StatelessWidget {
  const GameMatchApp({super.key});

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
    await prefs.setBool(
        'isDarkMode', isDark); // Save theme mode to SharedPreferences
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeNotifier>(
      builder: (context, themeNotifier, child) {
        return MaterialApp(
          title: 'GameMatch',
          themeMode: themeNotifier.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          theme: ThemeData(
            brightness: Brightness.light,
            fontFamily: 'SignikaNegative',
            primarySwatch: Colors.blue,
            scaffoldBackgroundColor: Colors.white,
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF74ACD5),
              foregroundColor: Colors.black,
            ),
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            fontFamily: 'SignikaNegative',
            primarySwatch: Colors.blue,
            scaffoldBackgroundColor: Colors.black,
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF1E1E1E),
              foregroundColor: Colors.white,
            ),
          ),
          home: SwipePage(),
          routes: {
            '/Sign_up': (context) => const SignUp(),
            '/Side_bar': (context) => SideBar(
                  onThemeChanged: (bool isDarkMode) {
                    themeNotifier.toggleTheme(isDarkMode);
                  },
                  isDarkMode: themeNotifier.isDarkMode,
                ),
            '/Profile': (context) => const Profile(),
            '/Interest': (context) => const InterestsPage(),
            // '/Edit_profile': (context) => const EditProfile(),
            '/Preference_&_Interest': (context) => PreferenceInterestPage(
                  onThemeChanged: (bool isDarkMode) {
                    themeNotifier.toggleTheme(isDarkMode);
                  },
                  isDarkMode: themeNotifier.isDarkMode,
            ),
            '/Settings': (context) => SettingsPage(),
            '/Appearance': (context) => SettingsAppearancePage(
                  isDarkMode: themeNotifier.isDarkMode,
                  onThemeChanged: (bool isDarkMode) {
                    themeNotifier.toggleTheme(isDarkMode);
                  },
            ),
        '/Log_in': (context) => const MyLoginPage(title: 'Login'),
        '/Home': (context) => const HomePage(
              title: 'Home',
            ),
        '/Post_home': (context) =>
            const WelcomePage(username: 'defaultUsername'),
        '/New_Releases': (context) =>
            const NewReleasesGames(), // Route to TopRatedGames widget
        //'/game_info': (context) => const GameListScreen(),
        //'/preference_page': (context) =>  GenrePreferencePage(), // Route to PreferencePage widget
      },
    );
  }
}
