import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'game_model.dart';
import 'api_service.dart';
import 'package:game_match/firestore_service.dart';
import 'View_Reviews.dart';
import 'threads.dart';
import 'package:game_match/theme_notifier.dart';
import 'package:provider/provider.dart';

class GameDetailScreen extends StatefulWidget {
  final String gameId;

  const GameDetailScreen({Key? key, required this.gameId}) : super(key: key);

  @override
  _GameDetailScreenState createState() => _GameDetailScreenState();
}

class _GameDetailScreenState extends State<GameDetailScreen> {
  final ApiService apiService = ApiService();
  final FirestoreService _firestoreService = FirestoreService();
  Game? selectedGame;

  @override
  void initState() {
    super.initState();
    _fetchGameDetails();
  }

  Future<void> _fetchGameDetails() async {
    try {
      selectedGame = await _firestoreService.getGameById(widget.gameId);
      if (selectedGame != null) {
        setState(() {});
      }
    } catch (e) {
      print('Error fetching game details: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Game not found or failed to load')),
      );
    }
  }

  void _showEnlargedImage(List<String> imageUrls, int initialIndex) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.all(10),
          child: StatefulBuilder(
            builder: (context, setState) {
              return GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: InteractiveViewer(
                  boundaryMargin: EdgeInsets.all(20),
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: PageView.builder(
                    controller: PageController(initialPage: initialIndex),
                    itemCount: imageUrls.length,
                    itemBuilder: (context, index) {
                      return Container(
                        width: MediaQuery.of(context).size.width * 0.95,
                        height: MediaQuery.of(context).size.height * 0.9,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          image: DecorationImage(
                            image: NetworkImage(imageUrls[index]),
                            fit: BoxFit.contain,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Game Details',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black,),
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
                          final screenshotUrl = selectedGame!.screenshotUrls![index];
                          return GestureDetector(
                            onTap: () =>
                                _showEnlargedImage(selectedGame!.screenshotUrls!, index),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12), // Rounded corners
                                child: Image.network(
                                  screenshotUrl,
                                  height: 200,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(Icons.image_not_supported);
                                  },
                                ),
                              ),
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

                  // Container for Price and Developer
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: themeNotifier.isDarkMode ? Colors.grey[850] : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
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
                  ),
                  const SizedBox(height: 12), // Spacing between containers

                  // Container for Platforms and Release Date
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: themeNotifier.isDarkMode ? Colors.grey[850] : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            'Platforms: ${selectedGame!.platforms?.join(', ') ?? 'Unknown platforms'}',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                        const SizedBox(width: 8), // Space between items
                        Expanded(
                          child: Text(
                            'Release Date: ${selectedGame!.releaseDates?.join(', ') ?? 'Unknown release date'}',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16), // Space between info and buttons

                  // Row for "See Reviews" and "See Threads" buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ViewReviewsPage(
                                  gameId: selectedGame!.id,
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.rate_review),
                          label: const Text('See Reviews'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF41B1F1),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12), // Space between buttons
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ThreadsPage(
                                  gameId: selectedGame!.id,
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.forum),
                          label: const Text('See Threads'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF41B1F1),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16), // Space between rows

                  // "Buy" button below the two
                  ElevatedButton.icon(
                    onPressed: () async {
                      final url = selectedGame?.websiteUrl;

                      if (url != null && Uri.tryParse(url)?.hasAbsolutePath == true) {
                        final Uri uri = Uri.parse(url);
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri, mode: LaunchMode.externalApplication);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Could not launch URL')),
                          );
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Invalid or missing URL')),
                        );
                      }
                    },
                    icon: const Icon(Icons.shopping_cart),
                    label: const Text('Buy'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF41B1F1),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      minimumSize: const Size.fromHeight(50), // Make "Buy" button full-width
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
