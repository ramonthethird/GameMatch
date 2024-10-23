import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'game_model.dart';
import 'api_service.dart';
import 'package:game_match/firestore_service.dart'; // Import your FirestoreService

class GameDetailScreen extends StatefulWidget {
  final String gameId;

  const GameDetailScreen({Key? key, required this.gameId}) : super(key: key);

  @override
  _GameDetailScreenState createState() => _GameDetailScreenState();
}

class _GameDetailScreenState extends State<GameDetailScreen> {
  final ApiService apiService = ApiService();
  final FirestoreService _firestoreService =
      FirestoreService(); // Initialize FirestoreService
  Game? selectedGame;

  @override
  void initState() {
    super.initState();
    _fetchGameDetails(); // Call to fetch game details when the screen is initialized
  }

  // Fetch game details from Firestore or API
  Future<void> _fetchGameDetails() async {
    try {
      // Try to get the game from Firestore
      selectedGame = await _firestoreService.getGameById(widget.gameId);

      if (selectedGame != null) {
        setState(() {});
      }
    } catch (e) {
      print('Error fetching game details: $e');
      // Show a snackbar or handle the error appropriately
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Game not found or failed to load')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Game Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: selectedGame == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (selectedGame!.screenshotUrls != null &&
                      selectedGame!.screenshotUrls!.isNotEmpty)
                    SizedBox(
                      height: 200,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: selectedGame!.screenshotUrls!.length,
                        itemBuilder: (context, index) {
                          final screenshotUrl =
                              selectedGame!.screenshotUrls![index];
                          return Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Image.network(
                              screenshotUrl,
                              height: 200,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(Icons.image_not_supported);
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  const SizedBox(height: 16),
                  Text(
                    selectedGame!.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    selectedGame!.summary ?? 'No description available',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${selectedGame!.price!.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        selectedGame!.developers != null &&
                                selectedGame!.developers!.isNotEmpty
                            ? selectedGame!.developers!.first
                            : 'Unknown Developer',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Platforms: ${selectedGame!.platforms?.join(', ') ?? 'Unknown platforms'}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Release Date: ${selectedGame!.releaseDates?.join(', ') ?? 'Unknown release date'}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () async {
                          final Uri url = Uri.parse(selectedGame!.websiteUrl!);
                          if (await canLaunchUrl(url)) {
                            await launchUrl(url,
                                mode: LaunchMode.externalApplication);
                          } else {
                            throw 'Could not launch $url';
                          }
                        },
                        icon: const Icon(Icons.shopping_cart),
                        label: const Text('Buy'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 12,
                          ),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          // Handle navigation to reviews page
                        },
                        icon: const Icon(Icons.rate_review),
                        label: const Text('See Reviews'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}
