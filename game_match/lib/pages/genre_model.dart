class Genre {
  final int id;
  final String name;

  Genre({required this.id, required this.name});

  factory Genre.fromJson(Map<String, dynamic> json) {
    return Genre(
      id: json['id'],
      name: json['name'],
    );
  }

// convert object to json
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}
