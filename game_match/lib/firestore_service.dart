import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'pages/game_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> addToWishlist(Game game) async {
  User? user = FirebaseAuth.instance.currentUser;

  // Ensure user is authenticated
  if (user != null) {
    try {
      // Reference to the user's wishlist collection in Firestore
      DocumentReference userRef = _db.collection('users').doc(user.uid);
      CollectionReference wishlistRef = userRef.collection('wishlist');

      // Add the game to the wishlist
      await wishlistRef.doc(game.id).set({
        'id': game.id,
        'name': game.name,
        'summary': game.summary,
        'genres': game.genres,
        'coverUrl': game.coverUrl,
        'platforms': game.platforms,
        'releaseDates': game.releaseDates,
        'websites': game.websites ?? [],
        'timeStamp': FieldValue.serverTimestamp(), // Add the timestamp here
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

    // Ensure user is authenticated
    if (user != null) {
      try {
        CollectionReference wishlistRef =
            _db.collection('users').doc(user.uid).collection('wishlist');
        QuerySnapshot snapshot = await wishlistRef.get();

        // Map the documents to Game objects
        return snapshot.docs.map((doc) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          return Game(
            id: data['id'],
            name: data['name'],
            summary: data['summary'],
            genres: List<String>.from(data['genres'] ?? []),
            coverUrl: data['coverUrl'],
            platforms: List<String>.from(data['platforms'] ?? []),
            releaseDates: List<String>.from(data['releaseDates'] ?? []),
            websites: List<String>.from(data['websites'] ?? []),
          );
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

  // Remove game from the wishlist
  Future<void> removeFromWishlist(String gameId) async {
    User? user = _auth.currentUser;

    // Ensure user is authenticated
    if (user != null) {
      try {
        // Reference to the game document in the user's wishlist
        DocumentReference gameRef = _db
            .collection('users')
            .doc(user.uid)
            .collection('wishlist')
            .doc(gameId);

        // Delete the game from the wishlist
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

    // Ensure user is authenticated
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
}