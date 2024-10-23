import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'pages/game_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Add a game to the user's wishlist
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
}
