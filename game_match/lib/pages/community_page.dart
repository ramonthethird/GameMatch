import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore package for database access
import 'package:game_match/firestore_service.dart'; // Custom Firestore service for database interaction
import 'game_model.dart'; // Model class for Game objects
import 'Api_Service.dart'; // Custom API service file to fetch game data
import 'game_description.dart'; // Page to show detailed game description
import 'Side_bar.dart'; // Sidebar widget for navigation

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Top Games App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const GameListScreen(),
    );
  }
}

class GameListScreen extends StatefulWidget {
  const GameListScreen({super.key});

  @override
  _GameListScreenState createState() => _GameListScreenState();
}

class _GameListScreenState extends State<GameListScreen> {
  final ApiService apiService = ApiService(); // Instance to fetch games from API
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>(); // Key for managing scaffold
  final FirestoreService _firestoreService = FirestoreService(); // Instance for Firestore interactions

  Map<String, List<Map<String, dynamic>>> gameThreads = {}; // Stores recent threads data
  List<Game> games = []; // List of games to be displayed
  bool isLoading = true; // Loading state for games

  @override
  void initState() {
    super.initState();
    fetchTrendingGames(); // Fetch trending games on initialization
    fetchRecentThreads(); // Fetch recent threads on initialization
  }

  // Fetches trending games using ApiService
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

  // Fetches recent threads from Firestore
  Future<void> fetchRecentThreads() async {
    try {
      // Fetch the 4 most recent threads from the 'threads' collection
      QuerySnapshot<Map<String, dynamic>> snapshot = await _firestoreService.getRecentThreads(limit: 4);

      // Process and enrich each thread
      List<Map<String, dynamic>> fetchedThreads = await Future.wait(
        snapshot.docs.map((doc) async {
          Map<String, dynamic> thread = doc.data();
          String threadId = doc.id;
          String userId = thread['userId'] ?? 'unknownUser';

          // Fetch user info from Firestore
          Map<String, dynamic>? userInfo = await _firestoreService.getUserInfo(userId);
          thread['userName'] = userInfo?['username'] ?? 'Anonymous';
          thread['avatarUrl'] = userInfo?['profileImageUrl'];
          thread['id'] = threadId;

          DateTime threadTimestamp = (thread['timestamp'] as Timestamp).toDate();
          thread['timestamp'] = threadTimestamp;

          // Fetch like, comment counts and ensure content exists
          thread['likes'] = thread['likes'] ?? 0;
          thread['comments'] = thread['comments'] ?? [];
          thread['content'] = thread['content'] ?? 'No body content available';

          return thread;
        }).toList(),
      );

      // Update state with fetched threads
      setState(() {
        gameThreads['recent'] = fetchedThreads;
      });
    } catch (e) {
      print('Error fetching recent threads: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey, // Key for the scaffold
      appBar: AppBar(
        title: const Text('Community', style: TextStyle(fontSize: 18)),
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.black), // Sidebar Icon
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer(); // Open the drawer on icon press
          },
        ),
      ),
      drawer: Drawer(
        child: SideBar(
          onThemeChanged: (isDarkMode) {
            // Handle theme change (if applicable)
          },
          isDarkMode: false, // Replace with actual theme state if needed
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search bar widget
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

            // Trending Games section title
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.0),
              child: Text(
                'Trending Games',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 5), // Spacing between title and list

            // Horizontal list view for games
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
                                width: 150, // Width of the game container
                                height: 200, // Height of the game container
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10.0),
                                  color: Colors.grey[300],
                                ),
                                child: Column(
                                  children: [
                                    // Game cover image
                                    Expanded(
                                      flex: 3,
                                      child: game.coverUrl != null
                                          ? Image.network(
                                              game.coverUrl!,
                                              width: 150,
                                              height: 150,
                                              fit: BoxFit.cover,
                                            )
                                          : Container(
                                              width: 150,
                                              height: 150,
                                              color: Colors.grey[400],
                                              child: const Icon(Icons.videogame_asset, size: 50),
                                            ),
                                    ),
                                    // Game name at the bottom
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

            // Recent Threads section title
            const Padding(
              padding: EdgeInsets.all(10.0),
              child: Text(
                'Recent Threads',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),

            // Recent threads list
            if (gameThreads['recent'] != null)
              ...gameThreads['recent']!.map((thread) {
                return buildThreadContainer(
                  thread['avatarUrl'] ?? '', // Profile image
                  thread['userName'] ?? 'Anonymous', // Username
                  thread['timestamp'] as DateTime, // Date posted
                  thread['content'] ?? 'No body content available', // Body
                  thread['id'], // Thread ID
                  thread['likes'] ?? 0,// Likes count
                  0, //thread['comments'].length, // Comments count
                );
              })
            else
              const Center(child: CircularProgressIndicator()), // Loading indicator
          ],
        ),
      ),
    );
  }

  // Helper function to format timestamp
  String formatTimestamp(DateTime timestamp) {
    // Format timestamp in a consistent way
    return "${timestamp.day.toString().padLeft(2, '0')}-"
           "${timestamp.month.toString().padLeft(2, '0')}-"
           "${timestamp.year} "
           "${timestamp.hour.toString().padLeft(2, '0')}:" 
           "${timestamp.minute.toString().padLeft(2, '0')}";
  }

  // Helper function to build thread container UI
  Widget buildThreadContainer(
    String avatarUrl,
    String userName,
    DateTime timestamp,
    String content,
    String threadId,
    int likes,
    int commentsCount,
  ) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
        padding: const EdgeInsets.all(15.0),
        decoration: BoxDecoration(
          color: Colors.white, // Set body color to white
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile picture, username, and date
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    //Navigator.pushNamed(context, '/View_profile', arguments: thread['userId']);
                  },
                  child: CircleAvatar(
                    radius: 20,
                    backgroundImage: avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
                    child: avatarUrl.isEmpty ? const Icon(Icons.person, size: 25) : null,
                  ),
                ),
                const SizedBox(width: 10),
                Text(userName, style: const TextStyle(fontWeight: FontWeight.bold)),
                const Spacer(),
                Text(formatTimestamp(timestamp),
                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 10),
            // Thread body
            Text(content),
            const SizedBox(height: 10),
            // Like button and comments section
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.favorite, color: Colors.grey),
                  onPressed: () {
                    print('Liked thread $threadId');
                    // Handle like functionality (e.g., update Firestore)
                  },
                ),
                Text('$likes Likes'),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.comment, color: Colors.grey),
                  onPressed: () {
                    // Handle view comments functionality
                  },
                ),
                //Text('$commentsCount Comments'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
