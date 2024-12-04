import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore package for database access
import 'package:game_match/firestore_service.dart'; // Custom Firestore service for database interaction
import 'game_model.dart'; // Model class for Game objects
import 'api_Service.dart'; // Custom API service file to fetch game data
import 'game_description.dart'; // Page to show detailed game description
import 'Side_bar.dart'; // Sidebar widget for navigation
import 'Threads.dart';
import 'Thread_Comments.dart';
import 'package:game_match/theme_notifier.dart';
import 'package:provider/provider.dart';

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
  final ApiService apiService = ApiService();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final FirestoreService _firestoreService = FirestoreService();

  Map<String, List<Map<String, dynamic>>> gameThreads = {};
  List<Game> games = [];
  bool isLoading = true;
  String? mostLikedReviewTitle;
  String? mostLikedReviewScreenshot;

  @override
  void initState() {
    super.initState();
    fetchTrendingGames();
    fetchRecentThreads();
    fetchMostLikedReview();
  }

  Future<void> fetchTrendingGames() async {
    try {
      final fetchedGames = await apiService.fetchTopVisitedGames(); // fetchPopularGames(); no args
      setState(() {
        games = fetchedGames ?? [];
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching games: $e');
    }
  }

  Future<void> fetchRecentThreads() async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot = await _firestoreService.getRecentThreads(limit: 5);
      List<Map<String, dynamic>> fetchedThreads = await Future.wait(
        snapshot.docs.map((doc) async {
          Map<String, dynamic> thread = doc.data();
          String threadId = doc.id;
          String userId = thread['userId'] ?? 'unknownUser';
          Map<String, dynamic>? userInfo = await _firestoreService.getUserInfo(userId);
          thread['userName'] = userInfo?['username'] ?? 'Anonymous';
          thread['avatarUrl'] = userInfo?['profileImageUrl'];
          thread['id'] = threadId;
          DateTime threadTimestamp = (thread['timestamp'] as Timestamp).toDate();
          thread['timestamp'] = threadTimestamp;
          thread['likes'] = thread['likes'] ?? 0;
          thread['comments'] = thread['comments'] ?? [];
          thread['content'] = thread['content'] ?? 'No body content available';
          thread["userId"] = userId;
          return thread;
        }).toList(),
      );
      setState(() {
        gameThreads['recent'] = fetchedThreads;
      });
    } catch (e) {
      print('Error fetching recent threads: $e');
    }
  }
  
    Future<void> fetchMostLikedReview() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('reviews')
           // Primary sort by likes
          .orderBy('timestamp', descending: true) // Secondary sort by timestamp
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Extract the title of the most liked review
        Map<String, dynamic> reviewData =
        querySnapshot.docs.first.data() as Map<String, dynamic>;
        String title = reviewData['title'] ?? 'No Title';
        String gameId = reviewData['gameId'] ?? '';

        final Map<String, dynamic>? gameInfo = await apiService.fetchGameInfo(int.parse(gameId));
        final List<dynamic>? screenshots = gameInfo?['screenshots'];

        String? screenshotUrl;
        if (screenshots != null && screenshots.isNotEmpty) {
          screenshotUrl =
          'https://images.igdb.com/igdb/image/upload/t_720p/${screenshots.first['image_id']}.jpg';
        }

        setState(() {
          mostLikedReviewTitle = title;
          mostLikedReviewScreenshot = screenshotUrl;
        });
      } else {
        setState(() {
          mostLikedReviewTitle = 'No reviews found';
          mostLikedReviewScreenshot = null;
        });
      }
    } catch (e) {
      print('Error fetching most liked review: $e');
      setState(() {
        mostLikedReviewTitle = 'Error fetching review';
        mostLikedReviewScreenshot = null;
      });
    }
  }

  Future<void> _refreshPage() async {
    setState(() => isLoading = true);
    await Future.wait([fetchTrendingGames(), fetchRecentThreads()]);
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final isDarkMode = themeNotifier.isDarkMode;
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Community',
        style: TextStyle(
            color: Colors.black,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.black),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
      ),
      drawer: Drawer(
        child: SideBar(
          onThemeChanged: (isDarkMode) {
            // Handle theme change here
            themeNotifier.toggleTheme(isDarkMode);
          },
          isDarkMode: themeNotifier.isDarkMode,
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshPage,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: TextField(
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Theme.of(context).cardColor,
                    labelText: 'Search for a game...',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.search),
                  ),
                  onSubmitted: (query) async {
                    try {
                      final List<Game> searchResults = await apiService.searchGames(query);
                      final Game? matchingGame = searchResults.isNotEmpty
                          ? searchResults.firstWhere(
                              (game) => game.name.toLowerCase() == query.toLowerCase(),
                          orElse: () => searchResults.first)
                          : null;

                      if (matchingGame != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ThreadsPage(gameId: matchingGame.id),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Game "$query" not found.')),
                        );
                      }
                    } catch (error) {
                      print('Error searching for game: $error');
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Error searching for game.')),
                      );
                    }
                  },
                ),
              ),
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
                  children: games.take(10).map((game) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ThreadsPage(gameId: game.id.toString()),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10.0),
                          child: Container(
                            width: 150,
                            height: 220, // 350
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.0),
                              color: Colors.white, // Changed background color to white
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
                                // Game name and genres at the bottom
                                Expanded(
                                  flex: 1,
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(8.0),
                                    color: Theme.of(context).cardColor, // Ensure white background
                                    alignment: Alignment.center,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          game.name,
                                          style: TextStyle(
                                            color: isDarkMode ? Colors.white : Colors.black, // Game name in black
                                            fontWeight: FontWeight.bold,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          game.genres.take(1).join(', '), // Display genres
                                          style: const TextStyle(
                                            color: Colors.grey, // Genres in gray
                                            fontSize: 12,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
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
              const Padding(
                padding: EdgeInsets.all(10.0),
                child: Text(
                  'Recent Threads',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              if (gameThreads['recent'] != null)
                ...gameThreads['recent']!.map((thread) {
                  return buildThreadContainer(
                    thread['avatarUrl'] ?? '',
                    thread['userName'] ?? 'Anonymous',
                    thread['timestamp'] as DateTime,
                    thread['content'] ?? 'No body content available',
                    thread['id'],
                    thread['gameId'] ?? '',
                    thread['likes'] ?? 0,
                    thread['comments'] ?? 0, // Use the comments count directly as an integer
                    thread['imageUrl'] ?? '',
                    thread['userId'] ?? 'unknownUser', // Pass userId to buildThreadContainer
                  );
                }).toList()
              else
                const Center(child: CircularProgressIndicator()),
            ],
          ),
        ),
      ),
    );
  }

  String formatTimestamp(DateTime timestamp) {
    return "${timestamp.day.toString().padLeft(2, '0')}-"
        "${timestamp.month.toString().padLeft(2, '0')}-"
        "${timestamp.year} "
        "${timestamp.hour.toString().padLeft(2, '0')}:"
        "${timestamp.minute.toString().padLeft(2, '0')}";
  }
  Widget buildThreadContainer(
      String avatarUrl,
      String userName,
      DateTime timestamp,
      String content,
      String threadId,
      String gameId,
      int likes,
      int commentsCount,
      String? threadImageUrl, // New parameter for thread image
      String userId, // Add userId parameter
      ) {
      
    final ApiService apiService = ApiService();
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final isDarkMode = themeNotifier.isDarkMode;

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: FutureBuilder<Map<String, dynamic>?>(
        future: apiService.fetchGameInfo(int.parse(gameId)), // Use IGDB API to fetch game info
        builder: (context, snapshot) {
          String gameName = 'Loading...';
          if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
            gameName = snapshot.data?['name'] ?? 'Game Not Found';
          } else if (snapshot.hasError) {
            gameName = 'Error fetching game';
          }

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ThreadDetailPage(
                    threadId: threadId,
                    threadContent: content,
                    threadUserName: userName,
                    threadImageUrl: threadImageUrl,
                    threadUserAvatarUrl: avatarUrl,
                    timestamp: Timestamp.fromDate(timestamp),
                    likes: likes,
                    comments: commentsCount,
                    shares: 0,
                  ),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(15.0),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                // border: Border.all(color: Colors.white),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(gameName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      GestureDetector(
                          onTap: () {
                            // Pass the userId when navigating to the profile page
                            Navigator.pushNamed(context, '/View_profile', arguments: userId);
                          },
                      child: CircleAvatar(
                        radius: 20,
                        backgroundImage: avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
                        child: avatarUrl.isEmpty ? const Icon(Icons.person, size: 25) : null,
                      )
                      ),
                      const SizedBox(width: 10),
                      Text(userName, style: const TextStyle(fontWeight: FontWeight.bold)),
                      const Spacer(),
                      Text(
                        "${timestamp.year}-${timestamp.month}-${timestamp.day}",
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(content),
                  if (threadImageUrl != null && threadImageUrl.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          threadImageUrl,
                          height: 150,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const SizedBox();
                          },
                        ),
                      ),
                    ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Icon(Icons.favorite, color: Colors.red, size: 18),
                      const SizedBox(width: 5),
                      Text('$likes', style: TextStyle(color: isDarkMode ? Colors.white : Colors.black)),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  
}

class ThreadDetailScreen extends StatelessWidget {
  final String threadId;
  final String content;
  final String userName;
  final String avatarUrl;
  final DateTime timestamp;
  final int likes;
  final String gameId;

  const ThreadDetailScreen({
    super.key,
    required this.threadId,
    required this.content,
    required this.userName,
    required this.avatarUrl,
    required this.timestamp,
    required this.likes,
    required this.gameId,
  });

  @override
  Widget build(BuildContext context) {
    final FirestoreService firestoreService = FirestoreService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thread Details'),
      ),
      body: FutureBuilder<Game?>(
        future: firestoreService.getGameById(gameId),
        builder: (context, snapshot) {
          String gameName = 'Loading...';
          if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
            gameName = snapshot.data?.name ?? 'Game Not Found';
          }

          return Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ThreadsPage(gameId: gameId),
                      ),
                    );
                  },
                  child: Text(
                    gameName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.blue,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    GestureDetector(
                          onTap: () {
                            // Pass the userId when navigating to the profile page
                           Navigator.pushNamed(context, '/View_profile', arguments: threadId);
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
                    Text(
                      "${timestamp.day}-${timestamp.month}-${timestamp.year}",
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(content, style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 10),
              ],
            ),
          );
        },
      ),
    );
  }
}