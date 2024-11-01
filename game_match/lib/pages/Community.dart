// import 'package:flutter/material.dart';
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'ApiService.dart';
//
//
// void main() => runApp(const MyApp());
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return const MaterialApp(
//       home: MyHomePage(title: ''),
//     );
//   }
// }
//
// class MyHomePage extends StatefulWidget {
//   const MyHomePage({super.key, required this.title});
//
//   final String title;
//
//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }
//
// class _MyHomePageState extends State<MyHomePage> {
//   final ApiService apiService = ApiService();
//   String apexScreenshotUrl = '';
//   String cyberpunkScreenshotUrl = '';
//   String untilDawnScreenshotUrl = '';
//   String ghostOfTsushimaScreenshotUrl = '';
//   final String igdbImageBaseUrl = "https://images.igdb.com/igdb/image/upload/";
//
//
//   int _selectedIndex = 0;
//   static const TextStyle optionStyle =
//   TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
//
//
//
//   static const List<Widget> _widgetOptions = <Widget>[
//     Text(
//       '',
//       style: optionStyle,
//     ),
//     Text(
//       '',
//       style: optionStyle,
//     ),
//   ];
//
//   @override
//   void initState() {
//     super.initState();
//     loadScreenshots();
//   }
//
//   Future<void> loadScreenshots() async {
//     List<String> apexScreenshots = await apiService.fetchScreenshots('Apex Legends');
//     List<String> cyberpunkScreenshots = await apiService.fetchScreenshots('Cyberpunk 2077');
//     List<String> untilDawnScreenshots = await apiService.fetchScreenshots('Until Dawn');
//     List<String> ghostOfTsushimaScreenshots = await apiService.fetchScreenshots('Ghost of Tsushima');
//
//     setState(() {
//       apexScreenshotUrl = apexScreenshots.isNotEmpty
//           ? (apexScreenshots[0].startsWith('http') ? apexScreenshots[0] : igdbImageBaseUrl + apexScreenshots[0])
//           : '';
//       cyberpunkScreenshotUrl = cyberpunkScreenshots.isNotEmpty
//           ? (cyberpunkScreenshots[0].startsWith('http') ? cyberpunkScreenshots[0] : igdbImageBaseUrl + cyberpunkScreenshots[0])
//           : '';
//       untilDawnScreenshotUrl = untilDawnScreenshots.isNotEmpty
//           ? (untilDawnScreenshots[0].startsWith('http') ? untilDawnScreenshots[0] : igdbImageBaseUrl + untilDawnScreenshots[0])
//           : '';
//       ghostOfTsushimaScreenshotUrl = ghostOfTsushimaScreenshots.isNotEmpty
//           ? (ghostOfTsushimaScreenshots[0].startsWith('http') ? ghostOfTsushimaScreenshots[0] : igdbImageBaseUrl + ghostOfTsushimaScreenshots[0])
//           : '';
//     });
//   }
//
//   void _onItemTapped(int index) {
//     setState(() {
//       _selectedIndex = index;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.title),
//         leading: Builder(
//           builder: (context) {
//             return IconButton(
//               icon: const Icon(Icons.menu),
//               onPressed: () {
//                 Scaffold.of(context).openDrawer();
//               },
//             );
//           },
//         ),
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             Padding(
//               padding: const EdgeInsets.all(10.0),
//               child: Text('Community',
//                   style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
//             ),
//             Padding(
//               padding: const EdgeInsets.all(10.0),
//               child: TextField(
//                 decoration: InputDecoration(
//                   labelText: 'Search...',
//                   border: OutlineInputBorder(),
//                   prefixIcon: Icon(Icons.search),
//                 ),
//                 onSubmitted: (value) {
//                   print('Searching for: $value');
//                 },
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.all(10.0),
//               child: apexScreenshotUrl.isNotEmpty
//                   ? Image.network(apexScreenshotUrl)
//                   : CircularProgressIndicator(), // Loading indicator while fetching
//             ),
//             Padding(
//               padding: const EdgeInsets.all(10.0),
//               child: Text('Trending Games',
//                   style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
//             ),
//             Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: SingleChildScrollView(
//                 scrollDirection: Axis.horizontal,
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Column(
//                       children: [
//                         Container(
//                           width: 383,
//                           height: 215,
//                           child: Image.network(
//                             'https://i.guim.co.uk/img/media/b1cf1d39219150e9cc57ce23eed8a1fdd3855c17/60_0_1800_1080/master/1800.jpg?width=465&dpr=1&s=none&crop=none',
//                             fit: BoxFit.cover,
//                           ),
//                         ),
//                         SizedBox(height: 5), // Space between the image and the caption
//                         Text('Cyberpunk 2077'),
//                       ],
//                     ),
//                     SizedBox(width: 15),
//                     Column(
//                       children: [
//                         Container(
//                           width: 383,
//                           height: 215,
//                           child: Image.network(
//                             'https://image.api.playstation.com/vulcan/ap/rnd/202401/2910/3cb17e8780924be93de73d4b6b81e3309f69d24137c02d54.jpg',
//                             fit: BoxFit.cover,
//                           ),
//                         ),
//                         SizedBox(height: 5),
//                         Text('Until Dawn'),
//                       ],
//                     ),
//                     SizedBox(width: 15),
//                     Column(
//                       children: [
//                         Container(
//                           width: 383,
//                           height: 215,
//                           child: Image.network(
//                             'https://media.licdn.com/dms/image/D5612AQEnhLpRjbjREA/article-cover_image-shrink_720_1280/0/1706043456097?e=2147483647&v=beta&t=W2dbeO1-WRs6g4Ufv8vo5bIy5EryCnw--nUqg5SII60',
//                             fit: BoxFit.cover,
//                           ),
//                         ),
//                         SizedBox(height: 5),
//                         Text('Ghost of Tsushima'),
//                       ],
//                     ),
//                   ],
//
//                 ),
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.all(10.0),
//               child: Text('Most Recent Reviews \n (go to reviews page for games)',
//                   style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
//             ),
//
//             Padding(
//               padding: const EdgeInsets.all(10.0),
//               child: Container(
//                 width: double.infinity, // Make the container take up full width
//                 padding: EdgeInsets.all(10.0), // Padding inside the container
//                 decoration: BoxDecoration(
//                   color: Colors.grey[300], // Background color for the container
//                   borderRadius: BorderRadius.circular(12), // Rounded corners
//                   border: Border.all(color: Colors.black), // Optional: add a border
//                 ),
//                 child: Text(
//                   '@username \n game title: mario kart\n rate: 9/10 \n this game is rlly fun \n',
//                   style: TextStyle(fontSize: 16), // Optional: customize text style
//                 ),
//               ),
//             ),
//
//             Padding(
//               padding: const EdgeInsets.all(10.0),
//               child: Container(
//                 width: double.infinity, // Make the container take up full width
//                 padding: EdgeInsets.all(10.0), // Padding inside the container
//                 decoration: BoxDecoration(
//                   color: Colors.grey[300], // Background color for the container
//                   borderRadius: BorderRadius.circular(12), // Rounded corners
//                   border: Border.all(color: Colors.black), // Optional: add a border
//                 ),
//                 child: Text(
//                   '@username \n game title: cyberpunk 2077\n rate: 8/10 \n this game is rlly fun \n',
//                   style: TextStyle(fontSize: 16), // Optional: customize text style
//                 ),
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.all(10.0),
//               child: Container(
//                 width: double.infinity, // Make the container take up full width
//                 padding: EdgeInsets.all(10.0), // Padding inside the container
//                 decoration: BoxDecoration(
//                   color: Colors.grey[300], // Background color for the container
//                   borderRadius: BorderRadius.circular(12), // Rounded corners
//                   border: Border.all(color: Colors.black), // Optional: add a border
//                 ),
//                 child: Text(
//                   '@username \n game title: apex\n rate: 8/10 \n fast paced game! rlly fun!\n',
//                   style: TextStyle(fontSize: 16), // Optional: customize text style
//                 ),
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.all(10.0),
//               child: Container(
//                 width: double.infinity, // Make the container take up full width
//                 padding: EdgeInsets.all(10.0), // Padding inside the container
//                 decoration: BoxDecoration(
//                   color: Colors.grey[300], // Background color for the container
//                   borderRadius: BorderRadius.circular(12), // Rounded corners
//                   border: Border.all(color: Colors.black), // Optional: add a border
//                 ),
//                 child: Text(
//                   '@username \n game title: astro bot\n rate: 8/10 \n this game is rlly fun \n',
//                   style: TextStyle(fontSize: 16), // Optional: customize text style
//                 ),
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.all(10.0),
//               child: Container(
//                 width: double.infinity, // Make the container take up full width
//                 padding: EdgeInsets.all(10.0), // Padding inside the container
//                 decoration: BoxDecoration(
//                   color: Colors.grey[300], // Background color for the container
//                   borderRadius: BorderRadius.circular(12), // Rounded corners
//                   border: Border.all(color: Colors.black), // Optional: add a border
//                 ),
//                 child: Text(
//                   '@username \n game title: until dawn\n rate: 7/10 \n this game is ok \n',
//                   style: TextStyle(fontSize: 16), // Optional: customize text style
//                 ),
//               ),
//             ),
//
//             // Content for the selected index
//             Center(
//               child: _widgetOptions[_selectedIndex],
//             ),
//           ],
//         ),
//       ),
//       drawer: Drawer(
//         child: ListView(
//           padding: EdgeInsets.zero,
//           children: [
//             const DrawerHeader(
//               decoration: BoxDecoration(
//                 color: Colors.blue,
//               ),
//               child: Text('Drawer Header'),
//             ),
//             ListTile(
//               title: const Text('Home'),
//               selected: _selectedIndex == 0,
//               onTap: () {
//                 _onItemTapped(0);
//                 Navigator.pop(context);
//               },
//             ),
//             ListTile(
//               title: const Text('Business'),
//               selected: _selectedIndex == 1,
//               onTap: () {
//                 _onItemTapped(1);
//                 Navigator.pop(context);
//               },
//             ),
//             ListTile(
//               title: const Text('School'),
//               selected: _selectedIndex == 2,
//               onTap: () {
//                 _onItemTapped(2);
//                 Navigator.pop(context);
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'Api_Service.dart';
import 'game_model.dart';
import 'game_description.dart';
import 'Side_bar.dart';
// import 'FirestoreService.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Top Games App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: GameListScreen(),
    );
  }
}

