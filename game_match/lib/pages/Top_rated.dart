import 'package:flutter/material.dart';
import 'api_service.dart'; // Make sure to import your ApiService class
import 'pages/Top_rated.dart'; // Import the TopRatedGames widget

class TopRatedGames extends StatefulWidget {
  @override
  _TopRatedGamesState createState() => _TopRatedGamesState();
}

class _TopRatedGamesState extends State<TopRatedGames> {
  List<Game> _games = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchTopRatedGames();
  }

  Future<void> fetchTopRatedGames() async {
    ApiService apiService = ApiService();
    try {
      final games = await apiService.fetchGames();
      setState(() {
        _games = games;
        _isLoading = false;
      });
    } catch (e) {
      print(e); // Handle error appropriately
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Top Rated Games'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _games.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_games[index].name),
                  subtitle: Text(_games[index].summary ?? 'No summary available'),
                  leading: _games[index].cover != null
                      ? Image.network(
                          'https:${_games[index].cover?.url}',
                          width: 50,
                          fit: BoxFit.cover,
                        )
                      : null,
                );
              },
            ),
    );
  }
}
