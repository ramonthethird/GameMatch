import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class ThreadDetailPage extends StatefulWidget {
  final String threadId;
  final String threadContent;
  final String threadUserName;
  final String? threadImageUrl;
  final String? threadUserAvatarUrl;
  final Timestamp timestamp;
  final int likes;
  final int comments;
  final int shares;

  const ThreadDetailPage({
    Key? key,
    required this.threadId,
    required this.threadContent,
    required this.threadUserName,
    this.threadImageUrl,
    this.threadUserAvatarUrl,
    required this.timestamp,
    required this.likes,
    required this.comments,
    required this.shares,
  }) : super(key: key);

  @override
  _ThreadDetailPageState createState() => _ThreadDetailPageState();
}

class _ThreadDetailPageState extends State<ThreadDetailPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _commentController = TextEditingController();
  List<Map<String, dynamic>> comments = [];
  User? currentUser;
  bool isLoading = true;
  bool isThreadLiked = false;
  bool _isPaidUser = false;
  bool isSubscriptionLoading = true; // Track loading state of subscription check
  int threadLikes = 0;
  int commentCount = 0;

  @override
  void initState() {
    super.initState();
    currentUser = _auth.currentUser;
    threadLikes = widget.likes;
    _checkIfThreadLiked();
    _fetchComments();
    _listenToCommentCount(); // Add listener for comments count
    _fetchSubscriptionStatus(); // Fetch subscription status for current user
  }

  Future<void> _fetchSubscriptionStatus() async {
    if (currentUser != null) {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(currentUser!.uid).get();
      setState(() {
        _isPaidUser = userDoc.data()?['subscription'] == 'paid';
        isSubscriptionLoading = false;
      });
    } else {
      setState(() => isSubscriptionLoading = false);
    }
  }

  void _listenToCommentCount() {
    FirebaseFirestore.instance
        .collection('threads')
        .doc(widget.threadId)
        .collection('comments')
        .snapshots()
        .listen((snapshot) {
      setState(() {
        commentCount = snapshot.docs.length; // Update comment count dynamically
      });
    });
  }

  Future<void> _checkIfThreadLiked() async {
    if (currentUser == null) return;

    final threadDoc = await FirebaseFirestore.instance
        .collection('threads')
        .doc(widget.threadId)
        .get();

    if (threadDoc.exists) {
      final data = threadDoc.data()!;
      final likedBy = List<String>.from(data['likedBy'] ?? []);
      setState(() {
        isThreadLiked = likedBy.contains(currentUser!.uid);
      });
    }
  }

  Future<void> _toggleThreadLike() async {
    if (currentUser == null) return;

    final threadRef = FirebaseFirestore.instance.collection('threads').doc(widget.threadId);
    final threadDoc = await threadRef.get();

    if (threadDoc.exists) {
      final data = threadDoc.data()!;
      final likedBy = List<String>.from(data['likedBy'] ?? []);

      setState(() {
        if (likedBy.contains(currentUser!.uid)) {
          likedBy.remove(currentUser!.uid);
          threadLikes--;
          isThreadLiked = false;
        } else {
          likedBy.add(currentUser!.uid);
          threadLikes++;
          isThreadLiked = true;
        }
      });

      await threadRef.update({'likedBy': likedBy, 'likes': threadLikes});
    }
  }

  Future<void> _fetchComments() async {
    setState(() => isLoading = true);

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('threads')
          .doc(widget.threadId)
          .collection('comments')
          .orderBy('timestamp', descending: true)
          .get();

      final fetchedComments = await Future.wait(querySnapshot.docs.map((doc) async {
        Map<String, dynamic> commentData = doc.data() as Map<String, dynamic>;

        if (commentData['userId'] != null) {
          final userSnapshot = await FirebaseFirestore.instance
              .collection('users')
              .doc(commentData['userId'])
              .get();
          if (userSnapshot.exists) {
            final userData = userSnapshot.data() as Map<String, dynamic>;
            commentData['userName'] = userData['username'] ?? 'Anonymous';
            commentData['userAvatarUrl'] = userData['profileImageUrl'] ?? null;
          } else {
            commentData['userName'] = 'Anonymous';
          }
        } else {
          commentData['userName'] = 'Anonymous';
        }

        commentData['docId'] = doc.id;
        commentData['isLiked'] = (commentData['likedBy'] ?? []).contains(currentUser?.uid);
        return commentData;
      }).toList());

      setState(() {
        comments = fetchedComments;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching comments: $e');
      setState(() => isLoading = false);
    }
  }

  Future<void> _addComment(String content) async {
    if (content.isEmpty || !_isPaidUser) return; // Prevent empty or unauthorized comments

    final user = _auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You need to be logged in to comment.')),
      );
      return;
    }

    try {
      final userSnapshot = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final userData = userSnapshot.data() as Map<String, dynamic>?;

      final userName = userData?['username'] ?? 'Anonymous';
      final userAvatarUrl = userData?['profileImageUrl'];

      await FirebaseFirestore.instance
          .collection('threads')
          .doc(widget.threadId)
          .collection('comments')
          .add({
        'userId': user.uid,
        'userName': userName,
        'userAvatarUrl': userAvatarUrl,
        'content': content,
        'timestamp': FieldValue.serverTimestamp(),
        'likedBy': [],
        'likes': 0,
      });

      _commentController.clear();
      _fetchComments();
    } catch (e) {
      print('Error adding comment: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add comment. Please try again.')),
      );
    }
  }

  Future<void> _deleteComment(String commentId) async {

  bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
  Color textColor = isDarkMode ? Colors.white : Colors.black; 
  // Show a confirmation dialog before deleting
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Delete Comment'),
        content: Text('Are you sure you want to delete this comment?'),
        actions: [
          TextButton(
            child: Text('No', style: TextStyle(color: textColor)),
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog without deleting
            },
          ),
          TextButton(
            child: Text('Yes', style: TextStyle(color: textColor)),
            onPressed: () async {
              Navigator.of(context).pop(); // Close the dialog first

              try {
                // Delete the comment from Firestore
                await FirebaseFirestore.instance
                    .collection('threads')
                    .doc(widget.threadId)
                    .collection('comments')
                    .doc(commentId)
                    .delete();
                
                _fetchComments(); // Refresh comments after deletion
              } catch (e) {
                print('Error deleting comment: $e');
              }
            },
          ),
        ],
      );
    },
  );
}


  Future<void> _editComment(String commentId, String currentContent) async {
    TextEditingController editController = TextEditingController(text: currentContent);

    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    Color textColor = isDarkMode ? Colors.white : Colors.black;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Comment'),
          content: Container(
          width: 500,
          height: 250,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Comment',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                TextField(
                  controller: editController,
                  maxLines: 5,
                  maxLength: 150,
                  decoration: InputDecoration(
                    hintText: 'Add a comment...',
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
                if (editController.text.trim().isEmpty) return;
                await FirebaseFirestore.instance
                    .collection('threads')
                    .doc(widget.threadId)
                    .collection('comments')
                    .doc(commentId)
                    .update({'content': editController.text.trim()});
                Navigator.of(context).pop();
                _fetchComments();
              },
              child: Text('Save', style: TextStyle(color: textColor)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _toggleCommentLike(String commentId, bool isLiked, int index) async {
    if (currentUser == null) return;

    final commentRef = FirebaseFirestore.instance
        .collection('threads')
        .doc(widget.threadId)
        .collection('comments')
        .doc(commentId);

    final commentDoc = await commentRef.get();
    if (commentDoc.exists) {
      final data = commentDoc.data()!;
      final likedBy = List<String>.from(data['likedBy'] ?? []);
      int likes = data['likes'] ?? 0;

      setState(() {
        if (isLiked) {
          likedBy.remove(currentUser!.uid);
          likes--;
          comments[index]['isLiked'] = false;
        } else {
          likedBy.add(currentUser!.uid);
          likes++;
          comments[index]['isLiked'] = true;
        }
        comments[index]['likes'] = likes;
      });

      await commentRef.update({'likedBy': likedBy, 'likes': likes});
    }
  }

  String _formatTimestamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return DateFormat('yyyy-MM-dd hh:mm a').format(dateTime);
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
        title: Text(
          'Comments',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              color: Theme.of(context).cardColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.grey[300],
                          backgroundImage: widget.threadUserAvatarUrl != null && widget.threadUserAvatarUrl!.isNotEmpty
                            ? NetworkImage(widget.threadUserAvatarUrl!)
                            : null,
                          radius: 20,
                          child: widget.threadUserAvatarUrl == null || widget.threadUserAvatarUrl!.isEmpty
                            ? Icon(Icons.person, color: Colors.grey)
                            : null,
                        ),
                        SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.threadUserName,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              _formatTimestamp(widget.timestamp),
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.threadContent,
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 12),
                    if (widget.threadImageUrl != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            widget.threadImageUrl!,
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              // return Container(
                              //   height: 150,
                              //   color: Colors.grey[300],
                              //   child: Center(
                              //       child: Icon(Icons.image_not_supported)),
                              // );
                              return const SizedBox();
                            },
                          ),
                        ),
                      ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildCountButton(
                          Icons.favorite,
                          threadLikes,
                          isThreadLiked ? Colors.red : Colors.grey,
                          onPressed: _toggleThreadLike,
                        ),
                        _buildCountButton(
                          Icons.comment,
                          commentCount,
                          Colors.blue,
                        ),
                        _buildCountButton(
                          Icons.share,
                          widget.shares,
                          Colors.green,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Divider(),
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
  itemCount: comments.length,
  itemBuilder: (context, index) {
    final comment = comments[index];
    final commentId = comment['docId'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Stack(
        children: [
          Card(
            color: Theme.of(context).cardColor,
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Profile picture
                      GestureDetector(
                        onTap: () {
                          // Pass the userId when navigating to the profile page
                          Navigator.pushNamed(context, '/View_profile', arguments: comment['userId']);
                        },
                        child: CircleAvatar(
                          backgroundColor: Colors.grey[300],
                          backgroundImage: comment['userAvatarUrl'] != null && comment['userAvatarUrl']!.isNotEmpty
                            ? NetworkImage(comment['userAvatarUrl'])
                            : AssetImage('assets/default_avatar.png') as ImageProvider,
                          radius: 20,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Username and date
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            comment['userName'] ?? 'Anonymous',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            comment['timestamp'] != null
                                ? _formatTimestamp(comment['timestamp'])
                                : 'No timestamp available',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Comment content
                  Padding(
                    padding: const EdgeInsets.only(left: 0.0), // Align content under profile picture
                    child: Text(
                      comment['content'] ?? '',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Like button
                  Padding(
                    padding: const EdgeInsets.only(left: 0.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        _buildCountButton(
                          Icons.favorite,
                          comment['likes'] ?? 0,
                          comment['isLiked'] ? Colors.red : Colors.grey,
                          onPressed: () => _toggleCommentLike(
                              commentId, comment['isLiked'], index),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Popup menu icon positioned in the top right corner of the card
          Positioned(
            top: 4,
            right: 8,
            child: comment['userId'] == currentUser?.uid
                ? PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'Edit') {
                        _editComment(commentId, comment['content'] ?? '');
                      } else if (value == 'Delete') {
                        _deleteComment(commentId);
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
                  )
                : SizedBox.shrink(),
          ),
        ],
      ),
    );
  },
),
          ),
          Divider(),
          if (!isSubscriptionLoading) // Ensure subscription check is complete
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      enabled: _isPaidUser,
                      decoration: InputDecoration(
                        hintText: _isPaidUser ? 'Add a comment...' : 'Upgrade to comment...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.send),
                    color: Color(0xFF41B1F1),
                    onPressed: _isPaidUser
                        ? () => _addComment(_commentController.text.trim())
                        : null,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCountButton(
      IconData icon, int count, Color color, {VoidCallback? onPressed}) {
        bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return IconButton(
      icon: Row(
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
      onPressed: onPressed,
    );
  }
}