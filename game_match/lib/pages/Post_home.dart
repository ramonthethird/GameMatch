import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:game_match/pages/Side_bar.dart';
import 'package:url_launcher/url_launcher.dart'; // Import url_launcher for opening links
import 'api_service.dart'; // Import the ApiService
import 'game_model.dart'; // Import the Game model

class WelcomePage extends StatefulWidget {
  final String username;

  const WelcomePage({super.key, required this.username});

  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<Game> _searchResults = []; // List to store search results
  bool _isSearching = false;
  bool _hasSearched = false; // Indicates whether a search has been made

  @override
  void initState() {
    super.initState();
  }

  Future<String> getUserName() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      return userDoc['username'] ?? 'Unknown';
    }
    return 'Unknown';
  }
    // Method to launch URLs
  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }

  // Search function to query games by name
  Future<void> _searchGames(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _hasSearched = false; // Reset search state when query is empty
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _hasSearched = true; // Set search state to true when a query is entered
    });

    ApiService apiService = ApiService();
    try {
      final results = await apiService.searchGames(query);
      setState(() {
        _searchResults = results;
      });
    } catch (e) {
      debugPrint('Error fetching search results: $e');
      setState(() {
        _searchResults = [];
      });
    } finally {
      setState(() {
        _isSearching = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F3F4),
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text(
          'Welcome to Game Match!',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        leading: IconButton(
          alignment: Alignment.topLeft,
          icon: const Icon(Icons.menu),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        actions: [
          IconButton(
            alignment: Alignment.topRight,
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // Handle notification icon press
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search games...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (query) {
                _searchGames(query); // Trigger search on text change
              },
            ),
          ),
        ),
      ),
      drawer: Drawer(
        child: SideBar(
          onThemeChanged: (isDarkMode) {
            // Handle theme change here
          },
          isDarkMode: false,
        ),
      ),
      body: _isSearching
          ? const Center(
              child:
                  CircularProgressIndicator()) // Show loading indicator when searching
          : (_hasSearched && _searchResults.isEmpty)
              ? const Center(
                  child: Text(
                    'No games found for your search.',
                    style: TextStyle(fontSize: 18),
                  ),
                )
              : (_searchResults.isNotEmpty)
                  ? _buildSearchResults()
                  : _buildFeatureCards(context),
    );
  }

  // Method to display feature cards if no search results or no search is made
  Widget _buildFeatureCards(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 20),
          FutureBuilder<String>(
            future: getUserName(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return const Text(
                  'Error fetching username',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                );
              } else {
                final username = snapshot.data ?? 'Unknown';
                return Text(
                  'Welcome, $username!',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                );
              }
            },
          ),
          const SizedBox(height: 10),
          const Text(
            'Discover new games based on your preferences.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.black54,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          _buildFeatureCard(
            context,
            title: 'New Releases',
            description: 'Check out the latest games.',
            icon: Icons.star,
            routeName: '/New_Releases',
          ),
          _buildFeatureCard(
            context,
            title: 'Community trends',
            description: 'Updates from the gaming community.',
            icon: Icons.people,
            routeName: '/community_trends',
          ),
          _buildFeatureCard(
            context,
            title: 'Swiping games',
            description: 'Swipe right on games you like.',
            icon: Icons.favorite,
            routeName: '/swiping_games',
          ),
        ],
      ),
    );
  }

  // Method to build search results as a list
  Widget _buildSearchResults() {
    return ListView.builder(
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final game = _searchResults[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          elevation: 4,
          child: ListTile(
            leading: game.coverUrl != null
                ? Image.network(game.coverUrl!, width: 50, fit: BoxFit.cover)
                : const Icon(Icons.videogame_asset, size: 50),
            title: Text(game.name),
            subtitle: Text(
              game.summary != null ? game.summary! : 'No summary available',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            onTap: () {
              // Handle navigation to game details or link
              if (game.websiteUrl != null) {
                _launchURL(game.websiteUrl!);
              }
            },
          ),
        );
      },
    );
  }

  // Feature card widget
  Widget _buildFeatureCard(BuildContext context,
      {required String title,
      required String description,
      required IconData icon,
      required String routeName}) {
    return Card(
      margin: const EdgeInsets.all(10),
      elevation: 5,
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, routeName);
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(icon, size: 40, color: const Color(0xFF74ACD5)),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      description,
                      style: const TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
