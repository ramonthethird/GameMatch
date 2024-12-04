import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'api_service.dart';
import 'game_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:game_match/firestore_service.dart';
// import 'firestore_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'nexarda_service.dart'; // Nexarda API service
import 'price_results.dart'; // Price model for NEXARDA results
import 'side_bar.dart';
import 'game_info.dart';
import 'package:game_match/theme_notifier.dart';




void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensures all Flutter bindings are initialized
  await Firebase.initializeApp(); // Initialize Firebase before running the app
  runApp(MyApp());
}


class MyApp extends StatelessWidget {
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
  @override
  _WishlistPageState createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {

  final ApiService _apiService = ApiService();
  final NexardaService _nexardaService = NexardaService();
  final FirestoreService _firestoreService = FirestoreService();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<Game> _allGames = []; // Holds the full list from Firebase
  List<Game> _filteredGames = []; // Holds the filtered and sorted list
  String _sortCriteria = 'Sort by Custom';

  List<Game> games = [];
  bool isLoading = true;

  String _igdbStatusMessage = '';
  List<PriceOffer> _priceOffers = [];
  bool _isFetchingPrices = false;
  String? steamUrl;

  final TextEditingController _igdbController = TextEditingController();



  Future<void> searchSteamUrl(String gameName) async {
    setState(() {
      steamUrl = null;
    });

    try {
      final String? url = await _apiService.fetchGameWebsite(gameName);
      if (url != null) {
        setState(() {
          steamUrl = url;
        });
      } else {
        setState(() {
          steamUrl = 'Steam URL not found for "$gameName".';
        });
      }
    } catch (e) {
      print('Error fetching Steam URL: $e');
      setState(() {
        steamUrl = 'Error fetching Steam URL.';
      });
    }
  }



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

  // Future<List<PriceOffer>> _searchGamePrices(String query) async {
  //   List<PriceOffer> offers = [];
  //
  //   setState(() {
  //     _isFetchingPrices = true;
  //     _igdbStatusMessage = 'Searching for "$query"...';
  //     _priceOffers = [];
  //   });
  //
  //   try {
  //     // Search game in IGDB
  //     final game = await _apiService.searchGames(query).then((results) =>
  //     results.isNotEmpty ? results.first : null);
  //     if (game == null) {
  //       setState(() {
  //         _igdbStatusMessage = 'Game not found in IGDB.';
  //         _isFetchingPrices = false;
  //       });
  //       return offers;
  //     }
  //
  //     // Search game in NEXARDA
  //     final nexardaGame = await _nexardaService.fetchGameByName(query);
  //     if (nexardaGame == null) {
  //       setState(() {
  //         _igdbStatusMessage =
  //         'Game found in IGDB but not available in NEXARDA.';
  //         _isFetchingPrices = false;
  //       });
  //       return offers;
  //     }
  //
  //     // Fetch price offers
  //     final prices =
  //     await _nexardaService.fetchPriceOffersById(nexardaGame.id);
  //     setState(() {
  //       if (prices.isEmpty) {
  //         _igdbStatusMessage = 'No prices available for "$query".';
  //       } else {
  //         _igdbStatusMessage = 'Prices found for "$query".';
  //         // Filter offers by store names
  //         _priceOffers = prices.where((offer) {
  //           return offer.storeName.contains('Steam') ||
  //               offer.storeName.contains('Microsoft') ||
  //               offer.storeName.contains('Nintendo') ||
  //               offer.storeName.contains('PlayStation');
  //         }).toList();
  //       }
  //       _isFetchingPrices = false;
  //     });
  //   } catch (e) {
  //     setState(() {
  //       _igdbStatusMessage = 'Error occurred: $e';
  //       _isFetchingPrices = false;
  //     });
  //   }
  // }

  Future<List<PriceOffer>> _searchGamePrices(String query) async {
    List<PriceOffer> offers = [];

    setState(() {
      _isFetchingPrices = true;
      _igdbStatusMessage = 'Searching for "$query"...';
      _priceOffers = [];
    });

    try {
      // Step 1: Check IGDB
      final game = await _apiService.searchGames(query).then((results) =>
      results.isNotEmpty ? results.first : null);
      if (game == null) {
        setState(() {
          _igdbStatusMessage = 'Game not found in IGDB.';
          _isFetchingPrices = false;
        });
        return offers;
      }

      // Step 2: Check NEXARDA
      final nexardaGame = await _nexardaService.fetchGameByName(query);
      if (nexardaGame == null) {
        setState(() {
          _igdbStatusMessage = 'Game found in IGDB but not available in NEXARDA.';
          _isFetchingPrices = false;
        });
        return offers;
      }

      // Step 3: Fetch prices from NEXARDA if game exists in both
      final prices = await _nexardaService.fetchPriceOffersById(nexardaGame.id);

      setState(() {
        if (prices.isEmpty) {
          _igdbStatusMessage = 'No prices available for "$query".';
        } else {
          _igdbStatusMessage = 'Prices found for "$query".';
          // Filter offers by specified store names
          _priceOffers = prices.where((offer) {
            return offer.storeName.contains('Steam') ||
                offer.storeName.contains('Microsoft') ||
                offer.storeName.contains('Nintendo') ||
                offer.storeName.contains('PlayStation');
          }).toList();
        }
        _isFetchingPrices = false;
      });

      return _priceOffers;
    } catch (e) {
      setState(() {
        _igdbStatusMessage = 'Error occurred: $e';
        _isFetchingPrices = false;
      });
      return offers;
    }
  }


  void launchStoreUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          'Wishlist',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
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
            themeNotifier.toggleTheme(isDarkMode);
          },
          isDarkMode: themeNotifier.isDarkMode,
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
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),



          // Sort Dropdown
          // Padding(
          //   padding: const EdgeInsets.all(8.0),
          //   child: DropdownButton<String>(
          //     value: _sortCriteria,
          //     onChanged: (value) {
          //       _sortGames(value!);
          //     },
          //     items: [
          //       DropdownMenuItem(
          //         child: Text('Sort by Custom'),
          //         value: 'Sort by Custom',
          //       ),
          //       DropdownMenuItem(
          //         child: Text('Name: A - Z'),
          //         value: 'Name: A - Z',
          //       ),
          //       DropdownMenuItem(
          //         child: Text('Name: Z - A'),
          //         value: 'Name: Z - A',
          //       ),
          //     ],
          //   ),
          // ),

          // ElevatedButton(
          //   onPressed: () {
          //     // Action for the More button
          //     //_showMoreOptions();
          //   },
          //   style: ElevatedButton.styleFrom(
          //     backgroundColor: Colors.blue,
          //     foregroundColor: Colors.white,
          //   ),
          //   child: Text('More'),
          // ),

          // Replace the Sort Dropdown section in the `build` method with this:
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Dropdown menu
                DropdownButton<String>(
                  value: _sortCriteria,
                  onChanged: (value) {
                    _sortGames(value!);
                  },
                  items: [
                    DropdownMenuItem(
                      child: Text('Sort by Custom'),
                      value: 'Sort by Custom',
                    ),
                    DropdownMenuItem(
                      child: Text('Name: A - Z'),
                      value: 'Name: A - Z',
                    ),
                    DropdownMenuItem(
                      child: Text('Name: Z - A'),
                      value: 'Name: Z - A',
                    ),
                  ],
                ),

                // 'More' button
                // ElevatedButton(
                //   onPressed: () {
                //     Navigator.push(
                //       context,
                //       MaterialPageRoute(
                //         builder: (context) => SearchGameScreen(apiService: _apiService),
                //       ),
                //     );
                //   },
                //   style: ElevatedButton.styleFrom(
                //     backgroundColor: Colors.blue,
                //     foregroundColor: Colors.white,
                //   ),
                //   child: Text('More'),
                // ),
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
                            child: Icon(
                              Icons.image_not_supported,
                              size: 50,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 16), // Spacing between image and text

                          // Display game details in a column
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Align game name with the top of the cover image
                                Text(
                                  game.name,
                                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 8), // Space between name and platforms
                                Text(
                                  'Platforms: ${game.platforms.join(', ')}',
                                  style: TextStyle(color: Colors.grey[700]),
                                ),
                                SizedBox(height: 20), // Space before buttons
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    ElevatedButton(
                                      onPressed: () => _showLinkDialog(context, game),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue,
                                        foregroundColor: Colors.white,
                                      ),
                                      child: Text('Buy Now'),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.more_horiz),
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

  // void _showLinkDialog(BuildContext context, Game game) {
  //   final urls = _getStoreUrls(game.name);
  //
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: Text('Visit Store for ${game.name}'),
  //         content: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             _buildLinkText('Steam', urls['Steam']!, context),
  //             _buildLinkText('Playstation Store', urls['Playstation Store']!, context),
  //             _buildLinkText('Xbox', urls['Xbox']!, context),
  //             _buildLinkText('Nintendo Store', urls['Nintendo Store']!, context),
  //           ],
  //         ),
  //         actions: [
  //           TextButton(
  //             onPressed: () => Navigator.of(context).pop(),
  //             child: Text('Close', style: TextStyle(color: Colors.blue),),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  // void _showLinkDialog(BuildContext context, Game game) async {
  //   String _igdbStatusMessage = 'Fetching prices for ${game.name}...';
  //   List<PriceOffer> _priceOffers = [];
  //   bool _isLoading = true;
  //
  //   // Fetch price offers for the game
  //   try {
  //     _priceOffers = await _searchGamePrices(game.name);
  //     _igdbStatusMessage = _priceOffers.isNotEmpty
  //         ? '' // 'Found ${_priceOffers.length} offers:'
  //         : 'No price offers found for "${game.name}".';
  //   } catch (e) {
  //     _igdbStatusMessage = 'Error fetching prices: $e';
  //   } finally {
  //     _isLoading = false;
  //   }
  //
  //   // Show the dialog
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: Text('Visit Store for ${game.name}'),
  //         content: SingleChildScrollView(
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               if (_isLoading)
  //                 const Center(child: CircularProgressIndicator())
  //               else ...[
  //                 Padding(
  //                   padding: const EdgeInsets.all(10.0),
  //                   child: Text(
  //                     _igdbStatusMessage,
  //                     style: const TextStyle(fontSize: 16),
  //                   ),
  //                 ),
  //                 ..._priceOffers.map(
  //                       (offer) => ListTile(
  //                     title: Text(offer.storeName, style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline,)),
  //                     subtitle: Text(
  //                       '\$${offer.price}', // '${offer.price} ${offer.currency} - ${offer.region}',
  //                     ),
  //                     onTap: () {
  //                       launchStoreUrl(offer.url);
  //                     },
  //                   ),
  //                 ),
  //               ],
  //             ],
  //           ),
  //         ),
  //         actions: <Widget>[
  //           TextButton(
  //             child: const Text('Close', style: TextStyle(color: Colors.blue),),
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //             },
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  // void _showLinkDialog(BuildContext context, Game game) async {
  //   String igdbStatusMessage = 'Fetching prices for ${game.name}...';
  //   List<PriceOffer> priceOffers = [];
  //   bool isLoading = true;
  //
  //   // Fetch price offers for the game
  //   try {
  //     priceOffers = await _searchGamePrices(game.name);
  //     igdbStatusMessage = priceOffers.isNotEmpty
  //         ? '' // Prices found, so no message is needed
  //         : 'No price offers found for "${game.name}".';
  //
  //     // Fetch Steam URL as a fallback if no prices are found
  //     if (priceOffers.isEmpty) {
  //       await searchSteamUrl(game.name);
  //     }
  //   } catch (e) {
  //     igdbStatusMessage = 'Error fetching prices: $e';
  //   } finally {
  //     isLoading = false;
  //   }
  //
  //   // Show the dialog
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: Text('Visit Store for ${game.name}'),
  //         content: SingleChildScrollView(
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               if (isLoading)
  //                 const Center(child: CircularProgressIndicator())
  //               else ...[
  //                 Padding(
  //                   padding: const EdgeInsets.all(10.0),
  //                   child: Text(
  //                     igdbStatusMessage,
  //                     style: const TextStyle(fontSize: 16),
  //                   ),
  //                 ),
  //                 ...priceOffers.map(
  //                       (offer) => ListTile(
  //                     title: Text(
  //                       offer.storeName,
  //                       style: const TextStyle(
  //                         color: Colors.blue,
  //                         decoration: TextDecoration.underline,
  //                       ),
  //                     ),
  //                     subtitle: Text(
  //                       '\$${offer.price}',
  //                     ),
  //                     onTap: () => launchStoreUrl(offer.url),
  //                   ),
  //                 ),
  //                 if (priceOffers.isEmpty && steamUrl != null)
  //                   ListTile(
  //                     title: Text(
  //                       'Steam Store',
  //                       style: const TextStyle(
  //                         color: Colors.blue,
  //                         decoration: TextDecoration.underline,
  //                       ),
  //                     ),
  //                     subtitle: Text(
  //                       steamUrl!,
  //                     ),
  //                     onTap: () => launchStoreUrl(steamUrl!),
  //                   ),
  //               ],
  //             ],
  //           ),
  //         ),
  //
  //
  //
  //
  //
  //
  //
  //         actions: <Widget>[
  //           TextButton(
  //             child: const Text(
  //               'Close',
  //               style: TextStyle(color: Colors.blue),
  //             ),
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //             },
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  void _showLinkDialog(BuildContext context, Game game) async {
    String igdbStatusMessage = 'Fetching prices for ${game.name}...';
    List<PriceOffer> priceOffers = [];
    bool isLoading = true;

    // Fetch price offers and Steam URL
    try {
      priceOffers = await _searchGamePrices(game.name);
      igdbStatusMessage = priceOffers.isNotEmpty
          ? '' // No message if prices are found
          : 'No price offers found for "${game.name}".';

      // Fetch Steam URL if no prices are found
      if (priceOffers.isEmpty) {
        await searchSteamUrl(game.name);
      }
    } catch (e) {
      igdbStatusMessage = 'Error fetching prices: $e';
    } finally {
      isLoading = false;
    }

    // Show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Visit Store for ${game.name}'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isLoading)
                  const Center(child: CircularProgressIndicator())
                else if (priceOffers.isNotEmpty)
                  ...priceOffers.map(
                        (offer) => ListTile(
                      title: Text(
                        offer.storeName,
                        style: const TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      subtitle: Text('\$${offer.price}'),
                      onTap: () => launchStoreUrl(offer.url),
                    ),
                  )
                else if (steamUrl != null)
                    Center( // Center the Steam Store text
                      child: GestureDetector(
                        onTap: () => launchStoreUrl(steamUrl!),
                        child: Text(
                          'Steam Store',
                          style: const TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                            fontSize: 18, // Adjust font size as needed
                          ),
                        ),
                      ),
                    )
                  else
                    const Text(
                      'No store link available.',
                      style: TextStyle(fontSize: 16, color: Colors.red),
                    ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'Close',
                style: TextStyle(color: Colors.blue),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
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
          title: Text('Remove Game'),
          content: Text('Would you like to remove ${game.name} from the wishlist?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel', style: TextStyle(color: Colors.blue),),
            ),
            TextButton(
              onPressed: () {
                _firestoreService.removeFromWishlist(game.id.toString()).then((_) {
                  _fetchWishlistGames(); // Refresh the list after removing the game
                });
                Navigator.of(context).pop();
              },
              child: Text('Remove', style: TextStyle(color: Colors.blue),),
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
        style: TextStyle(
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

// class SearchGameScreen extends StatefulWidget {
//   final ApiService apiService;
//
//   const SearchGameScreen({Key? key, required this.apiService}) : super(key: key);
//
//   @override
//   _SearchGameScreenState createState() => _SearchGameScreenState();
// }
//
// class _SearchGameScreenState extends State<SearchGameScreen> {
//   final TextEditingController _searchController = TextEditingController();
//   bool _isLoading = false;
//   String? _errorMessage;
//
//   void _searchGame() async {
//     final query = _searchController.text.trim();
//     if (query.isEmpty) {
//       setState(() {
//         _errorMessage = "Please enter a game name.";
//       });
//       return;
//     }
//
//     setState(() {
//       _isLoading = true;
//       _errorMessage = null;
//     });
//
//     try {
//       final games = await widget.apiService.searchGames(query);
//       if (games.isNotEmpty) {
//         // Navigate to the GameDetailScreen with the first game's ID
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => GameDetailScreen(gameId: games.first.id),
//           ),
//         );
//       } else {
//         setState(() {
//           _errorMessage = "Game not found.";
//         });
//       }
//     } catch (e) {
//       setState(() {
//         _errorMessage = "An error occurred while searching.";
//       });
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Search for a Game'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             TextField(
//               controller: _searchController,
//               decoration: InputDecoration(
//                 labelText: 'Enter game name',
//                 border: OutlineInputBorder(),
//                 suffixIcon: IconButton(
//                   icon: const Icon(Icons.search),
//                   onPressed: _searchGame,
//                 ),
//               ),
//             ),
//             const SizedBox(height: 16),
//             if (_isLoading)
//               const CircularProgressIndicator(),
//             if (_errorMessage != null)
//               Text(
//                 _errorMessage!,
//                 style: const TextStyle(color: Colors.red),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }

class SearchGameScreen extends StatefulWidget {
  final ApiService apiService;

  const SearchGameScreen({Key? key, required this.apiService}) : super(key: key);

  @override
  _SearchGameScreenState createState() => _SearchGameScreenState();
}

class _SearchGameScreenState extends State<SearchGameScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _searchGame() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      setState(() {
        _errorMessage = "Please enter a game name.";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Fetch game details using the provided API service
      final gameDetails = await widget.apiService.fetchGameDetails(query);

      if (gameDetails != null) {
        print('Game ID: ${gameDetails['id']}'); // Debug the ID
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              final String gameId = gameDetails['id'].toString();
              return GameDetailScreen(gameId: gameId);
            },
          ),
        );
      } else {
        setState(() {
          _errorMessage = "Game not found.";
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "An error occurred while searching.";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search for a Game'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Enter game name',
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _searchGame,
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const CircularProgressIndicator(),
            if (_errorMessage != null)
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
          ],
        ),
      ),
    );
  }
}