import 'package:flutter/material.dart';
import 'dart:math';
import 'api_service.dart';
import 'game_model.dart';

class SwipePage extends StatefulWidget {
  @override
  _SwipePageState createState() => _SwipePageState();
}

class _SwipePageState extends State<SwipePage> with TickerProviderStateMixin {
  final ApiService apiService = ApiService();
  List<Game> games = [];
  List<Game> swipedGames = [];
  Offset _swipeOffset = Offset.zero;
  double _rotationAngle = 0.0;
  int _currentIndex = 0;
  AnimationController? _heartAnimationController;
  AnimationController? _heartbrokenAnimationController;
  Animation<double>? _heartFadeAnimation;
  Animation<double>? _heartScaleAnimation;
  Animation<double>? _heartbrokenFadeAnimation;
  Animation<double>? _heartbrokenScaleAnimation;
  bool _showHeart = false;
  bool _showHeartbroken = false;

  @override
  void initState() {
    super.initState();
    _fetchGames();

    // Heart animation controller
    _heartAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _heartFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _heartAnimationController!, curve: Curves.easeOut),
    );
    _heartScaleAnimation = Tween<double>(begin: 0.0, end: 1.2).animate(
      CurvedAnimation(
          parent: _heartAnimationController!, curve: Curves.easeOut),
    );

    // Heartbroken animation controller
    _heartbrokenAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _heartbrokenFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _heartbrokenAnimationController!, curve: Curves.easeOut),
    );
    _heartbrokenScaleAnimation = Tween<double>(begin: 0.0, end: 1.2).animate(
      CurvedAnimation(
          parent: _heartbrokenAnimationController!, curve: Curves.easeOut),
    );
  }

  Future<void> _fetchGames() async {
    try {
      List<Game> fetchedGames = await apiService.fetchGames();
      setState(() {
        games = fetchedGames;
      });
    } catch (e) {
      print('Error fetching games: $e');
    }
  }

  void _onSwipeComplete(DragEndDetails details) {
    if (_swipeOffset.dx > 150) {
      // Swiped right
      _onLike();
    } else if (_swipeOffset.dx < -150) {
      // Swiped left
      _onDislike();
    } else {
      // Reset position if not far enough
      setState(() {
        _swipeOffset = Offset.zero;
        _rotationAngle = 0.0;
      });
    }
  }

  void _onLike() {
    if (games.isNotEmpty) {
      setState(() {
        _showHeart = true;
      });
      _heartAnimationController!.forward().then((_) {
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

  void _onUndo() {
    if (swipedGames.isNotEmpty) {
      setState(() {
        games.insert(0, swipedGames.removeLast());
        _currentIndex--;
      });
    }
  }

  void _onGameSwiped(int index) {
    if (games.isNotEmpty) {
      setState(() {
        swipedGames.add(games[index]);
        games.removeAt(index);
      });
    }
  }

  @override
  void dispose() {
    _heartAnimationController?.dispose();
    _heartbrokenAnimationController?.dispose();
    super.dispose();
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

                    // Only render the cards from the current index onward
                    if (index < _currentIndex) return const SizedBox.shrink();

                    return Positioned.fill(
                      child: GestureDetector(
                        onPanUpdate: (details) {
                          setState(() {
                            _swipeOffset += details.delta;
                            _rotationAngle = _swipeOffset.dx / 300;
                          });
                        },
                        onPanEnd: _onSwipeComplete,
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
                                          print(
                                              'Info icon tapped for ${game.name}');
                                        },
                                        child: const Icon(
                                          Icons.info,
                                          color: Colors.white,
                                          size: 24.0,
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
                    );
                  }).toList(),
                ),
              ),
              Expanded(
                flex: 1,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Platforms: ${games.isNotEmpty ? games.first.platforms?.join(", ") ?? "Unknown platforms" : ""}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Release Date: ${games.isNotEmpty ? games.first.releaseDates?.join(", ") ?? "Unknown" : ""}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Genres: ${games.isNotEmpty ? games.first.genres?.join(", ") ?? "Unknown genres" : ""}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
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
                      backgroundColor: Colors.red,
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
          if (_showHeart)
            Center(
              child: FadeTransition(
                opacity: _heartFadeAnimation!,
                child: ScaleTransition(
                  scale: _heartScaleAnimation!,
                  child: const Icon(
                    Icons.favorite,
                    color: Colors.red,
                    size: 150,
                  ),
                ),
              ),
            ),
          if (_showHeartbroken)
            Center(
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
