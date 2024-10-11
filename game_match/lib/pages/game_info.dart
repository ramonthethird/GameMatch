import 'package:flutter/material.dart';
import 'package:game_match/pages/add_game.dart';
import 'api_service.dart';
import 'game_model.dart';
import 'package:url_launcher/url_launcher.dart';
import 'wishlist_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GameListScreen extends StatefulWidget {
  @override
  _GameListScreenState createState() => _GameListScreenState();
}

class _GameListScreenState extends State<GameListScreen> {
  final ApiService apiService = ApiService();
  final FirestoreService firestoreService = FirestoreService();
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

  // trying to add a game to wishlist and firebase
  Future<void> addToWishlist(Game game) async {
    WishlistGame wishlistGame = WishlistGame(
      id: game.name, // Use a unique identifier if possible
      name: game.name,
      coverUrl: game.coverUrl ?? '',
      url: game.websites?.isNotEmpty == true
          ? game.websites!.first
          : '', // Example: Using the first URL
    );

    try {
      // Reference to the wishlist collection for the user
      final userId =
          'example_user_id'; // Replace with actual user ID or authentication logic
      await FirebaseFirestore.instance
          .collection('wishlists')
          .doc(userId)
          .collection('games')
          .doc(wishlistGame.id)
          .set(wishlistGame.toJson());

      print('Game added to wishlist: ${wishlistGame.name}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${wishlistGame.name} added to wishlist!')),
      );
    } catch (e) {
      print('Error adding to wishlist: $e');
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
