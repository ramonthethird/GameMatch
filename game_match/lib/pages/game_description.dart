import 'package:flutter/material.dart';
import 'game_model.dart';
import 'Api_Service.dart';


class GameDescriptionPage extends StatefulWidget {
  final Game game;


  const GameDescriptionPage({super.key, 
    required this.game
  });

  @override
  _GameDescriptionPageState createState() => _GameDescriptionPageState();
}

class _GameDescriptionPageState extends State<GameDescriptionPage> {
  final ApiService apiService = ApiService();
  Map<String, dynamic>? gameDetails;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchGameDetails();
  }

  Future<void> fetchGameDetails() async {
    final details = await apiService.fetchGameDetails(widget.game.id);
    setState(() {
      gameDetails = details;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.game.name),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Display cover image
              widget.game.coverUrl != null
                  ? Image.network(widget.game.coverUrl!, fit: BoxFit.cover)
                  : const Icon(Icons.videogame_asset, size: 150),
              const SizedBox(height: 16),

              // Game title
              Text(
                widget.game.name,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // Game genres
              if (gameDetails?['genres'] != null)
                Text(
                  'Genres: ${gameDetails!['genres'].map((genre) => genre['name']).join(', ')}',
                  style: const TextStyle(fontSize: 16),
                ),
              const SizedBox(height: 8),

              // Game themes
              if (gameDetails?['themes'] != null)
                Text(
                  'Themes: ${gameDetails!['themes'].map((theme) => theme['name']).join(', ')}',
                  style: const TextStyle(fontSize: 16),
                ),
              const SizedBox(height: 8),

              // Game modes
              if (gameDetails?['game_modes'] != null)
                Text(
                  'Game Modes: ${gameDetails!['game_modes'].map((mode) => mode['name']).join(', ')}',
                  style: const TextStyle(fontSize: 16),
                ),
              const SizedBox(height: 8),

              // Platforms
              if (gameDetails?['platforms'] != null)
                Text(
                  'Platforms: ${gameDetails!['platforms'].map((platform) => platform['name']).join(', ')}',
                  style: const TextStyle(fontSize: 16),
                ),
              const SizedBox(height: 16),

              // Screenshots
              // if (gameDetails?['screenshots'] != null)
              //   Column(
              //     crossAxisAlignment: CrossAxisAlignment.start,
              //     children: [
              //       Text(
              //         'Screenshots:',
              //         style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              //       ),
              //       SizedBox(height: 8),
              //       SizedBox(
              //         height: 150,
              //         child: ListView.builder(
              //           scrollDirection: Axis.horizontal,
              //           itemCount: gameDetails!['screenshots'].length,
              //           itemBuilder: (context, index) {
              //             String screenshotUrl =
              //                 'https:${gameDetails!['screenshots'][index]['url']}';
              //             return Padding(
              //               padding: const EdgeInsets.only(right: 8.0),
              //               child: Image.network(screenshotUrl, fit: BoxFit.cover),
              //             );
              //           },
              //         ),
              //       ),
              //     ],
              //   ),
            ],
          ),
        ),
      ),
    );
  }
}