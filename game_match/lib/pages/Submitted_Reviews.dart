import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'api_service.dart';
import 'game_model.dart';
import 'package:intl/intl.dart';
import 'Side_bar.dart';
import 'package:game_match/theme_notifier.dart';
import 'package:provider/provider.dart';

class SubmittedReviewsPage extends StatefulWidget {
  @override
  _SubmittedReviewsPageState createState() => _SubmittedReviewsPageState();
}

class _SubmittedReviewsPageState extends State<SubmittedReviewsPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;
  final ApiService apiService = ApiService();

  List<Map<String, dynamic>> userReviews = [];
  Map<String, String> gameImages = {};
  Map<String, String> gameTitles = {};

  @override
  void initState() {
    super.initState();
    _fetchUserReviews();
  }

  Future<void> _fetchUserReviews() async {
    User? user = auth.currentUser;
    if (user != null) {
      QuerySnapshot querySnapshot = await firestore
          .collection('reviews')
          .where('userId', isEqualTo: user.uid)
          .get();

      List<Map<String, dynamic>> fetchedReviews = [];

      for (var doc in querySnapshot.docs) {
        Map<String, dynamic> reviewData = doc.data() as Map<String, dynamic>;
        String gameId = reviewData['gameId'] ?? 'unknown';

        if (gameId != 'unknown' && !gameImages.containsKey(gameId)) {
          _fetchGameDetails(gameId);
        }

        fetchedReviews.add({
          'review': reviewData,
          'id': doc.id,
        });
      }

      setState(() {
        userReviews = fetchedReviews;
      });
    }
  }

  Future<void> _fetchGameDetails(String gameId) async {
    try {
      List<Game> fetchedGames = await apiService.fetchGames();
      final matchedGame = fetchedGames.firstWhere(
        (game) => game.id == gameId,
        orElse: () => Game(
          id: gameId,
          name: 'Unknown Game',
          summary: 'No description available',
          genres: [],
          coverUrl: null,
          platforms: [],
          releaseDates: [],
          websiteUrl: '',
          price: null,
        ),
      );

      setState(() {
        gameImages[gameId] = matchedGame.coverUrl ?? '';
        gameTitles[gameId] = matchedGame.name;
      });
    } catch (e) {
      print('Error fetching game details: $e');
    }
  }

  Future<void> _deleteReview(String reviewId) async {
    await firestore.collection('reviews').doc(reviewId).delete();
    _fetchUserReviews();
  }

  Future<void> _editReview(
      String reviewId, Map<String, dynamic> currentReview) async {
    TextEditingController titleController =
        TextEditingController(text: currentReview['title']);
    TextEditingController bodyController =
        TextEditingController(text: currentReview['body']);
    double currentRating = currentReview['rating']?.toDouble() ?? 0.0;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Review'),
          content: Container(
            width: 500,
            height: 450,
            child: StatefulBuilder(
              builder: (context, setState) {
                void updateRating(double localX) {
                  final double starWidth = 32.0;

                  if (localX < 0) localX = 0;
                  if (localX > starWidth * 5) localX = starWidth * 5;

                  double newRating = (localX / starWidth);

                  setState(() {
                    currentRating = (newRating * 2).round() / 2;
                  });
                }

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Review Title',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        hintText: 'Enter review title...',
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Review Body',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: bodyController,
                      decoration: InputDecoration(
                        hintText: 'Write your review here...',
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 8,
                      maxLength: 300,
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Rating:',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    GestureDetector(
                      onPanUpdate: (details) {
                        updateRating(details.localPosition.dx);
                      },
                      onTapDown: (details) {
                        updateRating(details.localPosition.dx);
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: List.generate(5, (index) {
                          double starValue = index + 1;
                          return Icon(
                            currentRating >= starValue
                                ? Icons.star
                                : (currentRating >= starValue - 0.5
                                    ? Icons.star_half
                                    : Icons.star_border),
                            color: Colors.yellow,
                            size: 32,
                          );
                        }),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                try {
                  await firestore.collection('reviews').doc(reviewId).update({
                    'title': titleController.text,
                    'body': bodyController.text,
                    'rating': currentRating,
                  });

                  Navigator.of(context).pop();
                  _fetchUserReviews();

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Review updated successfully!'),
                      backgroundColor: Colors.green,
                      duration: Duration(seconds: 2),
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to update review: $e'),
                      backgroundColor: Colors.red,
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildReviewList() {
    if (userReviews.isEmpty) {
      return Center(
        child: Text('You have not submitted any reviews yet!'),
      );
    }
    return ListView.builder(
      itemCount: userReviews.length,
      itemBuilder: (context, index) {
        final review = userReviews[index]['review'];
        final reviewId = userReviews[index]['id'];
        final gameId = review['gameId'] ?? 'unknown';
        final gameTitle = gameTitles[gameId] ?? 'Unknown Game';
        final gameImageUrl = gameImages[gameId] ?? '';
        final double rating = review['rating']?.toDouble() ?? 0.0;
        final Timestamp timestamp = review['timestamp'];
        final String formattedDate =
            DateFormat('yyyy-MM-dd').format(timestamp.toDate());

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade300, width: 1),
          ),
          margin: EdgeInsets.symmetric(vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    gameImageUrl,
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 48,
                        height: 48,
                        color: Colors.grey,
                        child: Icon(
                          Icons.image_not_supported,
                          color: Colors.white,
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              gameTitle,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                          ),
                          PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'Edit') {
                                _editReview(reviewId, review);
                              } else if (value == 'Delete') {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text('Delete Review'),
                                    content: Text(
                                        'Are you sure you want to delete this review?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Text('No'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          _deleteReview(reviewId);
                                          Navigator.of(context).pop();
                                        },
                                        child: Text('Yes'),
                                      ),
                                    ],
                                  ),
                                );
                              }
                            },
                            itemBuilder: (BuildContext context) => [
                              PopupMenuItem<String>(
                                value: 'Edit',
                                child: Text('Edit'),
                              ),
                              PopupMenuItem<String>(
                                value: 'Delete',
                                child: Text('Delete'),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Row(
                            children: List.generate(
                              5,
                              (starIndex) {
                                double starValue = starIndex + 1;
                                if (rating >= starValue) {
                                  return Icon(Icons.star,
                                      color: Colors.yellow, size: 16);
                                } else if (rating >= starValue - 0.5) {
                                  return Icon(Icons.star_half,
                                      color: Colors.yellow, size: 16);
                                } else {
                                  return Icon(Icons.star_border,
                                      color: Colors.yellow, size: 16);
                                }
                              },
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            formattedDate,
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        review['title'] ?? '',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        review['body'] ?? '',
                        style: TextStyle(fontSize: 14),
                      ),
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.favorite, color: Colors.red, size: 24),
                              SizedBox(width: 4),
                              Text('${review['likes'] ?? 0}',
                                  style: TextStyle(fontSize: 12)),
                              SizedBox(width: 16),
                              Icon(Icons.heart_broken,
                                  color: Colors.blue, size: 24),
                              SizedBox(width: 4),
                              Text('${review['dislikes'] ?? 0}',
                                  style: TextStyle(fontSize: 12)),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          'My Reviews',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.black),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
      ),
      drawer: Drawer(
        child: SideBar(
          onThemeChanged: (isDarkMode) {
            // Handle theme change here
            themeNotifier.toggleTheme(isDarkMode);
          },
          isDarkMode: themeNotifier.isDarkMode,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'My Reviews',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Expanded(child: _buildReviewList()),
          ],
        ),
      ),
    );
  }
}
