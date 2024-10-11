class Game {
  final String name;
  final String? summary;
  final List<String> genres;
  final String? coverUrl;
  final List<String> websites;
  final List<String> platforms;
  final List<String> releaseDates;

  Game({
    required this.name,
    this.summary,
    required this.genres,
    this.coverUrl,
    required this.websites,
    required this.platforms,
    required this.releaseDates,
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

    return Game(
      name: json['name'] as String? ?? 'No title',
      summary: json['summary'] as String? ?? 'No description available',
      genres: genres, // No longer nullable
      coverUrl: json['cover'] != null
          ? 'https:${json['cover']['url']}' // Append https: to the cover URL
          : null,
      platforms: platforms, // No longer nullable
      releaseDates: releaseDates, // No longer nullable
      websites: websites, // No longer nullable
    );
  }
}
