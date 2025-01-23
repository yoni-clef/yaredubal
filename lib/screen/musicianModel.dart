
class Musician {
  final String name;
  final String biography;
  final String achievements;
  final String imagePath;

  Musician({
    required this.name,
    required this.biography,
    required this.achievements,
    required this.imagePath,
  });

  factory Musician.fromJson(Map<String, dynamic> json) {
    return Musician(
      name: json['name'],
      biography: json['biography'],
      achievements: json['achievements'],
      imagePath: json['imagePath'],
    );
  }
}
