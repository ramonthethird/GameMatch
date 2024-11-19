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
  List<Map<String, dynamic>> userThreads = [];
  Map<String, String> gameImages = {};
  Map<String, String> gameTitles = {};
  User? _currentUser; // Define the _currentUser variable

  @override
  void initState() {
    super.initState();
    _fetchUserReviews();
    _fetchUserThreads();
    _currentUser = auth.currentUser; // Initialize _currentUser with the current authenticated user
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

  Future<void> _fetchUserThreads() async {
  User? user = auth.currentUser;
  if (user != null) {
    QuerySnapshot querySnapshot = await firestore
        .collection('threads')
        .where('userId', isEqualTo: user.uid)
        .get();

    List<Map<String, dynamic>> fetchedThreads = await Future.wait(
      querySnapshot.docs.map((doc) async {
        final threadData = doc.data() as Map<String, dynamic>;
        final threadId = doc.id;

        // Fetch the comment count from the comments sub-collection
        QuerySnapshot commentSnapshot = await firestore
            .collection('threads')
            .doc(threadId)
            .collection('comments')
            .get();

        return {
          'thread': threadData,
          'id': threadId,
          'gameId': threadData['gameId'],
          'comments': commentSnapshot.size, // Store the comment count here
        };
      }).toList(),
    );

    setState(() {
      userThreads = fetchedThreads;
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

  String _formatTimestamp(Timestamp timestamp) {
  DateTime dateTime = timestamp.toDate();
  // Format the date as 'yyyy-MM-dd' or customize as needed
  return DateFormat('yyyy-MM-dd hh:mm a').format(dateTime);
}

  // Inside _SubmittedReviewsPageState class

Future<void> _confirmDelete(String threadId) async {
  bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
  Color textColor = isDarkMode ? Colors.white : Colors.black;

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Delete Thread'),
      content: Text('Are you sure you want to delete this thread?'),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Close dialog
          },
          child: Text('No', style: TextStyle(color: textColor)),
        ),
        TextButton(
          onPressed: () async {
            Navigator.of(context).pop(); // Close dialog first
            try {
              await _deleteThread(threadId); // Call delete method with await
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Thread deleted successfully.')),
              );
            } catch (e) {
              print('Error deleting thread: $e');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error deleting thread.')),
              );
            }
          },
          child: Text('Yes', style: TextStyle(color: textColor)),
        ),
      ],
    ),
  );
}

// Method to delete a thread from Firestore
Future<void> _deleteThread(String threadId) async {
  try {
    await firestore.collection('threads').doc(threadId).delete();
    setState(() {
      userReviews.removeWhere((review) => review['id'] == threadId); // Assuming userReviews contains thread data
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Thread deleted successfully.')),
    );
  } catch (e) {
    print('Error deleting thread: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error deleting thread.')),
    );
  }
}

