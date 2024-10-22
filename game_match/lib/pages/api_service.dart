import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'game_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';

class ApiService {
  // Instance of FlutterSecureStorage for storing sensitive info securely
  final FlutterSecureStorage secureStorage = FlutterSecureStorage();

  // Twitch API client credentials
  final String clientId = dotenv.env['CLIENT_ID']!;
  final String clientSecret = dotenv.env['CLIENT_SECRET']!;

  // Base URL for IGDB API
  final String baseUrl = 'https://api.igdb.com/v4';

  // Function to store the access token
  Future<void> storeAccessToken(String token) async {
    await secureStorage.write(key: 'access_token', value: token);
  }

  // Function to retrieve the access token from secure storage
  Future<String?> retrieveAccessToken() async {
    final token = await secureStorage.read(key: 'access_token');
    return token;
  }

  // Function to authenticate and get an access token from the API
  Future<void> authenticate() async {
    final Uri url = Uri.parse(
        'https://id.twitch.tv/oauth2/token?client_id=$clientId&client_secret=$clientSecret&grant_type=client_credentials');

    try {
      final response = await http.post(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> tokenData = json.decode(response.body);
        await storeAccessToken(tokenData['access_token']);
      } else {
        print('Failed to fetch token: ${response.statusCode} ${response.body}');
      }
    } catch (error) {
      print('Error fetching token: $error');
      throw Exception('Error fetching token: $error');
    }
  }

  // Function to fetch a list of games from the IGDB API
  Future<List<Game>> fetchGames() async {
    final String? accessToken = await retrieveAccessToken();

    if (accessToken == null) {
      await authenticate(); 
      return [];
    }

    final Uri url = Uri.parse('$baseUrl/games');
    const String body = '''
    fields id, name, summary, genres.name, cover.image_id, platforms.name, release_dates.human, websites.url;
    limit 50;
    ''';

    try {
      final response = await http.post(
        url,
        headers: {
          'Client-ID': clientId,
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: body,
      );

      if (response.statusCode == 200) {
        final List<dynamic> gameDataJson = json.decode(response.body);
        final List<Game> games = gameDataJson
            .map((dynamic json) => Game.fromJson(json as Map<String, dynamic>))
            .where((game) {
          return game.name.isNotEmpty &&
              game.coverUrl != null &&
              game.summary != null &&
              game.genres.isNotEmpty;
        }).toList();

        return games;
      } else {
        print('Failed to fetch game data: ${response.statusCode} ${response.body}');
        return [];
      }
    } catch (error) {
      print('Error fetching games: $error');
      return [];
    }
  }

  // Function to check if a genre exists
  Future<bool> checkGenreExists(String genreName) async {
    final String? accessToken = await retrieveAccessToken();

    if (accessToken == null) {
      await authenticate(); 
      return false;
    }

    final Uri url = Uri.parse('$baseUrl/genres');
    final String body = '''
    fields name;
    where name ~ "$genreName";
    limit 1;
    ''';

    try {
      final response = await http.post(
        url,
        headers: {
          'Client-ID': clientId,
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: body,
      );

      if (response.statusCode == 200) {
        final List<dynamic> genreDataJson = json.decode(response.body);
        return genreDataJson.isNotEmpty;
      } else {
        print('Failed to fetch genre data: ${response.statusCode} ${response.body}');
        return false;
      }
    } catch (error) {
      print('Error fetching genre: $error');
      return false;
    }
  }

  // Helper function to parse the release date
  DateTime? _parseReleaseDate(String dateStr) {
    try {
      if (dateStr == "TBD") {
        return null;
      }
      if (RegExp(r'^\d{4}$').hasMatch(dateStr)) {
        int year = int.parse(dateStr);
        return DateTime(year);
      }
      final DateFormat format = DateFormat('MMM dd, yyyy');
      return format.parse(dateStr);
    } catch (e) {
      print('Error parsing release date: $e');
      return null;
    }
  }

  // Method to fetch platforms
  Future<List<dynamic>> fetchPlatforms() async {
    final String? accessToken = await retrieveAccessToken();

    if (accessToken == null) {
      await authenticate();
      return [];
    }
    final Uri url = Uri.parse('$baseUrl/platforms');
    final String body = 'fields name, id, category; where category = 6; limit 50;';

    try {
      final response = await http.post(
        url,
        headers: {
          'Client-ID': clientId,
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: body,
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print('Failed to fetch platform data: ${response.statusCode} ${response.body}');
        return [];
      }
    } catch (error) {
      print('Error fetching platform: $error');
      return [];
    }
  }

  // Get CheapShark IDs for IGDB games and batch fetch prices
  Future<void> fetchPricesForIGDBGames(List<Game> igdbGames) async {
    List<int> cheapSharkIds = await getCheapSharkIds(igdbGames);
    Map<String, double> prices = await fetchPricesForMultipleGames(cheapSharkIds);

    for (var game in igdbGames) {
      final gameId = await fetchGameIDFromCheapShark(game.name);
      if (gameId != null && prices.containsKey(gameId.toString())) {
        game.updatePrice(prices[gameId.toString()]);
      }
    }
  }

  // Fetch CheapShark game ID by title
  Future<int?> fetchGameIDFromCheapShark(String gameTitle) async {
    final Uri url = Uri.parse('https://www.cheapshark.com/api/1.0/games?title=$gameTitle&limit=1&exact=1');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> gameData = json.decode(response.body);
        if (gameData.isNotEmpty) {
          final gameId = int.tryParse(gameData[0]['gameID'].toString());
          return gameId;
        }
      }
      return null;
    } catch (error) {
      print('Error fetching game ID for $gameTitle: $error');
      return null;
    }
  }

  // Fetch prices for multiple games by their IDs from CheapShark
  Future<Map<String, double>> fetchPricesForMultipleGames(List<int> gameIds) async {
    if (gameIds.isEmpty) {
      return {};
    }

    final String idsString = gameIds.join(',');
    final Uri url = Uri.parse('https://www.cheapshark.com/api/1.0/games?ids=$idsString');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final Map<String, dynamic> gamePriceData = json.decode(response.body);
        Map<String, double> prices = {};

        gamePriceData.forEach((gameId, priceInfo) {
          if (priceInfo['cheapestPriceEver'] != null) {
            prices[gameId] = double.tryParse(priceInfo['cheapestPriceEver']['price'].toString()) ?? 0.0;
          }
        });

        return prices;
      } else {
        print('Failed to fetch prices: ${response.reasonPhrase}');
        return {};
      }
    } catch (error) {
      print('Error fetching prices: $error');
      return {};
    }
  }

  // Get CheapShark IDs for IGDB games
  Future<List<int>> getCheapSharkIds(List<Game> igdbGames) async {
    List<int> cheapSharkIds = [];
    for (final game in igdbGames) {
      final gameId = await fetchGameIDFromCheapShark(game.name);
      if (gameId != null) {
        cheapSharkIds.add(gameId);
      }
    }
    await Future.delayed(Duration(milliseconds: 500));
    return cheapSharkIds;
  }
}