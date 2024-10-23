class WishlistGame {
  final String id; // Unique identifier for the game
  final String name;
  final String coverUrl; // Optional: If you want to store the cover image
  final String url; // Link to the game

  WishlistGame({
    required this.id,
    required this.name,
    required this.coverUrl,
    required this.url,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'coverUrl': coverUrl,
      'url': url,
    };
  }

  WishlistGame.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        coverUrl = json['coverUrl'],
        url = json['url'];
}
