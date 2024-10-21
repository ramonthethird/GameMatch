import 'package:flutter/material.dart';
import 'game_model.dart';

class GameDetailsScreen extends StatelessWidget {
  final Game game;

  GameDetailsScreen({required this.game});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Game Details'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Game cover image
            if (game.coverUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.network(
                  game.coverUrl!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            SizedBox(height: 16.0),
            // Game title
            Text(
              game.name,
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.0),
            // Game Description
            Text(
              game.summary ?? 'No description available',
              style: TextStyle(fontSize: 16.0),
            ),
            SizedBox(height: 16.0),
            // Price and Publisher Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Price
                if (game.price != null)
                  Container(
                    padding: EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.0),
                      color: Colors.grey[200],
                    ),
                    child: Text(
                      '\$${game.price!.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                // Publisher (for now using first platform as an example)
                if (game.platforms.isNotEmpty)
                  Container(
                    padding: EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.0),
                      color: Colors.grey[200],
                    ),
                    child: Text(
                      game.platforms.first,
                      style: TextStyle(
                        fontSize: 18.0,
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 16.0),
            // Buy Button
            ElevatedButton.icon(
              onPressed: () {},
              icon: Icon(Icons.shopping_cart),
              label: Text('Buy'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
              ),
            ),
            SizedBox(height: 16.0),
            // Rating Row
            Row(
              children: [
                // Stars
                Row(
                  children: List.generate(5, (index) {
                    return Icon(
                      Icons.star,
                      color: Colors.yellow,
                    );
                  }),
                ),
                SizedBox(width: 16.0),
                // Likes and Comments
                Icon(Icons.thumb_up_alt_outlined),
                SizedBox(width: 4.0),
                Text('300'),
                SizedBox(width: 16.0),
                Icon(Icons.comment_outlined),
                SizedBox(width: 4.0),
                Text('1200'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // void main() {
  //   Game sampleGame = Game(
  //     name: 'The Witcher 3: Wild Hunt',
  //     summary:
  //         'The Witcher 3: Wild Hunt is an open-world RPG developed by CD Projekt Red. Players control Geralt of Rivia, a monster hunter known as a Witcher, as he searches for his adopted daughter. The game features a rich storyline, complex characters, and a vast world filled with quests and adventures.',
  //     genres: ['RPG', 'Open World'],
  //     coverUrl: 'https://example.com/witcher3.jpg',
  //     websites: ['https://thewitcher.com'],
  //     platforms: ['PC', 'PlayStation', 'Xbox'],
  //     releaseDates: ['May 19, 2015'],
  //     price: 39.99,
  //   );
  //   runApp(MaterialApp(
  //     home: GameDetailsScreen(game: sampleGame),
  //   ));
  // }
}
