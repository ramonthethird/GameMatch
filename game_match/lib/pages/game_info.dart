import 'package:flutter/material.dart';
import 'api_service.dart';
import 'game_model.dart';
import 'package:url_launcher/url_launcher.dart';

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
    try {
      List<Game> fetchedGames = await apiService.fetchGames();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Game Info'),
      ),
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
                  leading: game.coverUrl != null
                      ? Image.network(
                          game.coverUrl!, // Show cover image if available
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(Icons.image_not_supported);
                          },
                        )
                      : Icon(Icons.image_not_supported),
                  title: Text(game.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          'Description: ${game.summary ?? 'No description available'}'),
                      Text(
                          'Genres: ${game.genres?.join(', ') ?? 'Unknown genres'}'),
                      Text(
                          'Platforms: ${game.platforms?.join(',') ?? 'Unknown platforms'}'),
                      Text(
                          'Release Date: ${game.releaseDates?.join(',') ?? 'Unknown'}'),
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
