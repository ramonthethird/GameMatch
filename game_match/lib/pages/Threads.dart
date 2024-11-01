import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:game_match/firestore_service.dart';
import 'Add_Threads.dart';
import 'Thread_Comments.dart';

class ThreadsPage extends StatefulWidget {
  final String gameId;
  const ThreadsPage({super.key, required this.gameId});

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

  @override
  void initState() {
    super.initState();
    _checkUserStatus();
  }

  void _checkUserStatus() {
    _currentUser = _auth.currentUser;
    if (_currentUser != null) {
      _fetchThreads();
    } else {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You need to be logged in to view threads.')),
      );
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
          thread['id'] = threadId;
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

  Future<void> _addThread(String content) async {
    if (content.isNotEmpty && _currentUser != null) {
      try {
        String userName = await _getUserName(_currentUser!.uid);
        await _firestoreService.addThread(widget.gameId, content, userName);
        _fetchThreads();
      } catch (e) {
        print('Error adding thread: $e');
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in to post a thread.')),
      );
    }
  }

  Future<String> _getUserName(String userId) async {
    Map<String, dynamic>? userInfo = await _firestoreService.getUserInfo(userId);
    return userInfo?['username'] ?? _currentUser!.email?.split('@')[0] ?? 'Anonymous';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Threads'),
      ),
      body: Column(
        children: [
          _buildFilterTabs(),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : threads.isEmpty
                    ? const Center(
                        child: Text(
                          'No Threads',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _fetchThreads,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16.0),
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
              onPressed: () => _navigateToAddThreadPage(),
              child: const Icon(Icons.add),
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
              margin: const EdgeInsets.only(top: 4),
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
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.grey[300],
                  backgroundImage: NetworkImage(
                    thread['avatarUrl'] ?? 'https://via.placeholder.com/150',
                  ),
                  radius: 20,
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      thread['userName'] ?? 'Anonymous',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatTimestamp(thread['timestamp']),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                if (thread['userId'] == _currentUser?.uid)
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        _editThread(thread);
                      } else if (value == 'delete') {
                        _confirmDelete(thread['id']);
                      }
                    },
                    itemBuilder: (BuildContext context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Text('Edit'),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('Delete'),
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              thread['content'] ?? '',
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
            const SizedBox(height: 16),
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
                        child: const Center(child: Icon(Icons.image_not_supported)),
                      );
                    },
                  ),
                ),
              ),
            const SizedBox(height: 16),
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
                // Inside ThreadsPage -> _buildThreadItem
                _buildActionButton(
                  Icons.comment,
                  thread['comments'],
                  Colors.blue,
                  () {
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
                    // Implement sharing functionality
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
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this thread?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteThread(threadId);
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
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
        const SnackBar(content: Text('Thread deleted successfully.')),
      );
    } catch (e) {
      print('Error deleting thread: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error deleting thread.')),
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
    return GestureDetector(
      onTap: onPressed,
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 4),
          Text(
            count.toString(),
            style: const TextStyle(fontSize: 14, color: Colors.black87),
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