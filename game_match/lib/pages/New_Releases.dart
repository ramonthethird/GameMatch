import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // Import url_launcher for opening links
import 'api_service.dart'; // Make sure this imports ApiService class
import 'game_model.dart'; // Import  Game model

class NewReleasesGames extends StatefulWidget {
  const NewReleasesGames({super.key});
  
  @override
  _NewReleasesGamesState createState() => _NewReleasesGamesState();
}

class _NewReleasesGamesState extends State<NewReleasesGames> {
  List<Game> _games = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchNewGames();
  }
  // Fetch top games from the API
  Future<void> fetchNewGames() async {
    ApiService apiService = ApiService();
    try {
      final games = await apiService.fetchNewReleases();
      setState(() {
        _games = games; // No need for casting since they are already Game type
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }
 // Launch the game's website URL
  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Releases', style: TextStyle(fontSize: 18)),
        backgroundColor: const Color(0xFFF1F3F4),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _games.isEmpty
              ? const Center(child: Text('No games found.'))
              : Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListView.builder(
                    itemCount: _games.length,
                    itemBuilder: (context, index) {
                      return Card(
                        elevation: 4, 
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: InkWell(
                          // Open the game's website when the card is tapped
                          onTap: () {
                            if (_games[index].websiteUrl != null) {
                              _launchURL(_games[index].websiteUrl!);
                            }
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(12)),
                                child: _games[index].coverUrl != null
                                    ? Image.network(
                                        _games[index].coverUrl!,
                                        height: 200,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                      )
                                    : Container(
                                        height: 200,
                                        color: Colors.grey,
                                        alignment: Alignment.center,
                                        child: const Text(
                                          'No Image Available',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _games[index].name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      _games[index].summary ??
                                          'No summary available',
                                      style: const TextStyle(fontSize: 14),
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Genres: ${_games[index].genres.join(', ')}',
                                      style: const TextStyle(
                                          fontSize: 12, color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}