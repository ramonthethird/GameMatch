import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'pages/game_model.dart';

class ApiService {
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  final String clientId = 'v5v1uyyo05m4ttc8yvd26yrwslfimc';
  final String clientSecret = 'hu3w4pwpc344uwdp2k77xfjozbaxc5';
  final String baseUrl = 'https://api.igdb.com/v4';

  Future<void> storeAccessToken(String token) async {
    await secureStorage.write(key: 'access_token', value: token);
  }

  Future<String?> retrieveAccessToken() async {
    return await secureStorage.read(key: 'access_token');
  }

  Future<void> authenticate() async {
    final Uri url = Uri.parse('https://id.twitch.tv/oauth2/token');
    final String body =
        'client_id=$clientId&client_secret=$clientSecret&grant_type=client_credentials';

    try {
      final response = await http.post(url, body: body);

      if (response.statusCode == 200) {
        final Map<String, dynamic> tokenData = json.decode(response.body);
        await storeAccessToken(tokenData['access_token']);
      } else {
        print('Failed to fetch token: ${response.statusCode} ${response.body}');
      }
    } catch (error) {
      print('Error fetching token: $error');
    }
  }

  Future<void> updatePreferences(String userId) async {
  try {
    final response = await http.get(
      Uri.parse('http://127.0.0.1:5000/recommend/$userId'), // Corrected URL
    );

    if (response.statusCode == 200) {
      print("Recommendations updated successfully!");
    } else {
      print("Failed to update recommendations: ${response.body}");
    }
  } catch (e) {
    print("Error while updating recommendations: $e");
  }
}

  Future<List<Game>> fetchGames() async {
    final String? accessToken = await retrieveAccessToken();

    if (accessToken == null) {
      print('Access token is null. Please fetch a new one.');
      await authenticate(); // Authenticate if the token is not available
      return [];
    }

    final Uri url = Uri.parse('$baseUrl/games');
    const String body = '''
    fields name, summary, genres.name. cover.url;
    limit 10;
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
            .toList();
        return games;
      } else {
        print(
            'Failed to fetch game data: ${response.statusCode} ${response.body}');
        return [];
      }
    } catch (error) {
      print('Error: $error');
      return [];
    }
  }
}
