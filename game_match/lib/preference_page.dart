// import 'package:flutter/material.dart';

// import 'ApiService.dart';

// import 'dart:convert';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:http/http.dart' as http;
// import 'main.dart';
// import 'preference_page.dart';
// import 'game_model.dart';

// /*
// * side bar navigation icon/button
// * preference page
// *
// * search bar
// * genre buttons
// * button action control (reset/save/view the rest of the genres that was selected)
// * */

// class PreferencePage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: GenrePreferencePage(),
//     );
//   }
// }

// class GenrePreferencePage extends StatefulWidget {
//   @override
//   _GenrePreferencePageState createState() => _GenrePreferencePageState();
// }

// class _GenrePreferencePageState extends State<GenrePreferencePage> {
//   List<String> genres = [
//     'Action', 'Casino', 'Adventure', 'Puzzle', 'Racing',
//     'Sports', 'Casual', 'Simulation', 'Horror', 'Platform', 'FPS',
//     'Fighting', 'Stealth', 'Rhythm'
//   ];

//   List<String> selectedGenres = [];
//   TextEditingController searchController = TextEditingController();

//   // keep track of genre buttons that was selected using a list and display all buttons that was selected in other page
//   void updateGenreSelection(String genre) {
//     setState(() {
//       if (selectedGenres.contains(genre)) {
//         selectedGenres.remove(genre);
//       } else {
//         selectedGenres.add(genre);
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Genre Preference Page')),
//       body: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: TextField(
//               controller: searchController,
//               decoration: InputDecoration(
//                 labelText: 'Search Video Game Genre',
//                 border: OutlineInputBorder(),
//                 prefixIcon: Icon(Icons.search),
//               ),
//               onSubmitted: (value) {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => SearchGenrePage(
//                       searchQuery: value,
//                       onGenreSelected: updateGenreSelection,
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//           Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Text('Scroll to view more genres. \nSearch for genres not displayed on the screen.',)
//           ),
//           Expanded(
//             child: GridView.builder(
//               padding: const EdgeInsets.all(10.0),
//               itemCount: genres.length,
//               gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                 crossAxisCount: 2,
//                 childAspectRatio: 3,
//                 crossAxisSpacing: 10,
//                 mainAxisSpacing: 10,
//               ),
//               itemBuilder: (context, index) {
//                 String genre = genres[index];
//                 return Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: ElevatedButton(
//                     onPressed: () => updateGenreSelection(genre),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: selectedGenres.contains(genre)
//                           ? Colors.blue
//                           : Colors.white60,
//                       minimumSize: Size(100, 40),
//                     ),
//                     child: Text(genre),
//                   ),
//                 );
//               },
//             ),
//           ),
//           Divider(
//             thickness: 2,
//             color: Colors.grey,
//           ),
//           Padding(
//             padding: const EdgeInsets.all(10.0),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 ElevatedButton(
//                   onPressed: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => MoreGenresPage(
//                           selectedGenres: selectedGenres,
//                           onGenresUnselected: updateGenreSelection,
//                         ),
//                       ),
//                     );
//                   }, 
//                   child: Text('More'),
//                   style: ElevatedButton.styleFrom(
//                     minimumSize: Size(150, 40),
//                   ),
//                 ),
//                 ElevatedButton(
//                   onPressed: () {
//                     setState(() {
//                       selectedGenres.clear();
//                     });
//                   },
//                   child: Text('Reset'),
//                   style: ElevatedButton.styleFrom(
//                     minimumSize: Size(150, 40),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }


// class SearchGenrePage extends StatelessWidget {
//   final String searchQuery;
//   final Function(String) onGenreSelected;

//   SearchGenrePage({required this.searchQuery, required this.onGenreSelected});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Search Genres')),
//       body: Center(
//         child: Column(
//           children: [
//             Text('Results for "$searchQuery"'),
//             ElevatedButton.icon(
//               onPressed: () {
//                 onGenreSelected(searchQuery);
//                 Navigator.pop(context);
//               },
//               icon: Icon(Icons.add),
//               label: Text(searchQuery),
//             )
//           ],


//         ),
//       ),
//     );
//   }
// }

// class MoreGenresPage extends StatelessWidget {
//   final List<String> selectedGenres;
//   final Function(String) onGenresUnselected;

//   MoreGenresPage({required this.selectedGenres, required this.onGenresUnselected});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('View All Selected Genres')),
//       body: ListView.builder(
//         itemCount: selectedGenres.length,
//         itemBuilder: (context, index) {
//           String genre = selectedGenres[index];
//           return ListTile(
//             title: Text(genre),
//             trailing: IconButton(
//               icon: Icon(Icons.remove_circle),
//               onPressed: () {
//                 onGenresUnselected(genre);
//                 ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(content: Text('Removing Genre'))
//                 );
//               },
//             ),
//           );
//         },
//       ),
//     );
//   }
// }