class GameListScreen extends StatefulWidget {
  @override
  _GameListScreenState createState() => _GameListScreenState();
}

class _GameListScreenState extends State<GameListScreen> {
  final ApiService apiService = ApiService();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // final FirestoreService firestoreService = FirestoreService();
  Map<String, List<Map<String, dynamic>>> gameThreads = {};
  List<Game> games = [];
  bool isLoading = true;
  Map<String, dynamic>? gameDetails;

  @override
  void initState() {
    super.initState();
    // fetchTopGames();
    fetchTrendingGames();
    // fetchGameInfo();
  }

  Future<void> fetchTrendingGames() async {
    try {
      final fetchedGames = await apiService.fetchPopularGames();
      setState(() {
        games = fetchedGames;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching games: $e');
    }
  }

  // Future<void> fetchThreeLatestThreads(int gameId) async {
  //   try {
  //     List<QueryDocumentSnapshot> threadDocs =
  //     await firestoreService.getThreeLatestThreads(gameId.toString());
  //     List<Map<String, dynamic>> threads = threadDocs
  //         .map((doc) => doc.data() as Map<String, dynamic>)
  //         .toList();
  //     setState(() {
  //       gameThreads[gameId.toString()] = threads; // Store the threads by gameId
  //     });
  //   } catch (e) {
  //     print('Error fetching threads: $e');
  //   }
  // }

  // Future<void> fetchTopGames() async {
  //   try {
  //     final fetchedGames = await apiService.fetchPopularGames();
  //     setState(() {
  //       // Filter out games without a cover image
  //       games = fetchedGames.where((game) => game.coverUrl != null).toList();
  //       isLoading = false;
  //     });
  //   } catch (e) {
  //     print('Error fetching games: $e');
  //   }
  // }

  // Future<void> fetchGameInfo() async {
  //   final details = await apiService.fetchGameInfo(widget.game.gameId!);
  //   setState(() {
  //     gameDetails = details;
  //     isLoading = false;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey, // Key for the scaffold
      appBar: AppBar(
        title: Text('Community'),
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.black), // Sidebar Icon
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
      ),
      drawer: Drawer(
        child: SideBar(
          onThemeChanged: (isDarkMode) {
            // Handle theme change here
          },
          isDarkMode: false, // Replace with actual theme state if implemented
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: TextField(
                decoration: InputDecoration(
                  labelText: 'Search...',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.search),
                ),
                onSubmitted: (value) {
                  print('Searching for: $value');
                },
              ),
            ),

            // Trending games title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Text(
                'Trending Games',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),

