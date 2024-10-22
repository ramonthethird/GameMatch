class Game {
  final String id; // Add the id parameter
  final String name;
  final String? summary;
  final List<String> genres;
  final String? coverUrl;
  final List<String> websites;
  final List<String> platforms;
  final List<String> releaseDates;
  double? price;

  Game({
    required this.id, // Mark id as required
    required this.name,
    this.summary,
    required this.genres,
    this.coverUrl,
    required this.websites,
    required this.platforms,
    required this.releaseDates,
    this.price,
  });

  factory Game.fromJson(Map<String, dynamic> json) {
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
    String? coverUrl;
    if (json['cover'] != null) {
      final imageId = json['cover']['image_id'];
      coverUrl = 'https://images.igdb.com/igdb/image/upload/t_720p/$imageId.jpg';
    } else {
      coverUrl = null;
    }

    return Game(
      id: json['id']?.toString() ?? 'Unknown', // Fetch the id and convert it to a string
      name: json['name'] as String? ?? 'No title',
      summary: json['summary'] as String? ?? 'No description available',
      genres: genres,
      coverUrl: coverUrl,
      platforms: platforms,
      releaseDates: releaseDates,
      websites: websites,
      price: null,
    );
  }

  // Method to update the price after fetching from CheapShark
  void updatePrice(double? newPrice) {
    price = newPrice;
  }
}