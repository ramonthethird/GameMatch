import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'game_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';

class ApiService {
  final FlutterSecureStorage secureStorage = FlutterSecureStorage();
  final String clientId = dotenv.env['CLIENT_ID']!;
  final String clientSecret = dotenv.env['CLIENT_SECRET']!;
  final String baseUrl = 'https://api.igdb.com/v4';

  Future<void> storeAccessToken(String token) async {
    await secureStorage.write(key: 'access_token', value: token);
  }

  Future<String?> retrieveAccessToken() async {
    return await secureStorage.read(key: 'access_token');
  }

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
        throw Exception('Failed to authenticate with Twitch API');
      }
    } catch (error) {
      print('Error fetching token: $error');
      throw Exception('Error fetching token: $error');
    }
  }

  Future<List<Game>> fetchGames() async {
    final String? accessToken = await retrieveAccessToken();

    // If no token available, authenticate and fetch a new one
    if (accessToken == null) {
      print('Access token is null. Fetching a new one...');
      await authenticate();
      return fetchGames(); // Retry fetching games after authentication
    }

    final Uri url = Uri.parse('$baseUrl/games');
    const String body = '''
    fields name, summary, genres.name, cover.url, platforms.name, release_dates.human, websites.url, tags, screenshots.image_id, involved_companies.company.name;
    where platforms = (6);
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
          if (game.coverUrl == null || game.coverUrl!.isEmpty) {
            return false;
          }
          if (game.screenshotUrls == null || game.screenshotUrls!.isEmpty) {
            print('${game.name} has no screenshots, skipping');
            return false;
          }
          if (game.summary == null || game.summary!.isEmpty) {
            print('${game.name} has no description, skipping');
            return false;
          }
          if (game.releaseDates == null || game.releaseDates.isEmpty) {
            print('${game.name} has no release date, skipping');
            return false;
          }
          String releaseDateStr = game.releaseDates.first;
          DateTime? releaseDate = _parseReleaseDate(releaseDateStr);
          return releaseDate != null && releaseDate.year >= 2020;
        }).toList();

        return games;
      } else if (response.statusCode == 401) {
        // If the access token has expired or is invalid, re-authenticate
        print('Access token expired. Re-authenticating...');
        await authenticate();
        return fetchGames(); // Retry fetching games after re-authentication
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

  DateTime? _parseReleaseDate(String dateStr) {
    try {
      if (dateStr == "TBD") {
        print('Release date is TBD, skipping');
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
  Map<String, int?> gameIdCache = {};

  // Get CheapShark IDs for IGDB games and batch fetch prices
  Future<void> fetchPricesForIGDBGames(List<Game> igdbGames) async {
    // Fetch CheapShark game IDs for each IGDB game
    List<int> cheapSharkIds = await getCachedCheapSharkIds(igdbGames);

    // Fetch prices for all games in a single batch request
    if (cheapSharkIds.isEmpty) {
      print('No valid CheapShark IDs found. No games to update with prices.');
      return;
    }

    Map<String, double> prices =
        await fetchPricesForMultipleGames(cheapSharkIds);

    // Remove games that do not have a valid CheapShark ID or a valid price
    igdbGames.removeWhere((game) {
      final gameId = gameIdCache[game.name];

      // Skip games without a valid CheapShark ID
      if (gameId == null || !prices.containsKey(gameId.toString())) {
        print('Skipping game without a valid CheapShark ID: ${game.name}');
        return true; // Remove this game
      }

      // If a valid ID is found, update the game's price
      double price = prices[gameId.toString()] ?? 0.0;
      if (price == 0.0) {
        print('${game.name} is free or has no price, skipping.');
        return true; // Remove this game if price is 0
      }

      // Update game price if valid
      game.updatePrice(price);
      return false; // Keep the game if it has a valid price
    });

    print('Finished processing games with valid CheapShark IDs.');
  }

  // Fetch Cached CheapShark IDs or Fetch Them from API if Not Cached
  Future<List<int>> getCachedCheapSharkIds(List<Game> igdbGames) async {
    List<int> cheapSharkIds = [];

    for (var game in igdbGames) {
      // Check if the game ID is already cached to avoid redundant API calls
      if (gameIdCache.containsKey(game.name)) {
        final cachedId = gameIdCache[game.name];
        if (cachedId != null) {
          cheapSharkIds.add(cachedId);
          print('Using cached ID for ${game.name}: $cachedId');
        } else {
          print('Cached ID for ${game.name} is null. Skipping...');
        }
      } else {
        // If not cached, fetch from the API and store in cache
        final gameId = await fetchGameIDFromCheapShark(game.name);
        if (gameId != null) {
          gameIdCache[game.name] = gameId; // Cache the result
          cheapSharkIds.add(gameId);
          print('Fetched and cached ID for ${game.name}: $gameId');
        } else {
          // skip games that have no valid ID
          print('No CheapShark ID found for ${game.name}');
        }

        // Introduce a small delay to avoid hitting rate limits
        await Future.delayed(Duration(milliseconds: 500));
      }
    }

    print('CheapShark IDs fetched: $cheapSharkIds');
    return cheapSharkIds;
  }

  // Fetch CheapShark game ID by title
  Future<int?> fetchGameIDFromCheapShark(String gameTitle) async {
    final Uri url = Uri.parse(
        'https://www.cheapshark.com/api/1.0/games?title=$gameTitle&limit=1&exact=1');

    // log the game title and URL
    print('Fetching CheapShark game ID for $gameTitle from URL: $url');

    try {
      final response = await http.get(url).timeout(Duration(seconds: 10));

      // Handle rate limit error
      if (response.statusCode == 429) {
        print('Rate limit hit, waiting for 60 seconds...');
        // wait before retrying
        await Future.delayed(Duration(seconds: 60));
        // retry after delay
        return fetchGameIDFromCheapShark(gameTitle);
      }

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
    // delay to avoid rate-limiting
    await Future.delayed(Duration(milliseconds: 500));
    print('CheapShark IDs fetched: $cheapSharkIds');
    return cheapSharkIds;
  }
}