            SizedBox(height: 5), // Adjust spacing between Trending Games and rectangles

            // Games horizontal list
            isLoading
                ? Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: games.map((game) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GameDescriptionPage(game: game),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10.0), // Rounded corners
                        child: Container(
                          width: 150,  // Set width for the rounded rectangle
                          height: 200, // Set height for the rounded rectangle
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0), // Rounded corners
                            color: Colors.grey[300],
                          ),
                          child: Column(
                            children: [
                              // Cover Image takes most of the space
                              Expanded(
                                flex: 3,
                                child: game.coverUrl != null
                                    ? Image.network(
                                  game.coverUrl!,
                                  width: 150, // Match the container width
                                  height: 150, // Fill the top part
                                  fit: BoxFit.cover, // Make sure the image fits the container
                                )
                                    : Container(
                                  width: 150,
                                  height: 150,
                                  color: Colors.grey[400],
                                  child: Icon(Icons.videogame_asset, size: 50),
                                ),
                              ),
                              // Game Name in the bottom part
                              Expanded(
                                flex: 1,
                                child: Container(
                                  width: double.infinity,
                                  color: Colors.black.withOpacity(0.7),
                                  alignment: Alignment.center,
                                  child: Text(
                                    game.name,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            // Recent Threads Section
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                'Recent Threads',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),

            // Example thread rectangles
            buildThreadContainer('Thread #1 \n\n'),
            buildThreadContainer('Thread #2 \n\n'),
            buildThreadContainer('Thread #3 \n\n'),
            buildThreadContainer('Thread #4 \n\n'),
            buildThreadContainer('Thread #5 \n\n'),

          ],
        ),
      ),
    );
  }

  Widget buildThreadContainer(String threadName) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black),
        ),
        child: Text(
          threadName,
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }


}