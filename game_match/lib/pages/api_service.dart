import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'game_model.dart';

class ApiService {
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  final String clientId = 'v5v1uyyo05m4ttc8yvd26yrwslfimc';
  final String clientSecret = 'hu3w4pwpc344uwdp2k77xfjozbaxc5';
  final String baseUrl = 'https://api.igdb.com/v4';

  Future<void> storeAccessToken(String token) async {
    print('Storing access token: $token');
    await secureStorage.write(key: 'access_token', value: token);
  }

  Future<String?> retrieveAccessToken() async {
    final token = await secureStorage.read(key: 'access_token');
    print('Retrieved access token: $token');
    return token;
  }

  Future<void> authenticate() async {
    final Uri url = Uri.parse(
        'https://id.twitch.tv/oauth2/token?client_id=$clientId&client_secret=$clientSecret&grant_type=client_credentials');

    try {
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

  Future<List<Game>> fetchGames() async {
    final String? accessToken = await retrieveAccessToken();

    if (accessToken == null) {
      print('Access token is null. Please fetch a new one.');
      await authenticate(); // Authenticate if the token is not available
      return [];
    }

    final Uri url = Uri.parse('https://api.igdb.com/v4/games');
    const String body = '''
    fields name, summary, genres.name, cover.url, platforms.name, release_dates.human, websites.url;
    limit 10;
    ''';

    try {
      final response = await http.post(
        url,
        headers: {
          'Client-ID': clientId, // Client ID as per instructions
          'Authorization':
              'Bearer $accessToken', // Include 'Bearer' as per instructions
          'Content-Type':
              'application/json', // Ensure the body is treated as JSON
        },
        body: body,
      );

      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        print('Response Body: ${response.body}');
        final List<dynamic> gameDataJson = json.decode(response.body);
        final List<Game> games = gameDataJson
            .map((dynamic json) => Game.fromJson(json as Map<String, dynamic>))
            .toList();
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
