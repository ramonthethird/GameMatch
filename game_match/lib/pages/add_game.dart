import 'package:cloud_firestore/cloud_firestore.dart';
import 'game_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> addGame(Game game) async {
    try {
      await _db.collection('games').add({
        'title': game.name,
        'link': game.websiteUrl ?? '',
        'coverUrl': game.coverUrl,
        'summary': game.summary,
        'genres': game.genres,
        'platforms': game.platforms,
        'releaseDates': game.releaseDates,
      });
      print('Game added successfully');
    } catch (e) {
      print('Failed to add game: $e');
    }
  }
}