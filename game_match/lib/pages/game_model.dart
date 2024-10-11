class Game {
  final String name;
  final String? summary;
  final List<String>? genres;
  final String? coverUrl;
  final List<String>? websites;
  final List<String>? platforms;
  final List<String>? releaseDates;

  Game({
    required this.name,
    this.summary,
    this.genres,
    this.coverUrl,
    this.websites,
    this.platforms,
    this.releaseDates,
  });

  factory Game.fromJson(Map<String, dynamic> json) {
    List<String> genres = (json['genres'] as List)
        .map((genre) => genre['name'] as String)
        .toList();

    return Game(
      name: json['name'] ?? 'No title',
      summary: json['summary'] ?? 'No description available',
      genres: genres,
      coverUrl: json['cover'] != null
          ? 'https:${json['cover']['url']}' // Append https: to the cover URL
          : null,
      websites: (json['websites'] as List<dynamic>?)
          ?.map((website) => website['url'] as String)
          .toList(),
      platforms: (json['platforms'] as List<dynamic>?)
          ?.map((platform) => platform['name'] as String)
          .toList(),
      releaseDates: (json['release_dates'] as List<dynamic>?)
          ?.map((date) => date['human'] as String)
          .toList(),
    );
  }
}
