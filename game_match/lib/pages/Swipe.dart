import 'package:flutter/material.dart';
import 'package:game_match/pages/game_info.dart';
import 'api_service.dart';
import 'game_model.dart';
import 'package:game_match/firestore_service.dart';
import 'dart:async';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SwipePage extends StatefulWidget {
  const SwipePage({Key? key}) : super(key: key);

  @override
  _SwipePageState createState() => _SwipePageState();
}

class _SwipePageState extends State<SwipePage> with TickerProviderStateMixin {
  final ApiService apiService = ApiService();
  final FirestoreService _firestoreService = FirestoreService();
  StreamSubscription? _firestoreSubscription;
  List<Game> games = [];
  List<Game> swipedGames = [];
  Game? selectedGame;
  Offset _swipeOffset = Offset.zero;
  double _rotationAngle = 0.0;
  double _opacity = 1.0;
  int _currentIndex = 0;
  int _swipeCount = 0; // track the number of swipes
  final int _swipeThreshold = 3; // number of swipes to trigger an ad

  AnimationController? _heartAnimationController;
  AnimationController? _heartbrokenAnimationController;
  Animation<double>? _heartFadeAnimation;
  Animation<double>? _heartScaleAnimation;
  Animation<double>? _heartbrokenFadeAnimation;
  Animation<double>? _heartbrokenScaleAnimation;
  bool _showHeart = false;
  bool _showHeartbroken = false;
  bool _showSwipeInstruction = true;
  AnimationController? _instructionFadeController;
  Animation<double>? _instructionFadeAnimation;
  AnimationController? _instructionAnimationController;
  Animation<Offset>? _instructionWagAnimation;

