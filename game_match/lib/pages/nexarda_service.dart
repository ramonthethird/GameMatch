import 'dart:convert';
import 'package:http/http.dart' as http;
import 'vidgame_model.dart';
import 'price_results.dart';
class NexardaService {
  final String baseSearchUrl = 'https://www.nexarda.com/api/v3/search';
  final String basePriceUrl = 'https://www.nexarda.com/api/v3/prices';

  // Fetch game details by name and return a VideoGame instance if found
  Future<VideoGame?> fetchGameByName(String gameName) async {
    final encodedGameName = Uri.encodeComponent(gameName);
    final url = Uri.parse('$baseSearchUrl?type=games&q=$encodedGameName');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final items = data['results']['items'];
        if (items != null && items.isNotEmpty) {
          return VideoGame.fromJson(items[0]);
        } else {
          print('No game found for the provided name.');
          return null;
        }
      } else {
        print('Failed to load game data. Status code: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error fetching game: $e');
      return null;
    }
  }

  // New method to fetch price offers for a specific game ID
  Future<List<PriceOffer>> fetchPriceOffersById(int gameId, {String currency = 'USD'}) async {
    final url = Uri.parse('$basePriceUrl?type=game&id=$gameId&currency=$currency');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        return (data['prices']['list'] as List)
            .map((offerJson) => PriceOffer.fromJson(offerJson))
            .toList();
      } else {
        print('Failed to load price offers. Status code: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error fetching price offers: $e');
      return [];
    }
  }
}