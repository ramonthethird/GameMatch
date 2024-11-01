import 'package:flutter/material.dart';
import 'ApiService.dart';
import 'game_model.dart';
import 'game_description.dart';
// import 'FirestoreService.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Community Page/Trending Games',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: GameListScreen(),
    );
  }
}

class GameListScreen extends StatefulWidget {
  const GameListScreen({super.key});

  @override
  _GameListScreenState createState() => _GameListScreenState();
}

class _GameListScreenState extends State<GameListScreen> {
  final ApiService apiService = ApiService();

  // final FirestoreService firestoreService = FirestoreService();
  Map<String, List<Map<String, dynamic>>> gameThreads = {};
  List<Game> games = [];
  bool isLoading = true;
  Map<String, dynamic>? gameDetails;

  @override
  void initState() {
    super.initState();
    fetchTrendingGames();
  }

  Future<void> fetchTrendingGames() async {
    try {
      final fetchedGames = await apiService.fetchPopularGames();
      setState(() {
        games = fetchedGames;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching games: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Community'),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            // Handle menu press
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('')),
            );
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: TextField(
                decoration: const InputDecoration(
                  labelText: 'Search...',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.search),
                ),
                onSubmitted: (value) {
                  print('Searching for: $value');
                },
              ),
            ),

            // Trending games title
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.0),
              child: Text(
                'Trending Games',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 5),


            isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: games.map((game) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GameDescriptionPage(game: game),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10.0),
                        child: Container(
                          width: 150,
                          height: 200,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            color: Colors.grey[300],
                          ),
                          child: Column(
                            children: [

                              Expanded(
                                flex: 3,
                                child: game.coverUrl != null
                                    ? Image.network(
                                  game.coverUrl!,
                                  width: 150,
                                  height: 150, // Fill the top part
                                  fit: BoxFit.cover, // Make sure the image fits the container
                                )
                                    : Container(
                                  width: 150,
                                  height: 150,
                                  color: Colors.grey[400],
                                  child: const Icon(Icons.videogame_asset, size: 50),
                                ),
                              ),
                              // Game Name in the bottom part
                              Expanded(
                                flex: 1,
                                child: Container(
                                  width: double.infinity,
                                  color: Colors.black.withOpacity(0.7),
                                  alignment: Alignment.center,
                                  child: Text(
                                    game.name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            // Recent Threads Section
            const Padding(
              padding: EdgeInsets.all(10.0),
              child: Text(
                'Recent Threads',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),

            buildThreadContainer('Thread #1'),
            buildThreadContainer('Thread #2'),
            buildThreadContainer('Thread #3'),
            buildThreadContainer('Thread #4'),
            buildThreadContainer('Thread #5'),

          ],
        ),
      ),
    );
  }

  Widget buildThreadContainer(String threadName) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black),
        ),
        child: Text(
          threadName,
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }


}
