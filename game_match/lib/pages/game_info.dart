import 'package:flutter/material.dart';
import 'api_service.dart';
import 'game_model.dart';
import 'package:url_launcher/url_launcher.dart';

// The main screen displaying the list of games
class GameListScreen extends StatefulWidget {
  @override
  _GameListScreenState createState() => _GameListScreenState();
}

// The state class for the GameListScreen
class _GameListScreenState extends State<GameListScreen> {
  final ApiService apiService = ApiService();
  List<Game> games = [];

  // Called when the widget is first inserted into the widget tree
  @override
  void initState() {
    super.initState();
    _fetchGames();
  }

  // Function to fetch games from the API
  Future<void> _fetchGames() async {
    try {
      // Fetch games using the APIService
      List<Game> fetchedGames = await apiService.fetchGames();
      // Update the state
      setState(() {
        games = fetchedGames;
      });
      if (games.isEmpty) {
        print('No games found in the response.');
      }
    } catch (e) {
      print('Error fetching games: $e');
    }
  }

  // Build method to construct the UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Game Info'),
      ),
      // Check if games list is empty, if so, show a loading
      body: games.isEmpty
          ? Center(
              child:
                  CircularProgressIndicator(), // Show loading spinner while data is fetched
            )
          : ListView.builder(
              itemCount: games.length,
              itemBuilder: (context, index) {
                final game = games[index];
                return ListTile(
                  // Show the game cover image if available, otherwise show a default icon
                  leading: game.coverUrl != null
                      ? Image.network(
                          game.coverUrl!, // Show cover image from URL
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(Icons.image_not_supported);
                          },
                        )
                      : Icon(Icons.image_not_supported),
                  title: Text(game.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Game summary or fallback message if unavailable
                      Text(
                          'Description: ${game.summary ?? 'No description available'}'),
                      // Game genres or fallback message if unavailable
                      Text(
                          'Genres: ${game.genres?.join(', ') ?? 'Unknown genres'}'),
                      // Game platforms or fallback message if unavailable
                      Text(
                          'Platforms: ${game.platforms?.join(',') ?? 'Unknown platforms'}'),
                      // Game release dates or fallback message if unavailable
                      Text(
                          'Release Date: ${game.releaseDates?.join(',') ?? 'Unknown'}'),
                      // Display the website URL if available
                      if (game.websites != null &&
                          game.websites!.isNotEmpty) ...[
                        SizedBox(height: 8),
                        Text('Official Website:'),
                        for (var urlString in game.websites!)
                          TextButton(
                            onPressed: () async {
                              // Enusre the url is a Uri object
                              final Uri url = Uri.parse(urlString);
                              // Check if url can launch
                              if (await canLaunchUrl(url)) {
                                await launchUrl(url);
                              } else {
                                throw 'Could not launch $url';
                              }
                            },
                            child: Text(urlString),
                          ),
                      ],
                    ],
                  ),
                );
              },
            ),
    );
  }
}
