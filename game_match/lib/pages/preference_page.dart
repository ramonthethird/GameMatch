import 'package:flutter/material.dart';
import 'ApiService.dart';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'main.dart';
import 'preference_page.dart';
import 'game_model.dart';
import 'genre_model.dart';
import 'side_bar.dart';


/*
(side bar) (title- preference page)

(search bar)
(genre buttons)
(editing buttons)
*/

/*
main screen -> search bar -> add genre
main screen -> 'more' button -> view all genres
main screen -> 'reset' button -> unselect all buttons
*/

class PreferencePage extends StatelessWidget {
  const PreferencePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home:GenrePreferencePage(),
      title: 'Preference Page',
    );
  }
}

// main screen for the prefernce page
class GenrePreferencePage extends StatefulWidget {
  @override
  _GenrePreferencePageState createState() => _GenrePreferencePageState();
}

// main screen for the prefernce page
// button is similar to checkbox where multiple buttons can be selected
class _GenrePreferencePageState extends State<GenrePreferencePage> {
  // used for genre buttons
  List<String> genres = ['Pinball', 'Adventure', 'Indie', 'Arcade', 'Visual Novel', 'Card Game', 'MOBA', 'Point-and-click', 'Fighting', 'Shooter', 'Music', 'Platform', 'Puzzle', 'Racing', 'RTS', 'RPG', 'Simulator', 'Sport', 'Strategy', 'TBS', 'Tactical', 'Hack & slash', 'Quiz/Trivia'];

  // keeps track of genres the user selected
  List<String> selectedGenres = [];

  // for search bar at top of the screen
  TextEditingController searchController = TextEditingController();

  // edits the genre selction when user clicks/unclicks buttons
  void updateGenreSelection(String genre) {
    setState(() {
      if (selectedGenres.contains(genre)) {
        selectedGenres.remove(genre);
      }
      else {
        selectedGenres.add(genre);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Genre Preference Page'),
          leading: IconButton(
            icon: const Icon(Icons.menu, color: Colors.black),
            onPressed: () {
              Navigator.pushNamed(context, '/side_bar');
            },
          ),
        ),


        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0), // indent in each direction by 10 pixels
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  labelText: 'Search Video Game Genre',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.search),
                ),

                // goes to the search genre page
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

            // keep instructions as text as is or change it to dialog alert box
            Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text('Scroll to view more genres. \nSearch for genres not displayed on the screen')
            ),

            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(10.0),
                itemCount: genres.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 3, crossAxisSpacing: 10, mainAxisSpacing: 10), // adjusts the stucture of the buttons
                itemBuilder: (context, index) {
                  String genre = genres[index];
                  return Padding(
                    padding: const EdgeInsets.all(10.0),
                    // button is intially white but turns to blue when selected
                    child: ElevatedButton(onPressed: () => updateGenreSelection(genre), style: ElevatedButton.styleFrom(
                      backgroundColor: selectedGenres.contains(genre)
                          ? Colors.blue
                          : Colors.white60,
                      minimumSize: Size(100, 40),
                    ),
                      child: Text(genre),
                    ),
                  );
                },
              ),
            ),

            // differentiate genre buttons and view/reset buttons
            Divider(
              thickness: 2,
              color: Colors.grey,
            ),

            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [

                  // view more button
                  // list view of buttons for better readability
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

                  // unselects all the genre buttons
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        selectedGenres.clear();
                      });
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
        )
    );
  }
}


// for the search bar / search page to look up specific genre names
class SearchPage extends StatelessWidget {
  final String searchQuery;
  final Function(String) onGenreSelected;

  SearchPage({required this.searchQuery, required this.onGenreSelected});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Search Video Game Genres')),
      body: Center(
        child: Column(
          children: [
            Text('Results for "$searchQuery'),
            ElevatedButton.icon(
              onPressed: () {
                onGenreSelected(searchQuery);
              },
              icon: Icon(Icons.add),
              label: Text(searchQuery),
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

  SearchGenrePage({required this.searchQuery, required this.onGenreSelected});

  @override
  _SearchGenrePageState createState() => _SearchGenrePageState();
}

// helps with search function and utilizes api here to check if it exists
class _SearchGenrePageState extends State<SearchGenrePage> {
  final ApiService _apiService = ApiService();
  String _errorMsg = '';
  String _searchResult = '';
  final String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchGenres(widget.searchQuery);
  }

  // retrieves info from api service from the other file
  Future<void> _fetchGenres(String genre_name) async {
    try {
      bool answer = await _apiService.checkGenreExists(genre_name);
      setState(() {
        // if genre is found, it would help show the button to include that genre into the list of genres
        if (answer == true) {
          _searchResult = 'Genre found';
        }
        else {
          _searchResult = 'Cannot find genre name: "$genre_name"';
        }
      });
    }
    catch (e) {
      _errorMsg = 'an error occured trying to find the genre: $_errorMsg';
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
                  Text(_errorMsg, style: TextStyle(color: Colors.red),)
                else
                  Text(_searchResult),

                // if the specific genre is found, it would show as a button here
                if(_searchResult.contains('Genre found'))
                  ElevatedButton.icon(
                    onPressed: () {
                      widget.onGenreSelected(widget.searchQuery);
                      Navigator.pop(context);
                    },
                    icon: Icon(Icons.add),
                    label: Text(widget.searchQuery),
                  )
              ],
            )
        )
    );
  }
}

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
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Removing Genre')));
                },
              )
          );
        },
      ),
    );
  }

}