  @override
  void initState() {
    super.initState();
    _fetchGames();

    _heartAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _heartFadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
          parent: _heartAnimationController!,
          curve: const Interval(0.5, 1.0, curve: Curves.easeOut)),
    );
    _heartScaleAnimation = Tween<double>(begin: 0.0, end: 1.2).animate(
      CurvedAnimation(
          parent: _heartAnimationController!,
          curve: const Interval(0.0, 0.5, curve: Curves.easeOutBack)),
    );
    _heartbrokenAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _heartbrokenFadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
          parent: _heartbrokenAnimationController!,
          curve: const Interval(0.5, 1.0, curve: Curves.easeOut)),
    );
    _heartbrokenScaleAnimation = Tween<double>(begin: 0.0, end: 1.2).animate(
      CurvedAnimation(
          parent: _heartbrokenAnimationController!,
          curve: const Interval(0.0, 0.5, curve: Curves.easeOutBack)),
    );

    _instructionFadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _instructionFadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
          parent: _instructionFadeController!, curve: Curves.easeOut),
    );

    _instructionAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _instructionWagAnimation = Tween<Offset>(
      begin: const Offset(-0.05, 0.0),
      end: const Offset(0.05, 0.0),
    ).animate(CurvedAnimation(
      parent: _instructionAnimationController!,
      curve: Curves.easeInOut,
    ));
  }

  void _showCustomAd() {
    if (!mounted) return;

    // Push the ad page on top of the current page without replacing it
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ModalRoute.of(context)?.isCurrent ?? false) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CustomAdPage()),
        ).then((_) {
          if (mounted) {
            setState(() {
              _swipeCount = 0; // Reset swipe count after ad
            });
          }
        });
      }
    });
  }

  Future<void> _fetchGames() async {
    try {
      // Try to load games from Firestore first
      List<Game> firestoreGames = await _firestoreService.loadGames();

      if (firestoreGames.isNotEmpty) {
        setState(() {
          games = firestoreGames;
          selectedGame = games[0];
        });
        print('Games loaded from Firestore');
      } else {
        // If Firestore is empty, fetch games from the API
        print('No games in Firestore, fetching from API...');
        List<Game> fetchedGames = await apiService.fetchGames();

        if (fetchedGames.isNotEmpty) {
          await _fetchPricesForGames(fetchedGames);

          setState(() {
            games = fetchedGames;
            selectedGame = games[0];
          });

          // Save the fetched games to Firestore for caching
          await _firestoreService.saveGames(fetchedGames);
          print('Games saved to Firestore');
        }
      }

      if (selectedGame == null) {
        print('No game found');
      }
    } catch (e) {
      print('Error fetching games: $e');
    }
  }

  Future<void> _fetchPricesForGames(List<Game> fetchedGames) async {
    try {
      await apiService.fetchPricesForIGDBGames(fetchedGames);
      fetchedGames
          .removeWhere((game) => game.price == null || game.price! <= 0);
      setState(() {
        games = fetchedGames;
      });
    } catch (e) {
      print('Error fetching game prices: $e');
    }
  }

  void _fadeOutInstruction() {
    if (_showSwipeInstruction) {
      _instructionFadeController!.forward().then((_) {
        setState(() {
          _showSwipeInstruction = false;
        });
      });
    }
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_showSwipeInstruction) {
      setState(() {
        _showSwipeInstruction = false;
      });
    }
    setState(() {
      _swipeOffset += details.delta;
      _rotationAngle = _swipeOffset.dx / 300;
      _opacity =
          1 - (_swipeOffset.dx.abs() / MediaQuery.of(context).size.width);
    });
  }

  @override
  void dispose() {
    _instructionFadeController?.dispose();
    _instructionAnimationController?.dispose();
    _heartAnimationController?.dispose();
    _heartbrokenAnimationController?.dispose();
    _firestoreSubscription?.cancel();
    super.dispose();
  }

  void _onPanEnd(DragEndDetails details) {
    if (_swipeOffset.dx > 150 || _swipeOffset.dx < -150) {
      _animateCardOffScreen();
    } else {
      setState(() {
        _swipeOffset = Offset.zero;
        _rotationAngle = 0.0;
        _opacity = 1.0;
      });
    }
  }

  void _animateCardOffScreen() {
    double endX = _swipeOffset.dx > 0
        ? MediaQuery.of(context).size.width
        : -MediaQuery.of(context).size.width;

    double endY = _swipeOffset.dy;

    setState(() {
      _swipeOffset = Offset(endX, endY);
      _opacity = 0.0;
    });

    Future.delayed(const Duration(milliseconds: 300), () {
      if (_swipeOffset.dx > 0) {
        _onLike();
      } else {
        _onDislike();
      }
    });
  }

  void _onLike() async {
    if (games.isNotEmpty) {
      setState(() {
        _showHeart = true;
      });
      _heartAnimationController!.forward().then((_) async {
        try {
          await _firestoreService.addToWishlist(games[_currentIndex]);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${games[_currentIndex].name} added to wishlist!'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Failed to add game to wishlist. Try again.'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 2),
            ),
          );
        }

        Future.delayed(const Duration(milliseconds: 200), () {
          _heartAnimationController!.reverse();
          setState(() {
            _showHeart = false;
          });
          _onGameSwiped(0);
        });
      });
    }
  }

  void _onDislike() {
    if (games.isNotEmpty) {
      setState(() {
        _showHeartbroken = true;
      });
      _heartbrokenAnimationController!.forward().then((_) {
        Future.delayed(const Duration(milliseconds: 200), () {
          _heartbrokenAnimationController!.reverse();
          setState(() {
            _showHeartbroken = false;
          });
          _onGameSwiped(0);
        });
      });
    }
  }

  void _onUndo() async {
    if (swipedGames.isNotEmpty) {
      Game lastSwipedGame = swipedGames.last;

      try {
        await _firestoreService.removeFromWishlist(lastSwipedGame.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Action has been reverted.'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 2),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to revert action.'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }

      setState(() {
        games.insert(_currentIndex, swipedGames.removeLast());
        _swipeOffset = Offset.zero;
        _rotationAngle = 0.0;
        _opacity = 1.0;
      });
    }
  }

  void _onGameSwiped(int index) {
    if (games.isNotEmpty) {
      setState(() {
        swipedGames.add(games[index]);
        games.removeAt(index);
        _swipeOffset = Offset.zero;
        _rotationAngle = 0.0;
        _opacity = 1.0;

        // increment swipe count and check it custom ad should be shown
        _swipeCount++;
        if (_swipeCount >= _swipeThreshold) {
          if (ModalRoute.of(context)?.isCurrent ?? false) {
            _showCustomAd();
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (games.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Swipe Games'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100.0),
        child: AppBar(
          centerTitle: true,
          leading: const Icon(Icons.menu),
          title: Image.asset(
            'assets/images/gamematchlogoresize.png',
            height: 50,
            width: 50,
          ),
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                flex: 4,
                child: Stack(
                  children:
                      games.asMap().entries.toList().reversed.map((entry) {
                    int index = entry.key;
                    Game game = entry.value;

                    if (index < _currentIndex) return const SizedBox.shrink();

                    return Positioned.fill(
                      child: GestureDetector(
                        onPanUpdate: _onPanUpdate,
                        onPanEnd: _onPanEnd,
                        child: Opacity(
                          opacity: index == _currentIndex ? _opacity : 1.0,
                          child: Transform.translate(
                            offset: index == _currentIndex
                                ? _swipeOffset
                                : Offset.zero,
                            child: Transform.rotate(
                              angle:
                                  index == _currentIndex ? _rotationAngle : 0.0,
                              child: Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                elevation: 5,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Stack(
                                    children: [
                                      Positioned.fill(
                                        child: Image.network(
                                          game.coverUrl ?? '',
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  const Center(
                                            child: Icon(
                                              Icons.image_not_supported,
                                              size: 150,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Positioned.fill(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                              colors: [
                                                Colors.transparent,
                                                Colors.black.withOpacity(0.7),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        bottom: 16.0,
                                        left: 16.0,
                                        child: Text(
                                          game.name ?? 'Unknown Game',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 18.0,
                                            fontWeight: FontWeight.bold,
                                            shadows: [
                                              Shadow(
                                                offset: Offset(1.0, 1.0),
                                                blurRadius: 3.0,
                                                color: Colors.black,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        bottom: 16.0,
                                        right: 16.0,
                                        child: GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    GameDetailScreen(
                                                        gameId: game.id),
                                              ),
                                            );
                                          },
                                          child: const Icon(
                                            Icons.info,
                                            color: Colors.white,
                                            size: 28.0,
                                            shadows: [
                                              Shadow(
                                                offset: Offset(1.0, 1.0),
                                                blurRadius: 3.0,
                                                color: Colors.black,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                flex: 1,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const FaIcon(Icons.gamepad, size: 24), // Gamepad icon
                          const SizedBox(width: 8),
                          Expanded(
                            child: Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 8,
                              children: [
                                Text(
                                  'Platforms:',
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color.fromARGB(255, 240, 98, 146)),
                                ),
                                if (games.isNotEmpty)
                                  ...games.first.platforms.map((platform) {
                                    if (platform
                                        .toLowerCase()
                                        .contains('playstation')) {
                                      return Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const FaIcon(
                                              FontAwesomeIcons.playstation,
                                              size: 20),
                                          const SizedBox(width: 4),
                                          Text(
                                            platform,
                                            style:
                                                const TextStyle(fontSize: 16),
                                          ),
                                        ],
                                      );
                                    } else if (platform
                                        .toLowerCase()
                                        .contains('xbox')) {
                                      return Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const FaIcon(FontAwesomeIcons.xbox,
                                              size: 20),
                                          const SizedBox(width: 4),
                                          Text(
                                            platform,
                                            style:
                                                const TextStyle(fontSize: 16),
                                          ),
                                        ],
                                      );
                                    } else if (platform
                                        .toLowerCase()
                                        .contains('pc')) {
                                      return Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const FaIcon(FontAwesomeIcons.desktop,
                                              size: 20),
                                          const SizedBox(width: 4),
                                          Text(
                                            platform,
                                            style:
                                                const TextStyle(fontSize: 16),
                                          ),
                                        ],
                                      );
                                    } else if (platform
                                        .toLowerCase()
                                        .contains('android')) {
                                      return Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const FaIcon(FontAwesomeIcons.android,
                                              size: 20),
                                          const SizedBox(width: 4),
                                          Text(
                                            platform,
                                            style:
                                                const TextStyle(fontSize: 16),
                                          ),
                                        ],
                                      );
                                    } else if (platform
                                        .toLowerCase()
                                        .contains('ios')) {
                                      return Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const FaIcon(FontAwesomeIcons.apple,
                                              size: 20),
                                          const SizedBox(width: 4),
                                          Text(
                                            platform,
                                            style:
                                                const TextStyle(fontSize: 16),
                                          ),
                                        ],
                                      );
                                    } else if (platform
                                        .toLowerCase()
                                        .contains('nintendo')) {
                                      return Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const FaIcon(FontAwesomeIcons.gamepad,
                                              size: 20),
                                          const SizedBox(width: 4),
                                          Text(
                                            platform,
                                            style:
                                                const TextStyle(fontSize: 16),
                                          ),
                                        ],
                                      );
                                    } else {
                                      return Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const FaIcon(Icons.videogame_asset,
                                              size: 20),
                                          const SizedBox(width: 4),
                                          Text(
                                            platform,
                                            style:
                                                const TextStyle(fontSize: 16),
                                          ),
                                        ],
                                      );
                                    }
                                  }).toList(),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today,
                              size: 24), // Icon for release date
                          const SizedBox(width: 8),
                          Text(
                            'Release Date: ',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue, // Color for "Release Date"
                            ),
                          ),
                          Expanded(
                            child: Text(
                              games.isNotEmpty
                                  ? games.first.releaseDates?.join(", ") ??
                                      "Unknown"
                                  : " ",
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors
                                    .black, // Default color for fetched text
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          const Icon(Icons.category,
                              size: 24), // Icon for genres
                          const SizedBox(width: 8),
                          Text(
                            'Genres: ',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(
                                  255, 240, 98, 146), // Color for "Genres"
                            ),
                          ),
                          Expanded(
                            child: Text(
                              games.isNotEmpty
                                  ? games.first.genres?.join(", ") ??
                                      "Unknown genres"
                                  : " ",
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors
                                    .black, // Default color for fetched text
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 25.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    FloatingActionButton(
                      heroTag: 'dislike',
                      backgroundColor: Colors.blue,
                      shape: const CircleBorder(),
                      child: const Icon(Icons.heart_broken,
                          color: Colors.white, size: 32),
                      onPressed: _onDislike,
                    ),
                    FloatingActionButton(
                      heroTag: 'undo',
                      backgroundColor: Colors.grey.shade300,
                      shape: const CircleBorder(),
                      child: const Icon(Icons.undo, size: 32),
                      onPressed: _onUndo,
                    ),
                    FloatingActionButton(
                      heroTag: 'like',
                      backgroundColor: Colors.pink[300],
                      shape: const CircleBorder(),
                      child: const Icon(Icons.favorite,
                          color: Colors.white, size: 32),
                      onPressed: _onLike,
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Swiping instruction UI
          if (_showSwipeInstruction)
            Positioned(
              left: MediaQuery.of(context).size.width / 1.8 - 80,
              top: MediaQuery.of(context).size.height * 0.2,
              child: SlideTransition(
                position: _instructionWagAnimation!,
                child: Column(
                  children: [
                    Icon(
                      Icons.swipe,
                      size: 100,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Swipe to interact',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        shadows: [
                          Shadow(
                            offset: Offset(1.0, 1.0),
                            blurRadius: 3.0,
                            color: Colors.black,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (_showHeart)
            Positioned(
              left: MediaQuery.of(context).size.width / 2 -
                  75, // Adjust to position horizontally
              top: MediaQuery.of(context).size.height / 3 -
                  75, // Adjust to position vertically
              child: FadeTransition(
                opacity: _heartFadeAnimation!,
                child: ScaleTransition(
                  scale: _heartScaleAnimation!,
                  child: const Icon(
                    Icons.favorite,
                    color: Color.fromARGB(255, 240, 98, 146),
                    size: 150,
                  ),
                ),
              ),
            ),
          if (_showHeartbroken)
            Positioned(
              left: MediaQuery.of(context).size.width / 2 -
                  75, // Adjust to position horizontally
              top: MediaQuery.of(context).size.height / 3 -
                  75, // Adjust to position vertically
              child: FadeTransition(
                opacity: _heartbrokenFadeAnimation!,
                child: ScaleTransition(
                  scale: _heartbrokenScaleAnimation!,
                  child: const Icon(
                    Icons.heart_broken,
                    color: Colors.blue,
                    size: 150,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class CustomAdPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Image has been removed since you don't have one
            Text(
              'This is a custom full-screen ad!',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                    context); // Close the ad and return to the main screen
              },
              child: Text('Close Ad'),
            ),
          ],
        ),
      ),
    );
  }
}
