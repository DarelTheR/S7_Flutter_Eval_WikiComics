import 'dart:convert';

class Movie {
  final String id;
  final String title;
  final String releaseYear;
  final String runtime;
  final String imageUrl;
  final String? apiDetailUrl;

  const Movie({
    required this.id,
    required this.title,
    required this.releaseYear,
    required this.runtime,
    required this.imageUrl,
    this.apiDetailUrl,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    final String? releaseDate = json['release_date'];
    final String computedYear = (releaseDate != null && releaseDate is String)
        ? (DateTime.tryParse(releaseDate)?.year.toString() ?? 'Année inconnue')
        : 'Année inconnue';
    final String? detailUrl = json['api_detail_url'];
    return Movie(
      id: json['id']?.toString() ?? '',
      title: json['name'] ?? 'Titre inconnu',
      releaseYear: computedYear,
      runtime: json['runtime']?.toString() ?? 'Durée inconnue',
      imageUrl: (json['image'] != null && json['image']['medium_url'] != null)
          ? json['image']['medium_url'] as String
          : 'https://via.placeholder.com/150',
      apiDetailUrl: detailUrl,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': title,
      'release_date': releaseYear,
      'runtime': runtime,
      'image': {'medium_url': imageUrl},
      'api_detail_url': apiDetailUrl,
    };
  }

  @override
  String toString() {
    return jsonEncode(toJson());
  }
}
