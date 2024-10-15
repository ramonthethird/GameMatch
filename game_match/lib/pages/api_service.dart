import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'game_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

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
    fields name, summary, genres.name, cover.url, platforms.name, release_dates.human, websites.url;
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
          return game.name.isNotEmpty &&
              game.coverUrl != null &&
              game.summary != null &&
              game.genres != null;
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
}
