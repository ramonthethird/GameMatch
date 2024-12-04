class VideoGame {
  final int id;
  final String title;
  final String shortDesc;
  final String imageUrl;
  final double? lowestPrice;
  final DateTime releaseDate;
  final List<String> platforms;

  VideoGame({
    required this.id,
    required this.title,
    required this.shortDesc,
    required this.imageUrl,
    this.lowestPrice,
    required this.releaseDate,
    required this.platforms,
  });

  // Factory method to create a VideoGame instance from JSON
  factory VideoGame.fromJson(Map<String, dynamic> json) {
    final gameInfo = json['game_info'];
    return VideoGame(
      id: gameInfo['id'] as int,
      title: gameInfo['name'] as String,
      shortDesc: gameInfo['short_desc'] as String? ?? '',
      imageUrl: json['image'] as String,
      lowestPrice: (gameInfo['lowest_price'] as num?)?.toDouble(),
      releaseDate: DateTime.fromMillisecondsSinceEpoch((gameInfo['release_date'] as int) * 1000),
      platforms: (gameInfo['platforms'] as List)
          .map((platform) => platform['name'] as String)
          .toList(),
    );
  }
}