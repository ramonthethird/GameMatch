import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'pages/game_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;


  // ------------------ Game Management Methods ------------------

  Future<void> addToWishlist(Game game) async {
    User? user = _auth.currentUser;

    if (user != null) {
      try {
        DocumentReference userRef = _db.collection('users').doc(user.uid);
        CollectionReference wishlistRef = userRef.collection('wishlist');

        await wishlistRef.doc(game.id).set({
          ...game.toMap(),
          'timeStamp': FieldValue.serverTimestamp(),
        });

        print('Game added to wishlist: ${game.name}');
      } catch (e) {
        print('Error adding game to wishlist: $e');
      }
    } else {
      print('User is not authenticated. Please log in.');
    }
  }

  // Retrieve games from the user's wishlist
  Future<List<Game>> getWishlist() async {
    User? user = _auth.currentUser;

    if (user != null) {
      try {
        CollectionReference wishlistRef =
            _db.collection('users').doc(user.uid).collection('wishlist');
        QuerySnapshot snapshot = await wishlistRef.get();

        return snapshot.docs.map((doc) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          return Game.fromMap(data);
        }).toList();
      } catch (e) {
        print('Error fetching wishlist: $e');
        return [];
      }
    } else {
      print('User is not authenticated. Please log in.');
      return [];
    }
  }

  // Remove a game from the user's wishlist
  Future<void> removeFromWishlist(String gameId) async {
    User? user = _auth.currentUser;

    if (user != null) {
      try {
        DocumentReference gameRef = _db
            .collection('users')
            .doc(user.uid)
            .collection('wishlist')
            .doc(gameId);

        await gameRef.delete();
        print('Game removed from wishlist: $gameId');
      } catch (e) {
        print('Error removing game from wishlist: $e');
      }
    } else {
      print('User is not authenticated. Please log in.');
    }
  }

  // Check if a game is already in the user's wishlist
  Future<bool> isGameInWishlist(String gameId) async {
    User? user = _auth.currentUser;

    if (user != null) {
      try {
        DocumentReference gameRef = _db
            .collection('users')
            .doc(user.uid)
            .collection('wishlist')
            .doc(gameId);

        DocumentSnapshot doc = await gameRef.get();
        return doc.exists;
      } catch (e) {
        print('Error checking if game is in wishlist: $e');
        return false;
      }
    } else {
      print('User is not authenticated. Please log in.');
      return false;
    }
  }

  // Save games in bulk to Firestore (for caching purposes)
  Future<void> saveGames(List<Game> games) async {
    try {
      WriteBatch batch = _db.batch();
      for (Game game in games) {
        DocumentReference gameRef = _db.collection('games').doc(game.id);
        batch.set(gameRef, game.toMap());
      }
      await batch.commit();
      print('Games saved to Firestore');
    } catch (e) {
      print('Error saving games to Firestore: $e');
    }
  }

  // Load games from Firestore
  Future<List<Game>> loadGames() async {
    try {
      QuerySnapshot snapshot = await _db.collection('games').get();
      return snapshot.docs.map((doc) {
        return Game.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      print('Error loading games from Firestore: $e');
      return [];
    }
  }

  // Retrieve a single game by its ID from Firestore
  Future<Game?> getGameById(String gameId) async {
    try {
      DocumentSnapshot doc = await _db.collection('games').doc(gameId).get();
      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return Game.fromMap(data);
      }
    } catch (e) {
      print('Error fetching game from Firestore: $e');
    }
    return null;
  }

  // Save a single game to Firestore (for individual caching)
  Future<void> saveGameToFirestore(Game game) async {
    try {
      await _db.collection('games').doc(game.id).set(game.toMap());
      print('Game saved to Firestore: ${game.name}');
    } catch (e) {
      print('Error saving game to Firestore: $e');
    }
  }

  // ------------------ Thread Management Methods ------------------

  Future<Map<String, dynamic>?> getUserInfo(String userId) async {
    try {
      DocumentSnapshot userDoc = await _db.collection('users').doc(userId).get();
      if (userDoc.exists) {
        return userDoc.data() as Map<String, dynamic>;
      }
    } catch (e) {
      print('Error fetching user info: $e');
    }
    return null;
  }

  Future<List<QueryDocumentSnapshot>> getThreadsByGameId(String gameId) async {
    try {
      QuerySnapshot snapshot = await _db
          .collection('threads')
          .where('gameId', isEqualTo: gameId)
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs;
    } catch (e) {
      print('Error fetching threads: $e');
      return [];
    }
  }

  Future<void> addThread(String gameId, String content, String userName, {String? imageUrl}) async {
    User? user = _auth.currentUser;

    if (user != null) {
      try {
        await _db.collection('threads').add({
          'gameId': gameId,
          'userId': user.uid,
          'userName': userName,
          'content': content,
          'imageUrl': imageUrl,
          'timestamp': FieldValue.serverTimestamp(),
          'likes': 0,
          'likedBy': [],
          'comments': 0,
          'shares': 0,
        });
        print('Thread added successfully');
      } catch (e) {
        print('Error adding thread: $e');
      }
    } else {
      print('User is not authenticated. Please log in.');
    }
  }

  Future<void> likeThread(String threadId, String userId) async {
  try {
    DocumentReference threadRef = _db.collection('threads').doc(threadId);
    await threadRef.update({
      'likedBy': FieldValue.arrayUnion([userId]),
      'likes': FieldValue.increment(1),
    });
    print('Thread liked successfully');
  } catch (e) {
    print('Error liking thread: $e');
  }
}

Future<void> unlikeThread(String threadId, String userId) async {
  try {
    DocumentReference threadRef = _db.collection('threads').doc(threadId);
    await threadRef.update({
      'likedBy': FieldValue.arrayRemove([userId]),
      'likes': FieldValue.increment(-1),
    });
    print('Thread unliked successfully');
  } catch (e) {
    print('Error unliking thread: $e');
  }
}


  Future<void> addComment(String threadId, String commentContent) async {
    User? user = _auth.currentUser;

    if (user != null) {
      try {
        DocumentReference commentRef = _db
            .collection('threads')
            .doc(threadId)
            .collection('comments')
            .doc();

        await commentRef.set({
          'userId': user.uid,
          'userName': user.displayName ?? 'Anonymous',
          'comment': commentContent,
          'timestamp': FieldValue.serverTimestamp(),
        });

        DocumentReference threadRef = _db.collection('threads').doc(threadId);
        await threadRef.update({
          'comments': FieldValue.increment(1),
        });

        print('Comment added to thread: $threadId');
      } catch (e) {
        print('Error adding comment: $e');
      }
    } else {
      print('User is not authenticated. Please log in.');
    }
  }

  Future<List<Map<String, dynamic>>> getCommentsForThread(String threadId) async {
    try {
      QuerySnapshot snapshot = await _db
          .collection('threads')
          .doc(threadId)
          .collection('comments')
          .orderBy('timestamp', descending: false)
          .get();

      return snapshot.docs.map((doc) {
        return doc.data() as Map<String, dynamic>;
      }).toList();
    } catch (e) {
      print('Error fetching comments for thread: $e');
      return [];
    }
  }

  Future<void> deleteThread(String threadId) async {
    try {
      await _db.collection('threads').doc(threadId).delete();
      print('Thread deleted: $threadId');
    } catch (e) {
      print('Error deleting thread: $e');
    }
  }
}
