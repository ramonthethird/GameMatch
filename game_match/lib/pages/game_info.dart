import 'package:flutter/material.dart';
import 'api_service.dart';
import 'game_model.dart';
import 'package:url_launcher/url_launcher.dart';

// The main screen displaying the list of games
class GameListScreen extends StatefulWidget {
  const GameListScreen({super.key});

  @override
  _GameListScreenState createState() => _GameListScreenState();
}

// The state class for the GameListScreen
class _GameListScreenState extends State<GameListScreen> {
  final ApiService apiService = ApiService();
  List<Game> games = [];
  List<dynamic> platforms = [];

  // Called when the widget is first inserted into the widget tree
  @override
  void initState() {
    super.initState();
    _fetchPlatformsAndGames();
  }

  Future<void> _fetchPlatformsAndGames() async {
    await _fetchPlatforms();
    await _fetchGames();
  }

  // Fetch platforms to find steam ID
  Future<void> _fetchPlatforms() async {
    platforms = await apiService.fetchPlatforms();
    var steamPlatforms = platforms
        .where((p) => p['name'].toString().toLowerCase().contains('steam'));
    print('Steam Platforms: $steamPlatforms');
    setState(() {});
  }

  // Function to fetch games from the API
  Future<void> _fetchGames() async {
    try {
      // Fetch games using the APIService
      List<Game> fetchedGames = await apiService.fetchGames();

      // Fetch prices from CheapShark for the fetched games
      if (fetchedGames.isNotEmpty) {
        await _fetchPricesForGames(fetchedGames);
      }

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

  // Function to fetch prices for games using GameShark API
  Future<void> _fetchPricesForGames(List<Game> fetchedGames) async {
    try {
      // Fetch CheapShark IDs for the games
      List<int> cheapSharksIds = [];

      // Fetch the CheapShark game IDs for each game
      for (var game in fetchedGames) {
        final gameId = await apiService.fetchGameIDFromCheapShark(game.name);
        if (gameId != null) {
          cheapSharksIds.add(gameId);
        } else {
          print('No CheapShark IDs found for ${game.name}');
        }
      }

      // If no valid IDs are found skip price fetching
      if (cheapSharksIds.isEmpty) {
        print('No valid CheapShark IDs found, skippng price fetching');
        return;
      }

      // Call the API to fetch prices for these games
      Map<String, double> prices =
          await apiService.fetchPricesForMultipleGames(cheapSharksIds);

      // Update the prices for these games
      for (var game in fetchedGames) {
        final gameId = await apiService.fetchGameIDFromCheapShark(game.name);
        if (gameId != null && prices.containsKey(gameId.toString())) {
          game.updatePrice(prices[gameId.toString()]);
        }
      }
      setState(() {
        games = fetchedGames;
      });
    } catch (e) {
      print('Error fetching game price: $e');
    }
  }

  // Build method to construct the UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Game Info'),
      ),
      // Check if games list is empty, if so, show a loading
      body: games.isEmpty
          ? const Center(
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
                            return const Icon(Icons.image_not_supported);
                          },
                        )
                      : const Icon(Icons.image_not_supported),
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
                      // Display the price
                      Text(
                          'Price: ${game.price != null && game.price! > 0 ? '\$${game.price!.toStringAsFixed(2)}' : 'Price not available'}'),
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

                      // Display screenshots if available
                      if (game.screenshotUrls != null &&
                          game.screenshotUrls!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        const Text('Screenshots:'),
                        SizedBox(
                            height: 150,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: game.screenshotUrls!.length,
                              itemBuilder: (context, screenshotIndex) {
                                final screenshotUrl =
                                    game.screenshotUrls![screenshotIndex];
                                return Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Image.network(
                                    screenshotUrl,
                                    height: 150,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Icon(
                                          Icons.image_not_supported);
                                    },
                                  ),
                                );
                              },
                            ))
                      ]
                    ],
                  ),
                );
              },
            ),
    );
  }
}
