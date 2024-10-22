class Game {
  final String name;
  final String? summary;
  final List<String> genres;
  final String? coverUrl;
  final List<String> websites;
  final List<String> platforms;
  final List<String> releaseDates;
  double? price;
  bool isFree = false;
  List<String>? screenshotUrls;

  Game({
    required this.name,
    required this.summary,
    required this.genres,
    this.coverUrl,
    required this.websites,
    required this.platforms,
    required this.releaseDates,
    this.price,
    this.screenshotUrls,
  });

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

    // log the screenshot URLs for each game
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

    // Safely map websites
    List<String> websites = (json['websites'] as List<dynamic>?)
            ?.map((website) => website['url'] as String)
            .toList() ??
        [];

    // Adjust the image URL to fetch higher resolution images
    String? highRescoverUrl;
    if (json['cover'] != null) {
      final imageId = json['cover']['url'].split('/').last;
      highRescoverUrl =
          'https://images.igdb.com/igdb/image/upload/t_720p/$imageId';
    } else {
      highRescoverUrl = null;
    }

    return Game(
      name: json['name'] as String? ?? 'No title',
      summary: json['summary'] as String? ?? 'No description available',
      genres: genres,
      coverUrl: highRescoverUrl ?? coverUrl,
      platforms: platforms,
      releaseDates: releaseDates,
      websites: websites,
      price: null,
      screenshotUrls: screenshotUrls,
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
