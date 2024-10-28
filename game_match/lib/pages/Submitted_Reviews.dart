import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'api_service.dart';
import 'game_model.dart';
import 'package:intl/intl.dart';

class SubmittedReviewsPage extends StatefulWidget {
  @override
  _SubmittedReviewsPageState createState() => _SubmittedReviewsPageState();
}

class _SubmittedReviewsPageState extends State<SubmittedReviewsPage> {
  final FirebaseFirestore firestore =
      FirebaseFirestore.instance; // Firestore instance to access the database
  final FirebaseAuth auth =
      FirebaseAuth.instance; // Firebase Authentication instance for user access
  final ApiService apiService =
      ApiService(); // Instance of ApiService to fetch game details

  List<Map<String, dynamic>> userReviews = []; // List to hold user reviews
  Map<String, String> gameImages = {}; // Map to hold game images
  Map<String, String> gameTitles = {}; // Map to hold game titles

  @override
  void initState() {
    super.initState();
    _fetchUserReviews(); // Fetch user reviews when the page is initialized
  }

  // Fetch user reviews from Firestore
  Future<void> _fetchUserReviews() async {
    User? user = auth.currentUser; // Get the currently authenticated user
    if (user != null) {
      // Fetch reviews where the user ID matches the current user's ID
      QuerySnapshot querySnapshot = await firestore
          .collection('reviews')
          .where('userId', isEqualTo: user.uid)
          .get();

      List<Map<String, dynamic>> fetchedReviews = [];

      for (var doc in querySnapshot.docs) {
        Map<String, dynamic> reviewData = doc.data() as Map<String, dynamic>;
        String gameId = reviewData['gameId'] ?? 'unknown';

        // Fetch game details if they haven't been loaded already
        if (gameId != 'unknown' && !gameImages.containsKey(gameId)) {
          _fetchGameDetails(gameId);
        }

        fetchedReviews.add({
          'review': reviewData,
          'id': doc.id,
        });
      }

      setState(() {
        userReviews = fetchedReviews; // Update the state with fetched reviews
      });
    }
  }

  // Fetch game details from the API based on gameId
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
        gameImages[gameId] = matchedGame.coverUrl ?? ''; // Store the cover URL
        gameTitles[gameId] = matchedGame.name; // Store the game name
      });
    } catch (e) {
      print(
          'Error fetching game details: $e'); // Log an error if fetching fails
    }
  }

  // Delete a review from Firestore
  Future<void> _deleteReview(String reviewId) async {
    await firestore.collection('reviews').doc(reviewId).delete();
    _fetchUserReviews(); // Refresh the review list after deletion
  }

  // Edit a review with a dialog box
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
                  final double starWidth = 32.0; // Width of each star
                  final double totalWidth =
                      starWidth * 5; // Total width of all stars

                  // Limit localX within the star area
                  if (localX < 0) localX = 0;
                  if (localX > totalWidth) localX = totalWidth;

                  double newRating = (localX / starWidth);

                  setState(() {
                    currentRating = (newRating * 2).round() /
                        2; // Update the rating to the nearest 0.5
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
                        //labelText: 'Review Title',
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
                        //labelText: 'Review Body',
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
                        updateRating(
                            details.localPosition.dx); // Update rating on drag
                      },
                      onTapDown: (details) {
                        updateRating(
                            details.localPosition.dx); // Update rating on tap
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
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                try {
                  // Update the review in Firestore
                  await firestore.collection('reviews').doc(reviewId).update({
                    'title': titleController.text,
                    'body': bodyController.text,
                    'rating': currentRating,
                  });

                  Navigator.of(context).pop(); // Close the dialog
                  _fetchUserReviews(); // Refresh the review list

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

  // Build the list of reviews for the user
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
                // Display game image
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
                      Text(
                        gameTitle,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          // Display the star rating
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
                          Spacer(),
                          IconButton(
                            icon:
                                Icon(Icons.edit, size: 18, color: Colors.grey),
                            onPressed: () {
                              _editReview(reviewId, review); // Edit the review
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete,
                                size: 18, color: Colors.grey),
                            onPressed: () {
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
                                        _deleteReview(
                                            reviewId); // Delete the review
                                        Navigator.of(context).pop();
                                      },
                                      child: Text('Yes'),
                                    ),
                                  ],
                                ),
                              );
                            },
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
    return Scaffold(
      appBar: AppBar(
        title: Text('My Reviews'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
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
            Expanded(
                child: _buildReviewList()), // Build the review list dynamically
          ],
        ),
      ),
    );
  }
}
