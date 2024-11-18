import 'package:flutter/material.dart';
import 'package:game_match/pages/game_info.dart';
import 'api_service.dart';
import 'game_model.dart';
import 'package:game_match/firestore_service.dart';
import 'dart:async';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'ad_helper.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'Side_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'Subscription.dart';

class SwipePage extends StatefulWidget {
  const SwipePage({super.key});

  @override
  _SwipePageState createState() => _SwipePageState();
}

class _SwipePageState extends State<SwipePage> with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ApiService apiService = ApiService();
  final FirestoreService _firestoreService = FirestoreService();
  StreamSubscription? _firestoreSubscription;
  InterstitialAd? _interstitialAd;
  List<Game> games = [];
  List<Game> swipedGames = [];
  Game? selectedGame;
  Offset _swipeOffset = Offset.zero;
  double _rotationAngle = 0.0;
  double _opacity = 1.0;
  final int _currentIndex = 0;
  int _swipeCount = 0; // track the number of swipes for free users
  int _adSwipeCount = 0; // track number of swipes for ads
  static const int dailySwipeLimit = 2; // The daily limit for free users
  static const int adSwipeInterval = 3; // show an ad every 3 swipes
  bool _isPremium = false;

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
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _fetchGames(user.uid);
    }
    _fetchSubscriptionStatus();
    _loadInterstitialAd();

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

    // load the first ad
    _loadInterstitialAd();
  }

  Future<void> _fetchGames(String userId) async {
    try {
      // Try to load recommended games from Firestore for the current user
      List<Game> recommendedGames = await _firestoreService.loadRecommendedGames(userId);

      if (recommendedGames.isNotEmpty) {
        setState(() {
          games = recommendedGames;
          selectedGame = games[0];
        });
        print('Recommended games loaded from Firestore');
      } else {
        // If no recommended games, fetch games from the API
        print('No recommended games in Firestore, fetching from API...');
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

  // Fetch subscription status of the user and swipe data
  Future<void> _fetchSubscriptionStatus() async {
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      String userId = currentUser.uid;
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get();

        if (userDoc.exists) {
          String subscriprionStatus = userDoc.get('subscription');
          setState(() {
            _isPremium = subscriprionStatus == 'paid';
          });
        }
      } catch (e) {
        print("Error fetching subscription status: $e");
      }
    }

    _fetchSwipeDate();
  }

  // Fetch swipe data count and last reset time from local storage
  Future<void> _fetchSwipeDate() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int savedSwipeCount = prefs.getInt('swipeCount') ?? 0;
    String? lastReset = prefs.getString('lastReset');
    String today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    if (lastReset != today) {
      // Reset count if its a new day
      _swipeCount = 0;
      await prefs.setInt('swipeCount', 0);
      await prefs.setString('lastReset', today);
    } else {
      _swipeCount = savedSwipeCount;
    }
  }

  // Incrament swipe count and save to local storage
  Future<void> _incramentSwipeCount() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _swipeCount += 1;
    });
    await prefs.setInt('swipeCount', _swipeCount);
  }

  Future<void> _fetchPricesForGames(List<Game> fetchedGames) async {
    try {
      // await apiService.fetchPricesForIGDBGames(fetchedGames);
      fetchedGames
          .removeWhere((game) => game.price == null || game.price! <= 0);
      setState(() {
        games = fetchedGames;
      });
    } catch (e) {
      print('Error fetching game prices: $e');
    }
  }

  // Load an interstitial ad
  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: AdHelper.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          _interstitialAd = ad;
        },
        onAdFailedToLoad: (LoadAdError error) {
          print('Failed to load interstitial ad');
          _interstitialAd = null;
        },
      ),
    );
  }

  // Display the interstitial ad
  void _showInterstitialAd() {
    if (_interstitialAd != null) {
      _interstitialAd!.show();
      _interstitialAd = null; // Reset the ad
      _loadInterstitialAd(); // Load a new ad for the next time
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
    _interstitialAd?.dispose();
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
            const SnackBar(
              content: Text('Failed to add game to wishlist. Try again.'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 2),
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
          const SnackBar(
            content: Text('Action has been reverted.'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 2),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to revert action.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
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

// get user info (subscription status) from Firestore
Future<Map<String, String>> getsubscriptionstatus() async {
  User? user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    String subscriptionStatus = userDoc['subscription'] ?? 'free';
    return {'subscriptionStatus': subscriptionStatus};
  }
    return {'subscriptionStatus': 'free'};
  }
  
  void _onGameSwiped(int index) async {
    if (games.isNotEmpty) {
      setState(() {
        swipedGames.add(games[index]);
        games.removeAt(index);
        _swipeOffset = Offset.zero;
        _rotationAngle = 0.0;
        _opacity = 1.0;

        // increment swipe count and check if custom ad should be shown
        _swipeCount++;
      });

      if (_swipeCount >= _swipeThreshold) {
        Map<String, String> subscriptionStatus = await getsubscriptionstatus();
        if (subscriptionStatus['subscriptionStatus'] == 'free') {
          _showCustomAd();
        } else {
          setState(() {
            _swipeCount = 0; // Reset swipe count after ad
          });
        }
      }

  void _onGameSwiped(int index) {
    if (_isPremium || _swipeCount < dailySwipeLimit) {
      // Premium users have no limit, free users are limited by dailySwipeLimit
      _incramentSwipeCount();

      if (games.isNotEmpty) {
        setState(() {
          swipedGames.add(games[index]);
          games.removeAt(index);
          _swipeOffset = Offset.zero;
          _rotationAngle = 0.0;
          _opacity = 1.0;

          // incrament swipe counts for both daily and ads
          _adSwipeCount++;
          _swipeCount++;

          // Show ad after threshold met
          if (!_isPremium && _adSwipeCount >= adSwipeInterval) {
            _showInterstitialAd();
            _adSwipeCount = 0;
          }
        });
      }
    } else {
      // Show limit reached dialog with timer and upgrade option
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return SwipeLimitDialog();
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey, // Key for the scaffold
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.black), // Sidebar Icon
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        title: Image.asset(
          'assets/images/gamematchlogoresize.png',
          height: 50,
          width: 50,
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
                                            fontSize: 20.0,
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
                                const Text(
                                  'Platforms:',
                                  style: TextStyle(
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
                                  }),
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
                          const Text(
                            'Release Date: ',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue, // Color for "Release Date"
                            ),
                          ),
                          Expanded(
                            child: Text(
                              games.isNotEmpty
                                  ? games.first.releaseDates.join(", ") ??
                                      "Unknown"
                                  : " ",
                              style: const TextStyle(
                                fontSize: 16,
                                //color: Colors.black, // Default color for fetched text
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
                          const Text(
                            'Genres: ',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(
                                  255, 240, 98, 146), // Color for "Genres"
                            ),
                          ),
                          Expanded(
                            child: Text(
                              games.isNotEmpty
                                  ? games.first.genres.join(", ") ??
                                      "Unknown genres"
                                  : " ",
                              style: const TextStyle(
                                fontSize: 16,
                                //color: Colors.black, // Default color for fetched text
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
                      onPressed: _onDislike,
                      child: const Icon(Icons.heart_broken,
                          color: Colors.white, size: 32),
                    ),
                    FloatingActionButton(
                      heroTag: 'undo',
                      backgroundColor: Colors.grey.shade300,
                      shape: const CircleBorder(),
                      onPressed: _onUndo,
                      child: const Icon(
                        Icons.undo,
                        size: 32,
                        color: Colors.black,
                      ),
                    ),
                    FloatingActionButton(
                      heroTag: 'like',
                      backgroundColor: Colors.pink[300],
                      shape: const CircleBorder(),
                      onPressed: _onLike,
                      child: const Icon(Icons.favorite,
                          color: Colors.white, size: 32),
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
                child: const Column(
                  children: [
                    Icon(
                      Icons.swipe,
                      size: 100,
                      color: Colors.white,
                    ),
                    SizedBox(height: 8),
                    Text(
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
  const CustomAdPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], // Light background color
      body: Center(
        child: Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 4,
          margin: const EdgeInsets.symmetric(horizontal: 24),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title
                const Text(
                  'Sponsored by NBA',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    'assets/images/nba-logo.png',
                    width: 300,
                    height: 300,
                    fit: BoxFit.cover,
                  ),
                ),

                const SizedBox(height: 16),

                // Description
                const Text(
                  'GameMatch is proud to be sponsored by the NBA. This partnership allows us to bring you exclusive content, special events, and unique gaming experiences. Stay tuned for more exciting updates and opportunities to engage with your favorite NBA teams and players through our platform.',
                  style: TextStyle(fontSize: 16, color: Colors.black87),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 20),

                // Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Learn Button
                    OutlinedButton(
                      onPressed: () {
                        // Handle Learn action
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.grey),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Learn',
                        style: TextStyle(color: Colors.black54),
                      ),
                    ),

                    // Close Button
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF41B1F1),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// custom dialog with countdown timer for swipe limit reset
class SwipeLimitDialog extends StatefulWidget {
  @override
  _SwipeLimitDialogState createState() => _SwipeLimitDialogState();
}

class _SwipeLimitDialogState extends State<SwipeLimitDialog> {
  late Timer _timer;
  late Duration _timeRemaining;

  @override
  void initState() {
    super.initState();
    _calculateTimeRemaining();
    _startTimer();
  }

  void _calculateTimeRemaining() {
    DateTime now = DateTime.now();
    DateTime resetTime = DateTime(now.year, now.month, now.day + 1);
    _timeRemaining = resetTime.difference(now);
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_timeRemaining.inSeconds > 0) {
          _timeRemaining -= Duration(seconds: 1);
        } else {
          _timer.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String formattedTime = _formatDuration(_timeRemaining);

    return AlertDialog(
      title: Text('Daily Swipe Limit Reached'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
              'You have reached your daily swipe limit. Upgrade to Premium for unlimited swipes and an ad-free experience!'),
          SizedBox(height: 16),
          Text(
            'Time until swipes reset: $formattedTime',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel'),
          style: TextButton.styleFrom(
            foregroundColor: Colors.black,
          ),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SubscriptionManagementScreen(),
              ),
            );
          },
          child: Text('Upgrade'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF41B1F1),
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    String hours = duration.inHours.toString().padLeft(2, '0');
    String minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    String seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }
}
