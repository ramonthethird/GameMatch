class Game {
  final String name;
  final String? summary;
  final List<String> genres;
  final String? coverUrl;

  Game({
    required this.name,
    this.summary,
    required this.genres,
    this.coverUrl,
  });

  factory Game.fromJson(Map<String, dynamic> json) {
    return Game(
      name: json['name'] ?? 'Unknown Game',
      summary: json['summary'] as String?,
      genres: (json['genres'] as List<dynamic>?)
              ?.map((genre) => genre['name'] as String)
              .toList() ??
          [],
      coverUrl: json['cover'] != null ? 'https:${json['cover']['url']}' : null,
    );
  }
}
