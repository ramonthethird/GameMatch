class Game {
  final String name;
  final String? summary;
  final Cover? cover;

  Game({required this.name, this.summary, this.cover});

  factory Game.fromJson(Map<String, dynamic> json) {
    return Game(
      name: json['name'],
      summary: json['summary'],
      cover: json['cover'] != null ? Cover.fromJson(json['cover']) : null,
    );
  }
}

class Cover {
  final String url;

  Cover({required this.url});

  factory Cover.fromJson(Map<String, dynamic> json) {
    return Cover(url: json['url']);
  }
}
