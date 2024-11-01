import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:game_match/pages/Swipe.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'theme_notifier.dart';

// Import all your pages
import 'pages/Preference_Interest.dart';
import 'pages/game_info.dart';
import 'pages/Profile.dart';
import 'pages/Side_bar.dart';
import 'pages/Interest.dart';
//import 'pages/Edit_profile.dart';
import 'pages/Sign_up.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'pages/Settings.dart';
import 'pages/Settings_Appearance.dart';
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
  Widget build(BuildContext context) {
    return Consumer<ThemeNotifier>(
      builder: (context, themeNotifier, child) {
        return MaterialApp(
          title: 'GameMatch',
          themeMode:
              themeNotifier.isDarkMode ? ThemeMode.dark : ThemeMode.light,
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
            '/Login': (context) => const MyLoginPage(title: 'Login'),
          },
        );
      },
    );
  }
}
