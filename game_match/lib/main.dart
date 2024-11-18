import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:game_match/pages/Billing_info.dart';
import 'package:game_match/pages/community_page.dart';
import 'package:game_match/pages/Edit_profile.dart';
import 'package:game_match/pages/Home.dart';
import 'package:game_match/pages/Settings_Privacy.dart';
import 'package:game_match/pages/Settings_Terms.dart';
import 'package:game_match/pages/Submitted_Reviews.dart';
//import 'package:game_match/pages/Add_Threads.dart';
import 'package:game_match/pages/Swipe.dart';
import 'package:game_match/pages/preference_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'theme_notifier.dart';
import 'pages/View_profile.dart';

// Import all your pages
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'pages/Preference_Interest.dart';
import 'pages/game_info.dart';
import 'pages/game_news.dart';
import 'pages/Profile.dart';
import 'pages/Side_bar.dart';
import 'pages/Interest.dart';
//import 'pages/Edit_profile.dart';
import 'pages/Sign_up.dart';
import 'pages/Settings.dart';
import 'pages/Settings_Appearance.dart';
import 'pages/Log_in.dart';
import 'pages/Subscription.dart';
import 'pages/Post_home.dart';
import 'pages/New_Releases.dart';
import 'pages/Game_news.dart';
import 'pages/Wish_list.dart';
import 'pages/SubscriptionPremium.dart';
import 'pages/notif.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Ensure dotenv is loaded before app runs
  await dotenv.load(fileName: ".env");

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
   // Initialize Google Mobile Ads SDK before app starts
  await MobileAds.instance.initialize();
  
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
            scaffoldBackgroundColor: const Color(0xFFF1F3F4),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF41B1F1),
              foregroundColor: Colors.black,
            ),
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            fontFamily: 'SignikaNegative',
            primarySwatch: Colors.blue,
            scaffoldBackgroundColor: Colors.black,
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF41B1F1),
              foregroundColor: Colors.white,
            ),
          ),
          home: const HomePage(title: 'Home'),
          // home: SwipePage(),
          routes: {
            '/Sign_up': (context) => const SignUpScreen(),
            '/Side_bar': (context) => SideBar(
                  onThemeChanged: (bool isDarkMode) {
                    themeNotifier.toggleTheme(isDarkMode);
                  },
                  isDarkMode: themeNotifier.isDarkMode,
                ),
            '/Profile': (context) => const Profile(),
            '/Interest': (context) => const InterestsPage(),
            '/Edit_profile': (context) => const EditProfile(),
            '/Preference_&_Interest': (context) => PreferenceInterestPage(
                  onThemeChanged: (bool isDarkMode) {
                    themeNotifier.toggleTheme(isDarkMode);
                  },
                  isDarkMode: themeNotifier.isDarkMode,
                ),
            '/Settings': (context) => const SettingsPage(),
            '/Appearance': (context) => SettingsAppearancePage(
                  isDarkMode: themeNotifier.isDarkMode,
                  onThemeChanged: (bool isDarkMode) {
                    themeNotifier.toggleTheme(isDarkMode);
                  },
                ),
            '/Login': (context) => const MyLoginPage(title: 'Login'),
            '/Home': (context) => const HomePage(
                  title: 'Home',
                ),
            '/Post_home': (context) =>
                const WelcomePage(username: 'defaultUsername'),
            '/Swipe': (context) => const SwipePage(),
            '/Reviews': (context) => const SubmittedReviewsPage(),
            '/Subscription': (context) => SubscriptionManagementScreen(),
            '/Billing_info': (context) => const BillingInfoPage(),
            '/New_Releases': (context) =>
                const NewReleasesGames(), // Route to TopRatedGames widget
            //'/game_info': (context) => const GameListScreen(),
            '/preference_page': (context) =>
                const GenrePreferencePage(), // Route to PreferencePage widget
            '/Terms': (context) => const SettingsTermsPage(),
            '/Privacy': (context) => const SettingsPrivacyPage(),
            '/Wishlist': (context) =>  WishlistPage(),
            '/community_page': (context) => const GameListScreen(),
            '/Game_news': (context) =>  const GamingNewsPage(),
            '/View_profile': (context) => const ViewProfile(),
            '/SubscriptionPremium': (context) => const PremiumSubscriptionPage(),
            '/notif': (context) => const NotificationsPage(),
          },
        );
      },
    );
  }
}
