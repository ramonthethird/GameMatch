import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'game_model.dart';
import 'api_service.dart';
import 'package:game_match/firestore_service.dart';
import 'View_Reviews.dart';
import 'threads.dart';
import 'package:game_match/theme_notifier.dart';
import 'package:provider/provider.dart';
import 'nexarda_service.dart';
import 'vidgame_model.dart';
import 'price_results.dart';

class GameDetailScreen extends StatefulWidget {
  final String gameId;

    const GameDetailScreen({super.key, required this.gameId});

  @override
  _GameDetailScreenState createState() => _GameDetailScreenState();
}

class _GameDetailScreenState extends State<GameDetailScreen> {
  final ApiService apiService = ApiService();
  final FirestoreService _firestoreService = FirestoreService();
  Game? selectedGame;



  final NexardaService nexardaService = NexardaService();
  Map<String, dynamic>? gameDetails;
  bool isLoading = true;
  String? errorMessage;
  List<PriceOffer> priceOffers = [];
  bool isFetchingPrices = true;
  VideoGame? videoGame;
  String? message;
  String? steamUrl;


  @override
  void initState() {
    super.initState();
    _fetchGameDetails();
  }

  // Future<void> fetchGameByName(String gameName) async {
  //   setState(() {
  //     isLoading = true;
  //     message = null;
  //     priceOffers = []; // Clear previous price offers
  //   });
  //
  //   final foundGame = await nexardaService.fetchGameByName(gameName);
  //   if (foundGame == null) {
  //     setState(() {
  //       message = 'Game "$gameName" does not exist in the NEXARDA API.';
  //       isLoading = false;
  //     });
  //   } else {
  //     setState(() {
  //       videoGame = foundGame;
  //     });
  //
  //     // Fetch price offers for the game and filter by specified stores
  //     final offers = await nexardaService.fetchPriceOffersById(foundGame.id);
  //     setState(() {
  //       priceOffers = offers.where((offer) =>
  //       offer.storeName.contains('PlayStation') ||
  //           offer.storeName.contains('Microsoft') ||
  //           offer.storeName.contains('Nintendo') ||
  //           offer.storeName.contains('Steam')).toList();
  //       isLoading = false;
  //     });
  //   }
  // }

  Future<void> fetchGameByName(String gameName) async {
    setState(() {
      isLoading = true;
      message = null;
      priceOffers = []; // Clear previous price offers
    });

    try {
      final foundGame = await nexardaService.fetchGameByName(gameName);
      if (foundGame == null) {
        setState(() {
          message = 'Price: Currently unavailable';
          isLoading = false;
        });
      } else {
        setState(() {
          videoGame = foundGame;
        });

        // Fetch price offers for the game
        final offers = await nexardaService.fetchPriceOffersById(foundGame.id);
        if (offers.isEmpty) {
          setState(() {
            message = 'Price: Currently unavailable';
            isLoading = false;
          });
        } else {
          setState(() {
            priceOffers = offers
                .where((offer) =>
                ['PlayStation', 'Microsoft', 'Nintendo', 'Steam']
                    .contains(offer.storeName))
                .toList();
            isLoading = false;
          });
        }
      }
    } catch (e) {
      setState(() {
        message = 'Price: Currently unavailable';
        isLoading = false;
      });
      print('Error in fetchGameByName: $e');
    }
  }

  void getSteamPlatformWebsite() async {
    final String? steamWebsite = await apiService.fetchSteamPlatformWebsite();
    if (steamWebsite != null) {
      print('Steam Platform Website: $steamWebsite');
    } else {
      print('Steam platform website not found.');
    }
  }

  void getSteamWebsiteLink() async {
    final String? steamWebsite = await apiService.fetchSteamWebsiteDetails();
    if (steamWebsite != null) {
      print('Steam Website: $steamWebsite');
    } else {
      print('Steam website not found.');
    }
  }


