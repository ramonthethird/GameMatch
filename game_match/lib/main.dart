import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'api_service.dart';
import 'game_model.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'pages/Home.dart'; // Import the home page
import 'pages/Profile.dart'; // Import the profile page
import 'pages/Side_bar.dart'; // Import the side bar page
import 'pages/Interest.dart'; // Import the interest page

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
        '/Interest':(context) => const InterestsPage(), // This is the interest page
      },
      //home: const HomePage(), // This is the main screen of your app
    );
  }
}

class GameListScreen extends StatefulWidget {
  @override
  _GameListScreenState createState() => _GameListScreenState();
}

class _GameListScreenState extends State<GameListScreen> {
  final ApiService apiService = ApiService();
  List<Game> games = [];

  @override
  void initState() {
    super.initState();
    _fetchGames();
  }

  Future<void> _fetchGames() async {
    List<Game> fetchedGames = await apiService.fetchGames();
    setState(() {
      games = fetchedGames; // Set the state with the fetched games
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Game Info'),
      ),
      body: games.isEmpty
          ? Center(
              child:
                  CircularProgressIndicator()) // Show loading spinner while data is fetched
          : ListView.builder(
              itemCount: games.length,
              itemBuilder: (context, index) {
                final game = games[index];
                return ListTile(
                  leading: game.coverUrl != null
                      ? Image.network(
                          game.coverUrl!) // Show cover image if available
                      : Icon(Icons.image_not_supported),
                  title: Text(game.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Description: ${game.summary}'),
                      Text('Genres: ${game.genres.join(', ')}'),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
