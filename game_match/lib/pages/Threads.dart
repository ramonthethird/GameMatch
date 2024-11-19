import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:game_match/firestore_service.dart';
import 'Add_Threads.dart';
import 'Thread_Comments.dart';
import 'game_model.dart';
import 'package:clipboard/clipboard.dart';
import 'package:share_plus/share_plus.dart';

class ThreadsPage extends StatefulWidget {
  final String gameId;
  const ThreadsPage({Key? key, required this.gameId}) : super(key: key);

  @override
  _ThreadsPageState createState() => _ThreadsPageState();
}

class _ThreadsPageState extends State<ThreadsPage> {
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool isLoading = true;
  List<Map<String, dynamic>> threads = [];
  User? _currentUser;
  String filter = 'New';
  String? gameTitle; // Default title
  String subscriptionStatus = "free"; // Default to "free" until fetched from Firestore


  @override
  void initState() {
    super.initState();
    _checkUserStatus();
    _fetchGameTitle(); // Fetch the game title on initialization
  }

  Future<void> _editThreadContent(String threadId, String currentContent) async {
    TextEditingController editController = TextEditingController(text: currentContent);

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
                  await _firestoreService.updateThreadContent(threadId, newContent);
                  Navigator.of(context).pop();
                  _fetchThreads();
                }
              },
              child: Text('Save', style: TextStyle(color: textColor)),
            ),
          ],
        );
      },
    );
  }

  void _shareThreadLink(String threadId) async {
  final link = 'https://yourwebsite.com/threads/$threadId';

  try {
    await Share.share(link, subject: 'Check out this thread!');
  } catch (e) {
    print("Error sharing link: $e");
  }
}

  Future<void> _checkUserStatus() async {
  _currentUser = _auth.currentUser;
  if (_currentUser != null) {
    // Fetch subscription status from Firestore
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(_currentUser!.uid).get();
    setState(() {
      subscriptionStatus = userDoc['subscription'] ?? "free";
    });
    _fetchThreads();
  } else {
    setState(() {
      isLoading = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('You need to be logged in to view threads.')),
    );
  }
}


  Future<void> _fetchGameTitle() async {
    try {
      // Assuming your FirestoreService has a method to get game details
      Game? game = await _firestoreService.getGameById(widget.gameId);
      setState(() {
        gameTitle = game?.name ?? "Threads"; // Default to "Threads" if title is null
      });
    } catch (e) {
      print('Error fetching game title: $e');
      setState(() {
        gameTitle = "Threads";
      });
    }
  }

  Future<void> _fetchThreads() async {
    try {
      List<QueryDocumentSnapshot> fetchedDocuments =
          await _firestoreService.getThreadsByGameId(widget.gameId);

      List<Map<String, dynamic>> fetchedThreads = await Future.wait(
        fetchedDocuments.map((doc) async {
          Map<String, dynamic> thread = doc.data() as Map<String, dynamic>;
          String threadId = doc.id;
          String userId = thread['userId'];
          Map<String, dynamic>? userInfo = await _firestoreService.getUserInfo(userId);

          thread['userName'] = userInfo?['username'] ?? 'Anonymous';
          thread['avatarUrl'] = userInfo?['profileImageUrl'] ?? null;
          thread['id'] = threadId;

          // Fetch the count of comments in the comments sub-collection
          int commentCount = await _firestoreService.getCommentCountForThread(threadId);
          thread['comments'] = commentCount;

          return thread;
        }).toList(),
      );

      if (filter == 'New') {
        fetchedThreads.sort((a, b) => b['timestamp'].compareTo(a['timestamp']));
      } else if (filter == 'Top') {
        fetchedThreads.sort((a, b) => (b['likes'] ?? 0).compareTo(a['likes'] ?? 0));
      }

      setState(() {
        threads = fetchedThreads;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching threads: ${e.toString()}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching threads: ${e.toString()}')),
      );
      setState(() {
        isLoading = false;
      });
    }
  }

void _copyLinkToClipboard(String threadId) {
  final link = 'https://yourwebsite.com/threads/$threadId'; // Update to your actual URL

  // Copy the link to the clipboard
  FlutterClipboard.copy(link).then((_) {
    // Show a confirmation message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Link copied to clipboard!')),
    );
  });
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // centerTitle: true,
        // title: Text('${gameTitle ?? 'Threads'} Threads'), // Display fetched game title
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black,),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          '${gameTitle ?? 'Threads'} Threads',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildFilterTabs(),
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : threads.isEmpty
                    ? Center(
                        child: Text(
                          'No Threads',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _fetchThreads,
                        child: ListView.builder(
                          padding: EdgeInsets.all(16.0),
                          itemCount: threads.length,
                          itemBuilder: (context, index) {
                            final thread = threads[index];
                            return _buildThreadItem(thread);
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: _currentUser != null
      ? FloatingActionButton(
          onPressed: () {
          if (subscriptionStatus == "free") {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Please upgrade to Premium to post your own threads.')),
            );
          } else {
            _navigateToAddThreadPage(); // Only "paid" users can add threads
          }
        },
          backgroundColor: Color(0xFF41B1F1), // Blue background color
          foregroundColor: Colors.white, // White icon color
          child: Icon(Icons.add), // "Plus" icon
        )
      : null,
    );
  }

  void _navigateToAddThreadPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddThreadsPage(gameId: widget.gameId)),
    );
  }

  Widget _buildFilterTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildFilterTab('New'),
          _buildFilterTab('Top'),
        ],
      ),
    );
  }

  Widget _buildFilterTab(String label) {
    return GestureDetector(
      onTap: () {
        setState(() {
          filter = label;
          _fetchThreads();
        });
      },
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: filter == label ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          if (filter == label)
            Container(
              margin: EdgeInsets.only(top: 4),
              height: 2,
              width: 40,
              color: Colors.blue,
            ),
        ],
      ),
    );
  }

  Widget _buildThreadItem(Map<String, dynamic> thread) {
  List<String> likedBy = List<String>.from(thread['likedBy'] ?? []);

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
              GestureDetector(
                onTap: () {
                  // Pass the userId when navigating to the profile page
                  Navigator.pushNamed(context, '/View_profile', arguments: thread['userId']);
                },
                child: CircleAvatar(
                  backgroundColor: Colors.grey[300],
                  backgroundImage: thread['avatarUrl'] != null && thread['avatarUrl']!.isNotEmpty
                  ? NetworkImage(thread['avatarUrl'])
                  : null,
                  radius: 20,
                  child: thread['avatarUrl'] == null || thread['avatarUrl']!.isEmpty
                  ? Icon(Icons.person, color: Colors.grey)
                  : null,
                ),
              ),
              SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    thread['userName'] ?? 'Anonymous',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    _formatTimestamp(thread['timestamp']),
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              Spacer(),
              if (thread['userId'] == _currentUser?.uid)
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      _editThreadContent(thread['id'], thread['content'] ?? '');
                    } else if (value == 'delete') {
                      _confirmDelete(thread['id']);
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
                ),
            ],
          ),
          SizedBox(height: 16),
            Text(
              thread['content'] ?? '',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 16),
            if (thread['imageUrl'] != null)
              GestureDetector(
                onTap: () => _showImageDialog(thread['imageUrl']),
                child: ClipRRect(
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
              ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildActionButton(
                Icons.favorite,
                thread['likes'],
                likedBy.contains(_currentUser?.uid) ? Colors.red : Colors.grey,
                () {
                  _toggleLike(thread['id'], thread);
                },
              ),
              _buildActionButton(
                Icons.comment,
                thread['comments'],
                Colors.blue,
                () {
                  // if (subscriptionStatus == "free") {
                  //   ScaffoldMessenger.of(context).showSnackBar(
                  //     SnackBar(content: Text('Please upgrade to Diamond Tier to comment on threads.')),
                  //   );
                  //   return;
                  // }
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ThreadDetailPage(
                        threadId: thread['id'],
                        threadContent: thread['content'],
                        threadUserName: thread['userName'] ?? 'Anonymous',
                        threadImageUrl: thread['imageUrl'],
                        threadUserAvatarUrl: thread['avatarUrl'],
                        timestamp: thread['timestamp'],
                        likes: thread['likes'] ?? 0,
                        comments: thread['comments'] ?? 0,
                        shares: thread['shares'] ?? 0,
                      ),
                    ),
                  );
                },
              ),
              _buildActionButton(
                Icons.share,
                thread['shares'],
                Colors.green,
                () {
                  if (subscriptionStatus == "free") {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Please upgrade to Premium to share threads.')),
                    );
                    return;
                  }
                  _shareThreadLink(thread['id']);
                },
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

  Future<void> _confirmDelete(String threadId) async {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    Color textColor = isDarkMode ? Colors.white : Colors.black;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Thread'),
          content: Text('Are you sure you want to delete this thread?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('No', style: TextStyle(color: textColor)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteThread(threadId);
              },
              child: Text('Yes', style: TextStyle(color: textColor)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteThread(String threadId) async {
    try {
      await _firestoreService.deleteThread(threadId);
      _fetchThreads();
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

  void _editThread(Map<String, dynamic> thread) async {
    print("Edit thread with ID: ${thread['id']}");
    // Open edit dialog or navigate to edit screen with current thread data
  }

  Future<void> _toggleLike(String threadId, Map<String, dynamic> thread) async {
    try {
      List<String> likedBy = List<String>.from(thread['likedBy'] ?? []);
      bool liked = likedBy.contains(_currentUser!.uid);

      if (liked) {
        await _firestoreService.unlikeThread(threadId, _currentUser!.uid);
        setState(() {
          thread['likes']--;
          likedBy.remove(_currentUser!.uid);
          thread['likedBy'] = likedBy;
        });
      } else {
        await _firestoreService.likeThread(threadId, _currentUser!.uid);
        setState(() {
          thread['likes']++;
          likedBy.add(_currentUser!.uid);
          thread['likedBy'] = likedBy;
        });
      }
    } catch (e) {
      print('Error toggling like: $e');
    }
  }

  Widget _buildActionButton(
      IconData icon, int count, Color color, VoidCallback onPressed) {
      bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onPressed,
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          SizedBox(width: 4),
          Text(
            count.toString(),
            style: TextStyle(fontSize: 14,
            color: isDarkMode ? Colors.white : Colors.black87,)
          ),
        ],
      ),
    );
  }

  void _showImageDialog(String imageUrl) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: NetworkImage(imageUrl),
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatTimestamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    String formattedDate = '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';

    int hour = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
    String formattedTime = '$hour:${dateTime.minute.toString().padLeft(2, '0')} ${dateTime.hour >= 12 ? 'PM' : 'AM'}';

    return '$formattedDate $formattedTime';
  }
}