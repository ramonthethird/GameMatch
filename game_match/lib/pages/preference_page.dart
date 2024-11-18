import 'package:flutter/material.dart';
import 'api_service.dart'; // Ensure the correct path is used here
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'side_bar.dart';

class MoreGenresPage extends StatelessWidget {
  final List<String> selectedGenres;
  final Function(String) onGenresUnselected;

  const MoreGenresPage({super.key, required this.selectedGenres, required this.onGenresUnselected});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Selected Genres', style: TextStyle(fontSize: 18)),
        backgroundColor: const Color(0xFF41B1F1),
        elevation: 0,
      ),
      body: ListView.builder(
        itemCount: selectedGenres.length,
        itemBuilder: (context, index) {
          String genre = selectedGenres[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            color: const Color(0xFFF1F3F4),
            child: ListTile(
              title: Text(
                genre,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.remove_circle, color: Colors.redAccent),
                onPressed: () {
                  onGenresUnselected(genre);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Removing Genre')),
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
    'Hack & slash', 'Quiz/Trivia', 'Board Game', 'Turn-based'
  ];
  List<String> genres = [
    'Adventure', 'Shooter', 'RPG', 'Platform', 'Puzzle', 'Racing', 'Sport', 'Fighting', 'Simulator', 'Music'
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

  void searchGenres(String query) {
    setState(() {
      searchResults = genres_stored
          .where((genre) => genre.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Genre Preference'),
        backgroundColor: const Color(0xFF41B1F1),
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFF1F3F4),
              Color(0xFFF1F3F4)
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  labelText: 'Search Genre',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                  prefixIcon: const Icon(Icons.search, color: Colors.black),
                  fillColor: Colors.white.withOpacity(0.8),
                  filled: true,
                ),
                onChanged: (value) {
                  searchGenres(value);
                },
              ),
            ),
            // Display search results only when searchResults is not empty
            if (searchController.text.isNotEmpty && searchResults.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListView.builder(
                  shrinkWrap: true,
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
            const Padding(
              padding: EdgeInsets.all(10.0),
              child: Text(
                'Explore genres or search for more!',
                style: TextStyle(color: Colors.black, fontSize: 16),
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(10.0),
                itemCount: genres.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, childAspectRatio: 3, crossAxisSpacing: 10, mainAxisSpacing: 10),
                itemBuilder: (context, index) {
                  String genre = genres[index];
                  return ElevatedButton(
                    onPressed: () => updateGenreSelection(genre),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: selectedGenres.contains(genre)
                          ? const Color(0xFF41B1F1)
                          : Colors.white.withOpacity(0.8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    child: Text(
                      genre,
                      style: TextStyle(
                        color: selectedGenres.contains(genre) ? Colors.white : Colors.black,
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
                            onGenresUnselected: updateGenreSelection,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF1F3F4),
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
                      backgroundColor: const Color(0xFFF1F3F4),
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
    );
  }
}

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
      'Hack & slash', 'Quiz/Trivia', 'Board Game', 'Turn-based'
    ];
  }

  @override
  Widget build(BuildContext context) {
    final filteredGenres = genres_stored.where((genre) {
      return genre.toLowerCase().contains(widget.searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Genre Search'),
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
