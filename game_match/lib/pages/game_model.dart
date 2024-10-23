class Game {
  final String id;
  final String name;
  final String? summary;
  final List<String> genres;
  final String? coverUrl;
  final String? websiteUrl;
  final List<String> platforms;
  final List<String> releaseDates;
  double? price;
  bool isFree = false;
  List<String>? screenshotUrls;
  List<String>? developers;

  Game({
    required this.id,
    required this.name,
    required this.summary,
    required this.genres,
    this.coverUrl,
    required this.websiteUrl,
    required this.platforms,
    required this.releaseDates,
    this.price,
    this.screenshotUrls,
    this.developers,
  });

  // Factory method to create Game instance from JSON (e.g., from API)
  factory Game.fromJson(Map<String, dynamic> json) {
    // Parse screenshots if available
    List<String> screenshotUrls = [];
    if (json['screenshots'] != null &&
        (json['screenshots'] as List).isNotEmpty) {
      screenshotUrls = (json['screenshots'] as List<dynamic>)
          .map((s) =>
              'https://images.igdb.com/igdb/image/upload/t_720p/${s['image_id']}.jpg')
          .toList();
    }

    // Parse cover URL
    String? coverUrl;
    if (json['cover'] != null && json['cover']['image_id'] != null) {
      coverUrl =
          'https://images.igdb.com/igdb/image/upload/t_720p/${json['cover']['image_id']}.jpg';
    }

    // Log the screenshot URLs for each game
    print('Screenshot URL for ${json['name']}: $screenshotUrls');

    // Safely map genres, providing an empty list if null
    List<String> genres = (json['genres'] as List<dynamic>?)
            ?.map((genre) => genre['name'] as String)
            .toList() ??
        [];

    // Safely map platforms
    List<String> platforms = (json['platforms'] as List<dynamic>?)
            ?.map((platform) => platform['name'] as String)
            .toList() ??
        [];

    // Safely map release dates
    List<String> releaseDates = (json['release_dates'] as List<dynamic>?)
            ?.map((date) => date['human'] as String)
            .toList() ??
        [];

    // Safely map website
    String? websiteUrl;
    if (json['websites'] != null && (json['websites'] as List).isNotEmpty) {
      websiteUrl = (json['websites'] as List<dynamic>)[0]['url'] as String?;
    }

    // Parse developers from involved companies
    List<String> developers = [];
    if (json['involved_companies'] != null &&
        (json['involved_companies'] as List).isNotEmpty) {
      developers = (json['involved_companies'] as List<dynamic>)
          .map((company) => company['company']['name'] as String)
          .toList();
    }

    // Adjust the image URL to fetch higher resolution images
    String? highResCoverUrl;
    if (json['cover'] != null) {
      final imageId = json['cover']['url'].split('/').last;
      highResCoverUrl =
          'https://images.igdb.com/igdb/image/upload/t_720p/$imageId';
    } else {
      highResCoverUrl = null;
    }

    return Game(
      id: json['id']?.toString() ?? 'Unknown',
      name: json['name'] as String? ?? 'No title',
      summary: json['summary'] as String? ?? 'No description available',
      genres: genres,
      coverUrl: highResCoverUrl ?? coverUrl,
      platforms: platforms,
      releaseDates: releaseDates,
      websiteUrl: websiteUrl,
      price: null,
      screenshotUrls: screenshotUrls,
      developers: developers,
    );
  }

  // Convert Game object to a map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'summary': summary,
      'genres': genres,
      'coverUrl': coverUrl,
      'websiteUrl': websiteUrl,
      'platforms': platforms,
      'releaseDates': releaseDates,
      'price': price,
      'isFree': isFree,
      'screenshotUrls': screenshotUrls,
      'developers': developers,
    };
  }

  // Create Game object from Firestore map
  factory Game.fromMap(Map<String, dynamic> map) {
    return Game(
      id: map['id'] ?? 'Unknown',
      name: map['name'] ?? 'No title',
      summary: map['summary'] ?? 'No description available',
      genres: List<String>.from(map['genres'] ?? []),
      coverUrl: map['coverUrl'],
      websiteUrl: map['websiteUrl'],
      platforms: List<String>.from(map['platforms'] ?? []),
      releaseDates: List<String>.from(map['releaseDates'] ?? []),
      price: map['price']?.toDouble(),
      screenshotUrls: List<String>.from(map['screenshotUrls'] ?? []),
      developers: List<String>.from(map['developers'] ?? []),
    );
  }

  // Method to update the price after fetching from CheapShark
  void updatePrice(double? newPrice) {
    price = newPrice;
    if (newPrice == 0.0) {
      isFree = true;
    }
  }
}
