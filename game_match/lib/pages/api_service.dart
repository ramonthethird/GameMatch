import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'game_model.dart';
import 'genre_model.dart';

class ApiService {
  // Secure storage for sensitive info
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  final String clientId = dotenv.env['CLIENT_ID'] ?? 'v5v1uyyo05m4ttc8yvd26yrwslfimc';
  final String clientSecret = dotenv.env['CLIENT_SECRET'] ?? 'hu3w4pwpc344uwdp2k77xfjozbaxc5';
  final String baseUrl = 'https://api.igdb.com/v4';
  final String cheapSharkBaseUrl = 'https://www.cheapshark.com/api/1.0';

  Map<String, int?> gameIdCache = {}; // Cache for CheapShark IDs

  // Store access token
  Future<void> storeAccessToken(String token) async {
    await secureStorage.write(key: 'access_token', value: token);
  }

  // Retrieve access token from secure storage
  Future<String?> retrieveAccessToken() async {
    return await secureStorage.read(key: 'access_token');
  }

  // Authenticate and get access token from Twitch API
  Future<void> authenticate() async {
    final Uri url = Uri.parse('https://id.twitch.tv/oauth2/token');
    final Map<String, String> body = {
      'client_id': clientId,
      'client_secret': clientSecret,
      'grant_type': 'client_credentials',
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: body,
      );

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

  // Ensure valid access token, authenticating if needed
  Future<String> getAccessToken() async {
    String? accessToken = await retrieveAccessToken();
    if (accessToken == null) {
      await authenticate();
      accessToken = await retrieveAccessToken();
      if (accessToken == null) throw Exception('Failed to authenticate');
    }
    return accessToken;
  }

  // Fetch list of games from IGDB API with additional filtering
  Future<List<Game>> fetchGames() async {
    final String accessToken = await getAccessToken();
    final Uri url = Uri.parse('$baseUrl/games');
    const String body = '''
    fields name, summary, genres.name, cover.url, platforms.name, release_dates.human, websites.url, tags, screenshots.image_id, involved_companies.company.name;
    where platforms = (6);
    limit 100;
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
        return gameDataJson
            .map((json) => Game.fromJson(json as Map<String, dynamic>))
            .where((game) {
          if (game.coverUrl == null || game.coverUrl!.isEmpty) return false;
          if (game.screenshotUrls == null || game.screenshotUrls!.isEmpty) return false;
          if (game.summary == null || game.summary!.isEmpty) return false;
          if (game.releaseDates == null || game.releaseDates.isEmpty) return false;

          DateTime? releaseDate = _parseReleaseDate(game.releaseDates.first);
          return releaseDate != null && releaseDate.year >= 2020;
        }).toList();
      } else if (response.statusCode == 401) {
        await authenticate();
        return fetchGames();
      } else {
        print('Failed to fetch game data: ${response.statusCode} ${response.body}');
        return [];
      }
    } catch (error) {
      print('Error fetching games: $error');
      return [];
    }
  }

  // Fetches new game releases sorted by release date
  Future<List<Game>> fetchNewReleases() async {
    final String accessToken = await getAccessToken();
    final Uri url = Uri.parse('$baseUrl/games');
    const String body = '''
    fields name, summary, genres.name, cover.url, first_release_date, websites.url;
    sort first_release_date desc;
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
        return gameDataJson.map((json) => Game.fromJson(json as Map<String, dynamic>)).toList();
      } else {
        print('Failed to fetch new releases: ${response.statusCode} ${response.body}');
        return [];
      }
    } catch (error) {
      print('Error fetching new releases: $error');
      return [];
    }
  }

  // Searches games by name
  Future<List<Game>> searchGames(String query) async {
    final String accessToken = await getAccessToken();
    final Uri url = Uri.parse('$baseUrl/games');
    final String body = '''
    search "$query";
    fields name, summary, genres.name, cover.url, websites.url;
    where name ~ *"$query"*;
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
        return gameDataJson.map((json) => Game.fromJson(json as Map<String, dynamic>)).toList();
      } else {
        print('Failed to fetch search results: ${response.statusCode} ${response.body}');
        return [];
      }
    } catch (error) {
      print('Error fetching search results: $error');
      return [];
    }
  }

  DateTime? _parseReleaseDate(String dateStr) {
    try {
      if (dateStr == "TBD") return null;
      if (RegExp(r'^\d{4}$').hasMatch(dateStr)) return DateTime(int.parse(dateStr));

      final DateFormat format = DateFormat('MMM dd, yyyy');
      return format.parse(dateStr);
    } catch (e) {
      print('Error parsing release date: $e');
      return null;
    }
  }

  // Fetch platform details
  Future<List<dynamic>> fetchPlatforms() async {
    final String accessToken = await getAccessToken();
    final Uri url = Uri.parse('$baseUrl/platforms');
    const String body = '''
    fields name, id, category;
    where category = 6;
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
        return json.decode(response.body);
      } else {
        print('Failed to fetch platforms: ${response.statusCode} ${response.body}');
        return [];
      }
    } catch (error) {
      print('Error fetching platforms: $error');
      return [];
    }
  }

  // Fetch prices from CheapShark API for IGDB games
  Future<void> fetchPricesForIGDBGames(List<Game> igdbGames) async {
    List<int> cheapSharkIds = await getCachedCheapSharkIds(igdbGames);
    if (cheapSharkIds.isEmpty) return;

    Map<String, double> prices = await fetchPricesForMultipleGames(cheapSharkIds);
    igdbGames.removeWhere((game) {
      final gameId = gameIdCache[game.name];
      if (gameId == null || !prices.containsKey(gameId.toString())) return true;

      double price = prices[gameId.toString()] ?? 0.0;
      if (price == 0.0) return true;

      game.updatePrice(price);
      return false;
    });
  }

  // Fetch Cached CheapShark IDs or Fetch Them from API if Not Cached
  Future<List<int>> getCachedCheapSharkIds(List<Game> igdbGames) async {
    List<int> cheapSharkIds = [];
    for (var game in igdbGames) {
      if (gameIdCache.containsKey(game.name)) {
        final cachedId = gameIdCache[game.name];
        if (cachedId != null) cheapSharkIds.add(cachedId);
      } else {
        final gameId = await fetchGameIDFromCheapShark(game.name);
        if (gameId != null) {
          gameIdCache[game.name] = gameId;
          cheapSharkIds.add(gameId);
        }
      }
    }
    return cheapSharkIds;
  }

  // Fetch CheapShark game ID by title
  Future<int?> fetchGameIDFromCheapShark(String gameTitle) async {
    final Uri url = Uri.parse('$cheapSharkBaseUrl/games?title=$gameTitle&limit=1&exact=1');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> gameData = json.decode(response.body);
        if (gameData.isNotEmpty) {
          return int.tryParse(gameData[0]['gameID'].toString());
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
    final String idsString = gameIds.join(',');
    final Uri url = Uri.parse('$cheapSharkBaseUrl/games?ids=$idsString');

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
        return {};
      }
    } catch (error) {
      print('Error fetching prices: $error');
      return {};
    }
  }

  Future<List<Genre>> fetchGenres({String? query}) async {
    final String? accessToken = await retrieveAccessToken();

    if (accessToken == null) {
      print('Access token is null. Please fetch a new one.');
      await authenticate(); // Authenticate if the token is not available
      return [];
    }

    final Uri url = Uri.parse('https://api.igdb.com/v4/genres');
    final String body = '''
    fields id, name;
    limit 50;
    '''; // Genre({required this.id, required this.name});

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
        final List<dynamic> genreDataJson = json.decode(response.body);
        final List<Genre> genres = genreDataJson
            .map((dynamic json) => Genre.fromJson(json as Map<String, dynamic>))
            .toList();
        return genres;
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

  Future<bool> checkGenreExists(String genreName) async {
    List<Genre> genres = await fetchGenres();
    return genres
        .any((genre) => genre.name.toLowerCase() == genreName.toLowerCase());
  }

  Future<String> fetchGamePrice(String gameName) async {
    final Uri url = Uri.parse(
        'https://www.cheapshark.com/api/1.0/games?title=$gameName&limit=1');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data.isNotEmpty) {
          // Extract the cheapest price if available
          return data[0]['cheapest'] != null
              ? '\$${data[0]['cheapest']}'
              : 'Not available';
        } else {
          return 'No price found';
        }
      } else {
        print('Error fetching price data: ${response.statusCode}');
        return 'Error fetching price';
      }
    } catch (e) {
      print('Exception: $e');
      return 'Error fetching price';
    }
  }

  Future<String?> fetchGameCover(String gameName) async {
    final String? accessToken = await retrieveAccessToken();

    if (accessToken == null) {
      print('Access token is null. Authenticating...');
      await authenticate();
      return null;
    }

    final Uri gameUrl = Uri.parse('$baseUrl/games');
    final String gameQuery = '''
  fields id;
  where name = "$gameName";
  limit 1;
  ''';

    try {
      final gameResponse = await http.post(
        gameUrl,
        headers: {
          'Client-ID': clientId,
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: gameQuery,
      );

      if (gameResponse.statusCode == 200) {
        final List<dynamic> gameDataJson = json.decode(gameResponse.body);
        if (gameDataJson.isEmpty) {
          print('Game not found: $gameName');
          return null;
        }

        final int gameId = gameDataJson[0]['id'];
        final Uri coverUrl = Uri.parse('$baseUrl/covers');
        final String coverQuery = '''
      fields url;
      where game = $gameId;
      limit 1;
      ''';

        final coverResponse = await http.post(
          coverUrl,
          headers: {
            'Client-ID': clientId,
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
          },
          body: coverQuery,
        );

        if (coverResponse.statusCode == 200) {
          final List<dynamic> coverDataJson = json.decode(coverResponse.body);
          if (coverDataJson.isNotEmpty) {
            final String? coverImageUrl = coverDataJson[0]['url'] != null
                ? 'https:${coverDataJson[0]['url']}'
                : null;
            return coverImageUrl;
          } else {
            print('No cover image found for game ID: $gameId');
            return null;
          }
        } else {
          print(
              'Failed to fetch cover image: ${coverResponse.statusCode} ${coverResponse.body}');
          return null;
        }
      } else {
        print(
            'Failed to fetch game ID: ${gameResponse.statusCode} ${gameResponse.body}');
        return null;
      }
    } catch (error) {
      print('Error fetching cover image: $error');
      return null;
    }
  }

  Future<Game?> fetchGameDetailsTwo(String gameName) async {
    final String? accessToken = await retrieveAccessToken();

    if (accessToken == null) {
      print('Access token is null. Authenticating...');
      await authenticate();
      return null;
    }

    final Uri url = Uri.parse('$baseUrl/games');
    final String query = '''
    fields name, platforms.name, aggregated_rating; 
    where name = "$gameName";
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
        body: query,
      );

      if (response.statusCode == 200) {
        final List<dynamic> gameDataJson = json.decode(response.body);
        if (gameDataJson.isNotEmpty) {
          return Game.fromJson(gameDataJson[0]); // Convert Map to Game object
        } else {
          print('Game not found: $gameName');
          return null;
        }
      } else {
        print(
            'Failed to fetch game details: ${response.statusCode} ${response.body}');
        return null;
      }
    } catch (error) {
      print('Error fetching game details: $error');
      return null;
    }
  }

  Future<Map<String, dynamic>?> fetchGameDetails(String gameName) async {
    final String? accessToken = await retrieveAccessToken();

    if (accessToken == null) {
      print('Access token is null. Authenticating...');
      await authenticate();
      return null;
    }

    final Uri url = Uri.parse('$baseUrl/games');
    final String query = '''
    fields name, platforms.name, aggregated_rating; 
    where name = "$gameName";
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
        body: query,
      );

      if (response.statusCode == 200) {
        final List<dynamic> gameDataJson = json.decode(response.body);
        if (gameDataJson.isNotEmpty) {
          return gameDataJson[0] as Map<String, dynamic>;
        } else {
          print('Game not found: $gameName');
          return null;
        }
      } else {
        print(
            'Failed to fetch game details: ${response.statusCode} ${response.body}');
        return null;
      }
    } catch (error) {
      print('Error fetching game details: $error');
      return null;
    }
  }

  Future<Map<String, dynamic>?> fetchGameDetailsThree(String gameId) async {
  final String? accessToken = await retrieveAccessToken();

  if (accessToken == null) {
    print('Access token is null. Authenticating...');
    await authenticate();
    return null;
  }

  final Uri url = Uri.parse('$baseUrl/games');
  final String query = '''
  fields name, cover.url; 
  where id = $gameId;
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
      body: query,
    );

    if (response.statusCode == 200) {
      final List<dynamic> gameDataJson = json.decode(response.body);
      if (gameDataJson.isNotEmpty) {
        final gameData = gameDataJson[0];
        return {
          'name': gameData['name'] ?? 'Unknown Game',
          'coverUrl': gameData['cover'] != null
              ? 'https:${gameData['cover']['url']}'
              : null,
        };
      } else {
        print('Game not found: $gameId');
        return {
          'name': 'Unknown Game',
          'coverUrl': null,
        };
      }
    } else {
      print('Failed to fetch game details: ${response.statusCode}');
      return null;
    }
  } catch (e) {
    print('Error fetching game details: $e');
    return null;
  }
}


  Future<int?> fetchThemeId(String themeName) async {
    final String? accessToken = await retrieveAccessToken();
    if (accessToken == null) return null;

    final Uri url = Uri.parse('$baseUrl/themes');
    final response = await http.post(
      url,
      headers: {
        'Client-ID': clientId,
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: 'fields id; where name = "$themeName";',
    );

    print(
        "Fetching theme ID for '$themeName' - Status Code: ${response.statusCode}");
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print("Theme Data: $data"); // Debugging output
      if (data.isNotEmpty) return data[0]['id'];
    }
    print("Theme '$themeName' not found or API error.");
    return null;
  }

  Future<List<Game>> fetchPopularGames() async {
    final accessToken = await retrieveAccessToken();
    final Uri url = Uri.parse('$baseUrl/games');
    final String body = '''
      fields name, summary, genres.name, cover.url, platforms.name, release_dates.human, websites.url;
      sort popularity desc;
      limit 10;
    ''';

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
      final List<dynamic> gameData = json.decode(response.body);
      return gameData.map((json) => Game.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch games');
    }
  }

  Future<List<Game>?> fetchTopVisitedGames() async {
    final String? accessToken = await retrieveAccessToken();

    if (accessToken == null) {
      print('Access token is null. Authenticating...');
      await authenticate();
      return [];
    }
    final Uri url = Uri.parse('$baseUrl/popularity_primitives');

    const String body = '''
    fields game_id, value, popularity_type;
    where popularity_type = 1;
    sort value desc;
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
        final List<dynamic> popularityData = json.decode(response.body);

        // Extract game IDs
        final List<int> gameIds = popularityData
            .map((entry) => entry['game_id'] as int)
            .toList();

        // Fetch game details
        return await fetchGameShortDetails(gameIds);
      } else if (response.statusCode == 401) {
        await authenticate();
        return fetchTopVisitedGames();
      } else {
        print('Failed to fetch popularity data: ${response.statusCode}');
        return [];
      }
    } catch (error) {
      print('Error fetching top visited games: $error');
      return [];
    }
  }

  Future<List<Game>> fetchGameShortDetails(List<int> gameIds) async {
    final String accessToken = await getAccessToken();
    final Uri url = Uri.parse('$baseUrl/games');

    final String body = '''
    fields id, name, summary, genres.name, cover.url, platforms.name, release_dates.human, websites.url, screenshots.image_id, involved_companies.company.name;
    where id = (${gameIds.join(",")});
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
        final List<dynamic> gameData = json.decode(response.body);
        return gameData
            .map((json) => Game.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        print('Failed to fetch game details: ${response.statusCode}');
        return [];
      }
    } catch (error) {
      print('Error fetching game details: $error');
      return [];
    }
  }

  Future<Map<String, dynamic>?> fetchGameInfo(int gameId) async {
    final String? accessToken = await retrieveAccessToken();
    if (accessToken == null) {
      await authenticate();
      return null;
    }

    final Uri url = Uri.parse('$baseUrl/games');
    final String body = '''
      fields name, genres.name, themes.name, game_modes.name, platforms.name, screenshots.url;
      where id = $gameId;
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
        final List<dynamic> gameDataJson = json.decode(response.body);
        if (gameDataJson.isNotEmpty) {
          return gameDataJson[0];
        }
      } else {
        print('Failed to fetch game details: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching game details: $error');
    }
    return null;
  }
  Future<String?> fetchSteamWebsite() async {
    final String accessToken = await getAccessToken();
    final Uri url = Uri.parse('$baseUrl/platform_websites');

    final String body = '''
  fields platform.name, url;
  where platform.name = "Steam";
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
        final List<dynamic> platformData = json.decode(response.body);
        if (platformData.isNotEmpty) {
          return platformData.first['url'] as String?;
        } else {
          print('No Steam platform website found.');
          return null;
        }
      } else {
        print('Failed to fetch Steam website: ${response.statusCode}');
        return null;
      }
    } catch (error) {
      print('Error fetching Steam website: $error');
      return null;
    }
  }

  Future<String?> fetchSteamPlatformWebsite() async {
    final String accessToken = await getAccessToken();
    final Uri url = Uri.parse('$baseUrl/platform_websites');

    final String body = '''
    fields platform.name, category, url;
    where platform.name = "steam" & category = 13;
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
        final List<dynamic> websiteData = json.decode(response.body);
        if (websiteData.isNotEmpty) {
          return websiteData.first['url'] as String?;
        } else {
          print('No Steam platform website found for category 13.');
          return null;
        }
      } else {
        print('Failed to fetch platform website: ${response.statusCode}');
        return null;
      }
    } catch (error) {
      print('Error fetching platform website: $error');
      return null;
    }
  }


  Future<String?> fetchSteamWebsiteDetails() async {
    final String accessToken = await getAccessToken();
    final Uri url = Uri.parse('$baseUrl/websites');

    final String body = '''
    fields url, category;
    where category = 13;
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
        final List<dynamic> websiteData = json.decode(response.body);
        if (websiteData.isNotEmpty) {
          final String? steamWebsiteUrl = websiteData.first['url'] as String?;
          print('Steam Website URL: $steamWebsiteUrl');
          return steamWebsiteUrl;
        } else {
          print('No Steam website found for category 13.');
          return null;
        }
      } else {
        print('Failed to fetch website details: ${response.statusCode}');
        return null;
      }
    } catch (error) {
      print('Error fetching website details: $error');
      return null;
    }
  }

  Future<String?> fetchGameWebsite(String gameName) async {
    final String accessToken = await getAccessToken();
    final Uri url = Uri.parse('$baseUrl/games');

    final String body = '''
  search "$gameName";
  fields id, websites.url, websites.category;
  where websites.category = 13;
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
        final List<dynamic> gameData = json.decode(response.body);
        if (gameData.isNotEmpty) {
          final websites = gameData.first['websites'] as List<dynamic>?;
          if (websites != null && websites.isNotEmpty) {
            final steamWebsite = websites.firstWhere(
                  (website) => website['category'] == 13,
              orElse: () => null,
            );
            return steamWebsite?['url'] as String?;
          }
        }
      } else {
        print('Failed to fetch game website: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching game website: $error');
    }
    return null;
  }
}