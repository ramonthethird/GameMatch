import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'api_service.dart';
import 'game_model.dart';
import 'Add_Reviews.dart';
import 'package:game_match/firestore_service.dart';

class ViewReviewsPage extends StatefulWidget {
  final String gameId; // Accept the gameId as a parameter

  const ViewReviewsPage({Key? key, required this.gameId}) : super(key: key);

  @override
  _ViewReviewsPageState createState() => _ViewReviewsPageState();
}

class _ViewReviewsPageState extends State<ViewReviewsPage> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;
  final ApiService apiService = ApiService();

  List<Map<String, dynamic>> reviews = [];
  User? currentUser; // Current logged-in user
  bool isLoading = true;
  double averageRating = 0.0; // Average rating of the reviews
  String? profilePictureUrl;
  String? gameImageUrl; // Game image URL
  String? gameTitle; // Game title
  int totalReviews = 0; // Total number of reviews
  String sortBy = 'Newest'; // Default sorting method
  Map<int, int> ratingCounts = {
    1: 0,
    2: 0,
    3: 0,
    4: 0,
    5: 0,
  };

  @override
  void initState() {
    super.initState();
    _fetchGameDetails(); // Fetch game details when page is initialized
    _fetchReviews(); // Fetch reviews when page is initialized
    currentUser = auth.currentUser; // Get the current user
  }

  final FirestoreService _firestoreService = FirestoreService();

  Future<void> _fetchGameDetails() async {
  try {
    // Fetch the game details directly by game ID
    Game? currentGame = await _firestoreService.getGameById(widget.gameId);

    if (currentGame != null) {
      setState(() {
        gameImageUrl = currentGame.coverUrl; // Set the game image URL
        gameTitle = currentGame.name; // Set the game title
      });
    } else {
      // Show a message if the game is not found
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Game not found')),
      );
    }
  } catch (e) {
    print('Error fetching game details: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Failed to load game details')),
    );
  }
}


  Future<void> _fetchReviews() async {
    try {
      // Fetch all reviews for the given game ID
      QuerySnapshot querySnapshot = await firestore
          .collection('reviews')
          .where('gameId',
              isEqualTo: widget.gameId) // Ensure this filters by game ID only
          .get();

      List<Map<String, dynamic>> fetchedReviews = [];
      double totalRating = 0.0;
      int reviewCount = 0;

      // Reset the rating counts before counting again
      ratingCounts = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};

      for (var doc in querySnapshot.docs) {
        Map<String, dynamic> reviewData = doc.data() as Map<String, dynamic>;
        String userId = reviewData['userId'];

        // Fetch user data for each review
        DocumentSnapshot userDoc =
            await firestore.collection('users').doc(userId).get();
        String username = 'Unknown User';
        String? profilePictureUrl;
        if (userDoc.exists) {
          Map<String, dynamic>? userData = userDoc.data() as Map<String, dynamic>?;
          username = userData?['username'] ?? 'Unknown User';
          profilePictureUrl = userData?['profileImageUrl'] ?? ''; // Fetch profile image
        }


        Timestamp? timestamp = reviewData['timestamp'];
        String formattedDate = '';
        if (timestamp != null) {
          DateTime dateTime = timestamp.toDate();
          formattedDate =
              DateFormat('yyyy-MM-dd').format(dateTime); // Format the timestamp
        }

        double rating = (reviewData['rating'] is int)
            ? (reviewData['rating'] as int).toDouble()
            : (reviewData['rating'] ?? 0).toDouble();

        // Update the rating counts
        if (rating >= 1 && rating <= 5) {
          ratingCounts[rating.floor()] =
              (ratingCounts[rating.floor()] ?? 0) + 1;
        }

        // Add the review data to the list
        fetchedReviews.add({
          'review': reviewData,
          'username': username,
          'profileImageUrl': profilePictureUrl, // Add profile image URL
          'date': formattedDate,
          'rating': rating,
          'docId': doc.id,
        });


        totalRating += rating;
        reviewCount++;
      }

      // Update the state with fetched reviews and other statistics
      setState(() {
        reviews = fetchedReviews; // Update reviews list
        averageRating = reviewCount > 0
            ? totalRating / reviewCount
            : 0.0; // Calculate average rating
        totalReviews = reviewCount; // Set total review count
        isLoading = false;
      });

      // Apply sorting after fetching reviews
      _sortReviews();
    } catch (e) {
      print('Error fetching reviews: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _editReview(String reviewId, Map<String, dynamic> currentReview) async {
  TextEditingController titleController = TextEditingController(text: currentReview['title']);
  TextEditingController bodyController = TextEditingController(text: currentReview['body']);
  double currentRating = currentReview['rating']?.toDouble() ?? 0.0;

  bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
  Color textColor = isDarkMode ? Colors.white : Colors.black;


  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('Edit Review'),
        content: Container(
          width: 500,
          height: 450,
          child: SingleChildScrollView( // Added SingleChildScrollView
            child: StatefulBuilder(
              builder: (context, setState) {
                void updateRating(double localX) {
                  final double starWidth = 32.0;
                  final double totalWidth = starWidth * 5;
                  if (localX < 0) localX = 0;
                  if (localX > totalWidth) localX = totalWidth;
                  double newRating = (localX / starWidth);
                  setState(() {
                    currentRating = (newRating * 2).round() / 2;
                  });
                }

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Review Title', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        hintText: 'Enter review title...',
                        filled: true,
                        fillColor: Theme.of(context).cardColor,
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 10),
                    Text('Review Body', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    TextField(
                      controller: bodyController,
                      decoration: InputDecoration(
                        hintText: 'Write your review here...',
                        filled: true,
                        fillColor: Theme.of(context).cardColor,
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 6,
                      maxLength: 300,
                    ),
                    SizedBox(height: 10),
                    Text('Rating:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    GestureDetector(
                      onPanUpdate: (details) {
                        updateRating(details.localPosition.dx);
                      },
                      onTapDown: (details) {
                        updateRating(details.localPosition.dx);
                      },
                      child: Row(
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
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel', style: TextStyle(color: textColor)),
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
                _fetchReviews();

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
            child: Text('Save', style: TextStyle(color: textColor)),
          ),
        ],
      );
    },
  );
}

Future<void> _deleteReview(String reviewId) async {
  try {
    await firestore.collection('reviews').doc(reviewId).delete();
    _fetchReviews(); // Refresh the reviews list after deletion

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Review deleted successfully!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Failed to delete review: $e'),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 2),
      ),
    );
  }
}


  // Function to toggle like or dislike for a review
  Future<void> _toggleLikeOrDislike(
      String docId, String action, int index) async {
    try {
      DocumentReference reviewRef = firestore.collection('reviews').doc(docId);
      DocumentSnapshot snapshot = await reviewRef.get();

      if (!snapshot.exists) {
        throw Exception("Review does not exist!");
      }

      Map<String, dynamic> reviewData = snapshot.data() as Map<String, dynamic>;
      List likedBy = reviewData['likedBy'] ?? [];
      List dislikedBy = reviewData['dislikedBy'] ?? [];

      int newLikes = reviewData['likes'] ?? 0;
      int newDislikes = reviewData['dislikes'] ?? 0;

      bool hasLiked = likedBy.contains(currentUser?.uid);
      bool hasDisliked = dislikedBy.contains(currentUser?.uid);

      if (action == 'like') {
        if (hasLiked) {
          likedBy.remove(currentUser?.uid); // Remove like if already liked
          newLikes--;
        } else {
          likedBy.add(currentUser?.uid); // Add like
          newLikes++;
          if (hasDisliked) {
            dislikedBy
                .remove(currentUser?.uid); // Remove dislike if already disliked
            newDislikes--;
          }
        }
      } else if (action == 'dislike') {
        if (hasDisliked) {
          dislikedBy
              .remove(currentUser?.uid); // Remove dislike if already disliked
          newDislikes--;
        } else {
          dislikedBy.add(currentUser?.uid); // Add dislike
          newDislikes++;
          if (hasLiked) {
            likedBy.remove(currentUser?.uid); // Remove like if already liked
            newLikes--;
          }
        }
      }

      // Update the review in Firestore
      await reviewRef.update({
        'likes': newLikes,
        'dislikes': newDislikes,
        'likedBy': likedBy,
        'dislikedBy': dislikedBy,
      });

      setState(() {
        // Update the state with the new values
        reviews[index]['review']['likes'] = newLikes;
        reviews[index]['review']['dislikes'] = newDislikes;
        reviews[index]['review']['likedBy'] = likedBy;
        reviews[index]['review']['dislikedBy'] = dislikedBy;
      });
    } catch (e) {
      print('Error toggling like/dislike: $e');
    }
  }

  // Function to sort reviews based on selected criteria
  void _sortReviews() {
    setState(() {
      if (sortBy == 'Newest') {
        reviews.sort((a, b) =>
            b['review']['timestamp'].compareTo(a['review']['timestamp']));
      } else if (sortBy == 'Oldest') {
        reviews.sort((a, b) =>
            a['review']['timestamp'].compareTo(b['review']['timestamp']));
      } else if (sortBy == 'Most Liked') {
        reviews.sort((a, b) {
          int likesA = a['review']['likes'] ?? 0;
          int likesB = b['review']['likes'] ?? 0;
          return likesB.compareTo(likesA);
        });
      } else if (sortBy == 'Highest Rated') {
        reviews.sort((a, b) => b['rating'].compareTo(a['rating']));
      } else if (sortBy == 'Lowest Rated') {
        reviews.sort((a, b) => a['rating'].compareTo(b['rating']));
      }
    });
  }

  // Widget to build the sort dropdown
  Widget _buildSortDropdown() {
    return DropdownButton<String>(
      value: sortBy,
      items: [
        'Newest',
        'Oldest',
        'Most Liked',
        'Highest Rated',
        'Lowest Rated',
      ].map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          sortBy = newValue!; // Update the sorting method
          _sortReviews();
        });
      },
    );
  }

  // Widget to build the average rating section
  Widget _buildAverageRating() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              averageRating.toStringAsFixed(1), // Display the average rating
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(width: 8),
            Row(
              children: List.generate(
                5,
                (index) => Icon(
                  averageRating >= index + 1
                      ? Icons.star
                      : (averageRating >= index + 0.5
                          ? Icons.star_half
                          : Icons.star_border),
                  color: Colors.yellow,
                  size: 24,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 4),
        Text(
          '$totalReviews Reviews', // Display total number of reviews
          style: TextStyle(color: Colors.grey),
        ),
      ],
    );
  }

  // Widget to build the rating breakdown
  Widget _buildRatingBreakdown() {
    int totalRatings = ratingCounts.values.reduce((a, b) => a + b);
    if (totalRatings == 0)
      return SizedBox(); // If no ratings, return empty widget

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...List.generate(5, (index) {
          int starValue = 5 - index; // Show star count from 5 down to 1
          double percentage = (ratingCounts[starValue]! / totalRatings) * 100;
          return Row(
            children: [
              Text(
                '$starValue',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              SizedBox(width: 8),
              Expanded(
                child: LinearProgressIndicator(
                  value: percentage / 100,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
              ),
              SizedBox(width: 8),
              Text(
                '${percentage.toStringAsFixed(0)}%',
                style: TextStyle(fontSize: 14),
              ),
            ],
          );
        }),
      ],
    );
  }

    // Widget to build the list of reviews
  Widget _buildReviewList() {

    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    Color textColor = isDarkMode ? Colors.white : Colors.black;

    if (reviews.isEmpty) {
      return Center(
        child: Text('No reviews yet!'), // Show message if no reviews
      );
    }
    return ListView.builder(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: reviews.length,
      itemBuilder: (context, index) {
        final review = reviews[index]['review'];
        final username = reviews[index]['username'];
        final profilePictureUrl = reviews[index]['profileImageUrl'];
        final date = reviews[index]['date'];
        final double rating = reviews[index]['rating'];
        final docId = reviews[index]['docId'];
        final String userId = review['userId'];

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(10),
            // border: Border.all(color: Colors.grey[300]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GestureDetector(
                      onTap: () {
                        // Pass the userId when navigating to the profile page
                        Navigator.pushNamed(context, '/View_profile', arguments: userId);
                      },
                      child: CircleAvatar(
                        backgroundColor: Colors.grey[300],
                        radius: 20,
                        backgroundImage: profilePictureUrl != null && profilePictureUrl!.isNotEmpty
                          ? NetworkImage(profilePictureUrl!)
                          : null,
                        child: profilePictureUrl == null || profilePictureUrl!.isEmpty
                          ? Icon(Icons.person, color: Colors.grey[600])
                          : null,
                      ),
                    ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          username, // Display username
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
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
                              date, // Display formatted date
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Show PopupMenuButton if current user is the review author
                  if (userId == currentUser?.uid)
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'Edit') {
                          _editReview(docId, review);
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
                                  child: Text('No', style: TextStyle(color: textColor)),
                                ),
                                TextButton(
                                  onPressed: () {
                                    _deleteReview(docId);
                                    Navigator.of(context).pop();
                                  },
                                  child: Text('Yes', style: TextStyle(color: textColor)),
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
              SizedBox(height: 8),
              if (review['title'] != null && review['title'].isNotEmpty)
                Text(
                  review['title'], // Display review title if available
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              SizedBox(height: 4),
              Text(
                review['body'] ?? '', // Display review body
                style: TextStyle(fontSize: 12),
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.favorite,
                      color:
                          (review['likedBy'] ?? []).contains(currentUser?.uid)
                              ? Colors.red
                              : Colors.grey,
                    ),
                    onPressed: () => _toggleLikeOrDislike(docId, 'like', index),
                  ),
                  Text('${review['likes'] ?? 0}'), // Display like count
                  SizedBox(width: 16),
                  IconButton(
                    icon: Icon(
                      Icons.heart_broken,
                      color: (review['dislikedBy'] ?? [])
                              .contains(currentUser?.uid)
                          ? Colors.blue
                          : Colors.grey,
                    ),
                    onPressed: () =>
                        _toggleLikeOrDislike(docId, 'dislike', index),
                  ),
                  Text('${review['dislikes'] ?? 0}'), // Display dislike count
                ],
              ),
            ],
          ),
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black,),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text('View Reviews',
          style: TextStyle(
              color: Colors.black, 
              fontSize: 16,
            ),
          ),
        centerTitle: true,
        //backgroundColor: Colors.white,
      ),
      body: isLoading
          ? Center(
              child:
                  CircularProgressIndicator()) // Show loading indicator if loading
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    gameImageUrl != null
                        ? Container(
                            height: 200,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: NetworkImage(gameImageUrl!),
                                fit: BoxFit.cover,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          )
                        : Container(
                            height: 200,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.image_not_supported,
                                size: 50,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                    SizedBox(height: 16),
                    if (gameTitle != null)
                      Text(
                        gameTitle!,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    SizedBox(height: 16),
                    _buildAverageRating(), // Display average rating
                    SizedBox(height: 16),
                    _buildRatingBreakdown(), // Display rating breakdown
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Game Reviews',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        _buildSortDropdown(), // Display sorting options
                      ],
                    ),
                    SizedBox(height: 12),
                    _buildReviewList(), // Display list of reviews
                  ],
                ),
              ),
            ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        AddReviewsPage(gameId: widget.gameId)),
              ).then((_) {
                _fetchReviews(); // Refresh reviews when returning from AddReviewPage
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF41B1F1),
              padding: EdgeInsets.symmetric(vertical: 16.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'Add Review',
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
        ),
      ),
    );
  }
}