import 'package:flutter/material.dart';
import 'api_service.dart'; // Ensure the correct path is used here
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:game_match/theme_notifier.dart';
import 'package:provider/provider.dart';

class MoreGenresPage extends StatefulWidget {
  final List<String> selectedGenres;
  final Function(String) onGenresUnselected;

  const MoreGenresPage({super.key, required this.selectedGenres, required this.onGenresUnselected});

  @override
  _MoreGenresPageState createState() => _MoreGenresPageState();
}

class _MoreGenresPageState extends State<MoreGenresPage> {
  late List<String> genres;

  @override
  void initState() {
    super.initState();
    // Initialize local list of genres from the parent
    genres = List.from(widget.selectedGenres);
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black,),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('Selected Genres', style: TextStyle(fontSize: 16, color: Colors.black)),
        centerTitle: true,
        backgroundColor: const Color(0xFF41B1F1),
        elevation: 0,
      ),
      body: ListView.builder(
        itemCount: genres.length,
        itemBuilder: (context, index) {
          String genre = genres[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            color: Theme.of(context).cardColor,
            child: ListTile(
              title: Text(
                genre,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.remove_circle, color: Colors.redAccent),
                onPressed: () {
                  setState(() {
                    genres.remove(genre); // Update the local list
                  });
                  widget.onGenresUnselected(genre);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Removed \'$genre\' genre'),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> saveGenresToFirestore(String userId, List<String> genres) async {
    try {
      await _db.collection('users').doc(userId).set({
        'selectedGenres': genres,
        'timestamp': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      print('Genres saved successfully');
    } catch (error) {
      print('Failed to save genres: $error');
    }
  }

  Future<List<String>> fetchGenresFromFirestore(String userId) async {
    try {
      DocumentSnapshot snapshot = await _db.collection('users').doc(userId).get();
      if (snapshot.exists) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        return List<String>.from(data['selectedGenres'] ?? []);
      } else {
        return [];
      }
    } catch (error) {
      print('Failed to fetch genres: $error');
      return [];
    }
  }
}

// Main screen for the preference page
class GenrePreferencePage extends StatefulWidget {
  const GenrePreferencePage({super.key});

  @override
  _GenrePreferencePageState createState() => _GenrePreferencePageState();
}

class _GenrePreferencePageState extends State<GenrePreferencePage> {
  List<String> genres_stored = [
      'Pinball', 'Adventure', 'Indie', 'Arcade', 'Visual Novel', 'Card Game', 'MOBA',
      'Point-and-click', 'Fighting', 'Shooter', 'Music', 'Platform', 'Puzzle',
      'Racing', 'RTS', 'RPG', 'Simulator', 'Sport', 'Strategy', 'TBS', 'Tactical',
      'Hack & slash', 'Quiz/Trivia', 'Board Game', 'Turn-based', 'Fantasy',
      'Battle Royale', 'Metroidvania', 'Survival Horror', 'Soulslike', 'Open World',
      'MMORPG', 'Stealth', 'Survival', 'Tower Defense', 'Sandbox', 'Roguelike',
      'Idle/Incremental', 'Rhythm', 'Party Games', 'Tycoon', 'Educational',
      'Walking Simulator', 'City Builder', 'Escape Room', 'Vehicular Combat',
      'Auto Chess', 'Deckbuilder', 'Asymmetric Multiplayer', 'VR Games',
      'ARG', 'Dating Simulators'
    ];
  List<String> genres = [
    'Adventure', 'Shooter', 'Arcade', 'Platform', 'Puzzle', 'Racing', 'Sport', 'Fighting', 'Simulator', 'Music'
  ];

  List<String> selectedGenres = [];
  FirestoreService firestoreService = FirestoreService();
  String? userId;
  TextEditingController searchController = TextEditingController();
  List<String> searchResults = []; // List to hold search results
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _fetchUserIdAndGenres();
  }

  Future<void> _fetchUserIdAndGenres() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      setState(() {
        userId = user.uid;
      });
      List<String> fetchedGenres = await firestoreService.fetchGenresFromFirestore(user.uid);
      setState(() {
        selectedGenres = fetchedGenres;
      });
    } else {
      print('No user is currently signed in');
    }
  }

  void updateGenreSelection(String genre) {
    if (userId != null) {
      setState(() {
        if (selectedGenres.contains(genre)) {
          selectedGenres.remove(genre);
        } else {
          selectedGenres.add(genre);
        }
        firestoreService.saveGenresToFirestore(userId!, selectedGenres);
      });
    }
  }

  void removeGenreSelection(String genre) {
    if (userId != null) {
      setState(() {
        selectedGenres.remove(genre);
      });
      firestoreService.saveGenresToFirestore(userId!, selectedGenres);
    }
  }

  void addGenreSelection(String genre) {
    if (userId != null) {
      setState(() {
        if (!selectedGenres.contains(genre)) {
          selectedGenres.add(genre); // Add the genre
        }
      });
      firestoreService.saveGenresToFirestore(userId!, selectedGenres); // Sync with Firestore
    }
  }
  
  void searchGenres(String query) {
    setState(() {
      searchResults = genres_stored
          .where((genre) => genre.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final isDarkMode = themeNotifier.isDarkMode;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black,),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('Genre Preference',style: TextStyle(fontSize: 16, color: Colors.black)),
        centerTitle: true,
        backgroundColor: const Color(0xFF41B1F1),
        elevation: 0,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      labelText: 'Search Genre',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                      prefixIcon: const Icon(Icons.search, color: Colors.black),
                      fillColor: Theme.of(context).cardColor,
                      filled: true,
                    ),
                    onChanged: (value) {
                      searchGenres(value);
                    },
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Text(
                    'Explore genres or search for more!',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                // Wrap GridView with SizedBox to control its height
                SizedBox(
                  height: 450,
                  child: GridView.builder(
                    padding: const EdgeInsets.all(10.0),
                    itemCount: genres.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, childAspectRatio: 3, crossAxisSpacing: 10, mainAxisSpacing: 10),
                    itemBuilder: (context, index) {
                      String genre = genres[index];
                      bool isSelected = selectedGenres.contains(genre);
                      return ElevatedButton(
                        onPressed: () {
                          if (isSelected) {
                            removeGenreSelection(genre);
                          }
                          else {
                            addGenreSelection(genre);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: selectedGenres.contains(genre)
                              ? const Color(0xFF41B1F1)
                              : Theme.of(context).cardColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        ),
                        child: Text(
                          genre,
                          style: TextStyle(
                            color: isDarkMode ? Colors.white : Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MoreGenresPage(
                                selectedGenres: selectedGenres,
                                onGenresUnselected: (genre) {
                                  removeGenreSelection(genre); // Update the parent state
                                },
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF41B1F1),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        ),
                        child: const Text('Selected Genres'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            selectedGenres.clear();
                          });
                          firestoreService.saveGenresToFirestore(userId!, selectedGenres);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).cardColor,
                          foregroundColor: const Color(0xFF41B1F1),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        ),
                        child: const Text('Reset'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Search results overlay
          if (searchController.text.isNotEmpty && searchResults.isNotEmpty)
            Positioned(
              top: 80, // Adjust the position as needed
              left: 20,
              right: 20,
              child: Container(
                height: 300, // Adjust the height as needed
                color: Colors.white,
                child: ListView.builder(
                  itemCount: searchResults.length,
                  itemBuilder: (context, index) {
                    String genre = searchResults[index];
                    return ListTile(
                      title: Text(genre),
                      onTap: () {
                        updateGenreSelection(genre);
                        setState(() {
                          searchController.clear();
                          searchResults.clear();
                        });
                      },
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// Updated SearchGenrePage to use the correct ApiService method
class SearchGenrePage extends StatefulWidget {
  final String searchQuery;
  final Function(String) onGenreSelected;

  const SearchGenrePage({super.key, required this.searchQuery, required this.onGenreSelected});

  @override
  _SearchGenrePageState createState() => _SearchGenrePageState();
}

class _SearchGenrePageState extends State<SearchGenrePage> {
  late List<String> genres_stored;

  @override
  void initState() {
    super.initState();
    genres_stored = [
          'Pinball', 'Adventure', 'Indie', 'Arcade', 'Visual Novel', 'Card Game', 'MOBA',
          'Point-and-click', 'Fighting', 'Shooter', 'Music', 'Platform', 'Puzzle',
          'Racing', 'RTS', 'RPG', 'Simulator', 'Sport', 'Strategy', 'TBS', 'Tactical',
          'Hack & slash', 'Quiz/Trivia', 'Board Game', 'Turn-based', 'Fantasy',
          'Battle Royale', 'Metroidvania', 'Survival Horror', 'Soulslike', 'Open World',
          'MMORPG', 'Stealth', 'Survival', 'Tower Defense', 'Sandbox', 'Roguelike',
          'Idle/Incremental', 'Rhythm', 'Party Games', 'Tycoon', 'Educational',
          'Walking Simulator', 'City Builder', 'Escape Room', 'Vehicular Combat',
          'Auto Chess', 'Deckbuilder', 'Asymmetric Multiplayer', 'VR Games',
          'ARG', 'Dating Simulators'
        ];
  }
  @override
  Widget build(BuildContext context) {
    final filteredGenres = genres_stored.where((genre) {
      return genre.toLowerCase().contains(widget.searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
    resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('Genre Search', style: TextStyle(fontSize: 16, color: Colors.black)),
        centerTitle: true,
        backgroundColor: const Color(0xFF41B1F1),
        elevation: 0,
      ),
      body: ListView.builder(
        itemCount: filteredGenres.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(filteredGenres[index]),
            onTap: () {
              widget.onGenreSelected(filteredGenres[index]);
              Navigator.pop(context);
            },
          );
        },
      ),
    );
  }
}