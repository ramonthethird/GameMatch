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
// loadRecommendedGames method to fetch the recommended games for a specific user
 Future<List<Game>> loadRecommendedGames(String userId) async {
  try {
    DocumentSnapshot userDoc = await _db.collection('users').doc(userId).get();
    if (userDoc.exists) {
      Map<String, dynamic>? userData = userDoc.data() as Map<String, dynamic>?;
      if (userData != null && userData.containsKey('recommendedGames')) {
        List<dynamic> recommendedGames = userData['recommendedGames'] as List<dynamic>;
        return recommendedGames.map((gameData) {
          if (gameData is Map<String, dynamic>) {
            // Convert 'id' to a string if necessary
            if (gameData.containsKey('id') && gameData['id'] is int) {
              gameData['id'] = gameData['id'].toString();
            }
            return Game.fromMap(gameData);
          }
          return null;
        }).whereType<Game>().toList();
      }
    }
    return [];
  } catch (e) {
    print('Error loading recommended games for user $userId: $e');
    return [];
  }
}

// getGameById method to show the game details for a specific gameId
Future<Game?> getGameById(dynamic gameId) async {
  try {
    // Convert input gameId to string for consistent comparison
    String searchId = gameId.toString();
    
    // Retrieve all documents in the 'users' collection
    QuerySnapshot snapshot = await _db.collection('users').get();
    
    // Iterate through each user's data
    for (var userDoc in snapshot.docs) {
      Map<String, dynamic>? userData;
      try {
        userData = userDoc.data() as Map<String, dynamic>?;
      } catch (e) {
        print('Error casting user data: $e');
        continue;
      }
      
      if (userData != null && userData.containsKey('recommendedGames')) {
        List<dynamic> recommendedGames;
        try {
          recommendedGames = userData['recommendedGames'] as List<dynamic>;
        } catch (e) {
          print('Error casting recommendedGames: $e');
          continue;
        }
        
        // Search for the game with matching gameId
        for (var gameData in recommendedGames) {
          try {
            if (gameData is Map<String, dynamic>) {
              // Debug log the game data
              print('Checking game data: $gameData');
              
              if (gameData.containsKey('id')) {
                var storedId = gameData['id'];
                // Debug log the stored ID and its type
                print('Found stored ID: $storedId (Type: ${storedId.runtimeType})');
                
                // Convert both to strings for comparison
                String storedIdString = storedId.toString();
                if (storedIdString == searchId) {
                  // Convert all numeric IDs in the map to strings
                  Map<String, dynamic> sanitizedGameData = Map.from(gameData);
                  sanitizedGameData['id'] = storedIdString;
                  
                  print('Match found! Converting to Game object...'); // Debug log
                  return Game.fromMap(sanitizedGameData);
                }
              }
            }
          } catch (e) {
            print('Error processing game data: $e');
            continue;
          }
        }
      }
    }
    
    print('Game with gameId $searchId not found in recommendedGames.');
    return null;
  } catch (e) {
    print('Error searching for gameId $gameId in recommendedGames: $e');
    return null;
  }
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
  Future<QuerySnapshot<Map<String, dynamic>>> getRecentThreads({int limit = 4}) {
  return _db
      .collection('threads')
      .orderBy('timestamp', descending: true)
      .limit(limit)
      .get();
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

Future<int> getCommentCountForThread(String threadId) async {
  QuerySnapshot commentsSnapshot = await _db
      .collection('threads')
      .doc(threadId)
      .collection('comments')
      .get();
  return commentsSnapshot.size;
}

Future<void> updateThreadContent(String threadId, String newContent) async {
  try {
    await FirebaseFirestore.instance.collection('threads').doc(threadId).update({
      'content': newContent,
    });
    print('Thread content updated successfully');
  } catch (e) {
    print('Error updating thread content: $e');
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

  Future<void> deleteComment(String threadId, String commentId) async {
    try {
      DocumentReference commentRef = _db
          .collection('threads')
          .doc(threadId)
          .collection('comments')
          .doc(commentId);

      await commentRef.delete();

      // Decrement comment count on the thread document
      DocumentReference threadRef = _db.collection('threads').doc(threadId);
      await threadRef.update({
        'comments': FieldValue.increment(-1),
      });

      print('Comment deleted from thread: $threadId');
    } catch (e) {
      print('Error deleting comment: $e');
    }
  }
}
