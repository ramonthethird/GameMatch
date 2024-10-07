class Game {
  final String name;
  final String summary;
  final List<String> genres;
  final String? coverUrl;

  Game({
    required this.name,
    required this.summary,
    required this.genres,
    this.coverUrl,
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
    );
  }
}
