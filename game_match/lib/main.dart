import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:game_match/pages/Billing_info.dart';
import 'package:game_match/pages/Community.dart';
import 'package:game_match/pages/Edit_profile.dart';
import 'package:game_match/pages/Game_news.dart';
import 'package:game_match/pages/Home.dart';
import 'package:game_match/pages/Settings_Privacy.dart';
import 'package:game_match/pages/Settings_Terms.dart';
import 'package:game_match/pages/Submitted_Reviews.dart';
import 'package:game_match/pages/SubscriptionPremium.dart';
//import 'package:game_match/pages/Add_Threads.dart';
import 'package:game_match/pages/Swipe.dart';
import 'package:game_match/pages/View_Profile.dart';
import 'package:game_match/pages/Wish_list.dart';
import 'package:game_match/pages/genre_model.dart';
import 'package:game_match/pages/preference_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'theme_notifier.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

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
import 'pages/Threads.dart';
import 'pages/Subscription.dart';
import 'pages/Home.dart';
import 'pages/Post_home.dart';
import 'pages/New_Releases.dart';
import 'pages/notif.dart';
import 'pages/notiftest.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Ensure dotenv is loaded before app runs
  await dotenv.load(fileName: ".env");
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

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
      child: OverlaySupport.global( // Wrap the app with OverlaySupport for banner notifications
        child: const GameMatchApp(),
      ),
    ),
  );
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Handling a background message: ${message.messageId}');
}

class GameMatchApp extends StatelessWidget {
  const GameMatchApp({super.key});

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
            scaffoldBackgroundColor: Color(0xFFF1F3F4),
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
            cardColor: Colors.grey[850], // Set a consistent dark color for cards
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF41B1F1),
              foregroundColor: Colors.white,
            ),
          ),
          home: HomePage(title: 'Home'),
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
            '/Settings': (context) => SettingsPage(),
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
            '/swiping_games': (context) => const SwipePage(),
            '/Reviews': (context) => SubmittedReviewsPage(),
            '/Subscription': (context) => SubscriptionManagementScreen(),
            '/SubscriptionPremium' : (context) => PremiumSubscriptionPage(),
            '/Billing_info': (context) => BillingInfoPage(),
            '/New_Releases': (context) =>
                const NewReleasesGames(), // Route to TopRatedGames widget
            //'/game_info': (context) => const GameListScreen(),
            '/preference_page': (context) =>  GenrePreferencePage(), // Route to PreferencePage widget
            '/Terms': (context) => SettingsTermsPage(),
            '/Privacy': (context) => SettingsPrivacyPage(),
            '/Wishlist': (context) => WishlistPage(),
            '/community_trends': (context) => GameListScreen(),
            '/notif': (context) => NotificationsPage(),
            '/Game_news': (context) => GamingNewsPage(),
            '/View_profile': (context) => const ViewProfile(),
          },
        );
      },
    );
  }
}
