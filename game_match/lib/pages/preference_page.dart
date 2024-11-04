import 'package:flutter/material.dart';
import 'api_service.dart'; // Ensure the correct path is used here
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'side_bar.dart';


// class PreferencePage extends StatelessWidget {
//   const PreferencePage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: GenrePreferencePage(),
//       title: 'Preference Page',
//     );
//   }
// }

class MoreGenresPage extends StatelessWidget {
  final List<String> selectedGenres;
  final Function(String) onGenresUnselected;

  MoreGenresPage({required this.selectedGenres, required this.onGenresUnselected});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('View All Selected Genres')),
      body: ListView.builder(
        itemCount: selectedGenres.length,
        itemBuilder: (context, index) {
          String genre = selectedGenres[index];
          return ListTile(
            title: Text(genre),
            trailing: IconButton(
              icon: Icon(Icons.remove_circle),
              onPressed: () {
                onGenresUnselected(genre);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Removing Genre')),
                );
              },
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
  @override
  _GenrePreferencePageState createState() => _GenrePreferencePageState();
}

class _GenrePreferencePageState extends State<GenrePreferencePage> {
  List<String> genres = [
    'Pinball', 'Adventure', 'Indie', 'Arcade', 'Visual Novel', 'Card Game', 'MOBA', 
    'Point-and-click', 'Fighting', 'Shooter', 'Music', 'Platform', 'Puzzle', 
    'Racing', 'RTS', 'RPG', 'Simulator', 'Sport', 'Strategy', 'TBS', 'Tactical', 
    'Hack & slash', 'Quiz/Trivia'
  ];

  List<String> selectedGenres = [];
  FirestoreService firestoreService = FirestoreService();
  String? userId;
  TextEditingController searchController = TextEditingController();
  ApiService _apiService = ApiService();

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Genre Preference Page'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pushNamed(context, "/Preference_&_Interest");
          },
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Search Video Game Genre',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onSubmitted: (value) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SearchGenrePage(
                      searchQuery: value,
                      onGenreSelected: updateGenreSelection,
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Text('Scroll to view more genres. \nSearch for genres not displayed on the screen'),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(10.0),
              itemCount: genres.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, 
                childAspectRatio: 3, 
                crossAxisSpacing: 10, 
                mainAxisSpacing: 10
              ),
              itemBuilder: (context, index) {
                String genre = genres[index];
                return Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: ElevatedButton(
                    onPressed: () => updateGenreSelection(genre),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: selectedGenres.contains(genre) ? Colors.blue : Colors.white60,
                      minimumSize: Size(100, 40),
                    ),
                    child: Text(genre),
                  ),
                );
              },
            ),
          ),
          Divider(
            thickness: 2,
            color: Colors.grey,
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
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
                  child: Text('View More'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(150, 40),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      selectedGenres.clear();
                    });
                    firestoreService.saveGenresToFirestore(userId!, selectedGenres);
                  },
                  child: Text('Reset'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(150, 40),
                  ),
                ),
              ],
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

  SearchGenrePage({required this.searchQuery, required this.onGenreSelected});

  @override
  _SearchGenrePageState createState() => _SearchGenrePageState();
}

class _SearchGenrePageState extends State<SearchGenrePage> {
  final ApiService _apiService = ApiService();
  String _errorMsg = '';
  String _searchResult = '';

  @override
  void initState() {
    super.initState();
    _fetchGenres(widget.searchQuery);
  }

  Future<void> _fetchGenres(String genreName) async {
    try {
      bool exists = await _apiService.checkGenreExists(genreName);
      setState(() {
        _searchResult = exists ? 'Genre found' : 'Cannot find genre name: "$genreName"';
      });
    } catch (e) {
      setState(() {
        _errorMsg = 'An error occurred trying to find the genre: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Search Genres')),
      body: Center(
        child: Column(
          children: [
            if (_errorMsg.isNotEmpty)
              Text(_errorMsg, style: TextStyle(color: Colors.red))
            else
              Text(_searchResult),
            if (_searchResult.contains('Genre found'))
              ElevatedButton.icon(
                onPressed: () {
                  widget.onGenreSelected(widget.searchQuery);
                  Navigator.pop(context);
                },
                icon: Icon(Icons.add),
                label: Text(widget.searchQuery),
              )
          ],
        ),
      ),
    );
  }
}