Future<void> _editThreadContent(String threadId, String currentContent) async {
  TextEditingController editController = TextEditingController(text: currentContent);

  final mainContext = context; // Store the main context to use for Snackbar

  bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
  Color textColor = isDarkMode ? Colors.white : Colors.black;


  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('Edit Thread'),
        content: Container(
          width: 500,
          height: 300,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Thread Description',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                TextField(
                  controller: editController,
                  maxLines: 6,
                  maxLength: 300,
                  decoration: InputDecoration(
                    hintText: 'Enter thread description...',
                    filled: true,
                    fillColor: Theme.of(context).cardColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                ),
              ],
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
              String newContent = editController.text.trim();
              if (newContent.isNotEmpty) {
                setState(() {
                  // Update local data immediately
                  userThreads.firstWhere((thread) => thread['id'] == threadId)['thread']['content'] = newContent;
                });

                Navigator.of(context).pop(); // Close the dialog

                try {
                  // Update Firestore data
                  await firestore.collection('threads').doc(threadId).update({
                    'content': newContent,
                  });
                  ScaffoldMessenger.of(mainContext).showSnackBar( // Use main context here
                    SnackBar(content: Text('Thread updated successfully!')),
                  );
                } catch (e) {
                  print('Error updating thread: $e');
                  ScaffoldMessenger.of(mainContext).showSnackBar( // Use main context here
                    SnackBar(content: Text('Error updating thread.')),
                  );
                }
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
          child: SingleChildScrollView(
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
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
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
                    Text(
                      'Review Body',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
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
                    Text(
                      'Rating:',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
            child: Text('Save', style: TextStyle(color: textColor)),
          ),
        ],
      );
    },
  );
}


  Widget _buildReviewList() {

  bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
  Color textColor = isDarkMode ? Colors.white : Colors.black;

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
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(10),
          // border: Border.all(color: Colors.grey.shade300, width: 1),
        ),
        margin: EdgeInsets.symmetric(vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Game Image
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
              
              // Game details in a column to align title, stars, and date horizontally
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
                              fontSize: 18,
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
                                      child: Text('No', style: TextStyle(color: textColor)),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        _deleteReview(reviewId);
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
                    
                    // Row for Stars and Date aligned with the image
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

                    // Review Title and Body
                    Text(
                      review['title'] ?? '',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      review['body'] ?? '',
                      style: TextStyle(fontSize: 12),
                    ),
                    SizedBox(height: 8),

                    // Like and Dislike Icons
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

  Widget _buildThreadList(List<Map<String, dynamic>> threads) {
  if (threads.isEmpty) {
    return Center(
      child: Text('You have not submitted any threads yet!'),
    );
  }
  return ListView.builder(
    itemCount: threads.length,
    itemBuilder: (context, index) {
      final thread = threads[index]['thread'];
      final threadId = threads[index]['id']; // Ensure thread ID is accessed here
      final gameId = threads[index]['gameId'];
      final gameTitle = gameTitles[gameId] ?? 'Unknown Game';
      final gameImageUrl = gameImages[gameId] ?? '';
      final timestamp = thread['timestamp'] as Timestamp?;
      final formattedDate = timestamp != null ? _formatTimestamp(timestamp) : 'No date available';

      return Card(
        color: Theme.of(context).cardColor,
        elevation: 2,
        margin: EdgeInsets.symmetric(vertical: 8.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
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
                        Text(
                          gameTitle,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          formattedDate,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        _editThreadContent(threadId, thread['content'] ?? ''); // Pass threadId directly here
                      } else if (value == 'delete') {
                        _confirmDelete(threadId); // Pass threadId directly here
                      }
                    },
                    itemBuilder: (BuildContext context) => [
                      PopupMenuItem(
                        value: 'edit',
                        child: Text('Edit'),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Text('Delete'),
                      ),
                    ],
                    icon: Icon(Icons.more_vert),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Text(
                thread['content'] ?? '',
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(height: 8),
              if (thread['imageUrl'] != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    thread['imageUrl'],
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 200,
                        color: Colors.grey[300],
                        child: Center(child: Icon(Icons.image_not_supported)),
                      );
                    },
                  ),
                ),
              SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Like icon and count
                  Row(
                    children: [
                      Icon(Icons.favorite, color: Colors.red, size: 20),
                      SizedBox(width: 4),
                      Text(
                        '${thread['likes'] ?? 0}',
                        style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodyLarge?.color),
                      ),
                    ],
                  ),
                  // Comment icon and count
                  Row(
                    children: [
                      Icon(Icons.comment, color: Colors.blue, size: 20),
                      SizedBox(width: 4),
                      Text(
                        '${threads[index]['comments'] ?? 0}',
                        style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodyLarge?.color),
                      ),
                    ],
                  ),
                  // Share icon and count
                  Row(
                    children: [
                      Icon(Icons.share, color: Colors.green, size: 20),
                      SizedBox(width: 4),
                      Text(
                        '${thread['shares'] ?? 0}',
                        style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodyLarge?.color),
                      ),
                    ],
                  ),
                ],
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
    return DefaultTabController(
      length: 2, // Two tabs: Reviews and Threads
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
  title: Text(
    'My Activity',
    style: TextStyle(
      color: Colors.black,
      fontSize: 16,
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
  bottom: TabBar(
    labelColor: Colors.black, // Set active tab text color to black
    unselectedLabelColor: Colors.black54, // Set inactive tab text color (optional)
    indicatorColor: Colors.white,
    tabs: [
      Tab(text: 'Reviews'),
      Tab(text: 'Threads'),
    ],
  ),
),

        drawer: Drawer(
          child: SideBar(
            onThemeChanged: (isDarkMode) {
              themeNotifier.toggleTheme(isDarkMode);
            },
            isDarkMode: themeNotifier.isDarkMode,
          ),
        ),
        body: TabBarView(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: _buildReviewList(),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: _buildThreadList(userThreads), // Pass userThreads here
            ),
          ],
        ),
      ),
    );
  }
}