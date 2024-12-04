import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'api_service.dart';
import 'game_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:game_match/firestore_service.dart';
// import 'firestore_service.dart';
import 'package:firebase_core/firebase_core.dart';

import 'Side_bar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensures all Flutter bindings are initialized
  await Firebase.initializeApp(); // Initialize Firebase before running the app
  runApp(MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'wishlist screen',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: WishlistPage(),
    );
  }
}

class WishlistPage extends StatefulWidget {
  const WishlistPage({super.key});

  @override
  _WishlistPageState createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  final FirestoreService _firestoreService = FirestoreService();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<Game> _allGames = []; // Holds the full list from Firebase
  List<Game> _filteredGames = []; // Holds the filtered and sorted list
  String _sortCriteria = 'Sort by Custom';

  Future<void> _fetchWishlistGames() async {
    List<Game> games = await _firestoreService.getWishlist();
    setState(() {
      _allGames = games;
      _filteredGames = List.from(_allGames); // Initialize filtered with all games
    });
  }

  Map<String, String> _getStoreUrls(String gameName) {
    final encodedName = Uri.encodeComponent(gameName);
    return {
      'Steam': 'https://store.steampowered.com/search/?term=$encodedName',
      'Playstation Store': 'https://store.playstation.com/search/$encodedName',
      'Xbox': 'https://www.xbox.com/en-US/search?q=$encodedName',
      'Nintendo Store': 'https://www.nintendo.com/search/#q=$encodedName',
    };
  }

  @override
  void initState() {
    super.initState();
    _fetchWishlistGames();
  }

  void _sortGames(String criteria) {
    setState(() {
      _sortCriteria = criteria;
      if (_sortCriteria == 'Name: A - Z') {
        _filteredGames.sort((a, b) => a.name.compareTo(b.name));
      } else if (_sortCriteria == 'Name: Z - A') {
        _filteredGames.sort((a, b) => b.name.compareTo(a.name));
      }
    });
  }

  void _searchGames(String query) {
    setState(() {
      _filteredGames = _allGames
          .where((game) => game.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
      _sortGames(_sortCriteria); // Reapply the sort after search
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text(
          'Wishlist',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.black),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
      ),
      drawer: Drawer(
        child: SideBar(
          onThemeChanged: (isDarkMode) {

          },
          isDarkMode: false,
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: _searchGames,
              decoration: InputDecoration(
                filled: true,
                fillColor: Theme.of(context).cardColor, // Match the color from com 901.txt
                hintText: 'Search...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),



          // Sort Dropdown
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButton<String>(
              value: _sortCriteria,
              onChanged: (value) {
                _sortGames(value!);
              },
              items: const [
                DropdownMenuItem(
                  value: 'Sort by Custom',
                  child: Text('Sort by Custom'),
                ),
                DropdownMenuItem(
                  value: 'Name: A - Z',
                  child: Text('Name: A - Z'),
                ),
                DropdownMenuItem(
                  value: 'Name: Z - A',
                  child: Text('Name: Z - A'),
                ),
              ],
            ),
          ),
          // Display the filtered and sorted wishlist
          Expanded(
            child: ListView.builder(
              itemCount: _filteredGames.length,
              itemBuilder: (context, index) {
                final game = _filteredGames[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(16.0),
                      border: Border.all(
                        color: Colors.grey.shade300,
                        width: 1.0,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Display the cover image if available
                          game.coverUrl != null
                              ? Image.network(
                            game.coverUrl!,
                            width: 100,
                            height: 150,
                            fit: BoxFit.cover,
                          )
                              : Container(
                            width: 100,
                            height: 150,
                            color: Colors.grey,
                            child: const Icon(
                              Icons.image_not_supported,
                              size: 50,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 16), // Spacing between image and text

                          // Display game details in a column
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Align game name with the top of the cover image
                                Text(
                                  game.name,
                                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8), // Space between name and platforms
                                Text(
                                  'Platforms: ${game.platforms.join(', ')}',
                                  style: TextStyle(color: Colors.grey[700]),
                                ),
                                const SizedBox(height: 20), // Space before buttons
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    ElevatedButton(
                                      onPressed: () => _showLinkDialog(context, game),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue,
                                        foregroundColor: Colors.white,
                                      ),
                                      child: const Text('Buy Now'),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.more_horiz),
                                      onPressed: () => _showRemoveDialog(context, game),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showLinkDialog(BuildContext context, Game game) {
    final urls = _getStoreUrls(game.name);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Visit Store for ${game.name}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildLinkText('Steam', urls['Steam']!, context),
              _buildLinkText('Playstation Store', urls['Playstation Store']!, context),
              _buildLinkText('Xbox', urls['Xbox']!, context),
              _buildLinkText('Nintendo Store', urls['Nintendo Store']!, context),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close', style: TextStyle(color: Colors.blue),),
            ),
          ],
        );
      },
    );
  }


  void _showRemoveDialog(BuildContext context, Game game) {
    // Use `game.id` if that's the correct field name in your `Game` model
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Remove Game'),
          content: Text('Would you like to remove ${game.name} from the wishlist?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel', style: TextStyle(color: Colors.blue),),
            ),
            TextButton(
              onPressed: () {
                _firestoreService.removeFromWishlist(game.id.toString()).then((_) {
                  _fetchWishlistGames(); // Refresh the list after removing the game
                });
                Navigator.of(context).pop();
              },
              child: const Text('Remove', style: TextStyle(color: Colors.blue),),
            ),
          ],
        );
      },
    );


    // _firestoreService.removeFromWishlist(game.id.toString()).then((_) {
    //   _fetchWishlistGames(); // Refresh the list after removing the game
    // });
  }
}

Widget _buildLinkText(String label, String url, BuildContext context) {
  return GestureDetector(
    onTap: () => _launchURL(context, url),  // Pass context here
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 18,
          color: Colors.blue,
          decoration: TextDecoration.underline,
        ),
      ),
    ),
  );
}


Future<void> _launchURL(BuildContext context, String url) async {
  final uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri);
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Could not launch $url')),
    );
  }
}