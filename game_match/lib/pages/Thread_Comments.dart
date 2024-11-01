import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
    super.key,
    required this.threadId,
    required this.threadContent,
    required this.threadUserName,
    this.threadImageUrl,
    this.threadUserAvatarUrl,
    required this.timestamp,
    required this.likes,
    required this.comments,
    required this.shares,
  });

  @override
  _ThreadDetailPageState createState() => _ThreadDetailPageState();
}

class _ThreadDetailPageState extends State<ThreadDetailPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _commentController = TextEditingController();
  List<Map<String, dynamic>> comments = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchComments();
  }

  Future<void> _fetchComments() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('threads')
          .doc(widget.threadId)
          .collection('comments')
          .orderBy('timestamp', descending: true)
          .get();

      // Retrieve comments and user info concurrently
      final fetchedComments = await Future.wait(querySnapshot.docs.map((doc) async {
        Map<String, dynamic> commentData = doc.data();

        // Get user data based on userId
        if (commentData['userId'] != null) {
          DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
              .collection('users')
              .doc(commentData['userId'])
              .get();
          if (userSnapshot.exists) {
            Map<String, dynamic> userData = userSnapshot.data() as Map<String, dynamic>;
            commentData['userName'] = userData['username'] ?? 'Anonymous';
            commentData['userAvatarUrl'] = userData['avatarUrl'];
          } else {
            commentData['userName'] = 'Anonymous';
          }
        } else {
          commentData['userName'] = 'Anonymous';
        }

        return commentData;
      }).toList());

      setState(() {
        comments = fetchedComments;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching comments: $e');
    }
  }

  Future<void> _addComment(String content) async {
    if (content.isEmpty) return;

    final User? user = _auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You need to be logged in to comment.')),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('threads')
          .doc(widget.threadId)
          .collection('comments')
          .add({
        'userId': user.uid,
        'content': content,
        'timestamp': FieldValue.serverTimestamp(),
      });

      _commentController.clear();
      _fetchComments();
    } catch (e) {
      print('Error adding comment: $e');
    }
  }

  String _formatTimestamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    String formattedDate =
        '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';

    int hour = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
    String formattedTime =
        '$hour:${dateTime.minute.toString().padLeft(2, '0')} ${dateTime.hour >= 12 ? 'PM' : 'AM'}';

    return '$formattedDate $formattedTime';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thread Details'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
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
                          backgroundImage: widget.threadUserAvatarUrl != null
                              ? NetworkImage(widget.threadUserAvatarUrl!)
                              : const AssetImage('assets/default_avatar.png')
                                  as ImageProvider,
                          radius: 20,
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.threadUserName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              _formatTimestamp(widget.timestamp),
                              style: const TextStyle(
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
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 12),
                    if (widget.threadImageUrl != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0, bottom: 16.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            widget.threadImageUrl!,
                            height: 150,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 150,
                                color: Colors.grey[300],
                                child: const Center(
                                    child: Icon(Icons.image_not_supported)),
                              );
                            },
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildActionButton(Icons.favorite, widget.likes,
                            widget.likes > 0 ? Colors.red : Colors.grey),
                        _buildActionButton(
                            Icons.comment, widget.comments, Colors.blue),
                        _buildActionButton(
                            Icons.share, widget.shares, Colors.green),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          const Divider(),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: comments.length,
                    itemBuilder: (context, index) {
                      final comment = comments[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8.0, vertical: 4.0),
                        child: Card(
                          elevation: 1,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.grey[300],
                              backgroundImage: comment['userAvatarUrl'] != null
                                  ? NetworkImage(comment['userAvatarUrl'])
                                  : const AssetImage('assets/default_avatar.png')
                                      as ImageProvider,
                            ),
                            title: Text(comment['userName'] ?? 'Anonymous'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text(comment['content'] ?? ''),
                                const SizedBox(height: 4),
                                Text(
                                  comment['timestamp'] != null
                                      ? _formatTimestamp(
                                          comment['timestamp'])
                                      : 'No timestamp available',
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: const InputDecoration(
                      hintText: 'Add a comment...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    _addComment(_commentController.text.trim());
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, int count, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 4),
        Text(
          count.toString(),
          style: const TextStyle(fontSize: 14, color: Colors.black87),
        ),
      ],
    );
  }
}