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
    print('Storing access token: $token');
    await secureStorage.write(key: 'access_token', value: token);
  }

  // Function to retrieve the access token from secure storage
  Future<String?> retrieveAccessToken() async {
    final token = await secureStorage.read(key: 'access_token');
    print('Retrieved access token: $token');
    return token;
  }

  // Function to autheticate and get an access token from the API
  Future<void> authenticate() async {
    final Uri url = Uri.parse(
        'https://id.twitch.tv/oauth2/token?client_id=$clientId&client_secret=$clientSecret&grant_type=client_credentials');

    try {
      // POST request to fetch the access token
      final response = await http.post(url);

      print('Authentication Response: ${response.body}');

      //Check if the request was successful
      if (response.statusCode == 200) {
        final Map<String, dynamic> tokenData = json.decode(response.body);
        await storeAccessToken(tokenData['access_token']);
        print('Access token stored successfully');
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
    // Retrieve access token from secure storage
    final String? accessToken = await retrieveAccessToken();

    // If no token available authenticate and fetch a new token
    if (accessToken == null) {
      print('Access token is null. Please fetch a new one.');
      await authenticate(); // Authenticate if the token is not available
      return [];
    }

    // API endpoint to fetch game data
    final Uri url = Uri.parse('https://api.igdb.com/v4/games');
    const String body = '''
    fields name, summary, genres.name, cover.url, platforms.name, release_dates.human, websites.url, tags, screenshots.image_id;
    where platforms = (6,48,49);
    limit 30;
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

      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      // If request is successful
      if (response.statusCode == 200) {
        print('Response Body: ${response.body}');
        // Decode the response body into a list of dynamic JSON objects
        final List<dynamic> gameDataJson = json.decode(response.body);

        // Convert JSON objects into a list of Game objects
        final List<Game> games = gameDataJson
            .map((dynamic json) => Game.fromJson(json as Map<String, dynamic>))
            .where((game) {
          // filter games to have screenshots, a non-empty summary, and a release date from 2020 and onwards
          // for screenshots
          if (game.screenshotUrls == null || game.summary!.isEmpty) {
            return false;
          }
          // for game description
          if (game.summary == null || game.summary!.isEmpty) {
            return false;
          }
          // for release date
          if (game.releaseDates == null || game.releaseDates.isEmpty) {
            return false;
          }
          String releaseDateStr = game.releaseDates.first;
          DateTime? releaseDate = _parseReleaseDate(releaseDateStr);
          return releaseDate != null && releaseDate.year >= 2020;
        }).toList();

        return games;
      } else {
        print(
            'Failed to fetch game data: ${response.statusCode} ${response.body}');
        return [];
      }
    } catch (error) {
      print('Error fetching games: $error');
      return [];
    }
  }

  // Helper function to parse the release date
  DateTime? _parseReleaseDate(String dateStr) {
    try {
      // Handle special cases
      if (dateStr == "TBD") {
        print('Release date is TBD, skipping');
        return null;
      }

      // If the date string is only a year, parse it manually
      if (RegExp(r'^\d{4}$').hasMatch(dateStr)) {
        int year = int.parse(dateStr);
        return DateTime(year);
      }

      // For dates formatted MMM dd yyyy
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
      print('Acess token is null. Please fetch a new one.');
      await authenticate();
      return [];
    }
    final Uri url = Uri.parse('$baseUrl/platforms');
    final String body =
        'fields name, id, category; where category = 6; limit 50;';

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
        print('Platform data fetched successfully');
        return json.decode(response.body);
      } else {
        print(
            'Failed to fetch platform data: ${response.statusCode} ${response.body}');
        return [];
      }
    } catch (error) {
      print('error fetching platform: $error');
      return [];
    }
  }

  // CheapShark API

  // Fetch CheapShark game ID by title
  Future<int?> fetchGameIDFromCheapShark(String gameTitle) async {
    //final Uri url = Uri.parse('https://www.cheapshark.com/api/1.0/games?title=$gameTitle&limit=1');
    final Uri url = Uri.parse(
        'https://www.cheapshark.com/api/1.0/games?title=$gameTitle&limit=1&exact=1');

    // log the game title and URL
    print('Fetching CheapShark game ID for $gameTitle from URL: $url');

    try {
      final response = await http.get(url);
      print('Response Status Code for $gameTitle: ${response.statusCode}');
      print('Response Body for $gameTitle: ${response.body}');
      if (response.statusCode == 200) {
        final List<dynamic> gameData = json.decode(response.body);
        if (gameData.isNotEmpty) {
          final gameId = int.tryParse(gameData[0]['gameID'].toString());
          print('Fetched game ID for $gameTitle: $gameId');
          return gameId;
        } else {
          print('No game ID found for $gameTitle');
        }
      }
      // return null if no ID is found
      return null;
    } catch (error) {
      print('Error fetching game ID for $gameTitle: $error');
      return null;
    }
  }

  // Fetch prices for multiple games by their IDs from CheapShark
  Future<Map<String, double>> fetchPricesForMultipleGames(
      List<int> gameIds) async {
    if (gameIds.isEmpty) {
      print('No game IDs provided for price fetching');
      return {};
    }

    final String idsString = gameIds.join(',');
    final Uri url =
        Uri.parse('https://www.cheapshark.com/api/1.0/games?ids=$idsString');
    // log the url being fetched
    print('Fetching prices from URL: $url');

    try {
      final response = await http.get(url);
      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> gamePriceData = json.decode(response.body);

        // Map to store prices for each game
        Map<String, double> prices = {};

        // Loop through the games data to extract the prices
        gamePriceData.forEach((gameId, priceInfo) {
          if (priceInfo['cheapestPriceEver'] != null) {
            prices[gameId] = double.tryParse(
                    priceInfo['cheapestPriceEver']['price'].toString()) ??
                0.0;
          }
        });

        print('Prices Fetched: $prices');
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
  Future<List<int>> getCheapSharkIds(List<Game> idgbGames) async {
    List<int> cheapSharkIds = [];
    for (final game in idgbGames) {
      final gameId = await fetchGameIDFromCheapShark(game.name);
      if (gameId != null) {
        cheapSharkIds.add(gameId);
      } else {
        print('No CheapShark ID found for $gameId');
      }
    }
    print('CheapShark IDs fetched: $cheapSharkIds');
    return cheapSharkIds;
  }

  // // clean up special characters
  // String cleanTitle(String title) {
  //   return title.replaceAll(RegExp(r'[^\w\s]'), '').toLowerCase();
  // }

  // // Remove edition tags from the game title
  // String removeEditionTags(String title) {
  //   return title
  //       .replaceAll(
  //           RegExp(
  //               r'\b(Edition|Remastered|Ultimate|Complete|GOTY|Game of the Year)\b',
  //               caseSensitive: false),
  //           '')
  //       .trim();
  // }
}