  // Future<void> _fetchGameDetails() async {
  //   try {
  //     selectedGame = await _firestoreService.getGameById(widget.gameId);
  //     if (selectedGame != null) {
  //       setState(() {});
  //       await fetchGameByName(selectedGame!.name); // Fetch prices using the game name
  //
  //       final steamWebsite = await apiService.fetchSteamWebsite();
  //       print('Fetched Steam Website: $steamWebsite');
  //       setState(() {
  //         selectedGame = selectedGame!.copyWith(steamWebsite: steamWebsite);
  //       });
  //
  //     } else {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text('Game not found in recommendations')),
  //       );
  //     }
  //   } catch (e) {
  //     print('Error fetching game details: $e');
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('Game not found or failed to load')),
  //     );
  //   }
  // }

  // Future<void> _fetchGameDetails() async {
  //   try {
  //     selectedGame = await _firestoreService.getGameById(widget.gameId);
  //     if (selectedGame != null) {
  //       setState(() {});
  //       await fetchGameByName(selectedGame!.name);
  //
  //       // Fetch the Steam website
  //       final steamWebsite = await apiService.fetchSteamPlatformWebsite();
  //       print('Fetched Steam Website: $steamWebsite');
  //
  //       setState(() {
  //         selectedGame = selectedGame!.copyWith(steamWebsite: steamWebsite);
  //       });
  //     } else {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text('Game not found in recommendations')),
  //       );
  //     }
  //   } catch (e) {
  //     print('Error fetching game details: $e');
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('Game not found or failed to load')),
  //     );
  //   }
  // }

  Future<void> _fetchGameDetails() async {
    try {
      selectedGame = await _firestoreService.getGameById(widget.gameId);
      if (selectedGame != null) {
        setState(() {});
        await fetchGameByName(selectedGame!.name);

        // Fetch the Steam website link dynamically
        await searchSteamUrl(selectedGame!.name);

        if (steamUrl != null) {
          print('Fetched Steam URL: $steamUrl');
        } else {
          print('Steam URL not found for ${selectedGame!.name}');
        }

      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Game not found in recommendations')),
        );
      }
    } catch (e) {
      print('Error fetching game details: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Game not found or failed to load')),
      );
    }
  }

  void getSteamWebsite() async {
    final String? steamWebsite = await apiService.fetchSteamWebsite();
    if (steamWebsite != null) {
      print('Steam Website: $steamWebsite');
    } else {
      print('Steam website not found.');
    }
  }

  Future<void> searchSteamUrl(String gameName) async {
    setState(() {
      steamUrl = null;
    });

    try {
      final String? url = await apiService.fetchGameWebsite(gameName);
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


//   Future<void> _fetchGameDetails() async {
//   try {
//     selectedGame = await _firestoreService.getGameById(widget.gameId);
//     if (selectedGame != null) {
//       setState(() {});
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Game not found in recommendations')),
//       );
//     }
//   } catch (e) {
//     print('Error fetching game details: $e');
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text('Game not found or failed to load')),
//     );
//   }
// }

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
  @override
Widget build(BuildContext context) {
  final themeNotifier = Provider.of<ThemeNotifier>(context);

  return Scaffold(
    appBar: AppBar(
      title: const Text(
        'Game Details',
        style: TextStyle(
          color: Colors.black,
          fontSize: 16,
        ),
      ),
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
    ),
    body: selectedGame == null
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            child: Padding(
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
                                borderRadius: BorderRadius.circular(12),
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
                      fontSize: 20,
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
                  // Container(
                  //   padding: const EdgeInsets.all(12),
                  //   decoration: BoxDecoration(
                  //     color: themeNotifier.isDarkMode ? Colors.grey[850] : Colors.white,
                  //     borderRadius: BorderRadius.circular(8),
                  //   ),
                  //   child: Row(
                  //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //
                  //     // get price using api
                  //     children: [
                  //
                  //
                  //
                  //
                  //       // Text(
                  //       //   '\$${(selectedGame!.price ?? (5.99 + (1.5 * (widget.gameId.hashCode % 2.5)))).toStringAsFixed(2)}',
                  //       //   style: const TextStyle(
                  //       //     fontSize: 14,
                  //       //     fontWeight: FontWeight.bold,
                  //       //   ),
                  //       // ),
                  //
                  //       // if (priceOffers.isNotEmpty)
                  //       //   Column(
                  //       //     crossAxisAlignment: CrossAxisAlignment.start,
                  //       //     children: [
                  //       //       const SizedBox(height: 16),
                  //       //       Text(
                  //       //         "Prices:",
                  //       //         style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  //       //       ),
                  //       //       const SizedBox(height: 8),
                  //       //       ...priceOffers.map((offer) => Text(
                  //       //         "\$${offer.price.toStringAsFixed(2)} (${offer.storeName})",
                  //       //         style: const TextStyle(fontSize: 14),
                  //       //       )),
                  //       //
                  //       //       const SizedBox(height: 12),
                  //       //       // Cheapest price display
                  //       //       if (priceOffers.isNotEmpty)
                  //       //         Text(
                  //       //           'Cheapest Price: \$${priceOffers.reduce((a, b) => a.price < b.price ? a : b).price.toStringAsFixed(2)} (${priceOffers.reduce((a, b) => a.price < b.price ? a : b).storeName})',
                  //       //           style: const TextStyle(
                  //       //             fontSize: 14,
                  //       //             fontWeight: FontWeight.bold,
                  //       //             color: Colors.green,
                  //       //           ),
                  //       //         ),
                  //       //
                  //       //
                  //       //
                  //       //     ],
                  //       //   ),
                  //
                  //       if (priceOffers.isNotEmpty)
                  //         Column(
                  //           crossAxisAlignment: CrossAxisAlignment.start,
                  //           children: [
                  //             const SizedBox(height: 16),
                  //             Text(
                  //               "Prices:",
                  //               style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  //             ),
                  //             const SizedBox(height: 8),
                  //             ...priceOffers.map((offer) => Text(
                  //               "\$${offer.price.toStringAsFixed(2)} (${offer.storeName})",
                  //               style: const TextStyle(fontSize: 14),
                  //             )),
                  //             const SizedBox(height: 12),
                  //             // Cheapest price display
                  //             if (priceOffers.isNotEmpty)
                  //               Text(
                  //                 'Cheapest Price: \$${priceOffers.reduce((a, b) => a.price < b.price ? a : b).price.toStringAsFixed(2)} (${priceOffers.reduce((a, b) => a.price < b.price ? a : b).storeName})',
                  //                 style: const TextStyle(
                  //                   fontSize: 14,
                  //                   fontWeight: FontWeight.bold,
                  //                   color: Colors.green,
                  //                 ),
                  //               ),
                  //           ],
                  //         )
                  //       else if (message != null)
                  //         RichText(
                  //           text: TextSpan(
                  //             text: 'Price: ', // Bold text
                  //             style: const TextStyle(
                  //               fontSize: 14,
                  //               fontWeight: FontWeight.bold,
                  //               fontFamily: 'SignikaNegative',
                  //               color: Colors.black, // Ensure consistent text color
                  //             ),
                  //             children: [
                  //               TextSpan(
                  //                 text: 'Currently unavailable', // Italic text
                  //                 style: const TextStyle(
                  //                   fontStyle: FontStyle.italic,
                  //                   fontFamily: 'SignikaNegative',
                  //                   fontWeight: FontWeight.normal,
                  //                 ),
                  //               ),
                  //             ],
                  //           ),
                  //         )
                  //       else
                  //         RichText(
                  //           text: TextSpan(
                  //             text: 'Price: ', // Bold text
                  //             style: const TextStyle(
                  //               fontSize: 14,
                  //               fontWeight: FontWeight.bold,
                  //               color: Colors.black,
                  //             ),
                  //             children: [
                  //               TextSpan(
                  //                 text: 'Currently unavailable', // Italic text
                  //                 style: const TextStyle(
                  //                   fontStyle: FontStyle.italic,
                  //                   fontWeight: FontWeight.normal,
                  //                 ),
                  //               ),
                  //             ],
                  //           ),
                  //         ),
                  //
                  //
                  //
                  //
                  //
                  //
                  //       Text(
                  //         selectedGame!.developers != null &&
                  //                 selectedGame!.developers!.isNotEmpty
                  //             ? selectedGame!.developers!.first
                  //             : 'Unknown Developer',
                  //         style: const TextStyle(fontSize: 14),
                  //       ),
                  //     ],
                  //   ),
                  // ),
                  //
                  //




                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: themeNotifier.isDarkMode ? Colors.grey[850] : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Display the price or a fallback message
                        if (priceOffers.isNotEmpty)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Prices:",
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              ...priceOffers.map((offer) => Text(
                                "\$${offer.price.toStringAsFixed(2)} (${offer.storeName})",
                                style: const TextStyle(fontSize: 14),
                              )),
                              const SizedBox(height: 12),
                              Text(
                                'Cheapest Price: \$${priceOffers.reduce((a, b) => a.price < b.price ? a : b).price.toStringAsFixed(2)} (${priceOffers.reduce((a, b) => a.price < b.price ? a : b).storeName})',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          )
                        else if (message != null)
                          RichText(
                            text: TextSpan(
                              text: 'Price: ', // Bold text
                              style: TextStyle(
                                fontSize: 14,
                                fontFamily: 'SignikaNegative',
                                fontWeight: FontWeight.bold,
                                color: themeNotifier.isDarkMode ? Colors.white : Colors.black,
                              ),
                              children: [
                                TextSpan(
                                  text: 'Currently unavailable', // Italic text
                                  style: const TextStyle(
                                    fontStyle: FontStyle.italic,
                                    fontFamily: 'SignikaNegative',
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          RichText(
                            text: TextSpan(
                              text: 'Price: ', // Bold text
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'SignikaNegative',
                                color: themeNotifier.isDarkMode ? Colors.white : Colors.black,
                              ),
                              children: [
                                TextSpan(
                                  text: 'Currently unavailable', // Italic text
                                  style: const TextStyle(
                                    fontFamily: 'SignikaNegative',
                                    fontStyle: FontStyle.italic,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 12), // Add spacing for the newline

                        // Display the developer information
                        RichText(
                          text: TextSpan(
                            text: 'Developer: ', // Bold text for "Developer:"
                            style: TextStyle(
                              fontSize: 14,
                              fontFamily: 'SignikaNegative',
                              fontWeight: FontWeight.bold,
                              color: themeNotifier.isDarkMode ? Colors.white : Colors.black, // Ensure consistent text color
                            ),
                            children: [
                              TextSpan(
                                text: selectedGame!.developers != null && selectedGame!.developers!.isNotEmpty
                                    ? selectedGame!.developers!.first
                                    : 'Unknown Developer',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontFamily: 'SignikaNegative',
                                  fontWeight: FontWeight.normal, // Normal text for developer name
                                  color: themeNotifier.isDarkMode ? Colors.white : Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),




                  const SizedBox(height: 12),
                  // Container for Platforms and Release Date
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: themeNotifier.isDarkMode ? Colors.grey[850] : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 1,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Platforms:',
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                selectedGame!.platforms.join(', '),
                                style: const TextStyle(fontSize: 14),
                              ),










                            ],
                          ),
                        ),
                        const SizedBox(width: 12), // Space between platform and release date columns
                        Expanded(
                          flex: 1,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Release Date:',
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                selectedGame!.releaseDates.isNotEmpty
                                    ? selectedGame!.releaseDates.last
                                    : 'Unknown release date',
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  // // Steam Website Link
                  // if (selectedGame?.steamWebsite != null)
                  //   GestureDetector(
                  //     onTap: () async {
                  //       final Uri uri = Uri.parse(selectedGame!.steamWebsite!);
                  //       if (await canLaunchUrl(uri)) {
                  //         await launchUrl(uri, mode: LaunchMode.externalApplication);
                  //       } else {
                  //         ScaffoldMessenger.of(context).showSnackBar(
                  //           const SnackBar(content: Text('Could not launch URL')),
                  //         );
                  //       }
                  //     },
                  //     child: Text(
                  //       'Visit Steam Page',
                  //       style: const TextStyle(
                  //         fontSize: 14,
                  //         fontWeight: FontWeight.bold,
                  //         color: Colors.blue,
                  //         decoration: TextDecoration.underline,
                  //       ),
                  //     ),
                  //   )
                  // else
                  //   Text(
                  //     'Website not found',
                  //     style: const TextStyle(
                  //       fontSize: 14,
                  //       fontStyle: FontStyle.italic,
                  //       color: Colors.red,
                  //     ),
                  //   ),


                  // Steam Website Link
                  const SizedBox(height: 0),






                  // Text('Steam Link'),
                  // const SizedBox(height: 12),
                  // if (steamUrl != null && steamUrl != 'Error fetching Steam URL.')
                  //   GestureDetector(
                  //     onTap: () async {
                  //       if (Uri.tryParse(steamUrl!)?.hasAbsolutePath == true) {
                  //         final Uri uri = Uri.parse(steamUrl!);
                  //         if (await canLaunchUrl(uri)) {
                  //           await launchUrl(uri, mode: LaunchMode.externalApplication);
                  //         } else {
                  //           ScaffoldMessenger.of(context).showSnackBar(
                  //             const SnackBar(content: Text('Could not launch URL')),
                  //           );
                  //         }
                  //       } else {
                  //         ScaffoldMessenger.of(context).showSnackBar(
                  //           const SnackBar(content: Text('Invalid URL')),
                  //         );
                  //       }
                  //     },
                  //     child: Text(
                  //       steamUrl!,
                  //       style: const TextStyle(
                  //         fontSize: 14,
                  //         fontWeight: FontWeight.bold,
                  //         color: Colors.blue,
                  //         decoration: TextDecoration.underline,
                  //       ),
                  //     ),
                  //   )
                  // else
                  //   const Text(
                  //     'Website not found',
                  //     style: TextStyle(
                  //       fontSize: 14,
                  //       fontStyle: FontStyle.italic,
                  //       color: Colors.red,
                  //     ),
                  //   ),
                  //









                  const SizedBox(height: 12),


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
                      const SizedBox(width: 12),
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
                  const SizedBox(height: 16),

                  // "Buy" button below the two



                  ElevatedButton.icon(
                    onPressed: () async {
                      if (steamUrl != null && Uri.tryParse(steamUrl!)?.hasAbsolutePath == true) {
                        final Uri uri = Uri.parse(steamUrl!);
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri, mode: LaunchMode.externalApplication);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Could not launch Steam URL')),
                          );
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Invalid or missing Steam URL')),
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
                      minimumSize: const Size.fromHeight(50),
                    ),
                  )







                ],
              ),
            ),
          ),
  );
}

}